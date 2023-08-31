//
//  ZGRecordCaptureViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by zego on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGRecordCaptureViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NSString* const ZGRecordCaptureRoomID = @"ZGRecordCaptureRoomID";
NSString* const ZGRecordCaptureStreamID = @"ZGRecordCaptureStreamID";

typedef NS_ENUM(NSUInteger, ZGDemoRecordType) {
    ZGDemoRecordTypeAAC,
    ZGDemoRecordTypeFLV,
    ZGDemoRecordTypeMP4,
};

@interface ZGRecordCaptureViewController ()<ZegoEventHandler, ZegoDataRecordEventHandler, UITextFieldDelegate, UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *mediaPlayerView;

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UIButton *publishButton;


@property (weak, nonatomic) IBOutlet UIButton *startRecordButton;

@property (weak, nonatomic) IBOutlet UIButton *stopRecordButton;

@property (weak, nonatomic) IBOutlet UIButton *playLocalMediaButton;

@property (weak, nonatomic) IBOutlet UILabel *roomIDAndStreamIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishQualityLabel;

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;

@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, assign) BOOL isPlayingLocalMedia;

@property (nonatomic, strong) UIBarButtonItem *recordTypeSwitchButton;
@property (nonatomic, strong) NSDictionary<NSNumber *, NSString *> *recordTypeMap;
@property (nonatomic, assign) ZGDemoRecordType selectedRecordType;

@property (nonatomic, strong)  ZegoMediaPlayer *mediaPlayer;

@property (nonatomic) ZegoRoomStateChangedReason roomState;
@property (nonatomic) ZegoPublisherState publisherState;
@end

@implementation ZGRecordCaptureViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RecordCapture" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGRecordCaptureViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.roomID = @"0026";
    self.streamID = @"0026";
    self.recordTypeMap = @{
        @(ZGDemoRecordTypeAAC): @"aac",
        @(ZGDemoRecordTypeFLV): @"flv",
        @(ZGDemoRecordTypeMP4): @"mp4",
    };
    // Record MP4 by default
    self.selectedRecordType = ZGDemoRecordTypeMP4;

    [self setupUI];
    [self createEngine];
}

- (void)dealloc {
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}


- (void)setupUI {
    self.navigationItem.title = @"Record Capture";

    self.recordTypeSwitchButton = [[UIBarButtonItem alloc] initWithTitle:@"RecordType" style:UIBarButtonItemStylePlain target:self action:@selector(selectRecordType:)];
    self.navigationItem.rightBarButtonItem = self.recordTypeSwitchButton;

    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];

    self.roomStateLabel.text = @"🔴 RoomState: Disconnected";
    self.roomStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.roomStateLabel.textColor = [UIColor whiteColor];

    [self.publishButton setTitle:@"Stop Publishing" forState:UIControlStateSelected];
    [self.publishButton setTitle:@"Start Publishing" forState:UIControlStateNormal];
    
    self.publisherStateLabel.text = @"🔴 PublisherState: NoPublish";
    self.publisherStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.publisherStateLabel.textColor = [UIColor whiteColor];

    self.publishResolutionLabel.text = @"";
    self.publishResolutionLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.publishResolutionLabel.textColor = [UIColor whiteColor];

    self.publishQualityLabel.text = @"";
    self.publishQualityLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.publishQualityLabel.textColor = [UIColor whiteColor];

    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: | StreamID: "];
    self.roomIDAndStreamIDLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.roomIDAndStreamIDLabel.textColor = [UIColor whiteColor];
    
    [self.playLocalMediaButton setTitle:@"Stop Play Media" forState:UIControlStateSelected];
    [self.playLocalMediaButton setTitle:@"Play Local Media" forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)createEngine {
    [self appendLog:@"🚀 Create ZegoExpressEngine"];
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)

    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    
    // Here we use the broadcast scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    profile.scenario = ZegoScenarioBroadcast;
    
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
}

#pragma mark - Step 1: Start Publishing
- (IBAction)onPublishButtonClick:(UIButton *)sender {
    if (sender.isSelected) {
        [self stopLive];
    } else {
        [self startLive];
    }
}

#pragma mark - Step 2: Start Recording
- (IBAction)startRecordButtonClick:(id)sender {
    [self startRecord];
    self.isRecording = YES;
}

#pragma mark - Step 3: Stop Recording
- (IBAction)stopRecordButtonClick:(id)sender {
    [self stopRecord];
    self.isRecording = NO;
}

#pragma mark - Step 4: Play Local Media File
- (IBAction)onPlayLocalMediaButtonClick:(UIButton *)sender {
    if (self.isPlayingLocalMedia) {
        [self.mediaPlayer stop];
        self.isPlayingLocalMedia = NO;
        sender.selected = NO;
    } else {
        if (!self.mediaPlayer) {
            self.mediaPlayer =  [[ZegoExpressEngine sharedEngine] createMediaPlayer];
            [self.mediaPlayer setPlayerCanvas:[ZegoCanvas canvasWithView:self.mediaPlayerView]];
        }
        [self.mediaPlayer loadResource:[self recordCaptureFilePath:self.selectedRecordType] callback:^(int errorCode) {
            if (errorCode == 0) {
                [self.mediaPlayer start];
                self.isPlayingLocalMedia = YES;
                sender.selected = YES;
            }
        }];
        
    }
    
}

- (void)startRecord {
    // Set DataRecordEventHandler
    [[ZegoExpressEngine sharedEngine] setDataRecordEventHandler: self];
    
    // Build record config
    ZegoDataRecordConfig *config = [[ZegoDataRecordConfig alloc] init];
    config.filePath = [self recordCaptureFilePath:self.selectedRecordType];
    config.recordType = ZegoDataRecordTypeAudioAndVideo;
    
    // Start record
    [self appendLog:[NSString stringWithFormat:@"🎥 Start record capture, type: %@", self.recordTypeMap[@(self.selectedRecordType)]]];
    [[ZegoExpressEngine sharedEngine] startRecordingCapturedData:config channel:ZegoPublishChannelMain];
}

- (void)stopRecord {
    [self appendLog:@"🎥 Stop record capture"];
    [[ZegoExpressEngine sharedEngine] stopRecordingCapturedData:ZegoPublishChannelMain];
}

- (NSString *)recordCaptureFilePath:(ZGDemoRecordType)recordType {
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [docPath objectAtIndex:0];

    NSString *fileName = [NSString stringWithFormat:@"ZGRecordCapture.%@", self.recordTypeMap[@(recordType)]];

    return [documentsPath stringByAppendingPathComponent:fileName];
}

- (void)startLive {
    [self appendLog:@"🚪 Start login room"];

    
    // This demonstrates simply using the device model as the userID. In actual use, you can set the business-related userID as needed.
    NSString *userID = ZGUserIDHelper.userID;
    NSString *userName = ZGUserIDHelper.userName;

    // Login room
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:userID userName:userName]];

    // Start preview
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];

    [self appendLog:@"🔌 Start preview"];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
    
    [self appendLog:@"📤 Start publishing stream"];

    // Start publishing
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];

    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: %@ | StreamID: %@", self.roomID, self.streamID];
}

- (void)stopLive {
    // Stop Preview
    [[ZegoExpressEngine sharedEngine] stopPreview];
    [self appendLog:@"Stop Preview"];
    
    // Stop publishing
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [self appendLog:@"📤 Stop publishing stream"];

    // Logout room
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    [self appendLog:@"🚪 Logout room"];

    self.publishQualityLabel.text = @"";
}

#pragma mark - Helper

// Triggered by `recordTypeSwitchButton`
- (void)selectRecordType:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Set Record Type" message:@"Support Audio(aac) or Video(mp4/flv)" preferredStyle:UIAlertControllerStyleActionSheet];

    __weak typeof(self) weakSelf = self;
    for (NSNumber *index in self.recordTypeMap) {
        [alertController addAction:[UIAlertAction actionWithTitle:self.recordTypeMap[index].uppercaseString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.selectedRecordType = (ZGDemoRecordType)index.unsignedIntValue;
            [strongSelf appendLog:[NSString stringWithFormat:@"⚙️ Select record type: %@", self.recordTypeMap[@(self.selectedRecordType)]]];
        }]];
    }
    alertController.popoverPresentationController.sourceView = sender;

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)invalidateLiveStateUILayout {
    if(self.publisherState == ZegoPublisherStatePublishing)
    {
        [self showLiveStartedStateUI];
    }
    else if(self.publisherState == ZegoPublisherStatePublishRequesting)
    {
        [self showLiveRequestingStateUI];
    }
    else
    {
        [self showLiveStoppedStateUI];
    }
}

- (void)showLiveRequestingStateUI {
    
}

- (void)showLiveStartedStateUI {

}

- (void)showLiveStoppedStateUI {

}

/// Append Log to Top View
- (void)appendLog:(NSString *)tipText {
    if (!tipText || tipText.length == 0) {
        return;
    }

    ZGLogInfo(@"%@", tipText);

    NSString *oldText = self.logTextView.text;
    NSString *newLine = oldText.length == 0 ? @"" : @"\n";
    NSString *newText = [NSString stringWithFormat:@"%@%@ %@", oldText, newLine, tipText];

    self.logTextView.text = newText;
    if(newText.length > 0 ) {
        UITextView *textView = self.logTextView;
        NSRange bottom = NSMakeRange(newText.length -1, 1);
        [textView scrollRangeToVisible:bottom];
        // an iOS bug, see https://stackoverflow.com/a/20989956/971070
        [textView setScrollEnabled:NO];
        [textView setScrollEnabled:YES];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


#pragma mark - ZegoExpress ZegoDataRecordEventHandler

- (void)onCapturedDataRecordStateUpdate:(ZegoDataRecordState)state errorCode:(int)errorCode config:(ZegoDataRecordConfig *)config channel:(ZegoPublishChannel)channel {
    [self appendLog:[NSString stringWithFormat:@"🎥 Record state update, state: %d, errorCode: %d, file path: %@, record type: %d", (int)state, errorCode, config.filePath, (int)config.recordType]];
}

- (void)onCapturedDataRecordProgressUpdate:(ZegoDataRecordProgress *)progress config:(ZegoDataRecordConfig *)config channel:(ZegoPublishChannel)channel {
    NSLog(@"🎥 Record progress update, duration: %llu, file size: %llu", progress.duration, progress.currentFileSize);
}

#pragma mark - ZegoExpress EventHandler Room Event

-(void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if(reason == ZegoRoomStateChangedReasonLogining)
    {
        ZGLogInfo(@"🚩 🚪 Logining room");
    }
    else if(reason == ZegoRoomStateChangedReasonLogined)
    {
        ZGLogInfo(@"🚩 🚪 Login room success");
    }
    else if (reason == ZegoRoomStateChangedReasonLoginFailed)
    {
        ZGLogInfo(@"🚩 🚪 Login room failed");
    }
    else if(reason == ZegoRoomStateChangedReasonKickOut)
    {
        ZGLogInfo(@"🚩 🚪 Kick out of room");
    }
    else if(reason == ZegoRoomStateChangedReasonReconnecting)
    {
        ZGLogInfo(@"🚩 🚪 Reconnecting room");
    }
    else if(reason == ZegoRoomStateChangedReasonReconnectFailed)
    {
        ZGLogInfo(@"🚩 🚪 Reconnect room failed");
    }
    else if(reason == ZegoRoomStateChangedReasonReconnected)
    {
        ZGLogInfo(@"🚩 🚪 Reconnect room success");
    }
    else
    {
        // Logout
        // Logout failed
    }
}

#pragma mark - ZegoExpress EventHandler Publish Event

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📤 Publishing stream error of streamID: %@, errorCode:%d", streamID, errorCode]];
    } else {
        switch (state) {
            case ZegoPublisherStatePublishing:
                [self appendLog:@"🚩 📤 Publishing stream"];
                self.publisherStateLabel.text = @"🟢 PublisherState: Publishing";
                [self.publishButton setSelected:YES];
                break;

            case ZegoPublisherStatePublishRequesting:
                [self appendLog:@"🚩 📤 Requesting publish stream"];
                self.publisherStateLabel.text = @"🟡 PublisherState: Requesting";
                break;

            case ZegoPublisherStateNoPublish:
                [self appendLog:@"🚩 📤 No publish stream"];
                self.publisherStateLabel.text = @"🔴 PublisherState: NoPublish";
                [self.publishButton setSelected:NO];
                break;
        }
    }
    self.publisherState = state;
    [self invalidateLiveStateUILayout];
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    NSString *networkQuality = @"";
    switch (quality.level) {
        case 0:
            networkQuality = @"☀️";
            break;
        case 1:
            networkQuality = @"⛅️";
            break;
        case 2:
            networkQuality = @"☁️";
            break;
        case 3:
            networkQuality = @"🌧";
            break;
        case 4:
            networkQuality = @"❌";
            break;
        default:
            break;
    }
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"FPS: %d fps \n", (int)quality.videoSendFPS];
    [text appendFormat:@"Bitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"HardwareEncode: %@ \n", quality.isHardwareEncode ? @"✅" : @"❎"];
    [text appendFormat:@"NetworkQuality: %@", networkQuality];
    self.publishQualityLabel.text = [text copy];
}

- (void)onPublisherCapturedAudioFirstFrame {
    [self appendLog:@"onPublisherCapturedAudioFirstFrame"];
}

- (void)onPublisherCapturedVideoFirstFrame:(ZegoPublishChannel)channel {
    [self appendLog:@"onPublisherCapturedVideoFirstFrame"];
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    if (channel == ZegoPublishChannelAux) {
        return;
    }
    self.publishResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

@end

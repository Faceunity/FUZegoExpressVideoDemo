//
//  ZGOriginalAudioDataAcquisitionViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGOriginalAudioDataAcquisitionViewController.h"

#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
@interface ZGOriginalAudioDataAcquisitionViewController ()<ZegoEventHandler, ZegoAudioDataHandler>
@property (nonatomic, copy) NSString *streamID;

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

// LoginRoom
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;

@property (weak, nonatomic) IBOutlet UILabel *userIDRoomIDLabel;


// PublishStream
// Preview and Play View
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;

@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;

// PlayStream
@property (weak, nonatomic) IBOutlet UILabel *playStreamLabel;

@property (weak, nonatomic) IBOutlet UIView *remotePlayView;
@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;

@property (weak, nonatomic) IBOutlet UILabel *audioDataCallbackLabel;

@end

@implementation ZGOriginalAudioDataAcquisitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.streamID = @"0030";
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0030";
    self.playStreamIDTextField.text = self.streamID;
    self.publishStreamIDTextField.text = self.streamID;
    self.userIDRoomIDLabel.text = [NSString stringWithFormat:@"UserID: %@  RoomID:%@", self.userID, self.roomID];

    [self setupEngineAndLogin];
    
    // Set self as AudioDataHandler
    [[ZegoExpressEngine sharedEngine] setAudioDataHandler:self];
    [self enableAudioDataCallback: YES];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)setupEngineAndLogin {
    [self appendLog: [NSString stringWithFormat:@"🚀 Create ZegoExpressEngine"]];
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)
    
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    
    // Here we use the high quality video call scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    profile.scenario = ZegoScenarioHighQualityVideoCall;
    
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
    
    [self appendLog:[NSString stringWithFormat:@"🚪Login Room roomID: %@", self.roomID]];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:self.userID]];
}

- (void)enableAudioDataCallback:(BOOL)enable {
    // 音频数据类型 (Bitmask)，此处示例三个回调都开启
    // The required audio data type (Bitmask), all three callbacks are enabled here
    ZegoAudioDataCallbackBitMask bitmask = ZegoAudioDataCallbackBitMaskCaptured | ZegoAudioDataCallbackBitMaskPlayback | ZegoAudioDataCallbackBitMaskMixed;

    // 音频数据参数，此处示例单声道、16K
    // Required audio data parameters, the example here is mono, 16K
    ZegoAudioFrameParam *param = [[ZegoAudioFrameParam alloc] init];
    param.channel = ZegoAudioChannelMono;
    param.sampleRate = ZegoAudioSampleRate16K;

    // 开启获取原始音频数据的功能
    // Enable the function of obtaining raw audio data
    if (enable) {
        [[ZegoExpressEngine sharedEngine] startAudioDataObserver:bitmask param:param];
        [self appendLog:[NSString stringWithFormat:@"🟢 Start audio data observer"]];
    } else {
        [[ZegoExpressEngine sharedEngine] stopAudioDataObserver];
        [self appendLog:[NSString stringWithFormat:@"🔴 Stop audio data observer"]];
    }
}

- (void)setupUI {
    self.previewLabel.text = NSLocalizedString(@"PreviewLabel", nil);
    self.playStreamLabel.text = NSLocalizedString(@"PlayStreamLabel", nil);
    [self.startPlayingButton setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.startPlayingButton setTitle:@"Stop Playing" forState:UIControlStateSelected];
    
    [self.startPublishingButton setTitle:@"Start Publishing" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"Stop Publishing" forState:UIControlStateSelected];
    
    self.audioDataCallbackLabel.text = NSLocalizedString(@"Audio Data Callback", nil);
    
}

- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.publishStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
    } else {
        // Start preview
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
        [self appendLog:@"🔌 Start preview"];
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        
        // Start publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.publishStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.publishStreamIDTextField.text];
    }
    sender.selected = !sender.isSelected;
    
}
- (IBAction)onStartPlayingButtonTappd:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop playing

        [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", self.playStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
    } else {
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.playStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:playCanvas];
    }
    sender.selected = !sender.isSelected;
    
}

- (IBAction)onAudioDataCallbackSwitchChanged:(UISwitch *)sender {
    [self enableAudioDataCallback:sender.isOn];
}

#pragma mark - AudioDataHandler

- (void)onCapturedAudioData:(const unsigned char *)data dataLength:(unsigned int)dataLength param:(ZegoAudioFrameParam *)param {
    // 收到本地采集的音频数据，开始推流后即可收到回调，该回调不在主线程中。开发者可以使用原始数据进行鉴黄等业务处理。
    // The callback for obtaining the audio data captured by the local microphone.The callback is not in the main thread.Developers can use the original data to perform business processing such as pornographic identification.
    
}

- (void)onPlaybackAudioData:(const unsigned char *)data dataLength:(unsigned int)dataLength param:(ZegoAudioFrameParam *)param {
    // 收到远端拉流音频数据，开始拉流后可收到回调，该回调不在主线程中。开发者可以使用原始数据进行鉴黄等业务处理。
    // The callback for obtaining the audio data of all the streams playback by SDK.The callback is not in the main thread.Developers can use the original data to perform business processing such as pornographic identification.

}

- (void)onMixedAudioData:(const unsigned char *)data dataLength:(unsigned int)dataLength param:(ZegoAudioFrameParam *)param {
    // 本地采集与远端拉流声音混合后的音频数据回调，该回调不在主线程中。开发者可以使用原始数据进行鉴黄等业务处理。
    
    // The callback for obtaining the mixed audio data. Such mixed auido data are generated by the SDK by mixing the audio data of all the remote playing streams and the auido data captured locally.The callback is not in the main thread.Developers can use the original data to perform business processing such as pornographic identification.

}

#pragma mark - ZegoEventHandler

/// Publish stream state callback
- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (state == ZegoPublisherStatePublishing && errorCode == 0) {
        [self appendLog:@"🚩 📤 Publishing stream success"];
        // Add a flag to the button for successful operation
        self.startPublishingButton.selected = true;
    }
    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 📤 Publishing stream fail"];
    }
}

/// Play stream state callback
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (state == ZegoPlayerStatePlaying && errorCode == 0) {
        [self appendLog:@"🚩 📥 Playing stream success"];
        // Add a flag to the button for successful operation
        self.startPlayingButton.selected = true;
    }
    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 📥 Playing stream fail"];
    }
}


#pragma mark - Others

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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

#pragma mark - Exit

- (void)dealloc {
    ZGLogInfo(@"🚪 Exit the room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}


@end

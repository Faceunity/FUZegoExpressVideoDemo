//
//  ZGPlayStreamViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_PlayStream

#import "ZGPlayStreamViewController.h"
#import "ZGPlayStreamSettingTableViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NSString* const ZGPlayStreamTopicRoomID = @"ZGPlayStreamTopicRoomID";
NSString* const ZGPlayStreamTopicStreamID = @"ZGPlayStreamTopicStreamID";

@interface ZGPlayStreamViewController () <ZegoEventHandler, UITextFieldDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIView *startPlayConfigView;

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;

@property (weak, nonatomic) IBOutlet UIButton *startLiveButton;
@property (weak, nonatomic) IBOutlet UIButton *stopLiveButton;
@property (nonatomic, strong) UIBarButtonItem *settingButton;

@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomIDAndStreamIDLabel;

@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;
@property (weak, nonatomic) IBOutlet UILabel *hardwareDecoderLabel;
@property (weak, nonatomic) IBOutlet UILabel *networkQualityLabel;

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;

@property (nonatomic) ZegoRoomState roomState;
@property (nonatomic) ZegoPlayerState playerState;

@end

@implementation ZGPlayStreamViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PlayStream" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGPlayStreamViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [self createEngine];

    self.enableHardwareDecoder = NO;
    self.playVolume = 100;
}

- (void)dealloc {

    // Stop publishing before exiting
    if (self.playerState != ZegoPlayerStateNoPlay) {
        ZGLogInfo(@"📥 Stop playing stream");
        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];
    }

    // Logout room before exiting
    if (self.roomState != ZegoRoomStateDisconnected) {
        ZGLogInfo(@"🚪 Logout room");
        [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    }

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)setupUI {
    self.navigationItem.title = @"Play Stream";

    self.settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Setting"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettingController)];

    self.navigationItem.rightBarButtonItem = self.settingButton;

    self.stopLiveButton.alpha = 0;
    self.startPlayConfigView.alpha = 1;

    self.roomID = [self savedValueForKey:ZGPlayStreamTopicRoomID];
    self.roomIDTextField.text = self.roomID;
    self.roomIDTextField.delegate = self;

    self.streamID = [self savedValueForKey:ZGPlayStreamTopicStreamID];
    self.streamIDTextField.text = self.streamID;
    self.streamIDTextField.delegate = self;

    [self resetQualityLabelText];
}

- (void)resetQualityLabelText {
    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: | StreamID: "];
    self.resolutionLabel.text = @"Resolution:";
    self.bitrateLabel.text = @"Bitrate:";
    self.fpsLabel.text = @"FPS:";
    self.hardwareDecoderLabel.text = @"HardwareDecode:";
    self.networkQualityLabel.text = @"NetworkQuality:";
}

#pragma mark - Actions

- (void)createEngine {
    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];

    [self appendLog:@"🚀 Create ZegoExpressEngine"];

    [ZegoExpressEngine createEngineWithAppID:(unsigned int)appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];

    // Set debug verbose on
    //    [[ZegoExpressEngine sharedEngine] setDebugVerbose:YES language:ZegoLanguageEnglish];
}

- (IBAction)startLiveButtonClick:(id)sender {
    [self startLive];
}

- (IBAction)stopLiveButtonClick:(id)sender {
    [self stopLive];
}


- (void)startLive {
    [self appendLog:@"🚪 Start login room"];

    self.roomID = self.roomIDTextField.text;
    self.streamID = self.streamIDTextField.text;

    [self saveValue:self.roomID forKey:ZGPlayStreamTopicRoomID];
    [self saveValue:self.streamID forKey:ZGPlayStreamTopicStreamID];

    // This demonstrates simply using the device model as the userID. In actual use, you can set the business-related userID as needed.
    NSString *userID = ZGUserIDHelper.userID;
    NSString *userName = ZGUserIDHelper.userName;

    ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];

    // Login room
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:userID userName:userName] config:config];

    [self appendLog:@"📥 Start playing stream"];

    // Start playing
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];

    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamID canvas:playCanvas];

    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: %@ | StreamID: %@", self.roomID, self.streamID];
}

- (void)stopLive {
    // Stop playing
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];
    [self appendLog:@"📥 Stop playing stream"];

    // Logout room
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    [self appendLog:@"🚪 Logout room"];

    [self resetQualityLabelText];
}


#pragma mark - Helper

- (void)invalidateLiveStateUILayout {
    if (self.roomState == ZegoRoomStateConnected &&
        self.playerState == ZegoPlayerStatePlaying) {
        [self showLiveStartedStateUI];
    } else if (self.roomState == ZegoRoomStateDisconnected &&
               self.playerState == ZegoPlayerStateNoPlay) {
        [self showLiveStoppedStateUI];
    } else {
        [self showLiveRequestingStateUI];
    }
}

- (void)showLiveRequestingStateUI {
    [self.startLiveButton setEnabled:NO];
    [self.stopLiveButton setEnabled:NO];
}

- (void)showLiveStartedStateUI {
    [self.startLiveButton setEnabled:NO];
    [self.stopLiveButton setEnabled:YES];
    [UIView animateWithDuration:0.5 animations:^{
        self.startPlayConfigView.alpha = 0;
        self.stopLiveButton.alpha = 1;
    }];
}

- (void)showLiveStoppedStateUI {
    [self.startLiveButton setEnabled:YES];
    [self.stopLiveButton setEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.startPlayConfigView.alpha = 1;
        self.stopLiveButton.alpha = 0;
    }];
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

- (void)showSettingController {
    ZGPlayStreamSettingTableViewController *vc = [ZGPlayStreamSettingTableViewController instanceFromStoryboard];
    vc.preferredContentSize = CGSizeMake(250.0, 150.0);
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.delegate = self;
    vc.popoverPresentationController.barButtonItem = self.settingButton;
    vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;

    vc.presenter = self;
    vc.streamID = _streamID;
    vc.enableHardwareDecoder = _enableHardwareDecoder;
    vc.playVolume = _playVolume;
    vc.streamExtraInfo = _streamExtraInfo;
    vc.roomExtraInfo = _roomExtraInfo;

    [self presentViewController:vc animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    if (textField == self.roomIDTextField) {
        [self.streamIDTextField becomeFirstResponder];
    } else if (textField == self.streamIDTextField) {
        [self startLive];
    }

    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)updateStreamExtraInfo:(NSArray<ZegoStream *> *)streamList {
    NSMutableString *streamExtraInfoString = [NSMutableString string];
    for (ZegoStream *stream in streamList) {
        [streamExtraInfoString appendFormat:@"streamID:%@,info:%@;\n", stream.streamID, stream.extraInfo];
    }
    self.streamExtraInfo = streamExtraInfoString;
    [self appendLog:[NSString stringWithFormat:@"🚩 💬 Stream extra info update: %@", streamExtraInfoString]];
}

#pragma mark - ZegoExpress EventHandler Room Event

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 🚪 Room state error, errorCode: %d", errorCode]];
    } else {
        switch (state) {
            case ZegoRoomStateConnected:
                [self appendLog:@"🚩 🚪 Login room success"];
                self.roomStateLabel.text = @"🟢 RoomState: Connected";
                break;

            case ZegoRoomStateConnecting:
                [self appendLog:@"🚩 🚪 Requesting login room"];
                self.roomStateLabel.text = @"🟡 RoomState: Connecting";
                break;

            case ZegoRoomStateDisconnected:
                [self appendLog:@"🚩 🚪 Logout room"];
                self.roomStateLabel.text = @"🔴 RoomState: Disconnected";
                break;
        }
    }
    self.roomState = state;
    [self invalidateLiveStateUILayout];
}

- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    [self appendLog:[NSString stringWithFormat:@"🚩 🌊 Room stream update, updateType:%lu, streamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID]];
    [self updateStreamExtraInfo:streamList];
}

- (void)onRoomStreamExtraInfoUpdate:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    [self updateStreamExtraInfo:streamList];
}

- (void)onRoomExtraInfoUpdate:(NSArray<ZegoRoomExtraInfo *> *)roomExtraInfoList roomID:(NSString *)roomID {
    NSMutableString *roomExtraInfoString = [NSMutableString string];
    for (ZegoRoomExtraInfo *info in roomExtraInfoList) {
        [roomExtraInfoString appendFormat:@"key:%@,value:%@;\n", info.key, info.value];

    }
    self.roomExtraInfo = roomExtraInfoString;
    [self appendLog:[NSString stringWithFormat:@"🚩 💭 Room extra info update: %@", roomExtraInfoString]];
}

#pragma mark - ZegoExpress EventHandler Play Event

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📥 Playing stream error of streamID: %@, errorCode:%d", streamID, errorCode]];
    } else {
        switch (state) {
            case ZegoPlayerStatePlaying:
                [self appendLog:@"🚩 📥 Playing stream"];
                self.playerStateLabel.text = @"🟢 PlayerState: Playing";
                break;

            case ZegoPlayerStatePlayRequesting:
                [self appendLog:@"🚩 📥 Requesting play stream"];
                self.playerStateLabel.text = @"🟡 PlayerState: Requesting";
                break;

            case ZegoPlayerStateNoPlay:
                [self appendLog:@"🚩 📥 No play stream"];
                self.playerStateLabel.text = @"🔴 PlayerState: NoPlay";
                break;
        }
    }
    self.playerState = state;
    [self invalidateLiveStateUILayout];
}

- (void)onPlayerVideoSizeChanged:(CGSize)size streamID:(NSString *)streamID {
    self.resolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality streamID:(NSString *)streamID {
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

    self.bitrateLabel.text = [NSString stringWithFormat:@"Bitrate: %.2f kb/s \n", quality.videoKBPS];
    self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %d fps \n", (int)quality.videoRecvFPS];
    self.hardwareDecoderLabel.text = [NSString stringWithFormat:@"HardwareDecode: %@ \n", quality.isHardwareDecode ? @"✅" : @"❎"];
    self.networkQualityLabel.text = [NSString stringWithFormat:@"NetworkQuality: %@", networkQuality];
}

@end

#endif

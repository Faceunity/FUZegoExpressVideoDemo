//
//  ZGEncodingDecodingViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/13.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGEncodingDecodingViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
@interface ZGEncodingDecodingViewController ()<ZegoEventHandler>

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

// LoginRoom
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;

@property (nonatomic, assign) ZegoVideoStreamType streamType;

@property (nonatomic, strong) ZegoVideoConfig *videoConfig;

@property (nonatomic, assign) ZegoTrafficControlMinVideoBitrateMode bitrateMode;

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

@property (weak, nonatomic) IBOutlet UILabel *hardwareEncoderLabel;
@property (weak, nonatomic) IBOutlet UISwitch *hardwareEncoderSwitch;

@property (weak, nonatomic) IBOutlet UILabel *hardwareDecoderLabel;
@property (weak, nonatomic) IBOutlet UISwitch *hardwareDecoderSwitch;

@property (weak, nonatomic) IBOutlet UILabel *codecIDLabel;

@property (weak, nonatomic) IBOutlet UIButton *codecIDButton;

@property (weak, nonatomic) IBOutlet UILabel *scalableVideoCodingLabel;

@property (weak, nonatomic) IBOutlet UIButton *videoLayerModeButton;

@property (weak, nonatomic) IBOutlet UIButton *videoEncoderProfileButton;

@property (weak, nonatomic) IBOutlet UITextField *encodeWidthTextField;
@property (weak, nonatomic) IBOutlet UITextField *encodeHeightTextField;
@property (weak, nonatomic) IBOutlet UITextField *captureWidthTextField;
@property (weak, nonatomic) IBOutlet UITextField *captureHeightTextField;
@property (weak, nonatomic) IBOutlet UITextField *videoFPSTextField;
@property (weak, nonatomic) IBOutlet UITextField *videoBitrateTextField;
@property (weak, nonatomic) IBOutlet UIStepper *trafficControlMode;

@property (weak, nonatomic) IBOutlet UILabel *trafficControlModeLabel;

@property (weak, nonatomic) IBOutlet UITextField *trafficControlWidthTextField;
@property (weak, nonatomic) IBOutlet UITextField *trafficControlHeightTextField;

@property (weak, nonatomic) IBOutlet UITextField *trafficControlBitrateTextField;
@property (weak, nonatomic) IBOutlet UIButton *trafficControlModeButton;
@property (weak, nonatomic) IBOutlet UITextField *seiTextField;

@end

@implementation ZGEncodingDecodingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0012";
    self.streamType = ZegoVideoStreamTypeDefault;
    self.playStreamIDTextField.text = @"0012";
    self.publishStreamIDTextField.text = @"0012";
    self.userIDRoomIDLabel.text = [NSString stringWithFormat:@"UserID: %@  RoomID:%@", self.userID, self.roomID];
    self.videoConfig = [[ZegoVideoConfig alloc] init];

    [self setupEngineAndLogin];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)setupEngineAndLogin {
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
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

- (void)setupUI {
    self.previewLabel.text = NSLocalizedString(@"PreviewLabel", nil);
    self.playStreamLabel.text = NSLocalizedString(@"PlayStreamLabel", nil);
    [self.startPlayingButton setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.startPlayingButton setTitle:@"Stop Playing" forState:UIControlStateSelected];

    [self.startPublishingButton setTitle:@"Start Publishing" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"Stop Publishing" forState:UIControlStateSelected];

    self.hardwareEncoderLabel.text = NSLocalizedString(@"HardwareEncoder", nil);
    self.hardwareDecoderLabel.text = NSLocalizedString(@"HardwareDecoder", nil);

    self.codecIDLabel.text = NSLocalizedString(@"CodecID", nil);
    self.scalableVideoCodingLabel.text = NSLocalizedString(@"ScalableVideoCoding", nil);
}

- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.publishStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
    } else {
        // Start preview
        bool hardwareEncode = self.hardwareEncoderSwitch.isOn;
        [[ZegoExpressEngine sharedEngine] enableHardwareEncoder:hardwareEncode];
        
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
        [self appendLog:@"🔌 Start preview"];
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];

        // Start publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream streamID: %@", self.publishStreamIDTextField.text]];

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
        bool hardwareDecode = self.hardwareDecoderSwitch.isOn;
        [[ZegoExpressEngine sharedEngine] enableHardwareDecoder:hardwareDecode];
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream,streamID: %@", self.playStreamIDTextField.text]];
        
        [[ZegoExpressEngine sharedEngine] setPlayStreamVideoType:self.streamType streamID:self.playStreamIDTextField.text];
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:playCanvas];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onVideoConfigButtonTapped:(UIButton *)sender {
    self.videoConfig.captureResolution = CGSizeMake(self.captureWidthTextField.text.integerValue, self.captureHeightTextField.text.integerValue);
    self.videoConfig.encodeResolution = CGSizeMake(self.encodeWidthTextField.text.integerValue, self.encodeHeightTextField.text.integerValue);
    self.videoConfig.fps = self.videoFPSTextField.text.intValue;
    self.videoConfig.bitrate = self.videoBitrateTextField.text.intValue;
    
    [ZegoExpressEngine.sharedEngine setVideoConfig:self.videoConfig];
}

- (IBAction)onHardwareEncoderSwitchChanged:(UISwitch *)sender {
//    self.startPlayingButton.selected = NO;
//    self.startPublishingButton.selected = NO;
//    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
//    [[ZegoExpressEngine sharedEngine] stopPreview];
//    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
    [[ZegoExpressEngine sharedEngine] enableHardwareEncoder:sender.isOn];

}

- (IBAction)onHardwareDecoderSwitchChanged:(UISwitch *)sender {
//    self.startPlayingButton.selected = NO;
//    self.startPublishingButton.selected = NO;
//    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
//    [[ZegoExpressEngine sharedEngine] stopPreview];
//    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
    [[ZegoExpressEngine sharedEngine] enableHardwareDecoder:sender.isOn];
}

- (IBAction)onCodecIDButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Default" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // It needs to be invoked before [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] and [createAudioEffectPlayer]
        self.videoConfig.codecID = ZegoVideoCodecIDDefault;
        [self.codecIDButton setTitle:@"Default" forState:UIControlStateNormal];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"SVC" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // It needs to be invoked before [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] and [createAudioEffectPlayer]
        self.videoConfig.codecID = ZegoVideoCodecIDSVC;
        [self.codecIDButton setTitle:@"SVC" forState:UIControlStateNormal];
    }];

    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"VP8" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // It needs to be invoked before [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] and [createAudioEffectPlayer]
        self.videoConfig.codecID = ZegoVideoCodecIDVP8;
        [self.codecIDButton setTitle:@"VP8" forState:UIControlStateNormal];
    }];

    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"H265" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // It needs to be invoked before [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] and [createAudioEffectPlayer]
        self.videoConfig.codecID = ZegoVideoCodecIDH265;
        [self.codecIDButton setTitle:@"H265" forState:UIControlStateNormal];
    }];
    
    UIAlertAction *action5 = [UIAlertAction actionWithTitle:@"H264DualStream" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // It needs to be invoked before [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] and [createAudioEffectPlayer]
        self.videoConfig.codecID = ZegoVideoCodecIDH264DualStream;
        [self.codecIDButton setTitle:@"H264DualStream" forState:UIControlStateNormal];
    }];

    [alertController addAction:cancel];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [alertController addAction:action5];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onVideoLayerButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Default" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       // [self reset];
        self.streamType = ZegoVideoStreamTypeDefault;
        
        [[ZegoExpressEngine sharedEngine] setPlayStreamVideoType:self.streamType streamID:self.playStreamIDTextField.text];
        [self.videoLayerModeButton setTitle:@"Default" forState:UIControlStateNormal];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Small" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //[self reset];
        self.streamType = ZegoVideoStreamTypeSmall;
        
        [[ZegoExpressEngine sharedEngine] setPlayStreamVideoType:self.streamType streamID:self.playStreamIDTextField.text];
        
        [self.videoLayerModeButton setTitle:@"Small" forState:UIControlStateNormal];
    }];

    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Big" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       // [self reset];
        
        self.streamType = ZegoVideoStreamTypeBig;
        [[ZegoExpressEngine sharedEngine] setPlayStreamVideoType:self.streamType streamID:self.playStreamIDTextField.text];
        
        [self.videoLayerModeButton setTitle:@"Big" forState:UIControlStateNormal];
    }];

    [alertController addAction:cancel];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}
- (IBAction)onEncoderProfileSwitch:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Baseline" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *params = @"{\"method\":\"express.video.set_video_encoder_profile\",\"params\":{\"profile\":0,\"channel\":0}}";
        
        [ZegoExpressEngine.sharedEngine callExperimentalAPI:params];
        
        [self.videoEncoderProfileButton setTitle:@"Baseline" forState:UIControlStateNormal];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Main" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSString *params = @"{\"method\":\"express.video.set_video_encoder_profile\",\"params\":{\"profile\":1,\"channel\":0}}";
        
        [ZegoExpressEngine.sharedEngine callExperimentalAPI:params];
        
        [self.videoEncoderProfileButton setTitle:@"Main" forState:UIControlStateNormal];
    }];

    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Hight" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        NSString *params = @"{\"method\":\"express.video.set_video_encoder_profile\",\"params\":{\"profile\":2,\"channel\":0}}";
        
        [ZegoExpressEngine.sharedEngine callExperimentalAPI:params];
        
        [self.videoEncoderProfileButton setTitle:@"Hight" forState:UIControlStateNormal];
    }];

    [alertController addAction:cancel];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}
- (IBAction)onTrafficControlModeStepped:(UIStepper *)sender {
    self.trafficControlModeLabel.text = @(sender.value).stringValue;
}

- (IBAction)onTrafficControlSwitch:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] enableTrafficControl:sender.isOn property:self.trafficControlMode.value];
}

- (IBAction)onMinTrafficControlResolutionUpdateTapped:(id)sender {
    [ZegoExpressEngine.sharedEngine setMinVideoResolutionForTrafficControl:self.trafficControlWidthTextField.text.intValue height:self.trafficControlHeightTextField.text.intValue channel:ZegoPublishChannelMain];
}

- (IBAction)onMinTrafficControlFPSDidEnd:(UITextField *)sender {
    [ZegoExpressEngine.sharedEngine setMinVideoFpsForTrafficControl:sender.text.intValue channel:ZegoPublishChannelMain];
}

- (IBAction)onMinTrafficControlBitrateDidEnd:(UITextField *)sender {
    [ZegoExpressEngine.sharedEngine setMinVideoBitrateForTrafficControl:sender.text.intValue mode:self.bitrateMode];
}

- (IBAction)onMinTrafficControlBitrateModeTapped:(UIButton *)sender {
    
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"NoVideo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        self.bitrateMode = ZegoTrafficControlMinVideoBitrateModeNoVideo;
        
        [ZegoExpressEngine.sharedEngine setMinVideoBitrateForTrafficControl:self.trafficControlBitrateTextField.text.intValue mode:self.bitrateMode];
        
        [self.trafficControlModeButton setTitle:@"NoVideo" forState:UIControlStateNormal];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"UltraLowFPS" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        self.bitrateMode = ZegoTrafficControlMinVideoBitrateModeUltraLowFPS;
        
        [ZegoExpressEngine.sharedEngine setMinVideoBitrateForTrafficControl:self.trafficControlBitrateTextField.text.intValue mode:self.bitrateMode];
        
        [self.trafficControlModeButton setTitle:@"UltraLowFPS" forState:UIControlStateNormal];
    }];

    [alertController addAction:cancel];
    [alertController addAction:action1];
    [alertController addAction:action2];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onSendSEITapped:(UIButton *)sender {
    
    NSData *data = [self.seiTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    
    [ZegoExpressEngine.sharedEngine sendSEI:data];
}

- (void)reset {
    self.startPlayingButton.selected = NO;
    self.startPublishingButton.selected = NO;
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [[ZegoExpressEngine sharedEngine] stopPreview];
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
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

- (void)onPlayerRecvSEI:(NSData *)data streamID:(NSString *)streamID {
    [self appendLog:[NSString stringWithFormat:@"🚩 📥 Recv sei data. stream: %@, data: %@", streamID, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]]];
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

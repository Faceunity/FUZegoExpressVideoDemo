//
//  ZGScreenCaptureViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/9/17.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGScreenCaptureViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import "ZGScreenCaptureDefines.h"
#import "AppDelegate.h"
#import <ReplayKit/ReplayKit.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGScreenCaptureViewController ()<ZegoEventHandler>

@property (nonatomic, copy) NSString *streamID;

// LoginRoom
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;

/// Scenraio
@property (nonatomic, assign) ZegoScenario scenario;

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;
@property (weak, nonatomic) IBOutlet UILabel *micVolumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *appVolumeLabel;

@property (weak, nonatomic) IBOutlet UILabel *videoFpsLabel;
@property (weak, nonatomic) IBOutlet UIStepper *videoFpsStepper;
@property (nonatomic, assign) unsigned int videoFps;

@property (weak, nonatomic) IBOutlet UIStepper *micVolumeStepper;
@property (weak, nonatomic) IBOutlet UIStepper *appVolumeStepper;

@property (weak, nonatomic) IBOutlet UILabel *videoBitrateLabel;
@property (weak, nonatomic) IBOutlet UIStepper *videoBitrateStepper;
@property (nonatomic, assign) unsigned int videoBitrateKBPS;

@property (weak, nonatomic) IBOutlet UITextField *encodeWidthLabel;
@property (weak, nonatomic) IBOutlet UITextField *encodeHeightLabel;


@property (nonatomic, strong) ZegoScreenCaptureConfig *captureConfig;
@property (nonatomic, strong) ZegoMediaPlayer *mediaPlayer;

@end

@implementation ZGScreenCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Support landscape
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskAllButUpsideDown];
    
    self.streamID = @"0033";
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0033";
    
    // Here we use the high quality video call scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    self.scenario = ZegoScenarioBroadcast;
    
    self.captureConfig = [[ZegoScreenCaptureConfig alloc] init];
    
    [self setupUI];
    [self setupEngine];
}

- (void)setupEngine {
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)
    
    ZegoEngineConfig *config = [[ZegoEngineConfig alloc] init];
    config.advancedConfig = @{@"switch_media_source": @"true"};
    [ZegoExpressEngine setEngineConfig:config];
    
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    profile.scenario = self.scenario;
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
    
    [[ZegoExpressEngine sharedEngine] enableHardwareEncoder:true];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:self.userID]];
    [[ZegoExpressEngine sharedEngine] setVideoSource:ZegoVideoSourceTypeScreenCapture channel:ZegoPublishChannelAux];
    [[ZegoExpressEngine sharedEngine] setAudioSource:ZegoAudioSourceTypeScreenCapture channel:ZegoPublishChannelAux];
    
    self.mediaPlayer = [[ZegoExpressEngine sharedEngine] createMediaPlayer];
}

- (void)dealloc {
    // Reset to portrait
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskPortrait];
    
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)setupUI {
    
    self.roomIDTextField.text = self.roomID;
    self.streamIDTextField.text = self.streamID;
    
    self.micVolumeStepper.minimumValue = 0;
    self.micVolumeStepper.maximumValue = 200;
    self.micVolumeStepper.value = 100;
    self.micVolumeStepper.stepValue = 10;
    
    self.appVolumeStepper.minimumValue = 0;
    self.appVolumeStepper.maximumValue = 200;
    self.appVolumeStepper.value = 100;
    self.appVolumeStepper.stepValue = 10;
    
    self.videoFpsStepper.minimumValue = 5;
    self.videoFpsStepper.maximumValue = 30;
    self.videoFpsStepper.value = 15;
    self.videoFpsStepper.stepValue = 5;
    self.videoFps = (unsigned int)self.videoFpsStepper.value;

    self.videoBitrateStepper.minimumValue = 500;
    self.videoBitrateStepper.maximumValue = 3000;
    self.videoBitrateStepper.value = 1500;
    self.videoBitrateStepper.stepValue = 500;
    self.videoBitrateKBPS = (unsigned int)self.videoBitrateStepper.value;
    
}

- (void)setVideoConfig {
    
    // Set video config
    ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] init];
    videoConfig.encodeResolution = CGSizeMake(self.encodeWidthLabel.text.integerValue, self.encodeHeightLabel.text.integerValue);
    videoConfig.fps = self.videoFps;
    videoConfig.bitrate = self.videoBitrateKBPS;
    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig channel:ZegoPublishChannelAux];
}

- (IBAction)audioClick:(UIButton *)sender {
    if (self.mediaPlayer.currentState == ZegoMediaPlayerStatePlaying) {
        [self.mediaPlayer stop];
    } else {
        [self.mediaPlayer loadResource:@"https://storage.zego.im/demo/201808270915.mp4" callback:^(int errorCode) {
            [self.mediaPlayer start];
        }];
    }
}

- (IBAction)startScreenCaptureInAppClick:(UIButton *)sender {
    if (@available(iOS 12.0, *)) {
        
        [self setVideoConfig];
        [[ZegoExpressEngine sharedEngine] startScreenCaptureInApp:self.captureConfig];
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamIDTextField.text channel:ZegoPublishChannelAux];
    }
}

- (IBAction)startScreenCaptureClick:(UIButton *)sender {

    if (@available(iOS 12.0, *)) {
        
        [self setVideoConfig];

        [[ZegoExpressEngine sharedEngine] setAppGroupID:@"group.im.zego.express"];
        [[ZegoExpressEngine sharedEngine] startScreenCapture:self.captureConfig];
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamIDTextField.text channel:ZegoPublishChannelAux];
        // Note:
        // When screen recording is enabled, the iOS system will start an independent recording sub-process
        // and callback the methods of the [SampleHandler] class in the file [ ./ZegoExpressExample-iOS-OC-Broadcast/SampleHandler.m ]
        // Please refer to it to implement [SampleHandler] class in your own project
        
        // Note:
        // ⚠️ There is a known issue here: RPSystemBroadcastPickerView does not work on iOS 13
        // when using UIScene lifecycle (SceneDelegate), this issue was fixed since iOS 14. If
        // you want to use it on iOS 13, you should use the UIApplication lifecycle.
        //
        // Ref:
        // https://stackoverflow.com/q/60075142/7027076
        // https://github.com/twilio/video-quickstart-ios/issues/438
        //
        RPSystemBroadcastPickerView *broadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ZegoExpressExample-Broadcast" ofType:@"appex" inDirectory:@"PlugIns"];
        if (!bundlePath) {
            [ZegoHudManager showMessage:@"Can not find bundle `ZegoExpressExample-Broadcast.appex`"];
            return;
        }

        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        if (!bundle) {
            [ZegoHudManager showMessage:[NSString stringWithFormat:@"Can not find bundle at path: %@", bundlePath]];
            return;
        }

        broadcastPickerView.preferredExtension = bundle.bundleIdentifier;


        // Traverse the subviews to find the button to skip the step of clicking the system view

        // This solution is not officially recommended by Apple, and may be invalid in future system updates

        // The safe solution is to directly add RPSystemBroadcastPickerView as subView to your view

        for (UIView *subView in broadcastPickerView.subviews) {
            if ([subView isMemberOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subView;
                [button sendActionsForControlEvents:UIControlEventAllEvents];
            }
        }

    } else {
        [ZegoHudManager showMessage:@"This feature only supports iOS12 or above"];
    }
}

- (IBAction)stopScreenCaptureClick:(UIButton *)sender {
    if (@available(iOS 12.0, *)) {
        [[ZegoExpressEngine sharedEngine] stopScreenCapture];
    }
    [[ZegoExpressEngine sharedEngine] stopPublishingStream:ZegoPublishChannelAux];
    [[ZegoExpressEngine sharedEngine] stopPreview];
}
- (IBAction)captureVideoSwitch:(UISwitch *)sender {
    self.captureConfig.captureVideo = sender.isOn;
    if (@available(iOS 12.0, *)) {
        [[ZegoExpressEngine sharedEngine] updateScreenCaptureConfig:self.captureConfig];
    }
}
- (IBAction)captureAudioSwitch:(UISwitch *)sender {
    self.captureConfig.captureAudio = sender.isOn;
    if (@available(iOS 12.0, *)) {
        [[ZegoExpressEngine sharedEngine] updateScreenCaptureConfig:self.captureConfig];
    }
}

- (IBAction)videoFpsStepperValueChanged:(UIStepper *)sender {
    self.videoFps = (unsigned int)sender.value;
    self.videoFpsLabel.text = [NSString stringWithFormat:@"Video FPS: %d", self.videoFps];
    [self setVideoConfig];
}

- (IBAction)videoBitrateStepperValueChanged:(UIStepper *)sender {
    self.videoBitrateKBPS = (unsigned int)sender.value;
    self.videoBitrateLabel.text = [NSString stringWithFormat:@"Video Bitrate: %d (KBPS)", self.videoBitrateKBPS];
}

- (IBAction)micVolumeStepperValueChanged:(UIStepper *)sender {
    self.captureConfig.microphoneVolume = (unsigned int)sender.value;
    self.micVolumeLabel.text = [NSString stringWithFormat:@"Mic Volume: %.0f", sender.value];
    if (@available(iOS 12.0, *)) {
        [[ZegoExpressEngine sharedEngine] updateScreenCaptureConfig:self.captureConfig];
    }
}

- (IBAction)appVolumeStepperValueChanged:(UIStepper *)sender {
    self.captureConfig.applicationVolume = (unsigned int)sender.value;
    self.appVolumeLabel.text = [NSString stringWithFormat:@"App Volume: %.0f", sender.value];
    if (@available(iOS 12.0, *)) {
        [[ZegoExpressEngine sharedEngine] updateScreenCaptureConfig:self.captureConfig];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

//
//  ZGEarReturnAndChannelSettingsViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/13.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGEarReturnAndChannelSettingsViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
@interface ZGEarReturnAndChannelSettingsViewController ()<ZegoEventHandler>

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

@property (weak, nonatomic) IBOutlet UILabel *headphoneMonitorTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *headphoneMonitorNoticeLabel;

@property (weak, nonatomic) IBOutlet UILabel *headphoneMonitorLabel;

@property (weak, nonatomic) IBOutlet UILabel *volumeNoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *stereoChannelLabel;
@property (weak, nonatomic) IBOutlet UILabel *encoderStereolLabel;
@property (weak, nonatomic) IBOutlet UILabel *captureStereoLabel;
@property (weak, nonatomic) IBOutlet UIButton *captureStereo;



@end

@implementation ZGEarReturnAndChannelSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.streamID = @"0030";
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0030";
    self.playStreamIDTextField.text = self.streamID;
    self.publishStreamIDTextField.text = self.streamID;
    self.userIDRoomIDLabel.text = [NSString stringWithFormat:@"UserID: %@  RoomID:%@", self.userID, self.roomID];

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

    self.headphoneMonitorLabel.text = NSLocalizedString(@"HeadphoneMonitor", nil);
    self.headphoneMonitorTitleLabel.text = NSLocalizedString(@"HeadphoneMonitor", nil);
    self.headphoneMonitorNoticeLabel.text = NSLocalizedString(@"HeadphoneNotice", nil);
    self.volumeNoteLabel.text = NSLocalizedString(@"Volume", nil);
    self.volumeSlider.value = 100;
    self.volumeLabel.text = NSLocalizedString(@"100", nil);

    self.stereoChannelLabel.text = NSLocalizedString(@"Stereo Channel", nil);
    self.encoderStereolLabel.text = NSLocalizedString(@"Encoder Stereo", nil);
    self.captureStereoLabel.text = NSLocalizedString(@"Capture Stereo", nil);
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

- (IBAction)onHeadphoneMonitorSwitchChanged:(UISwitch *)sender {

    [[ZegoExpressEngine sharedEngine] enableHeadphoneMonitor:sender.isOn];
    [self appendLog:[NSString stringWithFormat:@"📥 OnHeadphoneMonitorSwitchChanged %d", sender.isOn]];
}
- (IBAction)onVolumeChanged:(UISlider *)sender {
    [[ZegoExpressEngine sharedEngine] setHeadphoneMonitorVolume:sender.value];
    [self appendLog:[NSString stringWithFormat:@"📥 OnHeadphoneVolumeChanged %d", (int)sender.value]];

    self.volumeLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
}

- (IBAction)onCaptureStereoButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    __block ZegoAudioCaptureStereoMode mode = ZegoAudioCaptureStereoModeNone;
    UIAlertAction *always = [UIAlertAction actionWithTitle:@"Always" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.startPlayingButton.selected = NO;
        self.startPublishingButton.selected = NO;
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];

        mode = ZegoAudioCaptureStereoModeAlways;
        // It needs to be invoked before [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] and [createAudioEffectPlayer]
        [[ZegoExpressEngine sharedEngine] setAudioCaptureStereoMode:mode];
        [self.captureStereo setTitle:@"Always" forState:UIControlStateNormal];
    }];
    UIAlertAction *adaptive = [UIAlertAction actionWithTitle:@"Adaptive" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.startPlayingButton.selected = NO;
        self.startPublishingButton.selected = NO;
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];

        mode = ZegoAudioCaptureStereoModeAdaptive;
        // It needs to be invoked before [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] and [createAudioEffectPlayer]
        [[ZegoExpressEngine sharedEngine] setAudioCaptureStereoMode:mode];
        [self.captureStereo setTitle:@"Adaptive" forState:UIControlStateNormal];

    }];

    UIAlertAction *none = [UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.startPlayingButton.selected = NO;
        self.startPublishingButton.selected = NO;
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];

        mode = ZegoAudioCaptureStereoModeNone;
        // It needs to be invoked before [startPublishingStream], [startPlayingStream], [startPreview], [createMediaPlayer] and [createAudioEffectPlayer]
        [[ZegoExpressEngine sharedEngine] setAudioCaptureStereoMode:mode];
        [self.captureStereo setTitle:@"None" forState:UIControlStateNormal];

    }];

    [alertController addAction:cancel];
    [alertController addAction:always];
    [alertController addAction:adaptive];
    [alertController addAction:none];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onEncoderStereoSwitchChanged:(UISwitch *)sender {
    self.startPlayingButton.selected = NO;
    self.startPublishingButton.selected = NO;
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [[ZegoExpressEngine sharedEngine] stopPreview];
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];

    ZegoAudioConfig *audioConfig = [ZegoAudioConfig defaultConfig];
    if (sender.isOn) {
        audioConfig.channel = 2;
    } else {
        audioConfig.channel = 1;
    }
    // Should be set before publishing stream.
    [[ZegoExpressEngine sharedEngine] setAudioConfig:audioConfig];
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

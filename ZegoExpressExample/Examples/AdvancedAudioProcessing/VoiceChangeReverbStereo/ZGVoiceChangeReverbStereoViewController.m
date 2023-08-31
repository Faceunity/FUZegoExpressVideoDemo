//
//  ZGAudioPreprocessMainViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/10/2.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGVoiceChangeReverbStereoViewController.h"
#import "ZGAudioPreprocessConfigTableViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGVoiceChangeReverbStereoViewController () <ZegoEventHandler>

@property (nonatomic, strong) UIBarButtonItem *resetButton;
@property (nonatomic, weak) ZGAudioPreprocessConfigTableViewController *configVC;

@property (nonatomic, strong) ZegoMediaPlayer *player;

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UIView *remotePlayView;
@property (weak, nonatomic) IBOutlet UILabel *captureStereoLabel;
@property (weak, nonatomic) IBOutlet UIButton *captureStereo;

@property (weak, nonatomic) IBOutlet UILabel *encoderStereo;
@property (weak, nonatomic) IBOutlet UILabel *backgroundMusicLabel;


@property (nonatomic, assign) ZegoPublisherState publisherState;
@property (weak, nonatomic) IBOutlet UIButton *startPublishButton;

@property (nonatomic, assign) ZegoPlayerState playerState;
@property (weak, nonatomic) IBOutlet UIButton *startPlayButton;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishStreamIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *playStreamIDLabel;

@end

@implementation ZGVoiceChangeReverbStereoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.roomID = @"0016";
    self.localPublishStreamID = @"0016";
    self.remotePlayStreamID = @"0016";

    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.publishStreamIDLabel.text = [NSString stringWithFormat:@"StreamID: %@", self.localPublishStreamID];
    self.playStreamIDLabel.text = [NSString stringWithFormat:@"StreamID: %@", self.remotePlayStreamID];

    self.resetButton = [[UIBarButtonItem alloc] initWithTitle:@"ResetAll" style:UIBarButtonItemStylePlain target:self.configVC action:@selector(resetAllEffect)];
    self.navigationItem.rightBarButtonItem = self.resetButton;

    [self createEngineAndLoginRoom];

    [self startPublishing];

    [self startPlaying];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self appendLog:[NSString stringWithFormat:@"🚪 Logout room"]];

    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];

    // Can destroy the engine when you don't need audio and video calls
    [self appendLog:[NSString stringWithFormat:@"🏳️ Destroy ZegoExpressEngine"]];

    [ZegoExpressEngine destroyEngine:nil];
}

- (void)createEngineAndLoginRoom {
    [self appendLog:@"🚀 Create ZegoExpressEngine"];

    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    
    // Here we use the high quality video call scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    profile.scenario = ZegoScenarioHighQualityVideoCall;
    
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];

    // In order to make the virtual stereo effect, you need to set the audio encoding channel to stereo
    ZegoAudioConfig *audioConfig = [ZegoAudioConfig configWithPreset:ZegoAudioConfigPresetStandardQualityStereo];
    [[ZegoExpressEngine sharedEngine] setAudioConfig:audioConfig];

    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];

    [self appendLog:[NSString stringWithFormat:@"🚪 Login room. roomID: %@", self.roomID]];

    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user];
}


- (IBAction)startPublishButtonClick:(UIButton *)sender {
    if (self.publisherState == ZegoPublisherStatePublishing) {
        [self stopPublishing];
    } else if (self.publisherState == ZegoPublisherStateNoPublish) {
        [self startPublishing];
    }
}

- (IBAction)onCaptureStereoButtonTapped:(UIButton *)sender {
    self.startPlayButton.selected = NO;
    self.startPublishButton.selected = NO;
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [[ZegoExpressEngine sharedEngine] stopPreview];
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.remotePlayStreamID];

    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *always = [UIAlertAction actionWithTitle:@"Always" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setAudioCaptureStereoMode:ZegoAudioCaptureStereoModeAlways];
        [self.captureStereo setTitle:@"Always" forState:UIControlStateNormal];
        [self appendLog:[NSString stringWithFormat:@"Always"]];

    }];
    UIAlertAction *adaptive = [UIAlertAction actionWithTitle:@"Adaptive" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setAudioCaptureStereoMode:ZegoAudioCaptureStereoModeAdaptive];
        [self.captureStereo setTitle:@"Adaptive" forState:UIControlStateNormal];
        [self appendLog:[NSString stringWithFormat:@"Adaptive"]];

    }];

    UIAlertAction *none = [UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setAudioCaptureStereoMode:ZegoAudioCaptureStereoModeNone];
        [self.captureStereo setTitle:@"None" forState:UIControlStateNormal];
        [self appendLog:[NSString stringWithFormat:@"None"]];

    }];

    [alertController addAction:cancel];
    [alertController addAction:always];
    [alertController addAction:adaptive];
    [alertController addAction:none];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onEncoderStereoSwitchChanged:(UISwitch *)sender {
    self.startPlayButton.selected = NO;
    self.startPublishButton.selected = NO;
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [[ZegoExpressEngine sharedEngine] stopPreview];
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.remotePlayStreamID];

    ZegoAudioConfig *audioConfig = [ZegoAudioConfig defaultConfig];
    if (sender.isOn) {
        audioConfig.channel = 2;
    } else {
        audioConfig.channel = 1;
    }
    [[ZegoExpressEngine sharedEngine] setAudioConfig:audioConfig];
    [self appendLog:[NSString stringWithFormat:@"AudioChannelCount: %lu", (unsigned long)audioConfig.channel]];

}

- (IBAction)onBackgroundMusicSwitchChanged:(UISwitch *)sender {
    if (!self.player) {
        self.player = [[ZegoExpressEngine sharedEngine] createMediaPlayer];
        [self.player enableAux:YES];
    }

    if (sender.isOn) {
        [self appendLog:[NSString stringWithFormat:@"MediaPlayer loadResource"]];

        [self.player loadResource:@"https://storage.zego.im/demo/201808270915.mp4" callback:^(int errorCode) {
            if (errorCode == 0) {
                [self.player start];
            }
            [self appendLog:[NSString stringWithFormat:@"🚩 💽 Media Player load resource. errorCode: %d", errorCode]];

        }];
    } else {
        [self appendLog:[NSString stringWithFormat:@"MediaPlayer stop"]];
        [self.player stop];
    }

}


- (IBAction)startPlayButtonClick:(UIButton *)sender {
    if (self.playerState == ZegoPlayerStatePlaying) {
        [self stopPlaying];
    } else if (self.playerState == ZegoPlayerStateNoPlay) {
        [self startPlaying];
    }
}


- (void)startPublishing {
    [self appendLog:[NSString stringWithFormat:@"🔌 Start preview"]];

    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];

    [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.localPublishStreamID]];

    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.localPublishStreamID];
}

- (void)stopPublishing {
    [self appendLog:[NSString stringWithFormat:@"🔌 Stop preview"]];
    [[ZegoExpressEngine sharedEngine] stopPreview];

    [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream"]];
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
}

- (void)startPlaying {
    [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.remotePlayStreamID]];

    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.remotePlayStreamID canvas:playCanvas];
}

- (void)stopPlaying {
    [self appendLog:[NSString stringWithFormat:@"📥 Stop playing stream"]];

    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.remotePlayStreamID];
}


#pragma mark - ZegoEventHandler

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📤 Publishing stream error of streamID: %@, errorCode:%d",streamID, errorCode]];
    } else {
        switch (state) {
            case ZegoPublisherStatePublishing:
                [self appendLog:[NSString stringWithFormat:@"🚩 📤 Publishing stream"]];

                [self.startPublishButton setTitle:@"Stop Publish" forState:UIControlStateNormal];
                break;

            case ZegoPublisherStatePublishRequesting:
                [self appendLog:[NSString stringWithFormat:@"🚩 📤 Requesting publish stream"]];

                [self.startPublishButton setTitle:@"Requesting" forState:UIControlStateNormal];
                break;

            case ZegoPublisherStateNoPublish:
                [self appendLog:[NSString stringWithFormat:@"🚩 📤 No publish stream"]];
                [self.startPublishButton setTitle:@"Start Publish" forState:UIControlStateNormal];
                break;
        }
    }
    self.publisherState = state;
}

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📥 Playing stream error of streamID: %@, errorCode:%d", streamID, errorCode]];

    } else {
        switch (state) {
            case ZegoPlayerStatePlaying:
                [self appendLog:[NSString stringWithFormat:@"🚩 📥 Playing stream"]];
                [self.startPlayButton setTitle:@"Stop Play" forState:UIControlStateNormal];
                break;

            case ZegoPlayerStatePlayRequesting:
                [self appendLog:[NSString stringWithFormat:@"🚩 📥 Requesting play stream"]];

                [self.startPlayButton setTitle:@"Requesting" forState:UIControlStateNormal];
                break;

            case ZegoPlayerStateNoPlay:
                [self appendLog:[NSString stringWithFormat:@"🚩 📥 No play stream"]];
                [self.startPlayButton setTitle:@"Start Play" forState:UIControlStateNormal];
                break;
        }
    }
    self.playerState = state;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ZGAudioPreprocessConfigSegue"]) {
        self.configVC = segue.destinationViewController;
    }
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
@end

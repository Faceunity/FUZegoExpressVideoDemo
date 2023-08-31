//
//  ZGAudioEffectPlayerViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/9/22.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGAudioEffectPlayerViewController.h"
#import "ZGMediaPlayerMediaItem.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"

#import <ZegoExpressEngine/ZegoExpressEngine.h>

static const int ZGAudioEffectOneID = 1;
static const int ZGAudioEffectTwoID = 2;

@interface ZGAudioEffectPlayerViewController ()<ZegoEventHandler, ZegoAudioEffectPlayerEventHandler, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) ZegoAudioEffectPlayer *player;

@property (nonatomic, assign) ZegoPublisherState publisherState;

@property (nonatomic, copy) NSArray<ZGMediaPlayerMediaItem *> *mediaItems;

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UILabel *userIDRoomIDLabel;

// PublishStream
// Preview and Play View
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;

@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;

// PlayStream
@property (weak, nonatomic) IBOutlet UILabel *playStreamLabel;
@property (weak, nonatomic) IBOutlet UIView *remotePlayView;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;

@property (weak, nonatomic) IBOutlet UIPickerView *audioEffectOneResourcePicker;
@property (weak, nonatomic) IBOutlet UISwitch *audioEffectOneIsPublishOutSwitch;
@property (nonatomic, assign) BOOL audioEffectOneHasBeenLoaded;
@property (nonatomic, assign) unsigned int audioEffectOnePlayCount;
@property (weak, nonatomic) IBOutlet UILabel *audioEffectOnePlayCountLabel;
@property (weak, nonatomic) IBOutlet UIStepper *audioEffectOnePlayCountStepper;

@property (weak, nonatomic) IBOutlet UIPickerView *audioEffectTwoResourcePicker;
@property (weak, nonatomic) IBOutlet UISwitch *audioEffectTwoIsPublishOutSwitch;
@property (nonatomic, assign) BOOL audioEffectTwoHasBeenLoaded;
@property (nonatomic, assign) unsigned int audioEffectTwoPlayCount;
@property (weak, nonatomic) IBOutlet UILabel *audioEffectTwoPlayCountLabel;
@property (weak, nonatomic) IBOutlet UIStepper *audioEffectTwoPlayCountStepper;


@end

@implementation ZGAudioEffectPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.roomID = @"0020";
    self.streamID = @"0020";
    self.userIDRoomIDLabel.text = [NSString stringWithFormat:@"UserID: %@  RoomID:%@", [ZGUserIDHelper userID], self.roomID];


    [self setupUI];

    [self createEngineAndLoginRoom];

    [self createAudioEffectPlayer];

}

- (void)setupUI {

    self.previewLabel.text = NSLocalizedString(@"PreviewLabel", nil);
    self.playStreamLabel.text = NSLocalizedString(@"PlayStreamLabel", nil);
    [self.startPlayingButton setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.startPlayingButton setTitle:@"Stop Playing" forState:UIControlStateSelected];
    
    [self.startPublishingButton setTitle:@"Start Publishing" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"Stop Publishing" forState:UIControlStateSelected];
    
    
    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];

    self.audioEffectOnePlayCount = 1;
    self.audioEffectTwoPlayCount = 1;

    self.audioEffectOnePlayCountLabel.text = [NSString stringWithFormat:@"%u", self.audioEffectOnePlayCount];
    self.audioEffectTwoPlayCountLabel.text = [NSString stringWithFormat:@"%u", self.audioEffectTwoPlayCount];

    self.audioEffectOneResourcePicker.delegate = self;
    self.audioEffectTwoResourcePicker.delegate = self;

    self.audioEffectOneResourcePicker.dataSource = self;
    self.audioEffectTwoResourcePicker.dataSource = self;
}

- (void)createEngineAndLoginRoom {
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

    ZegoAudioConfig *audioConfig = [ZegoAudioConfig configWithPreset:ZegoAudioConfigPresetHighQualityStereo];
    [[ZegoExpressEngine sharedEngine] setAudioConfig:audioConfig];

    [[ZegoExpressEngine sharedEngine] setAudioCaptureStereoMode:ZegoAudioCaptureStereoModeAlways];

    [self appendLog:[NSString stringWithFormat:@"🚪 Login room. roomID: %@", _roomID]];
    [[ZegoExpressEngine sharedEngine] loginRoom:_roomID user:[ZegoUser userWithUserID:[ZGUserIDHelper userID]]];
}

- (void)createAudioEffectPlayer {
    self.player = [[ZegoExpressEngine sharedEngine] createAudioEffectPlayer];
    if (self.player) {
        [self appendLog:[NSString stringWithFormat:@"💽 Create ZegoAudioEffectPlayer"]];
    } else {
        [self appendLog:[NSString stringWithFormat:@"💽 ❌ Create ZegoAudioEffectPlayer failed"]];
        return;
    }

    [self.player setEventHandler:self];
}

- (void)dealloc {
    [self appendLog:[NSString stringWithFormat:@"🏳️ Destroy ZegoAudioEffectPlayer"]];
    [[ZegoExpressEngine sharedEngine] destroyAudioEffectPlayer:self.player];

    [self appendLog:[NSString stringWithFormat:@"🏳️ Destroy ZegoExpressEngine"]];
    [ZegoExpressEngine destroyEngine:nil];
}

#pragma mark Publisher Actions


- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.streamID]];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
    } else {
        // Start preview
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
        [self appendLog:@"🔌 Start preview"];
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        
        // Start publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.streamID]];

        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];
    }
    sender.selected = !sender.isSelected;
}
- (IBAction)onStartPlayingButtonTappd:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", self.streamID]];

        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];
    } else {
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.streamID]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamID canvas:playCanvas];
    }
    sender.selected = !sender.isSelected;
}


- (void)startLive {
    [[ZegoExpressEngine sharedEngine] startPreview:[ZegoCanvas canvasWithView:self.localPreviewView]];
    [self appendLog:[NSString stringWithFormat:@"🔌 Start preview"]];

    [[ZegoExpressEngine sharedEngine] startPublishingStream:_streamID];
    [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", [ZGUserIDHelper userID]]];
}

- (void)stopLive {
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream"]];

    [[ZegoExpressEngine sharedEngine] stopPreview];
    [self appendLog:[NSString stringWithFormat:@"🔌 Stop preview"]];
}


#pragma mark AudioEffectPlayer Actions

- (IBAction)onPressedAllEffectControllerButtons:(UIButton *)sender {
    if (sender.tag == 101) {
        [self appendLog:[NSString stringWithFormat:@"⏸ Pause all"]];
        [self.player pauseAll];
    } else if (sender.tag == 102) {
        [self appendLog:[NSString stringWithFormat:@"⏯ Resume all"]];
        [self.player resumeAll];
    } else if (sender.tag == 103) {
        [self appendLog:[NSString stringWithFormat:@"⏹ Stop all"]];
        [self.player stopAll];
    }
}

- (IBAction)onPressedAudioEffectLoadResourceButtons:(UIButton *)sender {
    if (sender.tag == 211) {
        // Audio Effect 1
        [self appendLog:[NSString stringWithFormat:@"📀 LoadResource. ID:%d", ZGAudioEffectOneID]];
        NSString *resourcePath = self.mediaItems[[self.audioEffectOneResourcePicker selectedRowInComponent:0]].fileURL;
        [self.player loadResource:resourcePath audioEffectID:ZGAudioEffectOneID callback:^(int errorCode) {
            [self appendLog:[NSString stringWithFormat:@"🚩 📀 LoadResource result. ID:%d, errorCode: %d", ZGAudioEffectOneID, errorCode]];
            if (errorCode == ZegoErrorCodeCommonSuccess) {
                self.audioEffectOneHasBeenLoaded = YES;
            }
        }];

    } else if (sender.tag == 311) {
        // Audio Effect 2
        [self appendLog:[NSString stringWithFormat:@"📀 LoadResource. ID:%d", ZGAudioEffectTwoID]];
        NSString *resourcePath = self.mediaItems[[self.audioEffectTwoResourcePicker selectedRowInComponent:0]].fileURL;
        [self.player loadResource:resourcePath audioEffectID:ZGAudioEffectTwoID callback:^(int errorCode) {
            [self appendLog:[NSString stringWithFormat:@"🚩 📀 LoadResource result. ID:%d, errorCode: %d", ZGAudioEffectTwoID, errorCode]];
            if (errorCode == ZegoErrorCodeCommonSuccess) {
                self.audioEffectTwoHasBeenLoaded = YES;
            }
        }];
    }
}

- (IBAction)onPressedAudioEffectUnloadResourceButtons:(UIButton *)sender {
    if (sender.tag == 212) {
        // Audio Effect 1
        [self appendLog:[NSString stringWithFormat:@"📀 UnloadResource. ID:%d", ZGAudioEffectOneID]];
        [self.player unloadResource:ZGAudioEffectOneID];
        self.audioEffectOneHasBeenLoaded = NO;

    } else if (sender.tag == 312) {
        // Audio Effect 2
        [self appendLog:[NSString stringWithFormat:@"📀 UnloadResource. ID:%d", ZGAudioEffectTwoID]];
        [self.player unloadResource:ZGAudioEffectTwoID];
        self.audioEffectTwoHasBeenLoaded = NO;
    }
}

- (IBAction)onPressedAudioEffectPlayButtons:(UIButton *)sender {
    if (sender.tag == 201) {
        // Audio Effect 1
        NSString *resourcePath = nil;
        if (!self.audioEffectOneHasBeenLoaded) {
            resourcePath = self.mediaItems[[self.audioEffectOneResourcePicker selectedRowInComponent:0]].fileURL;
        }

        ZegoAudioEffectPlayConfig *config = [[ZegoAudioEffectPlayConfig alloc] init];
        int playCount = self.audioEffectOnePlayCount;
        config.playCount = playCount >= 0 ? playCount : 1;
        config.isPublishOut = self.audioEffectOneIsPublishOutSwitch.on;

        [self appendLog:[NSString stringWithFormat:@"▶️ Play %@. ID:%d, playCount:%d, isPublishOut:%d", self.audioEffectOneHasBeenLoaded ? @"with preload" : @"directly", ZGAudioEffectOneID, config.playCount, config.isPublishOut]];

        [self.player start:ZGAudioEffectOneID path:resourcePath config:config];

    } else if (sender.tag == 301) {
        // Audio Effect 2
        NSString *resourcePath = nil;
        if (!self.audioEffectTwoHasBeenLoaded) {
            resourcePath = self.mediaItems[[self.audioEffectTwoResourcePicker selectedRowInComponent:0]].fileURL;
        }

        ZegoAudioEffectPlayConfig *config = [[ZegoAudioEffectPlayConfig alloc] init];
        int playCount = self.audioEffectTwoPlayCount;
        config.playCount = playCount >= 0 ? playCount : 1;
        config.isPublishOut = self.audioEffectTwoIsPublishOutSwitch.on;

        [self appendLog:[NSString stringWithFormat:@"▶️ Play %@. ID:%d, playCount:%d, isPublishOut:%d", self.audioEffectTwoHasBeenLoaded ? @"with preload" : @"directly", ZGAudioEffectTwoID, config.playCount, config.isPublishOut]];

        [self.player start:ZGAudioEffectTwoID path:resourcePath config:config];
    }
}

- (IBAction)onPressedAudioEffectPauseButtons:(UIButton *)sender {
    if (sender.tag == 202) {
        // Audio Effect 1
        [self appendLog:[NSString stringWithFormat:@"⏸ Pause. ID:%d", ZGAudioEffectOneID]];
        [self.player pause:ZGAudioEffectOneID];

    } else if (sender.tag == 302) {
        // Audio Effect 2
        [self appendLog:[NSString stringWithFormat:@"⏸ Pause. ID:%d", ZGAudioEffectTwoID]];
        [self.player pause:ZGAudioEffectTwoID];
    }
}

- (IBAction)onPressedAudioEffectResumeButtons:(UIButton *)sender {
    if (sender.tag == 203) {
        // Audio Effect 1
        [self appendLog:[NSString stringWithFormat:@"⏯ Resume. ID:%d", ZGAudioEffectOneID]];
        [self.player resume:ZGAudioEffectOneID];

    } else if (sender.tag == 303) {
        // Audio Effect 2
        [self appendLog:[NSString stringWithFormat:@"⏯ Resume. ID:%d", ZGAudioEffectTwoID]];
        [self.player resume:ZGAudioEffectTwoID];
    }
}

- (IBAction)onPressedAudioEffectStopButtons:(UIButton *)sender {
    if (sender.tag == 204) {
        // Audio Effect 1
        [self appendLog:[NSString stringWithFormat:@"⏹ Stop. ID:%d", ZGAudioEffectOneID]];
        [self.player stop:ZGAudioEffectOneID];

    } else if (sender.tag == 304) {
        // Audio Effect 2
        [self appendLog:[NSString stringWithFormat:@"⏹ Stop. ID:%d", ZGAudioEffectTwoID]];
        [self.player stop:ZGAudioEffectTwoID];
    }
}

- (IBAction)onPlayCountStepperValueChanged:(UIStepper *)sender {
    if (sender.tag == 401) {
        self.audioEffectOnePlayCount = sender.value;
        self.audioEffectOnePlayCountLabel.text = [NSString stringWithFormat:@"%u", self.audioEffectOnePlayCount];
    } else if (sender.tag == 501) {
        self.audioEffectTwoPlayCount = sender.value;
        self.audioEffectTwoPlayCountLabel.text = [NSString stringWithFormat:@"%u", self.audioEffectTwoPlayCount];
    }
}

#pragma mark AudioEffectPlayer Event

- (void)audioEffectPlayer:(ZegoAudioEffectPlayer *)audioEffectPlayer audioEffectID:(unsigned int)audioEffectID playStateUpdate:(ZegoAudioEffectPlayState)state errorCode:(int)errorCode {
    [self appendLog:[NSString stringWithFormat:@"🚩 💽 Play state update. ID:%d, state:%lu, err:%d", audioEffectID, (unsigned long)state, (int)errorCode]];
}

#pragma mark Publisher Event

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    [self appendLog:[NSString stringWithFormat:@"🚩 📤 Publisher state update. state: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID]];
    _publisherState = state;
}

#pragma mark PickerView DataSource & Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.mediaItems.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.mediaItems[row].mediaName;
}

#pragma mark Helper

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

#pragma mark Getter

- (NSArray<ZGMediaPlayerMediaItem *> *)mediaItems {
    if (!_mediaItems) {
        _mediaItems = @[
            [ZGMediaPlayerMediaItem itemWithFileURL:[[NSBundle mainBundle] pathForResource:@"effect_1_stereo" ofType:@"wav"] mediaName:@"effect_1_stereo.wav" isVideo:NO],
            [ZGMediaPlayerMediaItem itemWithFileURL:[[NSBundle mainBundle] pathForResource:@"effect_2_mono" ofType:@"wav"] mediaName:@"effect_2_mono.wav" isVideo:NO],
            [ZGMediaPlayerMediaItem itemWithFileURL:[[NSBundle mainBundle] pathForResource:@"effect_2_stereo" ofType:@"wav"] mediaName:@"effect_2_stereo.wav" isVideo:NO],
            [ZGMediaPlayerMediaItem itemWithFileURL:[[NSBundle mainBundle] pathForResource:@"effect_2_right" ofType:@"wav"] mediaName:@"effect_2_right.wav" isVideo:NO],
            [ZGMediaPlayerMediaItem itemWithFileURL:[[NSBundle mainBundle] pathForResource:@"effect_3_mono" ofType:@"mp3"] mediaName:@"effect_3_mono.mp3" isVideo:NO],
            [ZGMediaPlayerMediaItem itemWithFileURL:[[NSBundle mainBundle] pathForResource:@"effect_3_stereo" ofType:@"mp3"] mediaName:@"effect_3_stereo.mp3" isVideo:NO],
            [ZGMediaPlayerMediaItem itemWithFileURL:[[NSBundle mainBundle] pathForResource:@"ad" ofType:@"mp4"] mediaName:@"ad.mp4" isVideo:YES],
            [ZGMediaPlayerMediaItem itemWithFileURL:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp3"] mediaName:@"sample.mp3" isVideo:NO],
            [ZGMediaPlayerMediaItem itemWithFileURL:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"wav"] mediaName:@"test.wav" isVideo:NO],
        ];
    }
    return _mediaItems;
}

@end

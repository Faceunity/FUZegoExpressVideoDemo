//
//  ZGTestSettingTableViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/24.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_Test

#import "ZGTestSettingTableViewController.h"
#import "ZGAppGlobalConfigManager.h"

NSString* const ZGTestTopicKey_RoomID = @"kRoomID";
NSString* const ZGTestTopicKey_UserID = @"kUserID";
NSString* const ZGTestTopicKey_UserName = @"kUserName";

NSString* const ZGTestTopicKey_PublishStreamID = @"kPublishStreamID";
NSString* const ZGTestTopicKey_PreviewBackgroundColor = @"kPreviewBackgroundColor";

NSString* const ZGTestTopicKey_PlayStreamID = @"kPlayStreamID";
NSString* const ZGTestTopicKey_PlayBackgroundColor = @"kPlayBackgroundColor";
NSString* const ZGTestTopicKey_CdnUrl = @"kCdnUrl";
NSString* const ZGTestTopicKey_WatermarkFilePath = @"kWatermarkFilePath";
NSString* const ZGTestTopicKey_CaptureVolume = @"kCaptureVolume";
NSString* const ZGTestTopicKey_PlayVolume = @"kPlayVolume";
NSString* const ZGTestTopicKey_BeautifyFeature = @"kBeautifyFeature";
NSString* const ZGTestTopicKey_MixerTaskID = @"kMixerTaskID";
NSString* const ZGTestTopicKey_MixerInputFirstStreamIDs = @"kMixerInputFirstStreamIDs";
NSString* const ZGTestTopicKey_MixerInputSecondStreamIDs = @"kMixerInputSecondStreamIDs";
NSString* const ZGTestTopicKey_MixerOutputTargets = @"kMixerOutputTargets";

@interface ZGTestSettingTableViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) id<ZGTestViewDelegate> delegate;

@property (nonatomic, strong) NSDictionary *configDict;

@property (nonatomic, copy) NSArray<NSString *> *scenarioList;
@property (nonatomic, assign) ZegoScenario selectedScenario;

@property (nonatomic, copy) NSArray<NSString *> *resolutionList;
@property (nonatomic, assign) ZegoVideoConfigPreset selectedVideoConfigPreset;

@property (nonatomic, assign) ZegoVideoConfigPreset selectedMixerVideoConfigPreset;

@property (nonatomic, copy) NSArray<NSString *> *audioConfigPresetList;
@property (nonatomic, copy) NSDictionary<NSNumber *, NSString *> *audioConfigCodecIDMap;
@property (nonatomic, assign) ZegoAudioConfigPreset selectedAudioConfigPreset;

// Engine
@property (weak, nonatomic) IBOutlet UITextField *appIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *appSignTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *scenarioPicker;

@property (weak, nonatomic) IBOutlet UIButton *createEngineButton;
@property (weak, nonatomic) IBOutlet UIButton *destroyEngineButton;
@property (weak, nonatomic) IBOutlet UIButton *getVersionButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadLogButton;
@property (weak, nonatomic) IBOutlet UISwitch *enableDebugAssistantSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *setRoomModeSeg;
@property (weak, nonatomic) IBOutlet UITextField *advancedConfigKeyTextField;
@property (weak, nonatomic) IBOutlet UITextField *advancedConfigValueTextField;

// Room
@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutRoomButton;

// Publish
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPreviewButton;
@property (weak, nonatomic) IBOutlet UIButton *stopPreviewButton;
@property (weak, nonatomic) IBOutlet UIButton *startPublishButton;
@property (weak, nonatomic) IBOutlet UIButton *stopPublishButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *setPreviewViewModeSeg;
@property (weak, nonatomic) IBOutlet UITextField *previewCanvasBackgroundColorTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *setVideoConfigResolutionPicker;
@property (weak, nonatomic) IBOutlet UIButton *setVideoConfigButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *setVideoMirrorModeSeg;
@property (weak, nonatomic) IBOutlet UIButton *setVideoMirrorModeButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *setAppOrientationSeg;
@property (weak, nonatomic) IBOutlet UIButton *setAppOrientationButton;
@property (weak, nonatomic) IBOutlet UIPickerView *setAudioConfigPicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *setAudioConfigCodecIDSeg;
@property (weak, nonatomic) IBOutlet UISwitch *mutePublishAudioSwitch;
@property (weak, nonatomic) IBOutlet UIButton *mutePublishAudioButton;
@property (weak, nonatomic) IBOutlet UISwitch *mutePublishVideoSwitch;
@property (weak, nonatomic) IBOutlet UIButton *mutePublishVideoButton;
@property (weak, nonatomic) IBOutlet UISwitch *enableHardwareEncoderSwitch;
@property (weak, nonatomic) IBOutlet UIButton *enableHardwareEncoderButton;
@property (weak, nonatomic) IBOutlet UITextField *setCaptureVolumeTextField;
@property (weak, nonatomic) IBOutlet UIButton *setCaptureVolumeButton;
@property (weak, nonatomic) IBOutlet UITextField *CdnUrlTextField;
@property (weak, nonatomic) IBOutlet UIButton *addCdnUrlButton;
@property (weak, nonatomic) IBOutlet UIButton *removeCdnUrlButton;
@property (weak, nonatomic) IBOutlet UITextField *watermarkFilePathTextField;
@property (weak, nonatomic) IBOutlet UISwitch *watermarkIsPreviewVisibleSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableWatermarkSwitch;
@property (weak, nonatomic) IBOutlet UIButton *setWatermarkButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *setCapturePipelineScaleModeSeg;
@property (weak, nonatomic) IBOutlet UIButton *setCaptureScaleModeButton;
@property (weak, nonatomic) IBOutlet UITextField *sendSEITextField;
@property (weak, nonatomic) IBOutlet UIButton *sendSEIButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *setAudioCaptureStereoModeSeg;

// Play
@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *stopPlayButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *setPlayViewModeSeg;
@property (weak, nonatomic) IBOutlet UITextField *playCanvasBackgroundColorTextField;
@property (weak, nonatomic) IBOutlet UISwitch *mutePlayAudioSwitch;
@property (weak, nonatomic) IBOutlet UIButton *mutePlayAudioButton;
@property (weak, nonatomic) IBOutlet UISwitch *mutePlayVideoSwitch;
@property (weak, nonatomic) IBOutlet UIButton *mutePlayVideoButton;
@property (weak, nonatomic) IBOutlet UISwitch *enableHardwareDecoderSwitch;
@property (weak, nonatomic) IBOutlet UIButton *enableHardwareDecoderButton;
@property (weak, nonatomic) IBOutlet UITextField *setPlayVolumeTextField;
@property (weak, nonatomic) IBOutlet UIButton *setPlayVolumeButton;
@property (weak, nonatomic) IBOutlet UISwitch *enableCheckPocSwitch;
@property (weak, nonatomic) IBOutlet UIButton *enableCheckPocButton;

// Preprocess
@property (weak, nonatomic) IBOutlet UISegmentedControl *setAECModeSeg;
@property (weak, nonatomic) IBOutlet UIButton *setAECModeButton;
@property (weak, nonatomic) IBOutlet UISwitch *enableAECSwitch;
@property (weak, nonatomic) IBOutlet UIButton *enableAECButton;
@property (weak, nonatomic) IBOutlet UISwitch *enableAGCSwitch;
@property (weak, nonatomic) IBOutlet UIButton *enableAGCButton;
@property (weak, nonatomic) IBOutlet UISwitch *enableANSSwitch;
@property (weak, nonatomic) IBOutlet UIButton *enableANSButton;
@property (weak, nonatomic) IBOutlet UITextField *enableBeautifyTextField;
@property (weak, nonatomic) IBOutlet UIButton *enableBeautifyButton;

// Device
@property (weak, nonatomic) IBOutlet UISwitch *enableMicSwitch;
@property (weak, nonatomic) IBOutlet UIButton *enableMicButton;
@property (weak, nonatomic) IBOutlet UISwitch *muteSpeakerSwitch;
@property (weak, nonatomic) IBOutlet UIButton *muteSpeakerButton;
@property (weak, nonatomic) IBOutlet UISwitch *enableCamSwitch;
@property (weak, nonatomic) IBOutlet UIButton *enableCamButton;
@property (weak, nonatomic) IBOutlet UISwitch *useFrontCamSwitch;
@property (weak, nonatomic) IBOutlet UIButton *useFrontCamButton;
@property (weak, nonatomic) IBOutlet UISwitch *enableAudioCaptureDeviceSwitch;
@property (weak, nonatomic) IBOutlet UIButton *enableAudioCaptureDeviceButton;
@property (weak, nonatomic) IBOutlet UIButton *startSoundLevelMonitorButton;
@property (weak, nonatomic) IBOutlet UIButton *stopSoundLevelMonitorButton;
@property (weak, nonatomic) IBOutlet UIButton *startSpectrumMonitorButton;
@property (weak, nonatomic) IBOutlet UIButton *stopSpectrumMonitorButton;

// Mixer
@property (weak, nonatomic) IBOutlet UIPickerView *mixerResolutionPicker;
@property (weak, nonatomic) IBOutlet UITextField *mixerTaskIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *mixerInputFirstStreamIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *mixerInputSecondStreamIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *mixerOutputTargetsTextField;
@property (weak, nonatomic) IBOutlet UIButton *startMixerTaskButton;
@property (weak, nonatomic) IBOutlet UIButton *stopMixerTaskButton;
@property (weak, nonatomic) IBOutlet UITextView *mixerJsonConfigTextView;
@property (weak, nonatomic) IBOutlet UIButton *startMixerTaskWithJsonButton;

// IM
@property (weak, nonatomic) IBOutlet UITextField *broadcastMessageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendBroadcastMessageButton;
@property (weak, nonatomic) IBOutlet UITextField *customCommandTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendCustomCommandButton;

// RealTimeSequentialData
@property (weak, nonatomic) IBOutlet UITextField *rtsdManagerRoomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *rtsdBroadcastingStreamIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *rtsdSendDataTextField;
@property (weak, nonatomic) IBOutlet UITextField *rtsdSubscribingStreamIDTextField;

@end

@implementation ZGTestSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"ZegoTestJson" ofType:@"json"];
    self.configDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:jsonPath] options:0 error:nil];
    
    [self setupUI];
}

- (void)setupUI {
    self.scenarioList = @[@"General", @"Communication", @"Live", @"Default", @"StandardVideoCall", @"HighQualityVideoCall", @"StandardChatroom", @"HighQualityChatroom", @"Broadcast", @"Karaoke", @"StandardVoiceCall"];
    self.scenarioPicker.delegate = self;
    self.scenarioPicker.dataSource = self;
    self.scenarioPicker.tag = 1;
    [self pickerView:self.scenarioPicker didSelectRow:0 inComponent:0];

    self.resolutionList = @[@"180p", @"270p", @"360p", @"540p", @"720p", @"1080p"];
    self.setVideoConfigResolutionPicker.delegate = self;
    self.setVideoConfigResolutionPicker.dataSource = self;
    self.setVideoConfigResolutionPicker.tag = 2;
    [self pickerView:self.setVideoConfigResolutionPicker didSelectRow:0 inComponent:0];
    
    self.mixerResolutionPicker.delegate = self;
    self.mixerResolutionPicker.dataSource = self;
    self.mixerResolutionPicker.tag = 3;
    [self pickerView:self.mixerResolutionPicker didSelectRow:0 inComponent:0];

    self.audioConfigPresetList = @[@"16k / Mono", @"48k / Mono", @"56k / Stereo", @"128k / Mono", @"192k / Stereo"];
    self.setAudioConfigPicker.delegate = self;
    self.setAudioConfigPicker.dataSource = self;
    self.setAudioConfigPicker.tag = 4;
    [self pickerView:self.setAudioConfigPicker didSelectRow:1 inComponent:0];

    self.audioConfigCodecIDMap = @{
        @(ZegoAudioCodecIDDefault): @"Default",
        @(ZegoAudioCodecIDNormal): @"AAC-HE",
        @(ZegoAudioCodecIDNormal2): @"AAC-LC",
        @(ZegoAudioCodecIDNormal3): @"MP3",
        @(ZegoAudioCodecIDLow): @"EVS",
        @(ZegoAudioCodecIDLow2): @"SILK",
        @(ZegoAudioCodecIDLow3): @"OPUS"
    };
    [self.setAudioConfigCodecIDSeg removeAllSegments];
    for (NSNumber *idx in self.audioConfigCodecIDMap) {
        [self.setAudioConfigCodecIDSeg insertSegmentWithTitle:self.audioConfigCodecIDMap[idx] atIndex:idx.integerValue animated:NO];
    }
    self.setAudioConfigCodecIDSeg.selectedSegmentIndex = 0;
    
    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];
    
    self.appIDTextField.text = [NSString stringWithFormat:@"%u", appConfig.appID];
    self.appIDTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.appSignTextField.text = [appConfig appSign];
    
    self.roomIDTextField.text = [self savedValueForKey:ZGTestTopicKey_RoomID];
    self.userIDTextField.text = [self savedValueForKey:ZGTestTopicKey_UserID];
    self.userNameTextField.text = [self savedValueForKey:ZGTestTopicKey_UserName];
    
    self.publishStreamIDTextField.text = [self savedValueForKey:ZGTestTopicKey_PublishStreamID];
    
    NSString *savedPreviewBackgroundColor = [self savedValueForKey:ZGTestTopicKey_PreviewBackgroundColor];
    self.previewCanvasBackgroundColorTextField.text = savedPreviewBackgroundColor ? savedPreviewBackgroundColor : @"0x000000";
    
    self.playStreamIDTextField.text = [self savedValueForKey:ZGTestTopicKey_PlayStreamID];
    
    NSString *savedPlayBackgroundColor = [self savedValueForKey:ZGTestTopicKey_PlayBackgroundColor];
    self.playCanvasBackgroundColorTextField.text = savedPlayBackgroundColor ? savedPlayBackgroundColor : @"0x000000";
    
    NSString *savedWatermarkFilePath = [self savedValueForKey:ZGTestTopicKey_WatermarkFilePath];
    self.watermarkFilePathTextField.text = savedWatermarkFilePath ? savedWatermarkFilePath : @"asset:ZegoLogo";
    
    self.CdnUrlTextField.text = [self savedValueForKey:ZGTestTopicKey_CdnUrl];
    
    self.setCaptureVolumeTextField.text = [self savedValueForKey:ZGTestTopicKey_CaptureVolume];
    self.setCaptureVolumeTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.setPlayVolumeTextField.text = [self savedValueForKey:ZGTestTopicKey_PlayVolume];
    self.setPlayVolumeTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.enableBeautifyTextField.text = [self savedValueForKey:ZGTestTopicKey_BeautifyFeature];
    self.enableBeautifyTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    // Mixer
    self.mixerTaskIDTextField.text = [self savedValueForKey:ZGTestTopicKey_MixerTaskID];
    self.mixerInputFirstStreamIDTextField.text = [self savedValueForKey:ZGTestTopicKey_MixerInputFirstStreamIDs];
    self.mixerInputSecondStreamIDTextField.text = [self savedValueForKey:ZGTestTopicKey_MixerInputSecondStreamIDs];
    self.mixerOutputTargetsTextField.text = [self savedValueForKey:ZGTestTopicKey_MixerOutputTargets];
    
    self.mixerJsonConfigTextView.text = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.configDict[@"mixer"] options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}

- (void)setZGTestViewDelegate:(id<ZGTestViewDelegate>)delegate {
    self.delegate = delegate;
}

#pragma mark - Action

- (IBAction)createEngineClick:(UIButton *)sender {
    [self.manager createEngineWithAppID:(unsigned int)[self.appIDTextField.text longLongValue] appSign: self.appSignTextField.text scenario:(ZegoScenario)self.selectedScenario];
}

- (IBAction)destroyEngineClick:(UIButton *)sender {
    [self.manager destroyEngine];
}

- (IBAction)setRoomScenarioClick:(UIButton *)sender {
    [self.manager setRoomScenario:(ZegoScenario)self.selectedScenario];
}

- (IBAction)getVersionClick:(UIButton *)sender {
    [self.manager getVersion];
}

- (IBAction)uploadLogClick:(UIButton *)sender {
    [self.manager uploadLog];
}

- (IBAction)enableDebugAssistantClick:(UIButton *)sender {
    [self.manager enableDebugAssistant:self.enableDebugAssistantSwitch.on];
}

- (IBAction)setAdvancedConfigClick:(UIButton *)sender {
    NSString *key = self.advancedConfigKeyTextField.text;
    NSString *value = self.advancedConfigValueTextField.text;
    if (key && [key length] > 0 && value && [value length] > 0) {
        ZegoEngineConfig *config = [[ZegoEngineConfig alloc] init];
        config.advancedConfig = @{key: value};
        [self.manager setEngineConfig:config];
    }
}

- (IBAction)setRoomModeClick:(UIButton *)sender {
    [self.manager setRoomMode:(ZegoRoomMode)self.setRoomModeSeg.selectedSegmentIndex];
}

#pragma mark Room

- (IBAction)loginRoomClick:(UIButton *)sender {
    ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];
    config.isUserStatusNotify = YES;
    config.token = self.tokenTextField.text;
    [self.manager loginRoom:self.roomIDTextField.text userID:self.userIDTextField.text userName:self.userNameTextField.text config:config];
}

- (IBAction)switchRoomClick:(UIButton *)sender {
    NSString *currentRoomID = [self savedValueForKey:ZGTestTopicKey_RoomID];
    NSString *newRoomID = self.roomIDTextField.text;
    [self.manager switchRoom:currentRoomID toRoomID:newRoomID];
}

- (IBAction)logoutRoomClick:(UIButton *)sender {
    [self.manager logoutRoom:self.roomIDTextField.text];
}

#pragma mark Publisher

- (IBAction)startPublishClick:(UIButton *)sender {
//    [self]
    if ((ZegoRoomMode)self.setRoomModeSeg.selectedSegmentIndex == ZegoRoomModeMultiRoom) {
        [self.manager startPublishingStream:self.publishStreamIDTextField.text roomID:self.roomIDTextField.text];
    } else {
        [self.manager startPublishingStream:self.publishStreamIDTextField.text roomID:nil];
    }
}

- (IBAction)stopPublishClick:(UIButton *)sender {
    [self.manager stopPublishingStream];
}

- (IBAction)startPreviewClick:(UIButton *)sender {
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:[self.delegate getPublishView]];
    previewCanvas.viewMode = (ZegoViewMode)self.setPreviewViewModeSeg.selectedSegmentIndex;
    previewCanvas.backgroundColor = [[self.previewCanvasBackgroundColorTextField.text substringFromIndex:2] intValue];
    [self.manager startPreview:previewCanvas];
}

- (IBAction)stopPreviewClick:(UIButton *)sender {
    [self.manager stopPreview];
}

- (IBAction)setVideoConfigClick:(UIButton *)sender {
    ZegoVideoConfig *config = [ZegoVideoConfig configWithPreset:self.selectedVideoConfigPreset];
    [self.manager setVideoConfig:config];
}

- (IBAction)setMirrorClick:(UIButton *)sender {
    [self.manager setVideoMirrorMode:(ZegoVideoMirrorMode)self.setVideoMirrorModeSeg.selectedSegmentIndex];
}

- (IBAction)setCapOrientationClick:(UIButton *)sender {
    [self.manager setAppOrientation:(UIInterfaceOrientation)self.setAppOrientationSeg.selectedSegmentIndex];
}

- (IBAction)setAudioConfigClick:(UIButton *)sender {
    ZegoAudioConfig *config = [ZegoAudioConfig configWithPreset:self.selectedAudioConfigPreset];
    [self.manager setAudioConfig:config];
    ZegoAudioConfig *newConfig = [self.manager getAudioConfig];
    self.setAudioConfigCodecIDSeg.selectedSegmentIndex = (int)newConfig.codecID;
}

- (IBAction)setAudioConfigCodecIDClick:(UIButton *)sender {
    ZegoAudioConfig *config = [self.manager getAudioConfig];
    config.codecID = (ZegoAudioCodecID)self.setAudioConfigCodecIDSeg.selectedSegmentIndex;
    [self.manager setAudioConfig:config];
}

- (IBAction)mutePublishAudioClick:(UIButton *)sender {
    [self.manager mutePublishStreamAudio:self.mutePublishAudioSwitch.on];
}

- (IBAction)mutePublishVideoClick:(UIButton *)sender {
    [self.manager mutePublishStreamVideo:self.mutePublishVideoSwitch.on];
}

- (IBAction)enableHardwareEncoderClick:(UIButton *)sender {
    [self.manager enableHardwareEncoder:self.enableHardwareEncoderSwitch.on];
}

- (IBAction)setCaptureVolumeClick:(UIButton *)sender {
    [self.manager setCaptureVolume:[self.setCaptureVolumeTextField.text intValue]];
}
- (IBAction)addCdnUrlClick:(UIButton *)sender {
    [self.manager addPublishCdnUrl:self.CdnUrlTextField.text streamID:self.publishStreamIDTextField.text callback:nil];
}

- (IBAction)removeCdnUrlClick:(UIButton *)sender {
    [self.manager removePublishCdnUrl:self.CdnUrlTextField.text streamID:self.publishStreamIDTextField.text callback:nil];
}

- (IBAction)setWatermarkClick:(UIButton *)sender {
    ZegoWatermark *watermark = nil;
    if (self.enableWatermarkSwitch.on) {
        watermark = [[ZegoWatermark alloc] initWithImageURL:self.watermarkFilePathTextField.text layout:CGRectMake(30, 100, 300, 56.25)];
    }
    [self.manager setWatermark:watermark isPreviewVisible:self.watermarkIsPreviewVisibleSwitch.on];
}

- (IBAction)setCapturePipelineScaleModeClick:(UIButton *)sender {
    [self.manager setCapturePipelineScaleMode:(ZegoCapturePipelineScaleMode)self.setCapturePipelineScaleModeSeg.selectedSegmentIndex];
}

- (IBAction)sendSEIButtonClick:(UIButton *)sender {
//    char *str = "1234567\0";
//    [self.manager sendSEI:[NSData dataWithBytes:str length:7 ]];
    [self.manager sendSEI:[self.sendSEITextField.text dataUsingEncoding:NSUTF8StringEncoding]];
}

- (IBAction)setAudioCaptureStereoModeClick:(UIButton *)sender {
    [self.manager setAudioCaptureStereoMode:(ZegoAudioCaptureStereoMode)self.setAudioCaptureStereoModeSeg.selectedSegmentIndex];
}

#pragma mark Player

- (IBAction)startPlayClick:(UIButton *)sender {
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:[self.delegate getPlayView]];
    playCanvas.viewMode = (ZegoViewMode)self.setPlayViewModeSeg.selectedSegmentIndex;
    playCanvas.backgroundColor = [[self.playCanvasBackgroundColorTextField.text substringFromIndex:2] intValue];
    
    if ((ZegoRoomMode)self.setRoomModeSeg.selectedSegmentIndex == ZegoRoomModeMultiRoom) {
        [self.manager startPlayingStream:self.playStreamIDTextField.text canvas:playCanvas roomID:self.roomIDTextField.text];
    } else {
        [self.manager startPlayingStream:self.playStreamIDTextField.text canvas:playCanvas roomID:nil];
    }

}

- (IBAction)stopPlayClick:(UIButton *)sender {
    [self.manager stopPlayingStream:self.playStreamIDTextField.text];
}

- (IBAction)mutePlayAudioClick:(UIButton *)sender {
    [self.manager mutePlayStreamAudio:self.mutePlayAudioSwitch.on streamID:self.playStreamIDTextField.text];
}

- (IBAction)mutePlayVideoClick:(UIButton *)sender {
    [self.manager mutePlayStreamVideo:self.mutePlayVideoSwitch.on streamID:self.playStreamIDTextField.text];
}

- (IBAction)enableHardwareDecoderClick:(UIButton *)sender {
    [self.manager enableHarewareDecoder:self.enableHardwareDecoderSwitch.on];
}

- (IBAction)setPlayVolumeClick:(UIButton *)sender {
    [self.manager setPlayVolume:[self.setPlayVolumeTextField.text intValue] stream:self.playStreamIDTextField.text];
}

- (IBAction)enableCheckPocClick:(UIButton *)sender {
    [self.manager enableCheckPoc:self.enableCheckPocSwitch.on];
}

#pragma mark Preprocess

- (IBAction)setAECModeClick:(UIButton *)sender {
    [self.manager setAECMode:(ZegoAECMode)self.setAECModeSeg.selectedSegmentIndex];
}

- (IBAction)enableAECClick:(UIButton *)sender {
    [self.manager enableAEC:self.enableAECSwitch.on];
}

- (IBAction)enableAGCClick:(UIButton *)sender {
    [self.manager enableAGC:self.enableAGCSwitch.on];
}

- (IBAction)enableANSClick:(UIButton *)sender {
    [self.manager enableANS:self.enableANSSwitch.on];
}

- (IBAction)enableBeautifyClick:(UIButton *)sender {
    [self.manager enableBeautify:(int)[self.enableBeautifyTextField.text intValue]];
}

#pragma mark Device

- (IBAction)muteMicrophoneClick:(UIButton *)sender {
    [self.manager muteMicrophone:self.enableMicSwitch.on];
}

- (IBAction)muteSpeakerClick:(UIButton *)sender {
    [self.manager muteSpeaker:self.muteSpeakerSwitch.on];
}

- (IBAction)enableCameraClick:(UIButton *)sender {
    [self.manager enableCamera:self.enableCamSwitch.on];
}

- (IBAction)useFrontCameraClick:(UIButton *)sender {
    [self.manager useFrontCamera:self.useFrontCamSwitch.on];
}

- (IBAction)enableAudioCaptureDeviceClick:(UIButton *)sender {
    [self.manager enableAudioCaptureDevice:self.enableAudioCaptureDeviceSwitch.on];
}

- (IBAction)startSoundLevelMonitorClick:(UIButton *)sender {
    [self.manager startSoundLevelMonitor];
}

- (IBAction)stopSoundLevelMonitorClick:(UIButton *)sender {
    [self.manager stopSoundLevelMonitor];
}

- (IBAction)startAudioSpectrumMonitor:(UIButton *)sender {
    [self.manager startAudioSpectrumMonitor];
}

- (IBAction)stopAudioSpectrumMonitor:(UIButton *)sender {
    [self.manager stopAudioSpectrumMonitor];
}

- (IBAction)startPerformanceMonitor:(UIButton *)sender {
    [self.manager startPerformanceMonitor];
}

- (IBAction)stopPerformanceMonitor:(UIButton *)sender {
    [self.manager stopPerformanceMonitor];
}

#pragma mark Mixer

- (IBAction)startMixerTaskClick:(UIButton *)sender {
    ZegoMixerTask *task = [[ZegoMixerTask alloc] initWithTaskID:self.mixerTaskIDTextField.text];
    
    ZegoMixerVideoConfig *videoConfig = [[ZegoMixerVideoConfig alloc] initWithResolution:CGSizeMake(1080, 1920) fps:15 bitrate:3000];
    
    CGRect firstRect = CGRectMake(0, 0, videoConfig.resolution.width, videoConfig.resolution.height/2);
    ZegoMixerInput *firstInput = [[ZegoMixerInput alloc] initWithStreamID:self.mixerInputFirstStreamIDTextField.text contentType:ZegoMixerInputContentTypeVideo layout:firstRect];
    
    CGRect secondRect = CGRectMake(0, videoConfig.resolution.height/2, videoConfig.resolution.width, videoConfig.resolution.height/2);
    ZegoMixerInput *secondInput = [[ZegoMixerInput alloc] initWithStreamID:self.mixerInputSecondStreamIDTextField.text contentType:ZegoMixerInputContentTypeVideo layout:secondRect];
    
    NSArray<ZegoMixerInput *> *inputArray = @[firstInput, secondInput];
    
    NSArray<NSString *> *outputStringArray = [self.mixerOutputTargetsTextField.text componentsSeparatedByString:@" "];
    
    NSMutableArray<ZegoMixerOutput *> *outputArray = [[NSMutableArray alloc] initWithCapacity:outputStringArray.count];
    
    for (NSString *outputTargetString in outputStringArray) {
        [outputArray addObject:[[ZegoMixerOutput alloc] initWithTarget:outputTargetString]];
    }
    
    [task setAudioConfig:[ZegoMixerAudioConfig defaultConfig]];
    [task setVideoConfig:videoConfig];
    [task setInputList:inputArray];
    [task setOutputList:outputArray];
    
    [self.manager startMixerTask:task];

}

- (IBAction)stopMixerTaskClick:(UIButton *)sender {
    ZegoMixerTask *task = [[ZegoMixerTask alloc] initWithTaskID:self.mixerTaskIDTextField.text];
    [self.manager stopMixerTask:task];
}

- (IBAction)startMixerTaskWithJsonClick:(UIButton *)sender {
    NSString *configJsonStr = self.mixerJsonConfigTextView.text;
    NSDictionary *configDict = [NSJSONSerialization JSONObjectWithData:[configJsonStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    ZegoMixerTask *mixerTask = [[ZegoMixerTask alloc] initWithTaskID:[configDict objectForKey:@"taskID"]];
    
    if ([configDict objectForKey:@"inputList"]) {
        NSArray<NSDictionary *> *inputListObject = [configDict objectForKey:@"inputList"];
        NSMutableArray<ZegoMixerInput *> *mixerInputList = [NSMutableArray arrayWithCapacity:inputListObject.count];
        
        for (NSDictionary *input in inputListObject) {
            ZegoMixerInput *mixerInput = [[ZegoMixerInput alloc] init];
            int contentType = [(NSNumber *)input[@"contentType"] intValue];
            mixerInput.contentType = (ZegoMixerInputContentType)contentType;
            mixerInput.streamID = (NSString *)input[@"streamID"];
            NSLog(@"Mixer Input Stream: %@", mixerInput.streamID);
            mixerInput.layout = CGRectMake([(NSNumber *)input[@"layout"][@"x"] floatValue], [(NSNumber *)input[@"layout"][@"y"] floatValue], [(NSNumber *)input[@"layout"][@"width"] floatValue], [(NSNumber *)input[@"layout"][@"height"] floatValue]);
            [mixerInputList addObject:mixerInput];
        }
        [mixerTask setInputList:mixerInputList];
    }
    
    if ([configDict objectForKey:@"outputList"]) {
        NSArray<NSDictionary *> *outputListObject = [configDict objectForKey:@"outputList"];
        NSMutableArray<ZegoMixerOutput *> *mixerOutputList = [NSMutableArray arrayWithCapacity:outputListObject.count];
        
        for (NSDictionary *output in outputListObject) {
            [mixerOutputList addObject:[[ZegoMixerOutput alloc] initWithTarget:(NSString *)output[@"target"]]];
            NSLog(@"Mixer Output Target: %@", (NSString *)output[@"target"]);
        }
        [mixerTask setOutputList:mixerOutputList];
    }
    
    if ([configDict objectForKey:@"videoConfig"]) {
        NSDictionary *videoConfigObject = [configDict objectForKey:@"videoConfig"];
        ZegoMixerVideoConfig *mixerVideoConfig = [[ZegoMixerVideoConfig alloc] init];
        mixerVideoConfig.bitrate = [(NSNumber *)videoConfigObject[@"bitrate"] intValue];
        NSLog(@"Mixer Video Bitrate: %d", mixerVideoConfig.bitrate);
        mixerVideoConfig.fps = [(NSNumber *)videoConfigObject[@"fps"] intValue];
        NSLog(@"Mixer Video FPS: %d", mixerVideoConfig.fps);
        mixerVideoConfig.resolution = CGSizeMake([(NSNumber *)videoConfigObject[@"width"] floatValue], [(NSNumber *)videoConfigObject[@"height"] floatValue]);
        NSLog(@"Mixer Video Width: %f, Height: %f", mixerVideoConfig.resolution.width, mixerVideoConfig.resolution.height);
        
        [mixerTask setVideoConfig:mixerVideoConfig];
    }
    
    if ([configDict objectForKey:@"audioConfig"]) {
        NSDictionary *audioConfigObject = [configDict objectForKey:@"audioConfig"];
        ZegoMixerAudioConfig *mixerAudioConfig = [[ZegoMixerAudioConfig alloc] init];
        mixerAudioConfig.bitrate = [(NSNumber *)audioConfigObject[@"bitrate"] intValue];
        NSLog(@"Mixer Audio Bitrate: %d", mixerAudioConfig.bitrate);
        
        [mixerTask setAudioConfig:mixerAudioConfig];
    }
    
    if ([configDict objectForKey:@"watermark"]) {
        NSDictionary *watermarkObject = [configDict objectForKey:@"watermark"];
        ZegoWatermark *mixerWatermark = [[ZegoWatermark alloc] init];
        mixerWatermark.imageURL = watermarkObject[@"imageURL"];
        NSLog(@"Mixer Watermark URL: %@", mixerWatermark.imageURL);
        mixerWatermark.layout = CGRectMake([(NSNumber *)watermarkObject[@"layout"][@"x"] floatValue], [(NSNumber *)watermarkObject[@"layout"][@"y"] floatValue], [(NSNumber *)watermarkObject[@"layout"][@"width"] floatValue], [(NSNumber *)watermarkObject[@"layout"][@"height"] floatValue]);
        
        [mixerTask setWatermark:mixerWatermark];
    }
    
    if ([configDict objectForKey:@"backgroundImageURL"]) {
        NSString *backgroundImageURL = [configDict objectForKey:@"backgroundImageURL"];
        NSLog(@"Mixer Background Image URL: %@", backgroundImageURL);
        [mixerTask setBackgroundImageURL:backgroundImageURL];
    }
    
    [self.manager startMixerTask:mixerTask];
}

#pragma mark IM

- (IBAction)sendBroadcastMessageClick:(UIButton *)sender {
    [self.manager sendBroadcastMessage:self.broadcastMessageTextField.text roomID:self.roomIDTextField.text];
}

- (IBAction)sendCustomCommandClick:(UIButton *)sender {
    [self.manager sendCustomCommand:self.customCommandTextField.text toUserList:nil roomID:self.roomIDTextField.text];
}

#pragma mark RTSD

- (IBAction)createRealTimeSequentialDataManagerClick:(UIButton *)sender {
    [self.manager createRealTimeSequentialDataManager:self.rtsdManagerRoomIDTextField.text];
}

- (IBAction)destroyRealTimeSequentialDataManagerClick:(UIButton *)sender {
    [self.manager destroyRealTimeSequentialDataManager:self.rtsdManagerRoomIDTextField.text];
}

- (IBAction)realTimeSequentialDataStartBroadcastingClick:(UIButton *)sender {
    [self.manager startBroadcasting:self.rtsdBroadcastingStreamIDTextField.text managerRoomID:self.rtsdManagerRoomIDTextField.text];
}

- (IBAction)realTimeSequentialDataStopBroadcastringClick:(UIButton *)sender {
    [self.manager stopBroadcasting:self.rtsdBroadcastingStreamIDTextField.text managerRoomID:self.rtsdManagerRoomIDTextField.text];
}

- (IBAction)sendRealTimeSequentialDataClick:(UIButton *)sender {
    [self.manager sendRealTimeSequentialData:self.rtsdSendDataTextField.text streamID:self.rtsdBroadcastingStreamIDTextField.text managerRoomID:self.rtsdManagerRoomIDTextField.text];
}

- (IBAction)realTimeSequentialDataStartSubscribingClick:(UIButton *)sender {
    [self.manager startSubscribing:self.rtsdSubscribingStreamIDTextField.text managerRoomID:self.rtsdManagerRoomIDTextField.text];
}

- (IBAction)realTimeSequentialDataStopSubscribingClick:(UIButton *)sender {
    [self.manager stopSubscribing:self.rtsdSubscribingStreamIDTextField.text managerRoomID:self.rtsdManagerRoomIDTextField.text];
}

#pragma mark Utils

- (IBAction)startNetworkSpeedTestClick:(UIButton *)sender {
    [self.manager startNetworkSpeedTest];
}

- (IBAction)stopNetworkSpeedTestClick:(UIButton *)sender {
    [self.manager stopNetworkSpeedTest];
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 1) {
        return self.scenarioList.count;
    } else if (pickerView.tag == 2 || pickerView.tag == 3) {
        return self.resolutionList.count;
    } else if (pickerView.tag == 4) {
        return self.audioConfigPresetList.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == 1) {
        return self.scenarioList[row];
    } else if (pickerView.tag == 2 || pickerView.tag == 3) {
        return self.resolutionList[row];
    } else if (pickerView.tag == 4) {
        return self.audioConfigPresetList[row];
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == 1) {
        self.selectedScenario = (ZegoScenario)row;
    } else if (pickerView.tag == 2) {
        self.selectedVideoConfigPreset = (ZegoVideoConfigPreset)row;
    } else if (pickerView.tag == 3) {
        self.selectedMixerVideoConfigPreset = (ZegoVideoConfigPreset)row;
    } else if (pickerView.tag == 4) {
        self.selectedAudioConfigPreset = (ZegoAudioConfigPreset)row;
    }
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (textField == self.appIDTextField) {
//        [self.appSignTextField becomeFirstResponder];
//    } else if (textField == self.roomIDTextField) {
//        [self.userIDTextField becomeFirstResponder];
//    }
//    return YES;
//}


@end

#endif

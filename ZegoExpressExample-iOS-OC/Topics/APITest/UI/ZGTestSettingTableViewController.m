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
NSString* const ZGTestTopicKey_MultiRoomID = @"kMultiRoomID";

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

@property (nonatomic, copy) NSArray<NSString *> *resolutionList;
@property (nonatomic, assign) ZegoVideoConfigPreset selectedVideoConfigPreset;

@property (nonatomic, assign) ZegoVideoConfigPreset selectedMixerVideoConfigPreset;

// Engine
@property (weak, nonatomic) IBOutlet UITextField *appIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *appSignTextField;
@property (weak, nonatomic) IBOutlet UISwitch *testEnvSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scenarioSeg;

@property (weak, nonatomic) IBOutlet UIButton *createEngineButton;
@property (weak, nonatomic) IBOutlet UIButton *destroyEngineButton;
@property (weak, nonatomic) IBOutlet UIButton *getVersionButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadLogButton;
@property (weak, nonatomic) IBOutlet UISwitch *setDebugVerboseSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *setDebugVerboseLanguageSeg;
@property (weak, nonatomic) IBOutlet UIButton *setDebugVerboseButton;

// Room
@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutRoomButton;

// MultiRoom
@property (weak, nonatomic) IBOutlet UITextField *multiRoomIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginMultiRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutMultiRoomButton;


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


@end

@implementation ZGTestSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"ZegoTestJson" ofType:@"json"];
    self.configDict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:jsonPath] options:0 error:nil];
    
    [self setupUI];
}

- (void)setupUI {
    self.resolutionList = @[@"180p", @"270p", @"360p", @"540p", @"720p", @"1080p"];
    self.setVideoConfigResolutionPicker.delegate = self;
    self.setVideoConfigResolutionPicker.dataSource = self;
    self.setVideoConfigResolutionPicker.tag = 2;
    [self pickerView:self.setVideoConfigResolutionPicker didSelectRow:0 inComponent:0];
    
    self.mixerResolutionPicker.delegate = self;
    self.mixerResolutionPicker.dataSource = self;
    self.mixerResolutionPicker.tag = 3;
    [self pickerView:self.mixerResolutionPicker didSelectRow:0 inComponent:0];
    
    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];
    
    self.appIDTextField.text = [NSString stringWithFormat:@"%d", appConfig.appID];
    self.appIDTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.appSignTextField.text = appConfig.appSign;
    
    self.testEnvSwitch.on = appConfig.isTestEnv;
    self.scenarioSeg.selectedSegmentIndex = (int)appConfig.scenario;
    
    self.roomIDTextField.text = [self savedValueForKey:ZGTestTopicKey_RoomID];
    self.userIDTextField.text = [self savedValueForKey:ZGTestTopicKey_UserID];
    self.userNameTextField.text = [self savedValueForKey:ZGTestTopicKey_UserName];
    self.multiRoomIDTextField.text = [self savedValueForKey:ZGTestTopicKey_MultiRoomID];
    
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
    [self.manager createEngineWithAppID:[self.appIDTextField.text intValue] appSign:self.appSignTextField.text isTestEnv:self.testEnvSwitch.on scenario:(ZegoScenario)self.scenarioSeg.selectedSegmentIndex];
}

- (IBAction)destroyEngineClick:(UIButton *)sender {
    [self.manager destroyEngine];
}

- (IBAction)getVersionClick:(UIButton *)sender {
    [self.manager getVersion];
}

- (IBAction)uploadLogClick:(UIButton *)sender {
    [self.manager uploadLog];
}

- (IBAction)setDebugVerboseClick:(UIButton *)sender {
    [self.manager setDebugVerbose:self.setDebugVerboseSwitch.on language:(ZegoLanguage)self.setDebugVerboseLanguageSeg.selectedSegmentIndex];
}

#pragma mark Room

- (IBAction)loginRoomClick:(UIButton *)sender {
    [self.manager loginRoom:self.roomIDTextField.text userID:self.userIDTextField.text userName:self.userNameTextField.text];
    [self saveValue:self.roomIDTextField.text forKey:ZGTestTopicKey_RoomID];
    [self saveValue:self.userIDTextField.text forKey:ZGTestTopicKey_UserID];
    [self saveValue:self.userNameTextField.text forKey:ZGTestTopicKey_UserName];
}

- (IBAction)switchRoomClick:(UIButton *)sender {
    NSString *currentRoomID = [self savedValueForKey:ZGTestTopicKey_RoomID];
    NSString *newRoomID = self.roomIDTextField.text;
    [self.manager switchRoom:currentRoomID toRoomID:newRoomID];
    [self saveValue:newRoomID forKey:ZGTestTopicKey_RoomID];
}

- (IBAction)logoutRoomClick:(UIButton *)sender {
    [self.manager logoutRoom:self.roomIDTextField.text];
}

#pragma mark MultiRoom

- (IBAction)loginMultiRoomClick:(UIButton *)sender {
    [self.manager loginMultiRoom:self.multiRoomIDTextField.text];
    [self saveValue:self.multiRoomIDTextField.text forKey:ZGTestTopicKey_MultiRoomID];
}

- (IBAction)logoutMultiRoomClick:(UIButton *)sender {
    [self.manager logoutRoom:self.multiRoomIDTextField.text];
}

#pragma mark Publisher

- (IBAction)startPublishClick:(UIButton *)sender {
    [self.manager startPublishingStream:self.publishStreamIDTextField.text];
    [self saveValue:self.publishStreamIDTextField.text forKey:ZGTestTopicKey_PublishStreamID];
}

- (IBAction)stopPublishClick:(UIButton *)sender {
    [self.manager stopPublishingStream];
}

- (IBAction)startPreviewClick:(UIButton *)sender {
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:[self.delegate getPublishView]];
    previewCanvas.viewMode = (ZegoViewMode)self.setPreviewViewModeSeg.selectedSegmentIndex;
    previewCanvas.backgroundColor = [[self.previewCanvasBackgroundColorTextField.text substringFromIndex:2] intValue];
    [self.manager startPreview:previewCanvas];
    [self saveValue:self.previewCanvasBackgroundColorTextField.text forKey:ZGTestTopicKey_PreviewBackgroundColor];
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
    [self saveValue:self.setCaptureVolumeTextField.text forKey:ZGTestTopicKey_CaptureVolume];
}
- (IBAction)addCdnUrlClick:(UIButton *)sender {
    [self.manager addPublishCdnUrl:self.CdnUrlTextField.text streamID:self.publishStreamIDTextField.text callback:nil];
    [self saveValue:self.CdnUrlTextField.text forKey:ZGTestTopicKey_CdnUrl];
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
    [self saveValue:self.watermarkFilePathTextField.text forKey:ZGTestTopicKey_WatermarkFilePath];
}

- (IBAction)setCapturePipelineScaleModeClick:(UIButton *)sender {
    [self.manager setCapturePipelineScaleMode:(ZegoCapturePipelineScaleMode)self.setCapturePipelineScaleModeSeg.selectedSegmentIndex];
}

- (IBAction)sendSEIButtonClick:(UIButton *)sender {
    char *str = "1234567\0";
//    [self.manager sendSEI:[self.sendSEITextField.text dataUsingEncoding:NSUTF8StringEncoding]];
    [self.manager sendSEI:[NSData dataWithBytes:str length:7 ]];
}

#pragma mark Player

- (IBAction)startPlayClick:(UIButton *)sender {
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:[self.delegate getPlayView]];
    playCanvas.viewMode = (ZegoViewMode)self.setPlayViewModeSeg.selectedSegmentIndex;
    playCanvas.backgroundColor = [[self.playCanvasBackgroundColorTextField.text substringFromIndex:2] intValue];
    [self.manager startPlayingStream:self.playStreamIDTextField.text canvas:playCanvas];
    [self saveValue:self.playStreamIDTextField.text forKey:ZGTestTopicKey_PlayStreamID];
    [self saveValue:self.playCanvasBackgroundColorTextField.text forKey:ZGTestTopicKey_PlayBackgroundColor];
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
    [self saveValue:self.setPlayVolumeTextField.text forKey:ZGTestTopicKey_PlayVolume];
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
    [self saveValue:self.enableBeautifyTextField.text forKey:ZGTestTopicKey_BeautifyFeature];
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
    
    [self saveValue:self.mixerTaskIDTextField.text forKey:ZGTestTopicKey_MixerTaskID];
    [self saveValue:self.mixerInputFirstStreamIDTextField.text forKey:ZGTestTopicKey_MixerInputFirstStreamIDs];
    [self saveValue:self.mixerInputSecondStreamIDTextField.text forKey:ZGTestTopicKey_MixerInputSecondStreamIDs];
    [self saveValue:self.mixerOutputTargetsTextField.text forKey:ZGTestTopicKey_MixerOutputTargets];
}

- (IBAction)stopMixerTaskClick:(UIButton *)sender {
    [self.manager stopMixerTask:self.mixerTaskIDTextField.text];
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


#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 2 || pickerView.tag == 3) {
        return self.resolutionList.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == 2 || pickerView.tag == 3) {
        return self.resolutionList[row];
    }
    return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == 2) {
        if (row == 0) {
            self.selectedVideoConfigPreset = ZegoVideoConfigPreset180P;
        } else if (row == 1) {
            self.selectedVideoConfigPreset = ZegoVideoConfigPreset270P;
        } else if (row == 2) {
            self.selectedVideoConfigPreset = ZegoVideoConfigPreset360P;
        } else if (row == 3) {
            self.selectedVideoConfigPreset = ZegoVideoConfigPreset540P;
        } else if (row == 4) {
            self.selectedVideoConfigPreset = ZegoVideoConfigPreset720P;
        } else {
            self.selectedVideoConfigPreset = ZegoVideoConfigPreset1080P;
        }
    } else if (pickerView.tag == 3) {
        if (row == 0) {
            self.selectedMixerVideoConfigPreset = ZegoVideoConfigPreset180P;
        } else if (row == 1) {
            self.selectedMixerVideoConfigPreset = ZegoVideoConfigPreset270P;
        } else if (row == 2) {
            self.selectedMixerVideoConfigPreset = ZegoVideoConfigPreset360P;
        } else if (row == 3) {
            self.selectedMixerVideoConfigPreset = ZegoVideoConfigPreset540P;
        } else if (row == 4) {
            self.selectedMixerVideoConfigPreset = ZegoVideoConfigPreset720P;
        } else {
            self.selectedMixerVideoConfigPreset = ZegoVideoConfigPreset1080P;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.appIDTextField) {
        [self.appSignTextField becomeFirstResponder];
    } else if (textField == self.roomIDTextField) {
        [self.userIDTextField becomeFirstResponder];
    }
    return YES;
}


@end

#endif

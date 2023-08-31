//
//  ZGMediaPlayerViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/25.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGMediaPlayerViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"

#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGMediaPlayerViewController ()<ZegoEventHandler, ZegoMediaPlayerEventHandler, ZegoMediaPlayerVideoHandler, ZegoMediaPlayerAudioHandler, UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) ZegoMediaPlayer *mediaPlayer;

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, assign) ZegoPublisherState publisherState;

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

// PublishStream
// Preview View
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;

@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;

@property (weak, nonatomic) IBOutlet UILabel *playStreamLabel;

@property (weak, nonatomic) IBOutlet UIView *remotePlayView;
@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;


@property (weak, nonatomic) IBOutlet UIView *mediaPlayerView;
@property (weak, nonatomic) IBOutlet UIView *mediaPlayerParentView;
@property (weak, nonatomic) IBOutlet UILabel *currentProcessLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDurationLabel;
@property (weak, nonatomic) IBOutlet UISlider *processSlider;
@property (weak, nonatomic) IBOutlet UISwitch *enableRepeatSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableAuxSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *muteLocalSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *audioTrackSeg;

@property (weak, nonatomic) IBOutlet UISlider *playVolumeSlider;
@property (weak, nonatomic) IBOutlet UISlider *publishVolumeSlider;
@property (weak, nonatomic) IBOutlet UILabel *pitchValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;
@property (weak, nonatomic) IBOutlet UILabel *speedValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *speedSlider;

@property (weak, nonatomic) IBOutlet UITextField *encodeResolutionWidthTextField;
@property (weak, nonatomic) IBOutlet UITextField *encodeResolutionHeightTextField;

@property (weak, nonatomic) IBOutlet UITextField *captureResolutionWidthTextField;
@property (weak, nonatomic) IBOutlet UITextField *captureResolutionHeightTextField;
@property (weak, nonatomic) IBOutlet UISwitch *hardwareDecoder;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@end

@implementation ZGMediaPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MediaPlayer";

    self.roomID = @"0027";
    self.playStreamIDTextField.text = @"0027";
    self.publishStreamIDTextField.text = @"0027";
    
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)
    
    ZegoEngineConfig *config = [[ZegoEngineConfig alloc]init];
    if(self.mediaPlayerHardwareDecode){
        config.advancedConfig = @{@"mediaplayer_hardware_decode": @"true"};
    }else{
        config.advancedConfig = @{@"mediaplayer_hardware_decode": @"false"};
    }
    [ZegoExpressEngine setEngineConfig:config];

    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    
    // Here we use the high quality video call scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    profile.scenario = ZegoScenarioHighQualityVideoCall;
    
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
    
    [[ZegoExpressEngine sharedEngine] loginRoom:_roomID user:[ZegoUser userWithUserID:[ZGUserIDHelper userID]]];
    
    ZGLogInfo(@"🚪 Login room. roomID: %@", _roomID);
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
}

- (void)createMediaPlayer {
    if(self.mediaPlayer){
        ZGLogInfo(@"Media player exist,ignore.");
        return;
    }
    //设置解决断网不连续播放的问题
    ZegoEngineConfig *engineConfig = [[ZegoEngineConfig alloc] init];
    engineConfig.advancedConfig = @{@"mediaplay_cache_netsource": @"false"};
    [ZegoExpressEngine setEngineConfig:engineConfig];
    self.mediaPlayer = [[ZegoExpressEngine sharedEngine] createMediaPlayer];
    if (self.mediaPlayer) {
        ZGLogInfo(@"💽 Create ZegoMediaPlayer");
    } else {
        ZGLogWarn(@"💽 ❌ Create ZegoMediaPlayer failed");
        return;
    }
    
//    [self.mediaPlayer loadResource:self.mediaItem.fileURL callback:^(int errorCode) {
//        ZGLogInfo(@"🚩 💽 Media Player load resource. errorCode: %d", errorCode);
//        [self setupMediaPlayerUI];
//    }];
    
    ZegoMediaPlayerResource *resource = [[ZegoMediaPlayerResource alloc]init];
    resource.loadType = ZegoMultimediaLoadTypeFilePath;
    resource.filePath = self.mediaItem.fileURL;
    resource.alphaLayout = self.alphaLayout;
    [self.mediaPlayer loadResourceWithConfig:resource callback:^(int errorCode) {
        ZGLogInfo(@"🚩 💽 Media Player load resource. errorCode: %d", errorCode);
        [self setupMediaPlayerUI];
    }];
    
    // set media player event handler
    [self.mediaPlayer setEventHandler:self];
    
    // enable audio frame callback
    [self.mediaPlayer setAudioHandler:self];
    
    // enable video frame callback
    [self.mediaPlayer setVideoHandler:self format:ZegoVideoFrameFormatNV12 type:ZegoVideoBufferTypeCVPixelBuffer];
    
    [self.mediaPlayer enableAux:YES];
    
    [self.mediaPlayer enableRepeat:YES];
    
    [self.mediaPlayer muteLocal:NO];
}

- (void)setupMediaPlayerUI {

    self.totalDurationLabel.text = [NSString stringWithFormat:@"%02llu:%02llu", self.mediaPlayer.totalDuration / 1000 / 60, (self.mediaPlayer.totalDuration / 1000) % 60];
    
    self.processSlider.maximumValue = self.mediaPlayer.totalDuration;
    self.processSlider.minimumValue = 0.0;
    self.processSlider.value = self.mediaPlayer.currentProgress;
    self.processSlider.continuous = NO;
 
    [self.processSlider addTarget:self action:@selector(processSliderTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.processSlider addTarget:self action:@selector(processSliderTouchUp) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    
    self.playVolumeSlider.maximumValue = 200.0;
    self.playVolumeSlider.minimumValue = 0.0;
    self.playVolumeSlider.value = self.mediaPlayer.playVolume;
    self.playVolumeSlider.continuous = NO;

    self.publishVolumeSlider.maximumValue = 200.0;
    self.publishVolumeSlider.minimumValue = 0.0;
    self.publishVolumeSlider.value = self.mediaPlayer.publishVolume;
    self.publishVolumeSlider.continuous = NO;
    
    self.enableRepeatSwitch.on = YES;
    self.enableAuxSwitch.on = YES;
    self.muteLocalSwitch.on = NO;

    [self.audioTrackSeg removeAllSegments];
    unsigned int trackCount = self.mediaPlayer.audioTrackCount;
    if (trackCount > 0) {
        for (int i = 0; i < trackCount; i++) {
            [self.audioTrackSeg insertSegmentWithTitle:[NSString stringWithFormat:@"%d", i] atIndex:i animated:NO];
        }
    } else {
        [self.audioTrackSeg insertSegmentWithTitle:@"None" atIndex:0 animated:NO];
    }

    self.pitchSlider.continuous = NO;
    self.speedSlider.continuous = NO;
    
    if (self.mediaItem.isVideo) {
        ZegoCanvas *canvas = [ZegoCanvas canvasWithView:self.mediaPlayerView];
        canvas.alphaBlend = self.alphaBlend;
        [self.mediaPlayer setPlayerCanvas:canvas];
        
        if(self.alphaBlend){
            [self.mediaPlayerView setBackgroundColor:UIColor.clearColor];
        }
    } else {
        [self.mediaPlayerView addSubview:({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.mediaPlayerView.frame.size.width, 50)];
            label.text = @"Audio";
            label.font = [UIFont boldSystemFontOfSize:20];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        })];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.isBeingDismissed || self.isMovingFromParentViewController
        || (self.navigationController && self.navigationController.isBeingDismissed)) {
        ZGLogInfo(@"🏳️ Destroy ZegoMediaPlayer");
        
        if (self.mediaPlayer != nil)
            [[ZegoExpressEngine sharedEngine] destroyMediaPlayer:self.mediaPlayer];
        
        ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
        [ZegoExpressEngine destroyEngine:nil];
    }
    [super viewDidDisappear:animated];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark Publisher Actions

- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    [self.view endEditing:YES];
    if (sender.isSelected) {
        // Stop publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.publishStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
    } else {
        ZegoVideoConfig *videoConfig = [ZegoVideoConfig defaultConfig];
        
        videoConfig.captureResolution = CGSizeMake(self.captureResolutionWidthTextField.text.intValue, self.captureResolutionHeightTextField.text.intValue);
        videoConfig.encodeResolution = CGSizeMake(self.encodeResolutionWidthTextField.text.intValue, self.encodeResolutionHeightTextField.text.intValue);

        [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];

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
#pragma mark Player Actions
- (IBAction)onStartPlayingButtonTappd:(UIButton *)sender {
    [self.view endEditing:YES];
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

#pragma mark Media Player Actions

- (IBAction)playButtonClick:(UIButton *)sender {
    [self.mediaPlayer start];
    ZGLogInfo(@"▶️ Media Player start");
}

- (IBAction)pauseButtonClick:(UIButton *)sender {
    [self.mediaPlayer pause];
    ZGLogInfo(@"⏸ Media Player pause");
}

- (IBAction)resumeButtonClick:(UIButton *)sender {
    [self.mediaPlayer resume];
    ZGLogInfo(@"⏯ Media Player resume");
}

- (IBAction)stopButtonClick:(UIButton *)sender {
    [self.mediaPlayer stop];
    ZGLogInfo(@"⏹ Media Player stop");
}

- (IBAction)enableRepeatSwitchAction:(UISwitch *)sender {
    [self.mediaPlayer enableRepeat:sender.on];
    ZGLogInfo(@"%@ Media Player enable repeat: %@", sender.on ? @"🔂" : @"↩️", sender.on ? @"YES" : @"NO");
}

- (IBAction)enableAuxSwitchAction:(UISwitch *)sender {
    [self.mediaPlayer enableAux:sender.on];
    ZGLogInfo(@"⏺ Media Player enable aux: %@", sender.on ? @"YES" : @"NO");
}

- (IBAction)muteLocalSwitchAction:(UISwitch *)sender {
    [self.mediaPlayer muteLocal:sender.on];
    ZGLogInfo(@"%@ Media Player mute local: %@", sender.on ? @"🔇" : @"🔈", sender.on ? @"YES" : @"NO");
}

- (IBAction)audioTrackSegValueChanged:(UISegmentedControl *)sender {
    unsigned int index = (unsigned int)self.audioTrackSeg.selectedSegmentIndex;
    [self.mediaPlayer setAudioTrackIndex:index];
    ZGLogInfo(@"🎵 Media Player set audio track index: %d", index);
}
- (IBAction)onMediaHardwareDecodeChanged:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine]enableHardwareDecoder:sender.isOn];
    ZGLogInfo(@"enableHardwareDecoder: %d", (int)sender.isOn);
}

#pragma mark Media Player Slider Actions

- (IBAction)playVolumeSliderValueChanged:(UISlider *)sender {
    [self.mediaPlayer setPlayVolume:(int)sender.value];
    ZGLogInfo(@"🔊 Media Player set play volume: %d", (int)sender.value);
}

- (IBAction)publishVolumeSliderValueChanged:(UISlider *)sender {
    [self.mediaPlayer setPublishVolume:(int)sender.value];
    ZGLogInfo(@"🔊 Media Player set publish volume: %d", (int)sender.value);
}

- (IBAction)processSliderValueChanged:(UISlider *)sender {
    [self.mediaPlayer seekTo:(unsigned long long)sender.value callback:^(int errorCode) {
        ZGLogInfo(@"🚩 🔍 Media Player seek to callback. errorCode: %d", errorCode);
    }];
    ZGLogInfo(@"🔍 Media Player seek to: %llu", (unsigned long long)sender.value);
}

- (void)processSliderTouchDown {
    [self.mediaPlayer pause];
}

- (void)processSliderTouchUp {
    [self.mediaPlayer resume];
}

- (IBAction)pitchSliderValueChanged:(UISlider *)sender {
    ZegoVoiceChangerParam *param = [[ZegoVoiceChangerParam alloc] init];
    param.pitch = self.pitchSlider.value;
    [self.mediaPlayer setVoiceChangerParam:param audioChannel:ZegoMediaPlayerAudioChannelAll];
    self.pitchValueLabel.text = [NSString stringWithFormat:@"Pitch: %.2f", param.pitch];
    ZGLogInfo(@"🗣 Media Player set voice changer pitch: %.2f", param.pitch);
}
- (IBAction)speedSliderValueChanged:(id)sender {
    float speed = self.speedSlider.value;
    [self.mediaPlayer setPlaySpeed:speed];
    self.speedValueLabel.text = [NSString stringWithFormat:@"Speed: %.2f", speed];
    ZGLogInfo(@"🗣 Media Player set play speed: %.2f", speed);
}

- (IBAction)onSelectBackgroundButtonTapped:(UIButton *)sender {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    
    if(selectedImage){
        //show background
        [self.mediaPlayerParentView setBackgroundColor:[UIColor colorWithPatternImage:selectedImage]];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Publisher Event

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📤 Publisher State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
    
    _publisherState = state;
    
    switch (state) {
        case ZegoPublisherStateNoPublish:
            [self.startPublishingButton setTitle:@"StartPublish" forState:UIControlStateNormal];
            break;
        case ZegoPublisherStatePublishing: case ZegoPublisherStatePublishRequesting:
            [self.startPublishingButton setTitle:@"StopPublish" forState:UIControlStateNormal];
            break;
    }
}

-(void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID{
    if(reason == ZegoRoomStateChangedReasonLogined){
        [self createMediaPlayer];
    }
}


#pragma mark - Media Player Event Handler

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer stateUpdate:(ZegoMediaPlayerState)state errorCode:(int)errorCode {
    ZGLogInfo(@"🚩 📻 Media Player State Update: %d, errorCode: %d", (int)state, errorCode);
    switch (state) {
        case ZegoMediaPlayerStateNoPlay:
            // Stop
            break;
        case ZegoMediaPlayerStatePlaying:
            // Playing
            break;
        case ZegoMediaPlayerStatePausing:
            // Pausing
            break;
        case ZegoMediaPlayerStatePlayEnded:
            // Play ended, developer can play next song, etc.
            break;
    }
}

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer networkEvent:(ZegoMediaPlayerNetworkEvent)networkEvent {
    ZGLogInfo(@"🚩 ⏳ Media Player Network Event: %d", (int)networkEvent);
    if (networkEvent == ZegoMediaPlayerNetworkEventBufferBegin) {
        // Show loading UI, etc.
    } else if (networkEvent == ZegoMediaPlayerNetworkEventBufferEnded) {
        // End loading UI, etc.
    }
}

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer playingProgress:(unsigned long long)millisecond {
    // Update progress bar, etc.
    self.currentProcessLabel.text = [NSString stringWithFormat:@"%02llu:%02llu", millisecond / 1000 / 60, (millisecond / 1000) % 60];
    [self.processSlider setValue:millisecond animated:YES];
}

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer firstFrameEvent:(ZegoMediaPlayerFirstFrameEvent)event {
    ZGLogInfo(@"🚩 ⏳ Media Player First Frame Event: %d", (int)event);
}

#pragma mark - Media Player Audio Handler

/// @note Need to switch threads before processing audio frames
- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer audioFrameData:(unsigned char *)data dataLength:(unsigned int)dataLength param:(ZegoAudioFrameParam *)param {
//    NSLog(@"audio frame callback. bufferLength:%d, sampleRate:%d, channels:%d", param.bufferLength, param.sampleRate, param.channels);
}

#pragma mark - Media Player Video Handler

/// When video frame type is set to `ZegoVideoFrameTypeCVPixelBuffer`, video frame CVPixelBuffer data will be called back from this function
/// @note Need to switch threads before processing video frames
- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer videoFramePixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param {
//    NSLog(@"pixel buffer video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);
}

/// When video frame type is set to `ZegoVideoFrameTypeRawdata`, video frame raw data will be called back from this function
/// @note Need to switch threads before processing video frames
- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer videoFrameRawData:(const unsigned char * _Nonnull *)data dataLength:(unsigned int *)dataLength param:(ZegoVideoFrameParam *)param {
//    NSLog(@"raw data video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);
}

#pragma mark - Tool

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

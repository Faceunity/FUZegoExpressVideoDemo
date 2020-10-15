//
//  ZGCustomAudioIOViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_CustomAudioIO

#import "ZGCustomAudioIOViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"
#import "ZGAudioToolPlayer.h"
#import "ZGAudioToolRecorder.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGCustomAudioIOViewController () <ZegoEventHandler>

@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UIView *remotePlayView;

@property (nonatomic, assign) ZegoPublisherState publisherState;
@property (weak, nonatomic) IBOutlet UIButton *startPublishButton;

@property (nonatomic, assign) ZegoPlayerState playerState;
@property (weak, nonatomic) IBOutlet UIButton *startPlayButton;

@property (strong, nonatomic) NSTimer *audioCaptureTimer;

@property (nonatomic, strong) ZegoAudioFrameParam *audioCapturedFrameParam;
@property (nonatomic, strong) ZegoAudioFrameParam *audioRenderFrameParam;

// Audio data to be sent
@property (nonatomic, strong) NSData *audioCapturedData;
// Audio origin data position
@property (nonatomic, assign) void *audioCapturedDataPosition;

@property (nonatomic, strong) NSInputStream *inputStream;

@end

@implementation ZGCustomAudioIOViewController
{
    ZGAudioToolPlayer *_audioToolPlayer;
    ZGAudioToolRecorder *_audioToolRecorder;
}

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomAudioIO" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGCustomAudioIOViewController class])];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.audioRenderFrameParam = [[ZegoAudioFrameParam alloc] init];
    self.audioRenderFrameParam.channel = 1;
    self.audioRenderFrameParam.sampleRate = ZegoAudioSampleRate16K;
    
    self.audioCapturedFrameParam = [[ZegoAudioFrameParam alloc] init];
    self.audioCapturedFrameParam.channel = 1;
    self.audioCapturedFrameParam.sampleRate = ZegoAudioSampleRate16K;
    
    [self createEngineAndLoginRoom];
}

- (void)viewDidDisappear:(BOOL)animated {
    if ([self.audioCaptureTimer isValid]) {
        ZGLogInfo(@"⏱ Audio capture timer invalidate");
        [self.audioCaptureTimer invalidate];
    }
    self.audioCaptureTimer = nil;

    ZGLogInfo(@"🚪 Logout room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)dealloc {
    ZGLogInfo(@"🔴 %s dealloc", __FILE__);
}

- (void)createEngineAndLoginRoom {
    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];

    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    [ZegoExpressEngine createEngineWithAppID:appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];


    ZegoCustomAudioConfig *audioConfig = [[ZegoCustomAudioConfig alloc] init];
    audioConfig.sourceType = ZegoAudioSourceTypeCustom;

    ZGLogInfo(@"🎶 Enable custom audio io");
    [[ZegoExpressEngine sharedEngine] enableCustomAudioIO:YES config:audioConfig];

    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];

    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user config:[ZegoRoomConfig defaultConfig]];
}


- (IBAction)startPublishButtonClick:(UIButton *)sender {
    if (self.publisherState == ZegoPublisherStatePublishing) {
        [self stopPublishing];
    } else if (self.publisherState == ZegoPublisherStateNoPublish) {
//        [self startPublishing];
        [self startRecording];
    }
}

- (IBAction)startPlayButtonClick:(UIButton *)sender {
    if (self.playerState == ZegoPlayerStatePlaying) {
        [self stopPlaying:NO];
    } else if (self.playerState == ZegoPlayerStateNoPlay) {
        [self startPlaying:NO];
    }
}

- (void)startRecording {
    ZGLogInfo(@"🔌 Start preview");
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];

    ZGLogInfo(@"📤 Start publishing stream. streamID: %@", self.localPublishStreamID);
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.localPublishStreamID];

    if (!_audioToolRecorder) {
        _audioToolRecorder = [[ZGAudioToolRecorder alloc] initWithSampleRate:ZegoAudioSampleRate16K bufferSize:[self bufferSize]];
        __weak ZGCustomAudioIOViewController *weakSelf = self;
        _audioToolRecorder.bl_output = ^(ZGAudioToolRecorder *recorder,
                                         AudioUnitRenderActionFlags *ioActionFlags,
                                         const AudioTimeStamp *inTimeStamp,
                                         UInt32 inBusNumber,
                                         UInt32 inNumberFrames,
                                         AudioBufferList *bufferList) {
            AudioBuffer buffer = bufferList->mBuffers[0];
            unsigned int length = (unsigned int)buffer.mDataByteSize;
            [[ZegoExpressEngine sharedEngine] sendCustomAudioCapturePCMData:buffer.mData dataLength:length param:weakSelf.audioCapturedFrameParam];

        };
    }

    [_audioToolRecorder start];
}

- (void)startPublishing {

    ZGLogInfo(@"🔌 Start preview");
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];

    ZGLogInfo(@"📤 Start publishing stream. streamID: %@", self.localPublishStreamID);
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.localPublishStreamID];

    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"test" withExtension:@"wav"];
    NSInputStream *inputSteam = [NSInputStream inputStreamWithURL:url];
    self.inputStream = inputSteam;
    [inputSteam open];
    

    // Start a timer that triggers every 20ms to send audio data
    self.audioCaptureTimer = [NSTimer timerWithTimeInterval:0.02 target:self selector:@selector(sendCapturedAudioFrame) userInfo:nil repeats:YES];
    [NSRunLoop.mainRunLoop addTimer:self.audioCaptureTimer forMode:NSRunLoopCommonModes];
    ZGLogInfo(@"⏱ Audio capture timer fire 🚀");
    [self.audioCaptureTimer fire];
}

- (void)stopPublishing {

    if (self.audioCaptureTimer) {
        ZGLogInfo(@"⏱ Audio capture timer invalidate");
        [self.audioCaptureTimer invalidate];
        self.audioCaptureTimer = nil;
    }

    ZGLogInfo(@"🔌 Stop preview");
    [[ZegoExpressEngine sharedEngine] stopPreview];

    ZGLogInfo(@"📤 Stop publishing stream");
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    
    [self.inputStream close];
    self.inputStream = nil;

    [_audioToolRecorder stop];
}

- (void)startPlaying:(BOOL)saveToFile {

    ZGLogInfo(@"📥 Start playing stream, streamID: %@", self.remotePlayStreamID);
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.remotePlayStreamID canvas:playCanvas];

    if (!_audioToolPlayer) {
        _audioToolPlayer = [[ZGAudioToolPlayer alloc] initWithSampleRate:ZegoAudioSampleRate16K bufferSize:[self bufferSize]];
        __weak ZGCustomAudioIOViewController *weakSelf = self;
        _audioToolPlayer.bl_input = ^(ZGAudioToolPlayer *player,
                                      AudioUnitRenderActionFlags *ioActionFlags,
                                      const AudioTimeStamp *inTimeStamp,
                                      UInt32 inBusNumber,
                                      UInt32 inNumberFrames,
                                      AudioBufferList *bufferList) {

            AudioBuffer buffer = bufferList->mBuffers[0];
            unsigned int length = (unsigned int)buffer.mDataByteSize;

            // Fetch and render audio render buffer
            [[ZegoExpressEngine sharedEngine] fetchCustomAudioRenderPCMData:buffer.mData dataLength:length param:weakSelf.audioRenderFrameParam];
            buffer.mDataByteSize = length;
        };
    }

    [_audioToolPlayer play];
}

- (void)stopPlaying:(BOOL)saveToFile {

    ZGLogInfo(@"📥 Stop playing stream");
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.remotePlayStreamID];
    
    [_audioToolPlayer stop];
}


#pragma mark - Custom Audio IO

// Will be called by the NSTimer every 20ms
- (void)sendCapturedAudioFrame {

    uint8_t *audioCapturedDataPosition = (uint8_t *)malloc([self bufferSize]);
    NSInteger length = [self.inputStream read:audioCapturedDataPosition maxLength:[self bufferSize]];
    [[ZegoExpressEngine sharedEngine] sendCustomAudioCapturePCMData:audioCapturedDataPosition dataLength:(unsigned int)length param:_audioCapturedFrameParam];
    
}

- (unsigned int)bufferSize {
    float duration = 0.02; // 20ms
    int sampleRate = ZegoAudioSampleRate16K;
    int audioChannels = 1;
    int bytesPerSample = 2;

    unsigned int expectedDataLength = (unsigned int)(duration * sampleRate * audioChannels * bytesPerSample);
    return expectedDataLength;
}

#pragma mark - ZegoEventHandler

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        ZGLogError(@"🚩 ❌ 📤 Publishing stream error of streamID: %@, errorCode:%d", streamID, errorCode);
    } else {
        switch (state) {
            case ZegoPublisherStatePublishing:
                ZGLogInfo(@"🚩 📤 Publishing stream");
                [self.startPublishButton setTitle:@"Stop Publish" forState:UIControlStateNormal];
                break;

            case ZegoPublisherStatePublishRequesting:
                ZGLogInfo(@"🚩 📤 Requesting publish stream");
                [self.startPublishButton setTitle:@"Requesting" forState:UIControlStateNormal];
                break;

            case ZegoPublisherStateNoPublish:
                ZGLogInfo(@"🚩 📤 No publish stream");
                [self.startPublishButton setTitle:@"Start Publish" forState:UIControlStateNormal];
                break;
        }
    }
    self.publisherState = state;
}

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        ZGLogError(@"🚩 ❌ 📥 Playing stream error of streamID: %@, errorCode:%d", streamID, errorCode);
    } else {
        switch (state) {
            case ZegoPlayerStatePlaying:
                ZGLogInfo(@"🚩 📥 Playing stream");
                [self.startPlayButton setTitle:@"Stop Play" forState:UIControlStateNormal];
                break;

            case ZegoPlayerStatePlayRequesting:
                ZGLogInfo(@"🚩 📥 Requesting play stream");
                [self.startPlayButton setTitle:@"Requesting" forState:UIControlStateNormal];
                break;

            case ZegoPlayerStateNoPlay:
                ZGLogInfo(@"🚩 📥 No play stream");
                [self.startPlayButton setTitle:@"Start Play" forState:UIControlStateNormal];
                break;
        }
    }
    self.playerState = state;
}


@end

#endif

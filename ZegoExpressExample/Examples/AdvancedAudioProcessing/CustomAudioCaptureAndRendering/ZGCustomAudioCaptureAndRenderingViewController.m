//
//  ZGCustomAudioCaptureAndRenderingViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGCustomAudioCaptureAndRenderingViewController.h"
#import "KeyCenter.h"
#import "ZGAudioQueuePlayer.h"
#import "ZGAudioQueueRecorder.h"
#import "ZGAudioCommonTool.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import <AVFoundation/AVFoundation.h>

@interface ZGCustomAudioCaptureAndRenderingViewController () <ZegoEventHandler>

@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UIView *remotePlayView;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UITextField *localPublishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *remotePlayStreamIDTextField;

@property (nonatomic, assign) ZegoPublisherState publisherState;
@property (weak, nonatomic) IBOutlet UIButton *startPublishButton;

@property (nonatomic, assign) ZegoPlayerState playerState;
@property (weak, nonatomic) IBOutlet UIButton *startPlayButton;

@property (nonatomic, strong) ZegoAudioFrameParam *audioFrameParam;

@property (nonatomic, strong) ZGAudioQueueRecorder *audioQueueRecorder;
@property (nonatomic, strong) ZGAudioQueuePlayer *audioQueuePlayer;

@property (nonatomic, assign) BOOL haveSentAACAudioSpecificConfig;

@property (nonatomic, strong) NSMutableData *audioRecorderDataToBeSaved;
@property (nonatomic, strong) NSMutableData *audioPlayerDataToBeSaved;

@property (atomic, assign) UInt32 captureBufferCount;
@property (atomic, assign) UInt64 captureBufferLength;
@property (atomic, assign) UInt32 renderBufferCount;
@property (atomic, assign) UInt64 renderBufferLength;
@property (atomic, assign) Float32 captureTimestampInMs;
@property (atomic, assign) Float32 captureDurationInMs;
@property (atomic, assign) Float32 renderTimestampInMs;
@property (atomic, assign) Float32 renderDurationInMs;
@property (atomic, strong) NSDate *renderStartDate;

@property (weak, nonatomic) IBOutlet UILabel *captureFormatLabel;
@property (weak, nonatomic) IBOutlet UILabel *captureSampleRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *captureBufferCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *captureBufferLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *captureTimestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *captureDurationLabel;
@property (weak, nonatomic) IBOutlet UILabel *renderFormatLabel;
@property (weak, nonatomic) IBOutlet UILabel *renderSampleRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *renderBufferCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *renderBufferLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *renderTimestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *renderDurationLabel;

@end

@implementation ZGCustomAudioCaptureAndRenderingViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomAudioIO" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGCustomAudioCaptureAndRenderingViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
     
    self.haveSentAACAudioSpecificConfig = NO;
    
    self.audioRecorderDataToBeSaved = [NSMutableData data];
    self.audioPlayerDataToBeSaved = [NSMutableData data];
    
    self.audioFrameParam = [[ZegoAudioFrameParam alloc] init];
    self.audioFrameParam.channel = 1;
    self.audioFrameParam.sampleRate = (ZegoAudioSampleRate)self.sampleRate;
    
    [self setupAudioQueue];
    
    [self createEngineAndLoginRoom];
}

- (void)setupUI {
    self.localPublishStreamIDTextField.text = @"0022";
    self.remotePlayStreamIDTextField.text = @"0022";
    
    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];
    
    switch (self.captureFormat) {
        case ZGAudioCaptureFormatPCM:
            self.captureFormatLabel.text = @"Format: PCM";
            break;
        case ZGAudioCaptureFormatAAC:
            self.captureFormatLabel.text = @"Format: AAC";
            break;
    }
    self.renderFormatLabel.text = @"Format: PCM";
    self.captureSampleRateLabel.text = [NSString stringWithFormat:@"SampleRate: %d Hz", (int)self.sampleRate];
    self.renderSampleRateLabel.text = [NSString stringWithFormat:@"SampleRate: %d Hz", (int)self.sampleRate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopPlaying];
    [self stopPublishing];
    
    ZGLogInfo(@"🚪 Logout room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)setupAudioQueue {
    __weak typeof(self) weakSelf = self;
    self.audioQueuePlayer = [[ZGAudioQueuePlayer alloc] initWithSampleRate:self.sampleRate];
    self.audioQueuePlayer.dataCallback = ^(NSData *buffer) {
        if (!weakSelf) {
            return;
        }
        [weakSelf fetchCustomAudioRenderPCMData:buffer];
        
        if (weakSelf.saveAudioDataToDocuments) {
            [weakSelf.audioPlayerDataToBeSaved appendData:buffer];
        }
        
        Float32 currentTimestampInMs = [[NSDate date] timeIntervalSinceDate:weakSelf.renderStartDate] * 1000;
        weakSelf.renderBufferCount += 1;
        weakSelf.renderBufferLength = buffer.length;
        weakSelf.renderDurationInMs = currentTimestampInMs - weakSelf.renderTimestampInMs;
        weakSelf.renderTimestampInMs = currentTimestampInMs;
        [weakSelf updateRenderStatusUI];
    };
    
    self.audioQueueRecorder = [[ZGAudioQueueRecorder alloc] initWithSampleRate:self.sampleRate format:self.captureFormat];
    self.audioQueueRecorder.dataCallback = ^(NSData *buffer, CMTime timestamp) {
        if (!weakSelf) {
            return;
        }
        if (weakSelf.captureFormat == ZGAudioCaptureFormatPCM) {
            [weakSelf sendCustomAudioCapturePCMData:buffer];
            
            if (weakSelf.saveAudioDataToDocuments) {
                [weakSelf.audioRecorderDataToBeSaved appendData:buffer];
            }

        } else if (weakSelf.captureFormat == ZGAudioCaptureFormatAAC) {
            [weakSelf sendCustomAudioCaptureAACData:buffer timestamp:timestamp];

            if (weakSelf.saveAudioDataToDocuments) {
                NSData *adts = [ZGAudioCommonTool generateAacAdtsDataForSampleRate:weakSelf.sampleRate aacBufferSize:buffer.length];
                NSMutableData *aacBuffer = [[NSMutableData alloc] initWithData:adts];
                [aacBuffer appendData:buffer];
                [weakSelf.audioRecorderDataToBeSaved appendData:aacBuffer];
            }
        }
        
        Float32 currentTimestampInMs = (double)timestamp.value / timestamp.timescale * 1000;
        weakSelf.captureBufferCount += 1;
        weakSelf.captureBufferLength = buffer.length;
        weakSelf.captureDurationInMs = currentTimestampInMs - weakSelf.captureTimestampInMs;
        weakSelf.captureTimestampInMs = currentTimestampInMs;
        [weakSelf updateCaptureStatusUI];
    };
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
    
    [self appendLog:@"🎶 Enable custom audio io"];
    ZegoCustomAudioConfig *audioConfig = [[ZegoCustomAudioConfig alloc] init];
    audioConfig.sourceType = ZegoAudioSourceTypeCustom;
    [[ZegoExpressEngine sharedEngine] enableCustomAudioIO:YES config:audioConfig];
    
    // Enable 3A audio process
    [[ZegoExpressEngine sharedEngine] enableAEC:YES];
    [[ZegoExpressEngine sharedEngine] enableAGC:YES];
    [[ZegoExpressEngine sharedEngine] enableANS:YES];
    
    [self appendLog:[NSString stringWithFormat:@"🚪 Login room. roomID: %@", self.roomID]];
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID]
                                     userName:[ZGUserIDHelper userName]];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user];
}

- (IBAction)startPublishButtonClick:(UIButton *)sender {
    if (self.publisherState == ZegoPublisherStatePublishing) {
        [self stopPublishing];
    } else if (self.publisherState == ZegoPublisherStateNoPublish) {
        [self startPublishing];
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
    [self appendLog:@"🔌 Start preview"];
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
    
    [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.localPublishStreamIDTextField.text]];
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.localPublishStreamIDTextField.text];
    
    self.haveSentAACAudioSpecificConfig = NO;
    
    self.captureBufferCount = 0;
    [self appendLog:@"🎙 Custom audio capture microphone start record"];
    BOOL result = [self.audioQueueRecorder startRecording];
    if (!result) {
        [self appendLog:@"❌ 🎙 Start AQ recording failed!"];
    }
}

- (void)stopPublishing {
    [self appendLog:@"🎙 Custom audio capture microphone stop record"];
    BOOL result = [self.audioQueueRecorder stopRecording];
    if (!result) {
        [self appendLog:@"❌ 🎙 Stop AQ recording failed!"];
    }
    
    [self appendLog:@"🔌 Stop preview"];
    [[ZegoExpressEngine sharedEngine] stopPreview];
    
    [self appendLog:@"📤 Stop publishing stream"];
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    
    if (self.saveAudioDataToDocuments) {
        NSString *path;
        if (self.captureFormat == ZGAudioCaptureFormatPCM) {
            path = [ZGAudioCommonTool writePcmData:self.audioRecorderDataToBeSaved toLocalWavFileName:@"CustomAudioCapture.wav" withSampleRate:self.sampleRate channels:1];
        } else if (self.captureFormat == ZGAudioCaptureFormatAAC) {
            path = [ZGAudioCommonTool writeAacData:self.audioRecorderDataToBeSaved toLocalFileName:@"CustomAudioCapture.aac" withSampleRate:self.sampleRate channels:1];
        }
        [self appendLog:[NSString stringWithFormat:@"💾 Write custom audio capture data to file: %@", path]];
    }
}

- (void)startPlaying {
    [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.remotePlayStreamIDTextField.text]];
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.remotePlayStreamIDTextField.text canvas:playCanvas];
    
    // Use the speaker
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    
    self.renderStartDate = [NSDate date];
    self.renderBufferCount = 0;
    [self appendLog:@"🔉 Custom audio render speaker start play"];
    BOOL result = [self.audioQueuePlayer startPlaying];
    if (!result) {
        [self appendLog:@"❌ 🔉 Start AQ playing failed!"];
    }
}

- (void)stopPlaying {
    [self appendLog:@"🔉 Custom audio render speaker stop play"];
    BOOL result = [self.audioQueuePlayer stopPlaying];
    if (!result) {
        [self appendLog:@"❌ 🔉 Stop AQ playing failed!"];
    }
    
    [self appendLog:@"📥 Stop playing stream"];
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.remotePlayStreamIDTextField.text];
    
    if (self.saveAudioDataToDocuments) {
        NSString *path = [ZGAudioCommonTool writePcmData:self.audioPlayerDataToBeSaved toLocalWavFileName:@"CustomAudioRender.wav" withSampleRate:self.sampleRate channels:1];
        [self appendLog:[NSString stringWithFormat:@"💾 Write custom audio render data to file: %@", path]];
    }
}

- (void)updateCaptureStatusUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.captureBufferCountLabel.text = [NSString stringWithFormat:@"BufferCount: %u", self.captureBufferCount];
        self.captureBufferLengthLabel.text = [NSString stringWithFormat:@"BufferLength: %llu Bytes", self.captureBufferLength];
        
        self.captureTimestampLabel.text = [NSString stringWithFormat:@"Timestamp: %.1f ms", self.captureTimestampInMs];
        self.captureDurationLabel.text = [NSString stringWithFormat:@"Duration: %.1f ms", self.captureDurationInMs];
    });
}

- (void)updateRenderStatusUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.renderBufferCountLabel.text = [NSString stringWithFormat:@"BufferCount: %u", self.renderBufferCount];
        self.renderBufferLengthLabel.text = [NSString stringWithFormat:@"BufferLength: %llu Bytes", self.renderBufferLength];
        
        self.renderTimestampLabel.text = [NSString stringWithFormat:@"Timestamp: %.1f ms", self.renderTimestampInMs];
        self.renderDurationLabel.text = [NSString stringWithFormat:@"Duration: %.1f ms", self.renderDurationInMs];
    });
}

#pragma mark - ZegoEventHandler

- (void)onPublisherStateUpdate:(ZegoPublisherState)state
                     errorCode:(int)errorCode
                  extendedData:(NSDictionary *)extendedData
                      streamID:(NSString *)streamID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📤 Publishing stream error of streamID: %@, errorCode:%d", streamID, errorCode]];
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

- (void)onPlayerStateUpdate:(ZegoPlayerState)state
                  errorCode:(int)errorCode
               extendedData:(NSDictionary *)extendedData
                   streamID:(NSString *)streamID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📥 Playing stream error of streamID: %@, errorCode:%d", streamID, errorCode]];
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

- (void)fetchCustomAudioRenderPCMData:(NSData *)buffer {
    [[ZegoExpressEngine sharedEngine] fetchCustomAudioRenderPCMData:(unsigned char *)buffer.bytes
                                                         dataLength:(unsigned int)buffer.length
                                                              param:self.audioFrameParam];
}

- (void)sendCustomAudioCapturePCMData:(NSData *)buffer {
    [[ZegoExpressEngine sharedEngine] sendCustomAudioCapturePCMData:(unsigned char *)buffer.bytes
                                                         dataLength:(unsigned int)buffer.length
                                                              param:self.audioFrameParam];
}

- (void)sendCustomAudioCaptureAACData:(NSData *)buffer timestamp:(CMTime)timestamp {
    NSData *aacData = buffer;
    NSUInteger configLength = 0;
    if (!self.haveSentAACAudioSpecificConfig) {
        self.haveSentAACAudioSpecificConfig = YES;
        NSMutableData *newBuffer = [[NSMutableData alloc] init];
        NSData *asc = [ZGAudioCommonTool generateAacAudioSpecificConfigForSampleRate:self.sampleRate];
        [newBuffer appendData:asc];
        [newBuffer appendData:buffer];
        
        aacData = newBuffer;
        configLength = asc.length;
    }
        
    [[ZegoExpressEngine sharedEngine] sendCustomAudioCaptureAACData:(unsigned char *)aacData.bytes
                                                         dataLength:(unsigned int)aacData.length
                                                       configLength:(unsigned int)configLength
                                                          timestamp:timestamp
                                                            samples:1024
                                                              param:self.audioFrameParam
                                                            channel:ZegoPublishChannelMain];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

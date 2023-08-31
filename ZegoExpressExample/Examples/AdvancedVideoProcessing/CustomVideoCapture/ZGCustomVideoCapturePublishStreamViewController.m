//
//  ZGCustomVideoCapturePublishStreamViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/12.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGCustomVideoCapturePublishStreamViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"

#import "ZGCaptureDeviceCamera.h"
#import "ZGCaptureDeviceImage.h"
#import "ZGCaptureDeviceMediaPlayer.h"

#import "ZGVideoFrameEncoder.h"

#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGCustomVideoCapturePublishStreamViewController () <ZegoEventHandler, ZegoCustomVideoCaptureHandler, ZGCaptureDeviceDataOutputPixelBufferDelegate, ZGVideoFrameEncoderDelegate>

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (nonatomic, strong) UIBarButtonItem *startLiveButton;
@property (nonatomic, strong) UIBarButtonItem *stopLiveButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *streamIDLabel;

@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;

@property (nonatomic, strong) id<ZGCaptureDevice> captureDevice;

@property (nonatomic, strong) ZegoVideoEncodedFrameParam *encodeFrameParam;
@property (nonatomic, strong) ZGVideoFrameEncoder *encoder;

@end

@implementation ZGCustomVideoCapturePublishStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self preSetupUI];
    [self createEngineAndLoginRoom];
    [self startLive];
}

- (void)viewDidAppear:(BOOL)animated {
    [self postSetupUI];
}

- (void)preSetupUI {
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.streamIDLabel.text = [NSString stringWithFormat:@"StreamID: %@", self.streamID];

    self.startLiveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startLive)];
    self.stopLiveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(stopLive)];

    if (self.captureSourceType != ZGCustomVideoCaptureSourceTypeCamera) {
        self.switchCameraButton.hidden = YES;
    }
}

- (void)postSetupUI {
    if (self.captureBufferType == ZGCustomVideoCaptureBufferTypeEncodedFrame) {
        // The ZegoExpressEngine cannot render and preview the encoded video frame
        [self.previewView addSubview:({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.previewView.frame.size.width - 40, self.previewView.frame.size.height)];
            label.text = NSLocalizedString(@"CustomVideoCapture.RenderPreview", nil);
            label.font = [UIFont boldSystemFontOfSize:30];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label;
        })];
    }
}

- (IBAction)switchCamera:(UIButton *)sender {
    if ([self.captureDevice respondsToSelector:@selector(switchCameraPosition)]) {
        [self.captureDevice switchCameraPosition];
    }
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

    // Init capture config
    ZegoCustomVideoCaptureConfig *captureConfig = [[ZegoCustomVideoCaptureConfig alloc] init];

    if (self.captureBufferType == ZGCustomVideoCaptureBufferTypeCVPixelBuffer) {
        captureConfig.bufferType = ZegoVideoBufferTypeCVPixelBuffer;
    } else if (self.captureBufferType == ZGCustomVideoCaptureBufferTypeEncodedFrame) {
        captureConfig.bufferType = ZegoVideoBufferTypeEncodedData;
    }

    // Enable custom video capture
    [[ZegoExpressEngine sharedEngine] enableCustomVideoCapture:YES config:captureConfig channel:ZegoPublishChannelMain];

    // Set self as custom video capture handler
    [[ZegoExpressEngine sharedEngine] setCustomVideoCaptureHandler:self];

    // Login room
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    [self appendLog:[NSString stringWithFormat:@"🚪 Login room. roomID: %@", self.roomID]];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user];

    // Set video config
    ZegoVideoConfig *videoConfig = [ZegoVideoConfig configWithPreset:ZegoVideoConfigPreset720P];
    if (self.captureSourceType == ZGCustomVideoCaptureSourceTypeMediaPlayer) {
        // The media player's video resource resolution is landscape.
        videoConfig.encodeResolution = CGSizeMake(1280, 720);
    }
    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
    [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeNoMirror];
}

- (void)startLive {
    // The engine supports rendering the preview when the capture type is CVPixelBuffer.
    // Not supported when the capture type is EncodedData.
    [self appendLog:@"🔌 Start preview"];
    [[ZegoExpressEngine sharedEngine] startPreview:[ZegoCanvas canvasWithView:self.previewView]];

    [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.streamID]];
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];
}

- (void)stopLive {
    [self appendLog:@"🔌 Stop preview"];
    [[ZegoExpressEngine sharedEngine] stopPreview];

    [self appendLog:@"📤 Stop publishing stream"];
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
}

- (void)dealloc {
    // After destroying the engine, you will not receive the `-onStop:` callback, you need to stop the custom video caputre manually.
    [_captureDevice stopCapture];

    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:^{
        // This callback is only used to notify the completion of the release of internal resources of the engine.
        // Developers cannot release resources related to the engine within this callback.
        //
        // In general, developers do not need to listen to this callback.
        ZGLogInfo(@"🚩 🏳️ Destroy ZegoExpressEngine complete");
    }];
}

#pragma mark - Getter

- (id<ZGCaptureDevice>)captureDevice {
    if (!_captureDevice) {
        if (self.captureSourceType == ZGCustomVideoCaptureSourceTypeCamera) {
            // BGRA32 or NV12
            OSType pixelFormat = self.captureDataFormat == ZGCustomVideoCaptureDataFormatBGRA32 ? kCVPixelFormatType_32BGRA : kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
            _captureDevice = [[ZGCaptureDeviceCamera alloc] initWithPixelFormatType:pixelFormat];

        } else if (self.captureSourceType == ZGCustomVideoCaptureSourceTypeImage) {
            _captureDevice = [[ZGCaptureDeviceImage alloc] initWithMotionImage:[UIImage imageNamed:@"ZegoLogo"].CGImage contentSize:CGSizeMake(720, 1280)];

        } else if (self.captureSourceType == ZGCustomVideoCaptureSourceTypeMediaPlayer) {
            NSString *mp4ResPath = [[NSBundle mainBundle] pathForResource:@"ad" ofType:@"mp4"];
            _captureDevice = [[ZGCaptureDeviceMediaPlayer alloc] initWithMediaResource:mp4ResPath];
        }

        _captureDevice.delegate = self;
    }
    return _captureDevice;
}

- (ZGVideoFrameEncoder *)encoder {
    if (!_encoder) {
        // The media player's video resource resolution is landscape.
        CGSize resolution = self.captureSourceType == ZGCustomVideoCaptureSourceTypeMediaPlayer ? CGSizeMake(1280, 720) : CGSizeMake(720, 1280);

#if TARGET_OS_MACCATALYST
        // When the demo is running on macOS, the screen is always horizontal
        resolution = CGSizeMake(1280, 720);
#endif

        _encoder = [[ZGVideoFrameEncoder alloc] initWithResolution:resolution maxBitrate:(int)(3000 * 1000 * 1.5) averageBitrate:(int)(3000 * 1000) fps:15];
        _encoder.delegate = self;
    }
    return _encoder;
}


#pragma mark - ZegoCustomVideoCaptureHandler

// Note: This callback is not in the main thread. If you have UI operations, please switch to the main thread yourself.
- (void)onStart:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 🟢 ZegoCustomVideoCaptureHandler onStart, channel: %d", (int)channel);
    [self.captureDevice startCapture];
}

// Note: This callback is not in the main thread. If you have UI operations, please switch to the main thread yourself.
- (void)onStop:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 🔴 ZegoCustomVideoCaptureHandler onStop, channel: %d", (int)channel);
    [self.captureDevice stopCapture];
}

- (void)onEncodedDataTrafficControl:(ZegoTrafficControlInfo *)trafficControlInfo channel:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 🚦 onEncodedDataTrafficControl, should adjust to w: %d, h: %d, bitrate: %d, fps: %d", (int)trafficControlInfo.resolution.width, (int)trafficControlInfo.resolution.height, trafficControlInfo.bitrate, trafficControlInfo.fps);

    [self.encoder setMaxBitrate:trafficControlInfo.bitrate*1.5 averageBitrate:trafficControlInfo.bitrate fps:trafficControlInfo.fps];
    if ([self.captureDevice respondsToSelector:@selector(setFramerate:)]) {
        [self.captureDevice setFramerate:trafficControlInfo.fps];
    }
}


#pragma mark - ZGCustomVideoCapturePixelBufferDelegate

- (void)captureDevice:(id<ZGCaptureDevice>)device didCapturedData:(CMSampleBufferRef)data {

    if (self.captureBufferType == ZGCustomVideoCaptureBufferTypeCVPixelBuffer) {

        // BufferType: CVPixelBuffer

        // Send pixel buffer to ZEGO SDK
        [[ZegoExpressEngine sharedEngine] sendCustomVideoCapturePixelBuffer:CMSampleBufferGetImageBuffer(data) timestamp:CMSampleBufferGetPresentationTimeStamp(data)];

    } else if (self.captureBufferType == ZGCustomVideoCaptureBufferTypeEncodedFrame) {

        // BufferType: Encoded frame (H.264)

        // Need to encode frame
        [self.encoder encodeBuffer:data];
    }
}


#pragma mark - ZGVideoFrameEncoderDelegate

// BufferType: Encoded frame (H.264)
- (void)encoder:(ZGVideoFrameEncoder *)encoder encodedData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame timestamp:(CMTime)timestamp {

    self.encodeFrameParam.isKeyFrame = isKeyFrame;

    // Send encoded frame to ZEGO SDK
    [[ZegoExpressEngine sharedEngine] sendCustomVideoCaptureEncodedData:data params:self.encodeFrameParam timestamp:timestamp];
}

- (ZegoVideoEncodedFrameParam *)encodeFrameParam {
    if (!_encodeFrameParam) {
        _encodeFrameParam = [[ZegoVideoEncodedFrameParam alloc] init];
        _encodeFrameParam.size = CGSizeMake(720, 1280);
        _encodeFrameParam.format = ZegoVideoEncodedFrameFormatAVCC; // The VideoToolBox default compression format is AVCC
    }
    return _encodeFrameParam;
}


#pragma mark - ZegoEventHandler

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📤 Publisher State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);

    switch (state) {
        case ZegoPublisherStateNoPublish:
            self.title = @"🔴 No Publish";
            self.navigationItem.rightBarButtonItem = self.startLiveButton;
            break;
        case ZegoPublisherStatePublishRequesting:
            self.title = @"🟡 Publish Requesting";
            self.navigationItem.rightBarButtonItem = self.stopLiveButton;
            break;
        case ZegoPublisherStatePublishing:
            self.title = @"🟢 Publishing";
            self.navigationItem.rightBarButtonItem = self.stopLiveButton;
            break;
    }
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    self.resolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %d fps \n", (int)quality.videoSendFPS];
    self.bitrateLabel.text = [NSString stringWithFormat:@"Bitrate: %.2f kb/s \n", quality.videoKBPS];
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

//
//  ZGCustomVideoProcessPublishStreamViewController.m
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2021/11/15.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGCustomVideoProcessPublishStreamViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import "FUDemoManager.h"

@interface ZGCustomVideoProcessPublishStreamViewController () <ZegoEventHandler, ZegoCustomVideoProcessHandler>

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *playView;

@property (nonatomic, strong) UIBarButtonItem *startLiveButton;
@property (nonatomic, strong) UIBarButtonItem *stopLiveButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (nonatomic, assign) BOOL usingFrontCamera;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *streamIDLabel;

@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;
@property (weak, nonatomic) IBOutlet UILabel *cpuUseLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoryUseLabel;

@property (nonatomic, copy) NSString *playStreamID;
@property (nonatomic) ZegoPlayerState playerState;


@end

@implementation ZGCustomVideoProcessPublishStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usingFrontCamera = YES;
    [self preSetupUI];
    [self specifyRenderBackend];
    [self createEngineAndLoginRoom];
    [self startLive];
    
    // faceunity
    [FUDemoManager setupFUSDK];
    [[FUDemoManager shared] addDemoViewToView:self.view originY:CGRectGetHeight([UIScreen mainScreen].bounds) - FUBottomBarHeight - FUSafaAreaBottomInsets() - 100];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)preSetupUI {
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.streamIDLabel.text = [NSString stringWithFormat:@"StreamID: %@", self.streamID];

    self.startLiveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startLive)];
    self.stopLiveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(stopLive)];
}

- (void)specifyRenderBackend {
    NSString *backend = @"opengl";
    if (self.renderBackend == ZGCustomVideoProcessRenderBackendMetal) {
        [self appendLog:@"🧪 Use OpenGL as render backend"];
        backend = @"metal";
    }
    ZegoEngineConfig *engineConfig = [[ZegoEngineConfig alloc] init];
    engineConfig.advancedConfig = @{@"video_render_backend": backend};
    [ZegoExpressEngine setEngineConfig:engineConfig];
}

- (IBAction)switchCamera:(UIButton *)sender {
    self.usingFrontCamera = !self.usingFrontCamera;
    [[ZegoExpressEngine sharedEngine] useFrontCamera:self.usingFrontCamera];
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

    // Init process config
    ZegoCustomVideoProcessConfig *processConfig = [[ZegoCustomVideoProcessConfig alloc] init];
    processConfig.bufferType = ZegoVideoBufferTypeCVPixelBuffer;

    
    // Enable custom video process
    [[ZegoExpressEngine sharedEngine] enableCustomVideoProcessing:YES config:processConfig channel:ZegoPublishChannelMain];

    // Set self as custom video process handler
    [[ZegoExpressEngine sharedEngine] setCustomVideoProcessHandler:self];

    // Login room
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    [self appendLog:[NSString stringWithFormat:@"🚪 Login room. roomID: %@", self.roomID]];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user];

    // Set video config
    ZegoVideoConfig *videoConfig = [ZegoVideoConfig configWithPreset:self.resolutionPreset];
    videoConfig.fps = self.fps;
    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
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
    [FUDemoManager destory];
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:^{
        // This callback is only used to notify the completion of the release of internal resources of the engine.
        // Developers cannot release resources related to the engine within this callback.
        //
        // In general, developers do not need to listen to this callback.
        ZGLogInfo(@"🚩 🏳️ Destroy ZegoExpressEngine complete");
    }];
}

- (void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    
}

- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (updateType == ZegoUpdateTypeAdd) {
        // When the updateType is Add, stop playing current stream(if exist) and start playing new stream.
        if (self.playerState != ZegoPlayerStateNoPlay) {
            [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamID];
            self.playStreamID = nil;
        }
        
        // No processing, just play the first stream
        ZegoStream *stream = streamList.firstObject;
        self.playStreamID = stream.streamID;
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamID canvas:playCanvas];
        
    } else {
        // When the updateType is Delete, if the stream is being played, stop playing the stream.
        if (self.playerState == ZegoPlayerStateNoPlay) {
            return;
        }
        for (ZegoStream *stream in streamList) {
            if ([self.playStreamID isEqualToString:stream.streamID]) {
                [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamID];
                self.playStreamID = nil;
            }
        }
    }
}

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    self.playerState = state;
    [self appendLog:[NSString stringWithFormat:@"🚩 Player State Update State: %lu", state]];
    if (state == ZegoPlayerStatePlaying) {
        self.playView.hidden = NO;
    } else {
        self.playView.hidden = YES;
    }
}

#pragma mark - ZegoCustomVideoProcessHandler

// Note: This callback is not in the main thread. If you have UI operations, please switch to the main thread yourself.
- (void)onStart:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 🟢 ZegoCustomVideoProcessHandler onStart, channel: %d", (int)channel);
    
    // You can start your image processing unit in this callback, for example, start a beauty processor.
    
    // Here we demonstrate starting a performance monitor
    [[ZegoExpressEngine sharedEngine] startPerformanceMonitor:1000];
}

// Note: This callback is not in the main thread. If you have UI operations, please switch to the main thread yourself.
- (void)onStop:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 🔴 ZegoCustomVideoProcessHandler onStop, channel: %d", (int)channel);
    
    // You can stop your image processing unit in this callback.
    
    // Here we demonstrate stoping a performance monitor
    [[ZegoExpressEngine sharedEngine] stopPerformanceMonitor];
}

// Note: This callback is not in the main thread.
- (void)onCapturedUnprocessedCVPixelBuffer:(CVPixelBufferRef)buffer timestamp:(CMTime)timestamp channel:(ZegoPublishChannel)channel {
    
    // You can do any processing on the image buffer provided by the SDK here
    
    if (self.filterType == ZGCustomVideoProcessFilterTypeInvert) {
        [self filterInvert:buffer];
    } else if (self.filterType == ZGCustomVideoProcessFilterTypeGrayscale) {
        [self filterGrayscale:buffer];
    }
    
    [[FUDemoManager shared] checkAITrackedResult];
    
    [[FUTestRecorder shareRecorder] processFrameWithLog];
    if ([FUDemoManager shared].shouldRender) {
        [FUDemoManager updateBeautyBlurEffect];
        FURenderInput *input = [[FURenderInput alloc] init];
        //默认图片内部的人脸始终是朝上，旋转屏幕也无需修改该属性。
        input.renderConfig.imageOrientation = FUImageOrientationUP;
        //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
        input.renderConfig.gravityEnable = YES;
        input.renderConfig.isFromFrontCamera = self.usingFrontCamera;
//        input.renderConfig.isFromMirroredCamera = YES;
        input.renderConfig.stickerFlipH = self.usingFrontCamera;
        input.pixelBuffer = buffer;
        FURenderOutput *output = [[FURenderKit shareRenderKit] renderWithInput:input];
            [[ZegoExpressEngine sharedEngine] sendCustomVideoProcessedCVPixelBuffer:output.pixelBuffer timestamp:timestamp channel:channel];
    } else {
        [[ZegoExpressEngine sharedEngine] sendCustomVideoProcessedCVPixelBuffer:buffer timestamp:timestamp channel:channel];
    }
    
    // Then pass the processed image buffer back to the SDK for streaming
    
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

- (void)onPerformanceStatusUpdate:(ZegoPerformanceStatus *)status {
    self.cpuUseLabel.text = [NSString stringWithFormat:@"CPU: %.1f%% (APP) | %.1f%% (SYS) \n", status.cpuUsageApp * 100, status.cpuUsageSystem * 100];
    self.memoryUseLabel.text = [NSString stringWithFormat:@"MEM: %.1f%% (APP) | %.1f%% (SYS) | %.1f (MB, APP) \n", status.memoryUsageApp * 100, status.memoryUsageSystem * 100, status.memoryUsedApp];
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

#pragma mark - Simple Image Filters

- (void)filterInvert:(CVPixelBufferRef)buffer {
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    OSType formatType = CVPixelBufferGetPixelFormatType(buffer);
    
    if (formatType == kCVPixelFormatType_32BGRA) {
        
        size_t stride = CVPixelBufferGetBytesPerRow(buffer);
        size_t width = CVPixelBufferGetWidth(buffer);
        size_t height = CVPixelBufferGetHeight(buffer);
        uint8_t *baseAddress = CVPixelBufferGetBaseAddress(buffer);
        
        for (int row = 0; row < height; row++) {
            uint8_t *pixel = baseAddress + row * stride;
            for (int column = 0; column < width; column++) {
                unsigned char b = pixel[0];
                unsigned char g = pixel[1];
                unsigned char r = pixel[2];
                pixel[0] = 255 - b;
                pixel[1] = 255 - g;
                pixel[2] = 255 - r;
                pixel += 4;
            }
        }
        
    } else if (formatType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        
        size_t stride = CVPixelBufferGetBytesPerRowOfPlane(buffer, 1); // UV Plane
        size_t width = CVPixelBufferGetWidthOfPlane(buffer, 1);
        size_t height = CVPixelBufferGetHeightOfPlane(buffer, 1);
        uint8_t *baseAddress = CVPixelBufferGetBaseAddressOfPlane(buffer, 1);
        
        for (int row = 0; row < height; row++) {
            uint8_t *pixel = baseAddress + row * stride;
            for (int column = 0; column < width; column++) {
                unsigned char u = pixel[0];
                unsigned char v = pixel[1];
                // Invert U & V
                pixel[0] = v;
                pixel[1] = u;
                pixel += 2;
            }
        }
    }
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
}

- (void)filterGrayscale:(CVPixelBufferRef)buffer {
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    
    OSType formatType = CVPixelBufferGetPixelFormatType(buffer);
    
    if (formatType == kCVPixelFormatType_32BGRA) {
        
        size_t stride = CVPixelBufferGetBytesPerRow(buffer);
        size_t width = CVPixelBufferGetWidth(buffer);
        size_t height = CVPixelBufferGetHeight(buffer);
        uint8_t *baseAddress = CVPixelBufferGetBaseAddress(buffer);
        
        for (int row = 0; row < height; row++) {
            uint8_t *pixel = baseAddress + row * stride;
            for (int column = 0; column < width; column++) {
                unsigned char b = pixel[0];
                unsigned char g = pixel[1];
                unsigned char r = pixel[2];
                uint8_t gray = (uint8_t) ((30 * r + 59 * g + 11 * b) / 100);
                pixel[0] = gray;
                pixel[1] = gray;
                pixel[2] = gray;
                pixel += 4;
            }
        }
        
    } else if (formatType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        
        size_t stride = CVPixelBufferGetBytesPerRowOfPlane(buffer, 1); // UV Plane
        size_t width = CVPixelBufferGetWidthOfPlane(buffer, 1);
        size_t height = CVPixelBufferGetHeightOfPlane(buffer, 1);
        uint8_t *baseAddress = CVPixelBufferGetBaseAddressOfPlane(buffer, 1);
        
        for (int row = 0; row < height; row++) {
            uint8_t *pixel = baseAddress + row * stride;
            memset(pixel, 0x80, sizeof(unsigned char) * width);
        }
    }
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
}

@end

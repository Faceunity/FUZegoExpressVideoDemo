//
//  ZGCustomVideoRenderPlayStreamViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/1.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_CustomVideoRender

#import "ZGCustomVideoRenderPlayStreamViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"

@interface ZGCustomVideoRenderPlayStreamViewController () <ZegoEventHandler, ZegoCustomVideoRenderHandler>

@property (weak, nonatomic) IBOutlet UIImageView *customRenderPlayView;

@property (weak, nonatomic) IBOutlet UIView *engineRenderPlayView;

@end

@implementation ZGCustomVideoRenderPlayStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Play";
    
    [self createEngine];
    [self startLive];
}

- (void)createEngine {

    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];

    ZGLogInfo(@"🚀 Create ZegoExpressEngine");

    [ZegoExpressEngine createEngineWithAppID:(unsigned int)appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];

    // Init render config
    ZegoCustomVideoRenderConfig *renderConfig = [[ZegoCustomVideoRenderConfig alloc] init];
    renderConfig.bufferType = self.bufferType;
    renderConfig.frameFormatSeries = self.frameFormatSeries;
    renderConfig.enableEngineRender = self.enableEngineRender;

    // Enable custom video render
    [[ZegoExpressEngine sharedEngine] enableCustomVideoRender:YES config:renderConfig];

    // Set custom video render handler
    [[ZegoExpressEngine sharedEngine] setCustomVideoRenderHandler:self];
}

- (void)startLive {
    // Login Room
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user config:[ZegoRoomConfig defaultConfig]];
    
    // Start playing
    ZGLogInfo(@"📥 Start playing stream. streamID: %@", self.streamID);
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamID canvas:[ZegoCanvas canvasWithView:self.engineRenderPlayView]];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.isBeingDismissed || self.isMovingFromParentViewController
        || (self.navigationController && self.navigationController.isBeingDismissed)) {
        ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
        [ZegoExpressEngine destroyEngine:^{
            // This callback is only used to notify the completion of the release of internal resources of the engine.
            // Developers cannot release resources related to the engine within this callback.
            //
            // In general, developers do not need to listen to this callback.
            ZGLogInfo(@"🚩 🏳️ Destroy ZegoExpressEngine complete");
        }];
    }
    [super viewDidDisappear:animated];
}

#pragma mark - ZegoCustomVideoRenderHandler

/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeRawData`, the video frame raw data will be called back from this function
- (void)onRemoteVideoFrameRawData:(unsigned char * _Nonnull *)data dataLength:(unsigned int *)dataLength param:(ZegoVideoFrameParam *)param streamID:(NSString *)streamID {
//    if (streamID != self.streamID) return;
    NSLog(@"raw data video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);
    
    if (param.format == ZegoVideoFrameFormatBGRA32) {
        // Reverse color
        unsigned char *bgra32 = data[0];
        for (int i = 0; i < dataLength[0]; i += 4) {
            unsigned char b = bgra32[i];
            unsigned char g = bgra32[i + 1];
            unsigned char r = bgra32[i + 2];
            bgra32[i] = 255 - b;
            bgra32[i + 1] = 255 - g;
            bgra32[i + 2] = 255 - r;
        }
    } else if (param.format == ZegoVideoFrameFormatI420) {
        // Grayscale
        unsigned char *uPlanar = data[1];
        unsigned char *vPlanar = data[1];
        memset(uPlanar, 0x80, sizeof(char) * dataLength[1]);
        memset(vPlanar, 0x80, sizeof(char) * dataLength[2]);
    }
}

/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeCVPixelBuffer`, the video frame CVPixelBuffer will be called back from this function
- (void)onRemoteVideoFrameCVPixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param streamID:(NSString *)streamID {
//    if (streamID != self.streamID) return;
    NSLog(@"pixel buffer video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);
    [self renderWithCVPixelBuffer:buffer];
}

- (void)onRemoteVideoFrameEncodedData:(unsigned char *)data dataLength:(unsigned int)dataLength param:(ZegoVideoEncodedFrameParam *)param referenceTimeMillisecond:(unsigned long long)referenceTimeMillisecond streamID:(NSString *)streamID {
    NSLog(@"EEEncodedData Remote video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);

    
}

#pragma mark - Custom Render Method

- (void)renderWithCVPixelBuffer:(CVPixelBufferRef)buffer {
    CIImage *image = [CIImage imageWithCVPixelBuffer:buffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.customRenderPlayView.image = [UIImage imageWithCIImage:image];
    });
}



@end

#endif

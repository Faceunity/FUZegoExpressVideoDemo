//
//  ZegoStreamPublisher.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/12.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZegoStreamPublisher.h"

#import "ZGCaptureDeviceImage.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZegoStreamPublisher ()<ZGCaptureDeviceDataOutputPixelBufferDelegate, ZegoCustomVideoCaptureHandler>

@property (nonatomic, weak) UIImageView *canvasView;

@property (nonatomic, strong) id<ZGCaptureDevice> captureDevice;

@end

@implementation ZegoStreamPublisher

- (instancetype)initWithCanvasView:(UIImageView *)canvasView {
    self = [super init];
    if (self) {
        self.canvasView = canvasView;
        // Set capture config for aux publish channel
        ZegoCustomVideoCaptureConfig *captureConfig = [[ZegoCustomVideoCaptureConfig alloc] init];
        captureConfig.bufferType = ZegoVideoBufferTypeCVPixelBuffer;

        // Enable custom video capture for aux channel
        // Only the aux channel use custom video capture, and the main channel uses the SDK's own capture
        [[ZegoExpressEngine sharedEngine] enableCustomVideoCapture:YES config:captureConfig channel:ZegoPublishChannelAux];
        
        [[ZegoExpressEngine sharedEngine] setCustomVideoCaptureHandler:self];
    }
    return self;
}

#pragma mark - ZegoCustomVideoCaptureHandler

// Note: This callback is not in the main thread. If you have UI operations, please switch to the main thread yourself.
- (void)onStart:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 🟢 ZegoCustomVideoCaptureHandler onStart, channel: %@", channel == ZegoPublishChannelMain ? @"Main" : @"Aux");
    [self.captureDevice startCapture];
}

// Note: This callback is not in the main thread. If you have UI operations, please switch to the main thread yourself.
- (void)onStop:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 🔴 ZegoCustomVideoCaptureHandler onStop, channel: %@", channel == ZegoPublishChannelMain ? @"Main" : @"Aux");
    [self.captureDevice stopCapture];
}

#pragma mark - Capture device for aux channel

- (id<ZGCaptureDevice>)captureDevice {
    if (!_captureDevice) {
        _captureDevice = [[ZGCaptureDeviceImage alloc] initWithMotionImage:[UIImage imageNamed:@"ZegoLogo"].CGImage contentSize:CGSizeMake(720, 1280)];
        _captureDevice.delegate = self;
    }
    return _captureDevice;
}

#pragma mark - ZGCustomVideoCapturePixelBufferDelegate

- (void)captureDevice:(nonnull id<ZGCaptureDevice>)device didCapturedData:(nonnull CMSampleBufferRef)data {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(data);
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(data);

    // Send pixel buffer to ZEGO SDK for aux channel
    [[ZegoExpressEngine sharedEngine] sendCustomVideoCapturePixelBuffer:pixelBuffer timestamp:timestamp channel:ZegoPublishChannelAux];

    // When custom video capture is enabled, developers need to render the preview by themselves
    [self renderWithCVPixelBuffer:pixelBuffer];
}

#pragma mark - Render Preview

- (void)renderWithCVPixelBuffer:(CVPixelBufferRef)buffer {
    CIImage *image = [CIImage imageWithCVPixelBuffer:buffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.canvasView.image = [UIImage imageWithCIImage:image];
    });
}
@end

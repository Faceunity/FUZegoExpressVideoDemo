//
//  ZGCaptureDeviceCamera.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/12.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGCaptureDeviceCamera.h"

@interface ZGCaptureDeviceCamera () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    dispatch_queue_t _sampleBufferCallbackQueue;
}

@property (nonatomic, assign) OSType pixelFormatType;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, assign) int framerate;

@property (nonatomic, assign) BOOL isRunning;

@end

@implementation ZGCaptureDeviceCamera

- (instancetype)initWithPixelFormatType:(OSType)pixelFormatType {
    self = [super init];
    if (self) {
        _pixelFormatType = pixelFormatType;

        // Use front camera as default
        _cameraPosition = AVCaptureDevicePositionFront;

        // Default is 30 fps
        _framerate = 30;

        _sampleBufferCallbackQueue = dispatch_queue_create("im.zego.ZGCustomVideoCaptureCameraDevice.outputCallbackQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc {
//    [self stopCapture];
}


- (void)startCapture {
    ZGLogInfo(@"▶️ Camera start to capture");
    if (self.isRunning) {
        return;
    }
    
    [self.session beginConfiguration];
    
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    
    AVCaptureDeviceInput *input = self.input;
    
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    
    
    AVCaptureVideoDataOutput *output = self.output;
    
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }
    
    AVCaptureConnection *captureConnection = [output connectionWithMediaType:AVMediaTypeVideo];

    // Mirror the video when using the front camera
    if (input.device.position == AVCaptureDevicePositionFront) {
        captureConnection.videoMirrored = YES;
    }
    
    if (captureConnection.isVideoOrientationSupported) {
        captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    [self.session commitConfiguration];
    
    if (!self.session.isRunning) {
        [self.session startRunning];
    }
    
    self.isRunning = YES;
    ZGLogInfo(@"⏺ Camera has started capturing");
}

- (void)stopCapture {
    ZGLogInfo(@"⏸ Camera stops capture");
    if (!self.isRunning) {
        return;
    }
    
    if (self.session.isRunning) {
        [self.session stopRunning];
        [self.session removeInput:_input];
    }
    
    self.isRunning = NO;
    ZGLogInfo(@"⏹ Camera has stopped capturing");
}

- (void)switchCameraPosition {

    if (self.cameraPosition == AVCaptureDevicePositionFront) {
        self.cameraPosition = AVCaptureDevicePositionBack;
    } else {
        self.cameraPosition = AVCaptureDevicePositionFront;
    }

#if TARGET_OS_OSX

    ZGLogInfo(@"📷 🔄 macOS does not support switching front/back camera");

#elif TARGET_OS_IOS

    ZGLogInfo(@"📷 🔄 Switch to the %@ camera", self.cameraPosition == AVCaptureDevicePositionFront ? @"front" : @"back");

    // Restart capture
    if (self.isRunning) {
        [self stopCapture];
        [self startCapture];
    }

#endif
}

- (void)setFramerate:(int)framerate {
    if (!_device) {
        NSLog(@"Camera is not actived");
        return;
    }

    NSArray<AVFrameRateRange *> *ranges = _device.activeFormat.videoSupportedFrameRateRanges;
    AVFrameRateRange *range = [ranges firstObject];

    if (!range) {
        NSLog(@"videoSupportedFrameRateRanges is empty");
        return;
    }

    if (framerate > range.maxFrameRate || framerate < range.minFrameRate) {
        NSLog(@"Unsupport framerate: %d, range is %.2f ~ %.2f", framerate, range.minFrameRate, range.maxFrameRate);
        return;
    }

    NSError *error = [[NSError alloc] init];
    if (![_device lockForConfiguration:&error]) {
        NSLog(@"AVCaptureDevice lockForConfiguration failed. errCode:%ld, domain:%@", error.code, error.domain);
    }
    _device.activeVideoMinFrameDuration = CMTimeMake(1, framerate);
    _device.activeVideoMaxFrameDuration = CMTimeMake(1, framerate);
    [_device unlockForConfiguration];

    NSLog(@"Set framerate to %d", framerate);
}


#pragma mark - Getter

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

// Reacquire the camera every time it is called
- (AVCaptureDevice *)device {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
#pragma clang diagnostic pop

#if TARGET_OS_OSX

    // Note: This demonstration selects the last camera on Mac. Developers should choose the appropriate camera device by themselves.
    AVCaptureDevice *camera = cameras.lastObject;
    if (!camera) {
        NSLog(@"Failed to get camera");
        return nil;
    }

#elif TARGET_OS_IOS

    // Get the specified position camera
    NSArray *captureDeviceArray = [cameras filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"position == %d", _cameraPosition]];
    if (captureDeviceArray.count == 0) {
        NSLog(@"Failed to get camera");
        return nil;
    }
    AVCaptureDevice *camera = captureDeviceArray.firstObject;

#endif

    _device = camera;
    return _device;
}

// Reacquire the camera every time it is called
- (AVCaptureDeviceInput *)input {

    NSError *error = nil;
    AVCaptureDeviceInput *captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (error) {
        NSLog(@"Conversion of AVCaptureDevice to AVCaptureDeviceInput failed");
        return nil;
    }
    _input = captureDeviceInput;

    return _input;
}

- (AVCaptureVideoDataOutput *)output {
    if (!_output) {
        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:@(self.pixelFormatType)};
        [videoDataOutput setSampleBufferDelegate:self queue:_sampleBufferCallbackQueue];
        _output = videoDataOutput;
    }
    return _output;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    CFRetain(sampleBuffer);
    id<ZGCaptureDeviceDataOutputPixelBufferDelegate> delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(captureDevice:didCapturedData:)]) {
        [delegate captureDevice:self didCapturedData:sampleBuffer];
    }
    CFRelease(sampleBuffer);
}

@end

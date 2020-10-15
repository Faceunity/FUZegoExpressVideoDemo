//
//  ZGCaptureDeviceImage.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/12.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_CustomVideoCapture

#import "ZGCaptureDeviceImage.h"

@interface ZGCaptureDeviceImage ()

@property (nonatomic, assign) CGImageRef motionImage;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) NSUInteger fps;
@property (nonatomic, strong) NSTimer *fpsTimer;

@end

@implementation ZGCaptureDeviceImage

- (instancetype)initWithMotionImage:(CGImageRef)image contentSize:(CGSize)size {
    self = [super init];
    if (self) {
        CGImageRetain(image);
        self.motionImage = image;
        self.contentSize = size;
    }
    return self;
}

- (void)dealloc {
    CGImageRelease(_motionImage);
}

- (void)startCapture {
    ZGLogInfo(@"▶️ Start capture motion image");
    if (!self.fpsTimer) {
        self.fps = self.fps ? self.fps : 15;
        NSTimeInterval delta = 1.f / self.fps;
        self.fpsTimer = [NSTimer timerWithTimeInterval:delta target:self selector:@selector(captureImage) userInfo:nil repeats:YES];
        [NSRunLoop.mainRunLoop addTimer:self.fpsTimer forMode:NSRunLoopCommonModes];
    }
    
    [self.fpsTimer fire];
    [self captureImage];// Called immediately at the beginning
}

- (void)stopCapture {
    ZGLogInfo(@"⏸ Stop capture motion image");
    if (self.fpsTimer) {
        [self.fpsTimer invalidate];
        self.fpsTimer = nil;
    }
}

- (void)captureImage {
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        
        CVPixelBufferRef pixelBuffer = [self pixelBufferFromImage:self.motionImage contentSize:self.contentSize];

        CMTime time = CMTimeMakeWithSeconds([[NSDate date] timeIntervalSince1970], 1000);
        CMSampleTimingInfo timingInfo = { kCMTimeInvalid, time, time };

        CMVideoFormatDescriptionRef desc;
        CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &desc);

        CMSampleBufferRef sampleBuffer;
        CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, (CVImageBufferRef)pixelBuffer, desc, &timingInfo, &sampleBuffer);

        id<ZGCaptureDeviceDataOutputPixelBufferDelegate> delegate = self.delegate;
        if (delegate &&
            [delegate respondsToSelector:@selector(captureDevice:didCapturedData:)]) {
            [delegate captureDevice:self didCapturedData:sampleBuffer];
        }

        CFRelease(sampleBuffer);
        CFRelease(desc);
        CVPixelBufferRelease(pixelBuffer);
    });
}

#pragma mark - Utility Method

static OSType inputPixelFormat(){
    return kCVPixelFormatType_32BGRA;
}

static uint32_t bitmapInfoWithPixelFormatType(OSType inputPixelFormat, bool hasAlpha){

    if (inputPixelFormat == kCVPixelFormatType_32BGRA) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        if (!hasAlpha) {
            bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
        }
        return bitmapInfo;
    } else if (inputPixelFormat == kCVPixelFormatType_32ARGB) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big;
        return bitmapInfo;
    } else {
        NSLog(@"Unsupported bitmap format");
        return 0;
    }
}

BOOL imageContainsAlpha(CGImageRef imageRef) {
    if (!imageRef) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}

- (CVPixelBufferRef)pixelBufferFromImage:(CGImageRef)image contentSize:(CGSize)contentSize {

    CVReturn status;
    CVPixelBufferRef pixelBuffer;
    
    NSDictionary *pixelBufferAttributes = @{
        (id)kCVPixelBufferIOSurfacePropertiesKey: [NSDictionary dictionary],
        (id)kCVPixelBufferCGImageCompatibilityKey: @(YES),
        (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @(YES)
    };
    
    status = CVPixelBufferCreate(kCFAllocatorDefault, contentSize.width, contentSize.height, inputPixelFormat(), (__bridge CFDictionaryRef)pixelBufferAttributes, &pixelBuffer);
    
    if (status != kCVReturnSuccess) {
        return NULL;
    }
    
    time_t currentTime = time(0);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // Random Background Color
    char color[4] = {0};
    color[0] = (currentTime * 1) % 0xFF;
    color[1] = (currentTime * 2) % 0xFF;
    color[2] = (currentTime * 3) % 0xFF;
    color[3] = 0xFF;
    
    memset_pattern4(data, color, CVPixelBufferGetDataSize(pixelBuffer));
    
    CGFloat imageWith = CGImageGetWidth(image);
    CGFloat imageHeight = CGImageGetHeight(image);
    
    static CGPoint origin = {0, 0};
    static time_t lastTime = 0;
    
    if (lastTime != currentTime) {
        origin.x = rand() % (int)(contentSize.width - imageWith);
        origin.y = rand() % (int)(contentSize.height - imageHeight);
        
        lastTime = currentTime;
    }
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();

    BOOL hasAlpha = imageContainsAlpha(image);

    uint32_t bitmapInfo = bitmapInfoWithPixelFormatType(inputPixelFormat(), (bool)hasAlpha);
    
    CGContextRef context = CGBitmapContextCreate(data, contentSize.width, contentSize.height, 8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace, bitmapInfo);
    
    CGContextDrawImage(context, CGRectMake(origin.x, origin.y, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return pixelBuffer;
}

@end

#endif

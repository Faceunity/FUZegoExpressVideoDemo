//
//  ZGCaptureDeviceProtocol.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/12.
//  Copyright © 2020 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZGCustomVideoCaptureSourceType) {
    ZGCustomVideoCaptureSourceTypeCamera,
    ZGCustomVideoCaptureSourceTypeImage,
    ZGCustomVideoCaptureSourceTypeMediaPlayer
};

typedef NS_ENUM(NSUInteger, ZGCustomVideoCaptureDataFormat) {
    ZGCustomVideoCaptureDataFormatBGRA32,
    ZGCustomVideoCaptureDataFormatNV12
};

typedef NS_ENUM(NSUInteger, ZGCustomVideoCaptureBufferType) {
    ZGCustomVideoCaptureBufferTypeCVPixelBuffer,
    ZGCustomVideoCaptureBufferTypeEncodedFrame
};

@protocol ZGCaptureDevice;

@protocol ZGCaptureDeviceDataOutputPixelBufferDelegate <NSObject>

- (void)captureDevice:(id<ZGCaptureDevice>)device didCapturedData:(CMSampleBufferRef)data;

@end


@protocol ZGCaptureDevice <NSObject>

@property (nonatomic, weak) id<ZGCaptureDeviceDataOutputPixelBufferDelegate> delegate;

- (void)startCapture;

- (void)stopCapture;

@optional

// Only for camera
- (void)switchCameraPosition;

- (void)setFramerate:(int)framerate;

@end

NS_ASSUME_NONNULL_END

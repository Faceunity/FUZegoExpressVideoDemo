//
//  ZGCaptureDeviceImage.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/12.
//  Copyright © 2020 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZGCaptureDeviceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZGCaptureDeviceImage : NSObject <ZGCaptureDevice>

@property (nonatomic, weak) id<ZGCaptureDeviceDataOutputPixelBufferDelegate> delegate;

- (instancetype)initWithMotionImage:(CGImageRef)image contentSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END

//
//  ZGCaptureDeviceMediaPlayer.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2021/2/23.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZGCaptureDeviceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZGCaptureDeviceMediaPlayer : NSObject <ZGCaptureDevice>

@property (nonatomic, weak) id<ZGCaptureDeviceDataOutputPixelBufferDelegate> delegate;

- (instancetype)initWithMediaResource:(NSString *)resource;

@end

NS_ASSUME_NONNULL_END

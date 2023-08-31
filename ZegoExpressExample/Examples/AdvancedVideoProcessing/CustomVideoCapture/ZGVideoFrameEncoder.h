//
//  ZGVideoFrameEncoder.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/9.
//  Copyright © 2020 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZGVideoFrameEncoder;

@protocol ZGVideoFrameEncoderDelegate <NSObject>

- (void)encoder:(ZGVideoFrameEncoder *)encoder encodedData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame timestamp:(CMTime)timestamp;

@end

@interface ZGVideoFrameEncoder : NSObject

@property (nonatomic, weak) id<ZGVideoFrameEncoderDelegate> delegate;

- (instancetype)initWithResolution:(CGSize)resolution maxBitrate:(int)maxBitrate averageBitrate:(int)averageBitrate fps:(int)fps;

- (void)setMaxBitrate:(int)maxBitrate averageBitrate:(int)averageBitrate fps:(int)fps;

- (void)encodeBuffer:(CMSampleBufferRef)buffer;

@end

NS_ASSUME_NONNULL_END

//
//  ZGAudioQueuePlayer.h
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2023/5/10.
//  Copyright © 2023 Zego. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ZGAudioQueuePlayerDataCallback)(NSData *buffer);

@interface ZGAudioQueuePlayer : NSObject

@property (nonatomic, copy) ZGAudioQueuePlayerDataCallback dataCallback;
@property (nonatomic, assign, readonly) Float64 sampleRate;

- (instancetype)initWithSampleRate:(Float64)sampleRate;
- (BOOL)startPlaying;
- (BOOL)stopPlaying;

@end

NS_ASSUME_NONNULL_END

//
//  ZGAudioQueueRecorder.h
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2023/5/10.
//  Copyright © 2023 Zego. All rights reserved.
//

#import "ZGAudioCaptureFormat.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ZGAudioQueueRecorderDataCallback)(NSData *buffer, CMTime timestamp);

@interface ZGAudioQueueRecorder : NSObject

@property (nonatomic, copy) ZGAudioQueueRecorderDataCallback dataCallback;
@property (nonatomic, assign, readonly) Float64 sampleRate;
@property (nonatomic, assign, readonly) ZGAudioCaptureFormat captureFormat;

- (instancetype)initWithSampleRate:(Float64)sampleRate format:(ZGAudioCaptureFormat)format;
- (BOOL)startRecording;
- (BOOL)stopRecording;

@end

NS_ASSUME_NONNULL_END

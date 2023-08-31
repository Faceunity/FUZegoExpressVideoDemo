//
//  ZGAudioQueuePlayer.m
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2023/5/10.
//  Copyright © 2023 Zego. All rights reserved.
//

#import "ZGAudioQueuePlayer.h"
#import "ZGAudioCommonTool.h"

static void ZGAudioQueueOutputCallback(void *inUserData, AudioQueueRef inAQ,
                                       AudioQueueBufferRef inBuffer) {
    ZGAudioQueuePlayer *player = (__bridge ZGAudioQueuePlayer *)inUserData;
    if (!player) {
        return;
    }
    
    NSData *buffer = [NSData dataWithBytesNoCopy:inBuffer->mAudioData length:inBuffer->mAudioDataByteSize freeWhenDone:NO];
    player.dataCallback(buffer);
    
    OSStatus status = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    CheckOSStatus(status, "AQPlayer", "AudioQueueEnqueueBuffer failed");
}

@implementation ZGAudioQueuePlayer {
    AudioQueueRef _audioQueue;
    AudioQueueBufferRef _audioBuffers[kAudioQueueBuffers];
}

- (instancetype)initWithSampleRate:(Float64)sampleRate {
    self = [super init];
    if (self) {
        _sampleRate = sampleRate;
    }
    return self;
}

- (void)dealloc {
    [self stopPlaying];
}

- (BOOL)startPlaying {
    if (![self setupAudioQueue]) {
        return NO;
    }
    
    OSStatus status = AudioQueueStart(_audioQueue, NULL);
    if (CheckOSStatus(status, "AQPlayer", "AudioQueueStart failed")) {
        return NO;
    }
    
    return YES;
}

- (BOOL)stopPlaying {
    OSStatus status = AudioQueueStop(_audioQueue, true);
    if (CheckOSStatus(status, "AQPlayer", "AudioQueueStop failed")) {
        return NO;
    }
    
    for (int i = 0; i < kAudioQueueBuffers; i++) {
        AudioQueueFreeBuffer(_audioQueue, _audioBuffers[i]);
    }
    
    status = AudioQueueDispose(_audioQueue, true);
    if (CheckOSStatus(status, "AQPlayer", "AudioQueueDispose failed")) {
        return NO;
    }
    
    return YES;
}

- (BOOL)setupAudioQueue {
    AudioStreamBasicDescription desc;
    [ZGAudioCommonTool setPCMASBD:&desc sampleRate:_sampleRate];
    
    // duration * sampleRate * bytesPerFrame * channelsPerFrame
    UInt32 audioQueueBufferSize = kBufferDurationSeconds * desc.mSampleRate * desc.mBytesPerFrame * desc.mChannelsPerFrame;
    
    OSStatus status = AudioQueueNewOutput(&desc, ZGAudioQueueOutputCallback,
                                          (__bridge void *)(self), NULL, NULL, 0, &_audioQueue);
    if (CheckOSStatus(status, "AQPlayer", "AudioQueueNewOutput failed")) {
        return NO;
    }
    
    for (int i = 0; i < kAudioQueueBuffers; ++i) {
        status = AudioQueueAllocateBuffer(_audioQueue, audioQueueBufferSize, &_audioBuffers[i]);
        if (CheckOSStatus(status, "AQPlayer", "AudioQueueAllocateBuffer failed")) {
            return NO;
        }
        
        memset(_audioBuffers[i]->mAudioData, 0, audioQueueBufferSize);
        _audioBuffers[i]->mAudioDataByteSize = audioQueueBufferSize;
        status = AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL);
        if (CheckOSStatus(status, "AQPlayer", "AudioQueueEnqueueBuffer failed")) {
            return NO;
        }
    }
    
    return YES;
}

@end

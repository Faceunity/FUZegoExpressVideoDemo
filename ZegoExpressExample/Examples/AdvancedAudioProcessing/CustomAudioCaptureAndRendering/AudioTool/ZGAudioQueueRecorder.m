//
//  ZGAudioQueueRecorder.m
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2023/5/10.
//  Copyright © 2023 Zego. All rights reserved.
//

#import "ZGAudioQueueRecorder.h"
#import "ZGAudioCommonTool.h"

static void ZGAudioQueueInputCallback(void *inUserData, AudioQueueRef inAQ,
                                      AudioQueueBufferRef inBuffer,
                                      const AudioTimeStamp *inStartTime,
                                      UInt32 inNumberPacketDescriptions,
                                      const AudioStreamPacketDescription *inPacketDescs) {
    ZGAudioQueueRecorder *recorder = (__bridge ZGAudioQueueRecorder *)inUserData;
    if (!recorder) {
        return;
    }
    
    NSData *buffer = [NSData dataWithBytes:inBuffer->mAudioData
                                    length:inBuffer->mAudioDataByteSize];
    CMTime timestamp = CMTimeMake(inStartTime->mSampleTime, recorder.sampleRate);
    recorder.dataCallback(buffer, timestamp);
    
    OSStatus status = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    CheckOSStatus(status, "AQRecorder", "AudioQueueEnqueueBuffer failed");
}

@implementation ZGAudioQueueRecorder {
    AudioQueueRef _audioQueue;
    AudioQueueBufferRef _audioBuffers[kAudioQueueBuffers];
}

- (instancetype)initWithSampleRate:(Float64)sampleRate format:(ZGAudioCaptureFormat)format {
    self = [super init];
    if (self) {
        _sampleRate = sampleRate;
        _captureFormat = format;
    }
    return self;
}

- (void)dealloc {
    [self stopRecording];
}

- (BOOL)startRecording {
    if (![self setupAudioQueue]) {
        return NO;
    }
    
    OSStatus status = AudioQueueStart(_audioQueue, NULL);
    if (CheckOSStatus(status, "AQRecorder", "AudioQueueStart failed")) {
        return NO;
    }

    return YES;
}

- (BOOL)stopRecording {
    OSStatus status = AudioQueueStop(_audioQueue, true);
    if (CheckOSStatus(status, "AQRecorder", "AudioQueueStop failed")) {
        return NO;
    }
    
    for (int i = 0; i < kAudioQueueBuffers; i++) {
        AudioQueueFreeBuffer(_audioQueue, _audioBuffers[i]);
    }
    
    status = AudioQueueDispose(_audioQueue, true);
    if (CheckOSStatus(status, "AQRecorder", "AudioQueueDispose failed")) {
        return NO;
    }
    
    return YES;
}

- (BOOL)setupAudioQueue {
    AudioStreamBasicDescription desc;
    UInt32 audioQueueBufferSize = 0;
    switch (_captureFormat) {
    case ZGAudioCaptureFormatPCM:
        [ZGAudioCommonTool setPCMASBD:&desc sampleRate:_sampleRate];
        // duration * sampleRate * bytesPerFrame * channelsPerFrame
        audioQueueBufferSize = kBufferDurationSeconds * desc.mSampleRate * desc.mBytesPerFrame * desc.mChannelsPerFrame;
        break;

    case ZGAudioCaptureFormatAAC:
        [ZGAudioCommonTool setAACASBD:&desc sampleRate:_sampleRate];
        audioQueueBufferSize = desc.mFramesPerPacket;
        break;
    }

    OSStatus status =
        AudioQueueNewInput(&desc, ZGAudioQueueInputCallback, (__bridge void *)(self), NULL,
                           kCFRunLoopCommonModes, 0, &_audioQueue);
    if (CheckOSStatus(status, "AQRecorder", "AudioQueueNewInput failed")) {
        return NO;
    }

    for (int i = 0; i < kAudioQueueBuffers; ++i) {
        status = AudioQueueAllocateBuffer(_audioQueue, audioQueueBufferSize, &_audioBuffers[i]);
        if (CheckOSStatus(status, "AQRecorder", "AudioQueueAllocateBuffer failed")) {
            return NO;
        }
        
        status = AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL);
        if (CheckOSStatus(status, "AQRecorder", "AudioQueueEnqueueBuffer failed")) {
            return NO;
        }
    }
    return YES;
}

@end

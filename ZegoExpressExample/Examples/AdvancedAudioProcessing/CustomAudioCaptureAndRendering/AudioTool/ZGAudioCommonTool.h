//
//  ZGAudioCommonTool.h
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2023/5/11.
//  Copyright © 2023 Zego. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kAudioQueueBuffers 3
#define kBufferDurationSeconds 0.02

/// YES means error occurs
bool CheckOSStatus(OSStatus status, const char *tag, const char *message);

@interface ZGAudioCommonTool : NSObject

+ (void)setPCMASBD:(AudioStreamBasicDescription *)desc sampleRate:(Float64)sampleRate;

+ (void)setAACASBD:(AudioStreamBasicDescription *)desc sampleRate:(Float64)sampleRate;

+ (BOOL)isAudioQueueRunning:(AudioQueueRef)queue;

+ (uint8_t)samplingFrequencyIndexForSampleRate:(NSUInteger)sampleRate;

/// The Audio Specific Config is the global header for MPEG-4 Audio
///
/// https://wiki.multimedia.cx/index.php?title=MPEG-4_Audio#Channel_Configurations
///
///    5 bits: object type
///    if (object type == 31)
///        6 bits + 32: object type
///    4 bits: frequency index
///    if (frequency index == 15)
///        24 bits: frequency
///    4 bits: channel configuration
///    var bits: AOT Specific Config
+ (NSData *)generateAacAudioSpecificConfigForSampleRate:(Float64)sampleRate;

/// ADTS header at the beginning of each and every AAC packet.
///
/// See: http://wiki.multimedia.cx/index.php?title=ADTS
/// Also: http://wiki.multimedia.cx/index.php?title=MPEG-4_Audio#Channel_Configurations
+ (NSData *)generateAacAdtsDataForSampleRate:(Float64)sampleRate aacBufferSize:(NSInteger)aacBufferSize;

+ (NSString *)writePcmData:(NSData *)pcmData toLocalWavFileName:(NSString *)wavFileName withSampleRate:(NSInteger)sampleRate channels:(NSInteger)channels;

+ (NSString *)writeAacData:(NSData *)aacData toLocalFileName:(NSString *)fileName withSampleRate:(NSInteger)sampleRate channels:(NSInteger)channels;

@end

NS_ASSUME_NONNULL_END

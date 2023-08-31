//
//  ZGAudioCommonTool.m
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2023/5/11.
//  Copyright © 2023 Zego. All rights reserved.
//

#import "ZGAudioCommonTool.h"

bool CheckOSStatus(OSStatus status, const char *tag, const char *message) {
    if (status != noErr) {
        char fourCC[16];
        *(UInt32 *)fourCC = CFSwapInt32HostToBig(status);
        fourCC[4] = '\0';
        
        if (isprint(fourCC[0]) && isprint(fourCC[1]) && isprint(fourCC[2]) && isprint(fourCC[3])) {
            NSLog(@"[%s] %s: %d (%s)", tag, message, (int)status, fourCC);
        } else {
            NSLog(@"[%s] %s: %d", tag, message, (int)status);
        }
        return true;
    }
    return false;
}

@implementation ZGAudioCommonTool

+ (void)setPCMASBD:(AudioStreamBasicDescription *)desc sampleRate:(Float64)sampleRate {
    desc->mSampleRate = sampleRate;
    desc->mFormatID = kAudioFormatLinearPCM;
    desc->mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    desc->mBitsPerChannel = 16;
    desc->mChannelsPerFrame = 1;
    desc->mFramesPerPacket = 1;
    desc->mBytesPerFrame = (desc->mBitsPerChannel / 8) * desc->mChannelsPerFrame;
    desc->mBytesPerPacket = desc->mBytesPerFrame * desc->mFramesPerPacket;
}

+ (void)setAACASBD:(AudioStreamBasicDescription *)desc sampleRate:(Float64)sampleRate {
    desc->mSampleRate = sampleRate;
    desc->mFormatID = kAudioFormatMPEG4AAC;
    desc->mFormatFlags = kMPEG4Object_AAC_LC;
    desc->mBitsPerChannel = 0;
    desc->mChannelsPerFrame = 1;
    desc->mFramesPerPacket = 1024;
    desc->mBytesPerFrame = 0;
    desc->mBytesPerPacket = 0;
    desc->mReserved = 0;
}

+ (BOOL)isAudioQueueRunning:(AudioQueueRef)queue {
    UInt32 isRunning;
    UInt32 size = sizeof(isRunning);
    AudioQueueGetProperty(queue, kAudioQueueProperty_IsRunning, &isRunning, &size);
    return (BOOL)isRunning;
}

+ (uint8_t)samplingFrequencyIndexForSampleRate:(NSUInteger)sampleRate {
    static uint32_t samplingFrequencyIndexTable[] = {96000, 88200, 64000, 48000, 44100, 32000, 24000, 22050, 16000, 12000, 11025, 8000, 7350};
    for (int i = 0; i < 13; i++) {
        if (sampleRate == samplingFrequencyIndexTable[i]) {
            return (uint8_t)i;
        }
    }
    return 0;
}

+ (NSData *)generateAacAudioSpecificConfigForSampleRate:(Float64)sampleRate {
    uint8_t asc[2] = {0};

    // 1st part 5 bits: MPEG-4 Audio Object Type: AAC-LC, index: 2 (00010)
    asc[0] |= 0b00010000;

    // 2nd part 4 bits: frequency index
    if (sampleRate == 8000) {
        // 8000 Hz, index: 11 (1011)
        asc[0] |= 0b00000101;
        asc[1] |= 0b10000000;
    } else if (sampleRate == 16000) {
        // 16000 Hz, index: 8 (1000)
        asc[0] |= 0b00000100;
        asc[1] |= 0b00000000;
    } else if (sampleRate == 24000) {
        // 16000 Hz, index: 6 (0110)
        asc[0] |= 0b00000011;
        asc[1] |= 0b00000000;
    } else if (sampleRate == 32000) {
        // 16000 Hz, index: 5 (0101)
        asc[0] |= 0b00000010;
        asc[1] |= 0b10000000;
    } else if (sampleRate == 44100) {
        // 44100 Hz, index: 4 (0100)
        asc[0] |= 0b00000010;
        asc[1] |= 0b00000000;
    } else if (sampleRate == 48000) {
        // 48000 Hz, index: 3 (0011)
        asc[0] |= 0b00000001;
        asc[1] |= 0b10000000;
    } else {
        assert(false); // Unhandled sample rate
    }

    // 3rd part 4 bits: channel configuration index: Mono, index: 1 (0001)
    asc[1] |= 0b00001000;

    // 4th part 3 bits: AOT Specific Config: It must be all 0 for AAC-LC
    asc[1] |= 0b00000000;

    NSLog(@"Audio Specific Config: 0x%02x 0x%02x", asc[0], asc[1]);

    NSData *ascData = [NSData dataWithBytes:asc length:2];
    return ascData;
}

+ (NSData *)generateAacAdtsDataForSampleRate:(Float64)sampleRate aacBufferSize:(NSInteger)aacBufferSize {
    NSInteger adtsLength = 7;
    uint8_t adts[7] = {0};

    NSInteger channels = 1; // Mono
    NSInteger profile = 2;  //AAC LC
    NSInteger sampleRateIndex = [ZGAudioCommonTool samplingFrequencyIndexForSampleRate:sampleRate];

    NSInteger fullBufferSize = aacBufferSize + adtsLength;

    adts[0] = (char)0xFF; // 11111111     = syncword
    adts[1] = (char)0xF9; // 1111 1 00 1  = syncword MPEG-2 Layer CRC
    adts[2] = (char)(((profile - 1) << 6) + (sampleRateIndex << 2) + (channels >> 2));
    adts[3] = (char)(((channels & 3) << 6) + (fullBufferSize >> 11));
    adts[4] = (char)((fullBufferSize & 0x7FF) >> 3);
    adts[5] = (char)(((fullBufferSize & 7) << 5) + 0x1F);
    adts[6] = (char)0xFC;
    NSData *data = [NSData dataWithBytes:adts length:adtsLength];
    return data;
}

+ (NSString *)writePcmData:(NSData *)pcmData toLocalWavFileName:(NSString *)wavFileName withSampleRate:(NSInteger)sampleRate channels:(NSInteger)channels {
    NSInteger bitsPerSample = 16;
    NSInteger byteRate = sampleRate * channels * bitsPerSample / 8;
    NSInteger blockAlign = channels * bitsPerSample / 8;
    NSInteger pcmDataSize = pcmData.length;
    NSInteger totalDataSize = pcmDataSize + 36;

    NSMutableData *wavData = [[NSMutableData alloc] init];
    [wavData appendData:[@"RIFF" dataUsingEncoding:NSUTF8StringEncoding]];
    [wavData appendBytes:&totalDataSize length:4];
    [wavData appendData:[@"WAVE" dataUsingEncoding:NSUTF8StringEncoding]];
    [wavData appendData:[@"fmt " dataUsingEncoding:NSUTF8StringEncoding]];
    NSInteger fmtSize = 16;
    [wavData appendBytes:&fmtSize length:4];
    NSInteger audioFormat = 1;
    [wavData appendBytes:&audioFormat length:2];
    [wavData appendBytes:&channels length:2];
    [wavData appendBytes:&sampleRate length:4];
    [wavData appendBytes:&byteRate length:4];
    [wavData appendBytes:&blockAlign length:2];
    [wavData appendBytes:&bitsPerSample length:2];
    [wavData appendData:[@"data" dataUsingEncoding:NSUTF8StringEncoding]];
    [wavData appendBytes:&pcmDataSize length:4];
    [wavData appendData:pcmData];

    NSString *documentsPath =
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
            objectAtIndex:0];
    NSString *wavFilePath = [documentsPath stringByAppendingPathComponent:wavFileName];
    [wavData writeToFile:wavFilePath atomically:YES];
    return wavFilePath;
}

+ (NSString *)writeAacData:(NSData *)aacData toLocalFileName:(NSString *)fileName withSampleRate:(NSInteger)sampleRate channels:(NSInteger)channels {
    NSString *documentsPath =
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
            objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    [aacData writeToFile:filePath atomically:YES];
    return filePath;
}

@end

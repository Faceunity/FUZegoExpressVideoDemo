//
//  ZGAudioToolRecorder.m
//  ZegoExpressExample-iOS-OC
//
//  Created by zego on 2020/7/20.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGAudioToolRecorder.h"
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioToolCommon.h"

static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    char errorString[20];
    // See if it appears to be a 4-char-code
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
    if (isprint(errorString[1]) && isprint(errorString[2]) &&
        isprint(errorString[3]) && isprint(errorString[4])) {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    } else
        // No, format it as an integer
        sprintf(errorString, "%d", (int)error);
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    exit(1);
}

@implementation ZGAudioToolRecorder
{
    AudioUnit audioUnit;
    int _sampleRate;
    int _bufferSize;
}

- (instancetype)initWithSampleRate:(Float64)sampleRate bufferSize:(int)bufferSize {
    if (self = [super init]) {
        _sampleRate = sampleRate;
        _bufferSize = bufferSize;
        [self initPlayer];
    }
    return self;
}


- (double)getCurrentTime {
    Float64 timeInterval = 0;
    
    return timeInterval;
}



- (void)initPlayer {
    NSError *error = nil;
    OSStatus status = noErr;
    
    // set audio session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    AudioComponentDescription audioDesc;
    audioDesc.componentType = kAudioUnitType_Output;
    audioDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    audioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    audioDesc.componentFlags = 0;
    audioDesc.componentFlagsMask = 0;
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &audioDesc);
    AudioComponentInstanceNew(inputComponent, &audioUnit);
    
    //audio property
    UInt32 flag = 1;
    if (flag) {
        status = AudioUnitSetProperty(audioUnit,
                                      kAudioOutputUnitProperty_EnableIO,
                                      kAudioUnitScope_Output,
                                      OUTPUT_BUS,
                                      &flag,
                                      sizeof(flag));
    }
    if (status) {
        NSLog(@"AudioUnitSetProperty error with status:%d", status);
    }
    
    // format
    AudioStreamBasicDescription recordFormat;
    memset(&recordFormat, 0, sizeof(recordFormat));
    recordFormat.mSampleRate       = _sampleRate; // 采样率
    recordFormat.mFormatID         = kAudioFormatLinearPCM; // PCM格式
    recordFormat.mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger; // 整形
    recordFormat.mFramesPerPacket  = 1; // 每帧只有1个packet
    recordFormat.mChannelsPerFrame = 1; // 声道数
    recordFormat.mBytesPerFrame    = 2; // 每帧只有2个byte 声道*位深*Packet数
    recordFormat.mBytesPerPacket   = 2; // 每个Packet只有2个byte
    recordFormat.mBitsPerChannel   = 16; // 位深
    [self printAudioStreamBasicDescription:recordFormat];

    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  INPUT_BUS,
                                  &recordFormat,
                                  sizeof(recordFormat));
    if (status) {
        NSLog(@"AudioUnitSetProperty eror with status:%d", status);
    }
    
    // enable record
    status = AudioUnitSetProperty(audioUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input,
                         INPUT_BUS,
                         &flag,
                         sizeof(flag));
    if (status != noErr) {
        NSLog(@"AudioUnitGetProperty error, ret: %d", status);
    }
    
    //设置回调
    AURenderCallbackStruct inputCallBackStruce;
    inputCallBackStruce.inputProc = RecordCallback;
    inputCallBackStruce.inputProcRefCon = (__bridge void * _Nullable)(self);
    
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Output,
                                  INPUT_BUS,
                                  &inputCallBackStruce,
                                  sizeof(inputCallBackStruce));
    if (status != noErr) {
        NSLog(@"setProperty InputCallback error, ret: %d", status);
    }
    
    AudioStreamBasicDescription outputDesc0;
    UInt32 size = sizeof(outputDesc0);
    CheckError(AudioUnitGetProperty(audioUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Output,
                                    0,
                                    &outputDesc0,
                                    &size),"get property failure");
    
    AudioStreamBasicDescription outputDesc1;
    size = sizeof(outputDesc1);
    CheckError(AudioUnitGetProperty(audioUnit,
                                    kAudioUnitProperty_StreamFormat,
                                    kAudioUnitScope_Input,
                                    0,
                                    &outputDesc1,
                                    &size),"get property failure");


}


static OSStatus RecordCallback(void *inRefCon,
                               AudioUnitRenderActionFlags *ioActionFlags,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 inBusNumber,
                               UInt32 inNumberFrames,
                               AudioBufferList *ioData)
{
    ZGAudioToolRecorder *recorder = (__bridge ZGAudioToolRecorder *)inRefCon;
        typeof(recorder) __weak weakPlayer = recorder;
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = NULL;
    bufferList.mBuffers[0].mDataByteSize = 0;
    
    AudioUnitRender(recorder->audioUnit,
                    ioActionFlags,
                    inTimeStamp,
                    INPUT_BUS,
                    inNumberFrames,
                    &bufferList);
    
    if (recorder.bl_output)
    {
        recorder.bl_output(weakPlayer, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
    }
    return noErr;
}


- (void)start
{
    AudioOutputUnitStart(audioUnit);
}

- (void)stop
{
    AudioOutputUnitStop(audioUnit);
//    AudioUnitUninitialize(audioUnit);
//    AudioComponentInstanceDispose(audioUnit);
}

- (void)dealloc {
    AudioOutputUnitStop(audioUnit);
    AudioUnitUninitialize(audioUnit);
    AudioComponentInstanceDispose(audioUnit);
}


- (void)printAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd {
    char formatID[5];
    UInt32 mFormatID = CFSwapInt32HostToBig(asbd.mFormatID);
    bcopy (&mFormatID, formatID, 4);
    formatID[4] = '\0';
    printf("Sample Rate:         %10.0f\n",  asbd.mSampleRate);
    printf("Format ID:           %10s\n",    formatID);
    printf("Format Flags:        %10X\n",    (unsigned int)asbd.mFormatFlags);
    printf("Bytes per Packet:    %10d\n",    (unsigned int)asbd.mBytesPerPacket);
    printf("Frames per Packet:   %10d\n",    (unsigned int)asbd.mFramesPerPacket);
    printf("Bytes per Frame:     %10d\n",    (unsigned int)asbd.mBytesPerFrame);
    printf("Channels per Frame:  %10d\n",    (unsigned int)asbd.mChannelsPerFrame);
    printf("Bits per Channel:    %10d\n",    (unsigned int)asbd.mBitsPerChannel);
    printf("\n");
}

@end


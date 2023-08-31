//
//  ZGCaptureDeviceMediaPlayer.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2021/2/23.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGCaptureDeviceMediaPlayer.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGCaptureDeviceMediaPlayer () <ZegoMediaPlayerEventHandler, ZegoMediaPlayerVideoHandler>

@property (nonatomic, strong) ZegoMediaPlayer *mediaPlayer;

@property (nonatomic, copy) NSString *resourceURL;

@end

@implementation ZGCaptureDeviceMediaPlayer


- (instancetype)initWithMediaResource:(NSString *)resource {
    self = [super init];
    if (self) {
        self.resourceURL = resource;
    }
    return self;
}

- (void)startCapture {
    ZGLogInfo(@"▶️ Start capture media player");

    __weak typeof(self) weakSelf = self;
    [self.mediaPlayer loadResource:self.resourceURL callback:^(int errorCode) {
        ZGLogInfo(@"🚩 💽 Media Player load resource. errorCode: %d", errorCode);
        __strong typeof(self) strongSelf = weakSelf;
        ZGLogInfo(@"▶️ Media Player start");
        [strongSelf.mediaPlayer start];
    }];

}

- (void)stopCapture {
    if (_mediaPlayer) {
        ZGLogInfo(@"⏸ Stop capture media player");
        ZGLogInfo(@"⏹ Media Player stop");
        [_mediaPlayer stop];

        ZGLogInfo(@"🏳️ Destroy media player");
        [[ZegoExpressEngine sharedEngine] destroyMediaPlayer:_mediaPlayer];

        _mediaPlayer = nil;
    }
}

- (ZegoMediaPlayer *)mediaPlayer {
    if (!_mediaPlayer) {
        ZegoMediaPlayer *player = [[ZegoExpressEngine sharedEngine] createMediaPlayer];
        if (player) {
            ZGLogInfo(@"💽 Create ZegoMediaPlayer");
            _mediaPlayer = player;

            // set media player event handler
            [_mediaPlayer setEventHandler:self];

            // enable video frame callback
            [_mediaPlayer setVideoHandler:self format:ZegoVideoFrameFormatBGRA32 type:ZegoVideoBufferTypeCVPixelBuffer];
            [_mediaPlayer enableAux:YES];
            [_mediaPlayer enableRepeat:YES];
            [_mediaPlayer muteLocal:NO];

        } else {
            ZGLogWarn(@"💽 ❌ Create ZegoMediaPlayer failed");
        }
    }
    return _mediaPlayer;
}


#pragma mark - Media Player Event Handler

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer stateUpdate:(ZegoMediaPlayerState)state errorCode:(int)errorCode {
    ZGLogInfo(@"🚩 📻 Media Player State Update: %d, errorCode: %d", (int)state, errorCode);
    switch (state) {
        case ZegoMediaPlayerStateNoPlay:
            // Stop
            break;
        case ZegoMediaPlayerStatePlaying:
            // Playing
            break;
        case ZegoMediaPlayerStatePausing:
            // Pausing
            break;
        case ZegoMediaPlayerStatePlayEnded:
            // Play ended, developer can play next song, etc.
            break;
    }
}

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer networkEvent:(ZegoMediaPlayerNetworkEvent)networkEvent {
    ZGLogInfo(@"🚩 ⏳ Media Player Network Event: %d", (int)networkEvent);
    if (networkEvent == ZegoMediaPlayerNetworkEventBufferBegin) {
        // Show loading UI, etc.
    } else if (networkEvent == ZegoMediaPlayerNetworkEventBufferEnded) {
        // End loading UI, etc.
    }
}

- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer playingProgress:(unsigned long long)millisecond {
    // Update progress bar, etc.
}

#pragma mark - Media Player Video Handler

/// When video frame type is set to `ZegoVideoFrameTypeCVPixelBuffer`, video frame CVPixelBuffer data will be called back from this function
/// @note Need to switch threads before processing video frames
- (void)mediaPlayer:(ZegoMediaPlayer *)mediaPlayer videoFramePixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param {
    //    NSLog(@"pixel buffer video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);

    CMTime time = CMTimeMakeWithSeconds([[NSDate date] timeIntervalSince1970], 1000);
    CMSampleTimingInfo timingInfo = { kCMTimeInvalid, time, time };

    CMVideoFormatDescriptionRef desc;
    CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, buffer, &desc);

    CMSampleBufferRef sampleBuffer;
    CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, (CVImageBufferRef)buffer, desc, &timingInfo, &sampleBuffer);

    id<ZGCaptureDeviceDataOutputPixelBufferDelegate> delegate = self.delegate;
    if (delegate &&
        [delegate respondsToSelector:@selector(captureDevice:didCapturedData:)]) {
        [delegate captureDevice:self didCapturedData:sampleBuffer];
    }

    CFRelease(sampleBuffer);
    CFRelease(desc);
}

@end

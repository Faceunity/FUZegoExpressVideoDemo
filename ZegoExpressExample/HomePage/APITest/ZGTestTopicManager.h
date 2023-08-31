//
//  ZGTestTopicManager.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/24.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_Test

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import <ZegoExpressEngine/ZegoExpressEngine+IM.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZGTestDataSource <NSObject>

@required

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality;

- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality;

- (void)onPublisherVideoSizeChanged:(CGSize)size;

- (void)onPlayerVideoSizeChanged:(CGSize)size;

- (void)onActionLog:(NSString *)logInfo;

@end



@protocol ZGTestManager <NSObject>

@required

- (void)setZGTestDataSource:(id<ZGTestDataSource>)dataSource;

#pragma mark - Engine

- (void)createEngineWithAppID:(unsigned int)appID appSign:(NSString *)appSign scenario:(ZegoScenario)scenario;


- (void)destroyEngine;


- (void)setRoomScenario:(ZegoScenario)scenario;


- (NSString *)getVersion;


- (void)uploadLog;


- (void)enableDebugAssistant:(BOOL)enable;


- (void)setRoomMode:(ZegoRoomMode)mode;


- (void)setEngineConfig:(ZegoEngineConfig *)config;


#pragma mark - Room

- (void)loginRoom:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName config:(nullable ZegoRoomConfig *)config;


- (void)switchRoom:(NSString *)fromRoomID toRoomID:(NSString *)toRoomID;


- (void)logoutRoom:(NSString *)roomID;


#pragma mark - Publish

- (void)startPublishingStream:(NSString *)streamID roomID:(nullable NSString *)roomID;


- (void)stopPublishingStream;


- (void)startPreview:(ZegoCanvas *)canvas;


- (void)stopPreview;


- (void)setVideoConfig:(ZegoVideoConfig *)videoConfig;


- (void)setVideoMirrorMode:(ZegoVideoMirrorMode)mirrorMode;


- (void)setAppOrientation:(UIInterfaceOrientation)orientation;


- (ZegoAudioConfig *)getAudioConfig;


- (void)setAudioConfig:(ZegoAudioConfig *)config;


- (void)mutePublishStreamAudio:(BOOL)mute;


- (void)mutePublishStreamVideo:(BOOL)mute;


- (void)setCaptureVolume:(int)volume;


- (void)addPublishCdnUrl:(NSString *)targetURL streamID:(NSString *)streamID callback:(nullable ZegoPublisherUpdateCdnUrlCallback)callback;


- (void)removePublishCdnUrl:(NSString *)targetURL streamID:(NSString *)streamID callback:(nullable ZegoPublisherUpdateCdnUrlCallback)callback;


- (void)enableHardwareEncoder:(BOOL)enable;


- (void)setWatermark:(ZegoWatermark *)watermark isPreviewVisible:(BOOL)isPreviewVisible;


- (void)setCapturePipelineScaleMode:(ZegoCapturePipelineScaleMode)scaleMode;


- (void)sendSEI:(NSData *)data;


- (void)setAudioCaptureStereoMode:(ZegoAudioCaptureStereoMode)mode;


#pragma mark - Player

- (void)startPlayingStream:(NSString *)streamID canvas:(ZegoCanvas *)canvas roomID:(nullable NSString *)roomID;


- (void)stopPlayingStream:(NSString *)streamID;


- (void)setPlayVolume:(int)volume stream:(NSString *)streamID;


- (void)mutePlayStreamAudio:(BOOL)mute streamID:(NSString *)streamID;


- (void)mutePlayStreamVideo:(BOOL)mute streamID:(NSString *)streamID;


- (void)enableHarewareDecoder:(BOOL)enable;


- (void)enableCheckPoc:(BOOL)enable;


#pragma mark - PreProcess

- (void)enableAEC:(BOOL)enable;


- (void)setAECMode:(ZegoAECMode)mode;


- (void)enableAGC:(BOOL)enable;


- (void)enableANS:(BOOL)enable;


- (void)enableBeautify:(int)feature;


- (void)setBeautifyOption:(ZegoBeautifyOption *)option;


#pragma mark - Device

- (void)muteMicrophone:(BOOL)mute;


- (void)muteSpeaker:(BOOL)mute;


- (void)enableCamera:(BOOL)enable;


- (void)useFrontCamera:(BOOL)enable;


- (void)enableAudioCaptureDevice:(BOOL)enable;


- (void)startSoundLevelMonitor;


- (void)stopSoundLevelMonitor;


- (void)startAudioSpectrumMonitor;


- (void)stopAudioSpectrumMonitor;


- (void)startPerformanceMonitor;


- (void)stopPerformanceMonitor;


#pragma mark - Mixer


- (void)startMixerTask:(ZegoMixerTask *)task;


- (void)stopMixerTask:(ZegoMixerTask *)task;


#pragma mark - IM


- (void)sendBroadcastMessage:(NSString *)message roomID:(NSString *)roomID;


- (void)sendCustomCommand:(NSString *)command toUserList:(nullable NSArray<ZegoUser *> *)toUserList roomID:(NSString *)roomID;

#pragma mark - RTSD

- (void)createRealTimeSequentialDataManager:(NSString *)roomID;

- (void)destroyRealTimeSequentialDataManager:(NSString *)roomID;

- (void)startBroadcasting:(NSString *)streamID managerRoomID:(NSString *)roomID;

- (void)stopBroadcasting:(NSString *)streamID managerRoomID:(NSString *)roomID;

- (void)sendRealTimeSequentialData:(NSString *)data streamID:(NSString *)streamID managerRoomID:(NSString *)roomID;

- (void)startSubscribing:(NSString *)streamID managerRoomID:(NSString *)roomID;

- (void)stopSubscribing:(NSString *)streamID managerRoomID:(NSString *)roomID;


#pragma mark - Utils


- (void)startNetworkSpeedTest;


- (void)stopNetworkSpeedTest;


@end



@interface ZGTestTopicManager : NSObject<ZGTestManager>

@end


NS_ASSUME_NONNULL_END

#endif

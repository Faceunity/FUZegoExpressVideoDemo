//
//  ZGTestTopicManager.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/24.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_Test

#import "ZGTestTopicManager.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"

@interface ZGTestTopicManager () <ZegoEventHandler>

@property (nonatomic, strong) ZegoExpressEngine *engine;

@property (nonatomic, weak) id<ZGTestDataSource> dataSource;

@end

@implementation ZGTestTopicManager

- (void)dealloc {
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)setZGTestDataSource:(id<ZGTestDataSource>)dataSource {
    self.dataSource = dataSource;
}

- (void)createEngineWithAppID:(unsigned int)appID appSign:(NSString *)appSign isTestEnv:(BOOL)isTestEnv scenario:(ZegoScenario)scenario {
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    [self.dataSource onActionLog:@"🚀 Create ZegoExpressEngine"];
    self.engine = [ZegoExpressEngine createEngineWithAppID:appID appSign:appSign isTestEnv:isTestEnv scenario:scenario eventHandler:self];
}

- (void)destroyEngine {
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [self.dataSource onActionLog:@"🏳️ Destroy ZegoExpressEngine"];
    [ZegoExpressEngine destroyEngine:^{
        // This callback is only used to notify the completion of the release of internal resources of the engine.
        // Developers cannot release resources related to the engine within this callback.
        //
        // In general, developers do not need to listen to this callback.
        ZGLogInfo(@"🚩 🏳️ Destroy ZegoExpressEngine complete");
    }];
}

- (NSString *)getVersion {
    NSString *version = [ZegoExpressEngine getVersion];
    ZGLogInfo(@"ℹ️ Engine Version: %@", version);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"ℹ️ Engine Version: %@", version]];
    return version;
}

- (void)uploadLog {
    [self.engine uploadLog];
    ZGLogInfo(@"📬 Upload Log");
    [self.dataSource onActionLog:@"📬 Upload Log"];
}

- (void)setDebugVerbose:(BOOL)enable language:(ZegoLanguage)language {
    [self.engine setDebugVerbose:enable language:language];
    ZGLogInfo(@"📬 set debug verbose:%d, language:%@", enable, language == ZegoLanguageEnglish ? @"English" : @"中文");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"📬 set debug verbose:%d, language:%@", enable, language == ZegoLanguageEnglish ? @"English" : @"中文"]];
}


#pragma mark Room

- (void)loginRoom:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName {
    ZegoRoomConfig *roomConfig = [[ZegoRoomConfig alloc] init];
    roomConfig.isUserStatusNotify = YES;

    [self.engine loginRoom:roomID user:[ZegoUser userWithUserID:userID userName:userName] config:roomConfig];
    ZGLogInfo(@"🚪 Login room. roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🚪 Login room. roomID: %@", roomID]];
}

- (void)loginMultiRoom:(NSString *)roomID {
    ZegoRoomConfig *roomConfig = [[ZegoRoomConfig alloc] init];
    roomConfig.isUserStatusNotify = YES;

    [self.engine loginMultiRoom:roomID config:roomConfig];
    ZGLogInfo(@"🚪 Login multi room. roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🚪 Login multi room. roomID: %@", roomID]];
}

- (void)switchRoom:(NSString *)fromRoomID toRoomID:(NSString *)toRoomID {
    [self.engine switchRoom:fromRoomID toRoomID:toRoomID];
    ZGLogInfo(@"🚪 Switch room. from roomID: %@, to roomID: %@", fromRoomID, toRoomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🚪 Switch room. from roomID: %@, to roomID: %@", fromRoomID, toRoomID]];
}


- (void)logoutRoom:(NSString *)roomID {
    [self.engine logoutRoom:roomID];
    ZGLogInfo(@"🚪 Logout room. roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🚪 Logout room. roomID: %@", roomID]];
}


#pragma mark Publish

- (void)startPublishingStream:(NSString *)streamID {
    [self.engine startPublishingStream:streamID];
    ZGLogInfo(@"📤 Start publishing stream. streamID: %@", streamID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", streamID]];
}


- (void)stopPublishingStream {
    [self.engine stopPublishingStream];
    ZGLogInfo(@"📤 Stop publishing stream");
    [self.dataSource onActionLog:@"📤 Stop publishing stream"];
}


- (void)startPreview:(ZegoCanvas *)canvas {
    [self.engine startPreview:canvas];
    ZGLogInfo(@"🔌 Start preview");
    [self.dataSource onActionLog:@"🔌 Start preview"];
}


- (void)stopPreview {
    [self.engine stopPreview];
    ZGLogInfo(@"🔌 Stop preview");
    [self.dataSource onActionLog:@"🔌 Stop preview"];
}


- (void)setVideoConfig:(ZegoVideoConfig *)videoConfig {
    [self.engine setVideoConfig:videoConfig];
    ZGLogInfo(@"🧷 Set video config. width: %d, height: %d, bitrate: %d, fps: %d", (int)videoConfig.captureResolution.width, (int)videoConfig.captureResolution.height, videoConfig.bitrate, videoConfig.fps);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🧷 Set video config. width: %d, height: %d, bitrate: %d, fps: %d", (int)videoConfig.captureResolution.width, (int)videoConfig.captureResolution.height, videoConfig.bitrate, videoConfig.fps]];
}


- (void)setVideoMirrorMode:(ZegoVideoMirrorMode)mirrorMode {
    [self.engine setVideoMirrorMode:mirrorMode];
    ZGLogInfo(@"⚙️ Set video mirror mode. Mode: %d", (int)mirrorMode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"⚙️ Set video mirror mode. Mode: %d", (int)mirrorMode]];
}


- (void)setAppOrientation:(UIInterfaceOrientation)orientation {
    [self.engine setAppOrientation:orientation];
    ZGLogInfo(@"⚙️ Set capture orientation: %d", (int)orientation);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"⚙️ Set capture orientation: %d", (int)orientation]];
}


- (void)mutePublishStreamAudio:(BOOL)mute {
    [self.engine mutePublishStreamAudio:mute];
    ZGLogInfo(@"🙊 Mute publish stream audio: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🙊 Mute publish stream audio: %@", mute ? @"YES" : @"NO"]];
}


- (void)mutePublishStreamVideo:(BOOL)mute {
    [self.engine mutePublishStreamVideo:mute];
    ZGLogInfo(@"🙈 Mute publish stream video: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🙈 Mute publish stream video: %@", mute ? @"YES" : @"NO"]];
}


- (void)setCaptureVolume:(int)volume {
    [self.engine setCaptureVolume:volume];
    ZGLogInfo(@"⛏ Set capture volume: %d", volume);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"⛏ Set capture volume: %d", volume]];
}


- (void)addPublishCdnUrl:(NSString *)targetURL streamID:(NSString *)streamID callback:(nullable ZegoPublisherUpdateCdnUrlCallback)callback {
    [self.engine addPublishCdnUrl:targetURL streamID:streamID callback:^(int errorCode) {
        if (callback) {
            callback(errorCode);
        }
    }];
    ZGLogInfo(@"🔗 Add publish cdn url: %@, streamID: %@", targetURL, streamID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔗 Add publish cdn url: %@, streamID: %@", targetURL, streamID]];
}


- (void)removePublishCdnUrl:(NSString *)targetURL streamID:(NSString *)streamID callback:(nullable ZegoPublisherUpdateCdnUrlCallback)callback {
    [self.engine removePublishCdnUrl:targetURL streamID:streamID callback:^(int errorCode) {
        if (callback) {
            callback(errorCode);
        }
    }];
    ZGLogInfo(@"🔗 Remove publish cdn url: %@, streamID: %@", targetURL, streamID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔗 Remove publish cdn url: %@, streamID: %@", targetURL, streamID]];
}


- (void)enableHardwareEncoder:(BOOL)enable {
    [self.engine enableHardwareEncoder:enable];
    ZGLogInfo(@"🔧 Enable hardware encoder: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable hardware encoder: %@", enable ? @"YES" : @"NO"]];
}

- (void)setWatermark:(ZegoWatermark *)watermark isPreviewVisible:(BOOL)isPreviewVisible {
    [self.engine setPublishWatermark:watermark isPreviewVisible:isPreviewVisible];
    ZGLogInfo(@"🌅 Set publish watermark, filePath: %@, isPreviewVisible: %@", watermark.imageURL, isPreviewVisible ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🌅 Set publish watermark, filePath: %@, isPreviewVisible: %@", watermark.imageURL, isPreviewVisible ? @"YES" : @"NO"]];
}

- (void)setCapturePipelineScaleMode:(ZegoCapturePipelineScaleMode)scaleMode {
    [self.engine setCapturePipelineScaleMode:scaleMode];
    ZGLogInfo(@"🔧 Set capture pipeline scale mode: %d", (int)scaleMode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Set capture pipeline scale mode: %d", (int)scaleMode]];
}

- (void)sendSEI:(NSData *)data {
    [self.engine sendSEI:data];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    ZGLogInfo(@"✉️ Send SEI: %@", str);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"✉️ Send SEI: %@", str]];
}


#pragma mark Player

- (void)startPlayingStream:(NSString *)streamID canvas:(ZegoCanvas *)canvas {
    [self.engine startPlayingStream:streamID canvas:canvas];
    ZGLogInfo(@"📥 Start playing stream");
    [self.dataSource onActionLog:@"📥 Start playing stream"];
}


- (void)stopPlayingStream:(NSString *)streamID {
    [self.engine stopPlayingStream:streamID];
    ZGLogInfo(@"📥 Stop playing stream");
    [self.dataSource onActionLog:@"📥 Stop playing stream"];
}


- (void)setPlayVolume:(int)volume stream:(NSString *)streamID {
    [self.engine setPlayVolume:volume streamID:streamID];
    ZGLogInfo(@"⛏ Set play volume: %d", volume);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"⛏ Set play volume: %d", volume]];
}


- (void)mutePlayStreamAudio:(BOOL)mute streamID:(NSString *)streamID {
    ZGLogInfo(@"🙊 Mute play stream audio: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🙊 Mute play stream audio: %@", mute ? @"YES" : @"NO"]];
}


- (void)mutePlayStreamVideo:(BOOL)mute streamID:(NSString *)streamID {
    [self.engine mutePlayStreamVideo:mute streamID:streamID];
    ZGLogInfo(@"🙈 Mute play stream video: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🙈 Mute play stream video: %@", mute ? @"YES" : @"NO"]];
}


- (void)enableHarewareDecoder:(BOOL)enable {
    [self.engine enableHardwareDecoder:enable];
    ZGLogInfo(@"🔧 Enable hardware decoder: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable hardware decoder: %@", enable ? @"YES" : @"NO"]];
}

- (void)enableCheckPoc:(BOOL)enable {
    [self.engine enableCheckPoc:enable];
    ZGLogInfo(@"🔧 Enable check poc: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable check poc: %@", enable ? @"YES" : @"NO"]];
}


#pragma mark PreProcess

- (void)enableAEC:(BOOL)enable {
    [self.engine enableAEC:enable];
    ZGLogInfo(@"🔧 Enable AEC: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable AEC: %@", enable ? @"YES" : @"NO"]];
}


- (void)setAECMode:(ZegoAECMode)mode {
    [self.engine setAECMode:mode];
    ZGLogInfo(@"⛏ Set AEC mode: %d", (int)mode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"⛏ Set AEC mode: %d", (int)mode]];
}


- (void)enableAGC:(BOOL)enable {
    [self.engine enableAGC:enable];
    ZGLogInfo(@"🔧 Enable AGC: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable AGC: %@", enable ? @"YES" : @"NO"]];
}


- (void)enableANS:(BOOL)enable {
    [self.engine enableANS:enable];
    ZGLogInfo(@"🔧 Enable ANS: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable ANS: %@", enable ? @"YES" : @"NO"]];
}


- (void)enableBeautify:(int)feature {
    [self.engine enableBeautify:feature];
    ZGLogInfo(@"⛏ Enable beautify: %d", (int)feature);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"⛏ Enable beautify: %d", (int)feature]];
}


- (void)setBeautifyOption:(ZegoBeautifyOption *)option {
    [self.engine setBeautifyOption:option];
    ZGLogInfo(@"🔧 Set eautify option. polishStep: %f, whitenFactor: %f, sharpenFactor: %f", option.polishStep, option.whitenFactor, option.sharpenFactor);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Set eautify option. polishStep: %f, whitenFactor: %f, sharpenFactor: %f", option.polishStep, option.whitenFactor, option.sharpenFactor]];
}


#pragma mark Device

- (void)muteMicrophone:(BOOL)mute {
    [self.engine muteMicrophone:mute];
    ZGLogInfo(@"🔧 Mute microphone: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Mute microphone: %@", mute ? @"YES" : @"NO"]];
}


- (void)muteSpeaker:(BOOL)mute {
    [self.engine muteSpeaker:mute];
    ZGLogInfo(@"🔧 Mute audio output: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Mute audio output: %@", mute ? @"YES" : @"NO"]];
}


- (void)enableCamera:(BOOL)enable {
    [self.engine enableCamera:enable];
    ZGLogInfo(@"🔧 Enable camera: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable camera: %@", enable ? @"YES" : @"NO"]];
}


- (void)useFrontCamera:(BOOL)enable {
    [self.engine useFrontCamera:enable];
    ZGLogInfo(@"🔧 Use front camera: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Use front camera: %@", enable ? @"YES" : @"NO"]];
}


- (void)enableAudioCaptureDevice:(BOOL)enable {
    [self.engine enableAudioCaptureDevice:enable];
    ZGLogInfo(@"🔧 Enable audio capture device: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable audio capture device: %@", enable ? @"YES" : @"NO"]];
}

- (void)startSoundLevelMonitor {
    [self.engine startSoundLevelMonitor];
    ZGLogInfo(@"🎼 Start sound level monitor");
    [self.dataSource onActionLog:@"🎼 Start sound level monitor"];
}

- (void)stopSoundLevelMonitor {
    [self.engine stopSoundLevelMonitor];
    ZGLogInfo(@"🎼 Stop sound level monitor");
    [self.dataSource onActionLog:@"🎼 Stop sound level monitor"];
}

- (void)startAudioSpectrumMonitor {
    [self.engine startAudioSpectrumMonitor];
    ZGLogInfo(@"🎼 Start audio spectrum monitor");
    [self.dataSource onActionLog:@"🎼 Start audio spectrum monitor"];
}

- (void)stopAudioSpectrumMonitor {
    [self.engine stopAudioSpectrumMonitor];
    ZGLogInfo(@"🎼 Stop audio spectrum monitor");
    [self.dataSource onActionLog:@"🎼 Stop audio spectrum monitor"];
}

#pragma mark Mixer

- (void)startMixerTask:(ZegoMixerTask *)task {
    ZGLogInfo(@"🧬 Start mixer task");
    [self.engine startMixerTask:task callback:^(int errorCode, NSDictionary * _Nullable extendedData) {
        ZGLogInfo(@"🚩 🧬 Start mixer task result errorCode: %d", errorCode);
    }];
}

- (void)stopMixerTask:(ZegoMixerTask *)task {
    ZGLogInfo(@"🧬 Stop mixer task");
    [self.engine stopMixerTask:task callback:^(int errorCode) {
        ZGLogInfo(@"🚩 🧬 Stop mixer task result errorCode: %d", errorCode);
    }];
}

#pragma mark IM

- (void)sendBroadcastMessage:(NSString *)message roomID:(NSString *)roomID {
    [self.engine sendBroadcastMessage:message roomID:roomID callback:^(int errorCode, unsigned long long messageID) {
        ZGLogInfo(@"🚩 ✉️ Send broadcast message result errorCode: %d, messageID: %llu", errorCode, messageID);
    }];
}

- (void)sendCustomCommand:(NSString *)command toUserList:(nullable NSArray<ZegoUser *> *)toUserList roomID:(NSString *)roomID {
    [self.engine sendCustomCommand:command toUserList:nil roomID:roomID callback:^(int errorCode) {
        ZGLogInfo(@"🚩 ✉️ Send custom command (to all user) result errorCode: %d", errorCode);
    }];
}


#pragma mark - Callback

- (void)onDebugError:(int)errorCode funcName:(NSString *)funcName info:(NSString *)info {
    ZGLogInfo(@"🚩 ❓ Debug Error Callback: errorCode: %d, FuncName: %@ Info: %@", errorCode, funcName, info);
}

#pragma mark Room Callback

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🚪 Room State Update Callback: %lu, errorCode: %d, roomID: %@", (unsigned long)state, (int)errorCode, roomID);
}


- (void)onRoomUserUpdate:(ZegoUpdateType)updateType userList:(NSArray<ZegoUser *> *)userList roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🕺 Room User Update Callback: %lu, UsersCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)userList.count, roomID);
}

- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🌊 Room Stream Update Callback: %lu, StreamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);
}

- (void)onRoomStreamExtraInfoUpdate:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🌊 Room Stream Extra Info Update Callback, StreamsCount: %lu, roomID: %@", (unsigned long)streamList.count, roomID);
}

#pragma mark Publisher Callback

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📤 Publisher State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📈 Publisher Quality Update Callback: FPS:%f, Bitrate:%f, streamID: %@", quality.videoSendFPS, quality.videoKBPS, streamID);
    
    if ([self.dataSource respondsToSelector:@selector(onPublisherQualityUpdate:)]) {
        [self.dataSource onPublisherQualityUpdate:quality];
    }
}

- (void)onPublisherCapturedAudioFirstFrame {
    ZGLogInfo(@"🚩 ✨ Publisher Captured Audio First Frame Callback");
}

- (void)onPublisherCapturedVideoFirstFrame:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 ✨ Publisher Captured Audio First Frame Callback, channel: %d", (int)channel);
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 📐 Publisher Video Size Changed Callback: Width: %f, Height: %f, channel: %d", size.width, size.height, (int)channel);
    
    if ([self.dataSource respondsToSelector:@selector(onPublisherVideoSizeChanged:)]) {
        [self.dataSource onPublisherVideoSizeChanged:size];
    }
}

- (void)onPublisherRelayCDNStateUpdate:(NSArray<ZegoStreamRelayCDNInfo *> *)streamInfoList streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📡 Publisher Relay CDN State Update Callback: Relaying CDN Count: %lu, streamID: %@", (unsigned long)streamInfoList.count, streamID);
}

#pragma mark Player Callback

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📥 Player State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
}

- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📉 Player Quality Update Callback: FPS:%f, Bitrate:%f, streamID: %@", quality.videoRecvFPS, quality.videoKBPS, streamID);
    
    if ([self.dataSource respondsToSelector:@selector(onPlayerQualityUpdate:)]) {
        [self.dataSource onPlayerQualityUpdate:quality];
    }
}

- (void)onPlayerMediaEvent:(ZegoPlayerMediaEvent)event streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 🎊 Player Media Event Callback: %lu, streamID: %@", (unsigned long)event, streamID);
}

- (void)onPlayerRecvAudioFirstFrame:(NSString *)streamID {
    ZGLogInfo(@"🚩 ⚡️ Player Recv Audio First Frame Callback, streamID: %@", streamID);
}

- (void)onPlayerRecvVideoFirstFrame:(NSString *)streamID {
    ZGLogInfo(@"🚩 ⚡️ Player Recv Video First Frame Callback, streamID: %@", streamID);
}

- (void)onPlayerRenderVideoFirstFrame:(NSString *)streamID {
    ZGLogInfo(@"🚩 ⚡️ Player Recv Render First Frame Callback, streamID: %@", streamID);
}

- (void)onPlayerVideoSizeChanged:(CGSize)size streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📏 Player Video Size Changed Callback: Width: %f, Height: %f, streamID: %@", size.width, size.height, streamID);
    
    if ([self.dataSource respondsToSelector:@selector(onPlayerVideoSizeChanged:)]) {
        [self.dataSource onPlayerVideoSizeChanged:size];
    }
}

- (void)onPlayerRecvSEI:(NSData *)data streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 ✉️ Player Recv SEI: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

#pragma mark Device Callback

- (void)onDeviceError:(int)errorCode deviceName:(NSString *)deviceName {
    ZGLogInfo(@"🚩 💻 Device Error Callback: errorCode: %d, DeviceName: %@", errorCode, deviceName);
}

- (void)onRemoteCameraStateUpdate:(ZegoRemoteDeviceState)state streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📷 Remote Camera State Update Callback: state: %lu, DeviceName: %@", (unsigned long)state, streamID);
}

- (void)onRemoteMicStateUpdate:(ZegoRemoteDeviceState)state streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 🎙 Remote Mic State Update Callback: state: %lu, DeviceName: %@", (unsigned long)state, streamID);
}

#pragma mark Mixer Callback

- (void)onMixerRelayCDNStateUpdate:(NSArray<ZegoStreamRelayCDNInfo *> *)infoList taskID:(NSString *)taskID {
    ZGLogInfo(@"🚩 🧬 Mixer Relay CDN State Update Callback: taskID: %@", taskID);
    for (int idx = 0; idx < infoList.count; idx ++) {
        ZegoStreamRelayCDNInfo *info = infoList[idx];
        ZGLogInfo(@"🚩 🧬 --- %d: state: %lu, URL: %@, reason: %lu", idx, (unsigned long)info.state, info.url, (unsigned long)info.updateReason);
    }
}

#pragma mark IM Callback

- (void)onIMRecvBroadcastMessage:(NSArray<ZegoBroadcastMessageInfo *> *)messageList roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 📩 IM Recv Broadcast Message Callback: roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"📩 Received Broadcast Message"]];
    for (int idx = 0; idx < messageList.count; idx ++) {
        ZegoBroadcastMessageInfo *info = messageList[idx];
        ZGLogInfo(@"🚩 📩 --- %d: message: %@, fromUserID: %@, sendTime: %llu", idx, info.message, info.fromUser.userID, info.sendTime);
        [self.dataSource onActionLog:[NSString stringWithFormat:@"📩 [%@] --- from %@, time: %llu", info.message, info.fromUser.userID, info.sendTime]];
    }
}

- (void)onIMRecvBarrageMessage:(NSArray<ZegoBarrageMessageInfo *> *)messageList roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 📩 IM Recv Barrage Message Callback: roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"📩 Received Broadcast Message"]];
    for (int idx = 0; idx < messageList.count; idx ++) {
        ZegoBarrageMessageInfo *info = messageList[idx];
        ZGLogInfo(@"🚩 📩 --- %d: message: %@, fromUserID: %@, sendTime: %llu", idx, info.message, info.fromUser.userID, info.sendTime);
        [self.dataSource onActionLog:[NSString stringWithFormat:@"📩 [%@] --- from %@, time: %llu", info.message, info.fromUser.userID, info.sendTime]];
    }
}

- (void)onIMRecvCustomCommand:(NSString *)command fromUser:(ZegoUser *)fromUser roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 📩 IM Recv Custom Command Callback: command: %@, fromUserID: %@, roomID: %@", command, fromUser.userID, roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"📩 Received Custom Command"]];
    [self.dataSource onActionLog:[NSString stringWithFormat:@"📩 [%@] --- from %@", command, fromUser.userID]];
}

@end

#endif

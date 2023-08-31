//
//  ZGTestTopicManager.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/24.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_Test

#import "ZGTestTopicManager.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"

@interface ZGTestTopicManager () <ZegoEventHandler, ZegoRealTimeSequentialDataEventHandler>

@property (nonatomic, weak) id<ZGTestDataSource> dataSource;

@property (nonatomic, strong) NSMutableDictionary<NSString *, ZegoRealTimeSequentialDataManager *> *rtsdManagerMap;

@end

@implementation ZGTestTopicManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rtsdManagerMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)setZGTestDataSource:(id<ZGTestDataSource>)dataSource {
    self.dataSource = dataSource;
}

- (void)createEngineWithAppID:(unsigned int)appID appSign:(NSString *)appSign scenario:(ZegoScenario)scenario {
    ZGLogInfo(@"🚀 Create ZegoExpressEngine, scenario:%d", (int)scenario);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🚀 Create ZegoExpressEngine, scenario:%d", (int)scenario]];
    
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = appID;
    profile.appSign = appSign;
    profile.scenario = scenario;
    
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
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

- (void)setRoomScenario:(ZegoScenario)scenario {
    [[ZegoExpressEngine sharedEngine] setRoomScenario:scenario];
    ZGLogInfo(@"🥁 Set Room Scenario: %d", (int)scenario);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🥁 Set Room Scenario: %d", (int)scenario]];
}

- (NSString *)getVersion {
    NSString *version = [ZegoExpressEngine getVersion];
    ZGLogInfo(@"ℹ️ Engine Version: %@", version);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"ℹ️ Engine Version: %@", version]];
    return version;
}

- (void)uploadLog {
    [[ZegoExpressEngine sharedEngine] uploadLog];
    ZGLogInfo(@"📬 Upload Log");
    [self.dataSource onActionLog:@"📬 Upload Log"];
}

- (void)enableDebugAssistant:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableDebugAssistant:enable];
    ZGLogInfo(@"🤖 Enable debug assistant: %d", enable);
}

- (void)setRoomMode:(ZegoRoomMode)mode {
    [ZegoExpressEngine setRoomMode:mode];
    ZGLogInfo(@"🚪 Set room mode: %d", (int)mode);
}

- (void)setEngineConfig:(ZegoEngineConfig *)config {
    [ZegoExpressEngine setEngineConfig:config];
    NSMutableString *advancedConfig = [[NSMutableString alloc] init];
    for (NSString *key in config.advancedConfig) {
        [advancedConfig appendFormat:@"%@=%@; ", key, config.advancedConfig[key]];
    }
    ZGLogInfo(@"🔩 Set engien config, advanced config: %@", advancedConfig);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔩 Set engien config, advanced config: %@", advancedConfig]];
}


#pragma mark Room

- (void)loginRoom:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName config:(nullable ZegoRoomConfig *)config{
    [[ZegoExpressEngine sharedEngine] loginRoom:roomID user:[ZegoUser userWithUserID:userID userName:userName] config:config];
    ZGLogInfo(@"🚪 Login room. roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🚪 Login room. roomID: %@", roomID]];
}

- (void)switchRoom:(NSString *)fromRoomID toRoomID:(NSString *)toRoomID {
    [[ZegoExpressEngine sharedEngine] switchRoom:fromRoomID toRoomID:toRoomID];
    ZGLogInfo(@"🚪 Switch room. from roomID: %@, to roomID: %@", fromRoomID, toRoomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🚪 Switch room. from roomID: %@, to roomID: %@", fromRoomID, toRoomID]];
}


- (void)logoutRoom:(NSString *)roomID {
    [[ZegoExpressEngine sharedEngine] logoutRoom:roomID];
    ZGLogInfo(@"🚪 Logout room. roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🚪 Logout room. roomID: %@", roomID]];
}


#pragma mark Publish

- (void)startPublishingStream:(NSString *)streamID roomID:(nullable NSString *)roomID {
    ZegoPublisherConfig *config = [[ZegoPublisherConfig alloc] init];
    config.roomID = roomID ?: @"";
    [[ZegoExpressEngine sharedEngine] startPublishingStream:streamID config:config channel:ZegoPublishChannelMain];
    ZGLogInfo(@"📤 Start publishing stream. streamID: %@, roomID: %@", streamID, roomID ?: @"");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@, roomID: %@", streamID, roomID ?: @""]];
}


- (void)stopPublishingStream {
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    ZGLogInfo(@"📤 Stop publishing stream");
    [self.dataSource onActionLog:@"📤 Stop publishing stream"];
}


- (void)startPreview:(ZegoCanvas *)canvas {
    [[ZegoExpressEngine sharedEngine] startPreview:canvas];
    ZGLogInfo(@"🔌 Start preview");
    [self.dataSource onActionLog:@"🔌 Start preview"];
}


- (void)stopPreview {
    [[ZegoExpressEngine sharedEngine] stopPreview];
    ZGLogInfo(@"🔌 Stop preview");
    [self.dataSource onActionLog:@"🔌 Stop preview"];
}


- (void)setVideoConfig:(ZegoVideoConfig *)videoConfig {
    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
    ZGLogInfo(@"🧷 Set video config. width: %d, height: %d, bitrate: %d, fps: %d", (int)videoConfig.captureResolution.width, (int)videoConfig.captureResolution.height, videoConfig.bitrate, videoConfig.fps);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🧷 Set video config. width: %d, height: %d, bitrate: %d, fps: %d", (int)videoConfig.captureResolution.width, (int)videoConfig.captureResolution.height, videoConfig.bitrate, videoConfig.fps]];
}


- (void)setVideoMirrorMode:(ZegoVideoMirrorMode)mirrorMode {
    [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:mirrorMode];
    ZGLogInfo(@"⚙️ Set video mirror mode. Mode: %d", (int)mirrorMode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"⚙️ Set video mirror mode. Mode: %d", (int)mirrorMode]];
}


- (void)setAppOrientation:(UIInterfaceOrientation)orientation {
    [[ZegoExpressEngine sharedEngine] setAppOrientation:orientation];
    ZGLogInfo(@"⚙️ Set capture orientation: %d", (int)orientation);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"⚙️ Set capture orientation: %d", (int)orientation]];
}

- (ZegoAudioConfig *)getAudioConfig {
    return [[ZegoExpressEngine sharedEngine] getAudioConfig];
}

- (void)setAudioConfig:(ZegoAudioConfig *)config {
    [[ZegoExpressEngine sharedEngine] setAudioConfig:config];
    ZGLogInfo(@"🧷 Set audio config. bitrate: %d, channel: %d, codecID: %d", config.bitrate, (int)config.channel, (int)config.codecID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🧷 Set audio config. bitrate: %d, channel: %d, codecID: %d", config.bitrate, (int)config.channel, (int)config.codecID]];
}


- (void)mutePublishStreamAudio:(BOOL)mute {
    [[ZegoExpressEngine sharedEngine] mutePublishStreamAudio:mute];
    ZGLogInfo(@"🙊 Mute publish stream audio: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🙊 Mute publish stream audio: %@", mute ? @"YES" : @"NO"]];
}


- (void)mutePublishStreamVideo:(BOOL)mute {
    [[ZegoExpressEngine sharedEngine] mutePublishStreamVideo:mute];
    ZGLogInfo(@"🙈 Mute publish stream video: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🙈 Mute publish stream video: %@", mute ? @"YES" : @"NO"]];
}


- (void)setCaptureVolume:(int)volume {
    [[ZegoExpressEngine sharedEngine] setCaptureVolume:volume];
    ZGLogInfo(@"⛏ Set capture volume: %d", volume);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"⛏ Set capture volume: %d", volume]];
}


- (void)addPublishCdnUrl:(NSString *)targetURL streamID:(NSString *)streamID callback:(nullable ZegoPublisherUpdateCdnUrlCallback)callback {
    __weak typeof(self) weakSelf = self;
    [[ZegoExpressEngine sharedEngine] addPublishCdnUrl:targetURL streamID:streamID callback:^(int errorCode) {
        __strong typeof(self) strongSelf = weakSelf;
        ZGLogInfo(@"🚩 🔗 Add publish cdn url result: %d", errorCode);
        [strongSelf.dataSource onActionLog:[NSString stringWithFormat:@"🚩 🔗 Add publish cdn url result: %d", errorCode]];
        if (callback) {
            callback(errorCode);
        }
    }];
    ZGLogInfo(@"🔗 Add publish cdn url: %@, streamID: %@", targetURL, streamID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔗 Add publish cdn url: %@, streamID: %@", targetURL, streamID]];
}


- (void)removePublishCdnUrl:(NSString *)targetURL streamID:(NSString *)streamID callback:(nullable ZegoPublisherUpdateCdnUrlCallback)callback {
    __weak typeof(self) weakSelf = self;
    [[ZegoExpressEngine sharedEngine] removePublishCdnUrl:targetURL streamID:streamID callback:^(int errorCode) {
        __strong typeof(self) strongSelf = weakSelf;
        ZGLogInfo(@"🚩 🔗 Remove publish cdn url result: %d", errorCode);
        [strongSelf.dataSource onActionLog:[NSString stringWithFormat:@"🚩 🔗 Remove publish cdn url result: %d", errorCode]];
        if (callback) {
            callback(errorCode);
        }
    }];
    ZGLogInfo(@"🔗 Remove publish cdn url: %@, streamID: %@", targetURL, streamID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔗 Remove publish cdn url: %@, streamID: %@", targetURL, streamID]];
}


- (void)enableHardwareEncoder:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableHardwareEncoder:enable];
    ZGLogInfo(@"🔧 Enable hardware encoder: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable hardware encoder: %@", enable ? @"YES" : @"NO"]];
}

- (void)setWatermark:(ZegoWatermark *)watermark isPreviewVisible:(BOOL)isPreviewVisible {
    [[ZegoExpressEngine sharedEngine] setPublishWatermark:watermark isPreviewVisible:isPreviewVisible];
    ZGLogInfo(@"🌅 Set publish watermark, filePath: %@, isPreviewVisible: %@", watermark.imageURL, isPreviewVisible ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🌅 Set publish watermark, filePath: %@, isPreviewVisible: %@", watermark.imageURL, isPreviewVisible ? @"YES" : @"NO"]];
}

- (void)setCapturePipelineScaleMode:(ZegoCapturePipelineScaleMode)scaleMode {
    [[ZegoExpressEngine sharedEngine] setCapturePipelineScaleMode:scaleMode];
    ZGLogInfo(@"🔧 Set capture pipeline scale mode: %d", (int)scaleMode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Set capture pipeline scale mode: %d", (int)scaleMode]];
}

- (void)sendSEI:(NSData *)data {
    [[ZegoExpressEngine sharedEngine] sendSEI:data];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    ZGLogInfo(@"✉️ Send SEI: %@", str);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"✉️ Send SEI: %@", str]];
}

- (void)setAudioCaptureStereoMode:(ZegoAudioCaptureStereoMode)mode {
    [[ZegoExpressEngine sharedEngine] setAudioCaptureStereoMode:mode];
    ZGLogInfo(@"🎶 Set audio capture stereo mode: %d", (int)mode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🎶 Set audio capture stereo mode: %d", (int)mode]];
}


#pragma mark Player

- (void)startPlayingStream:(NSString *)streamID canvas:(ZegoCanvas *)canvas roomID:(nullable NSString *)roomID {
    if (roomID) {
        ZegoPlayerConfig *config = [[ZegoPlayerConfig alloc] init];
        config.resourceMode = ZegoStreamResourceModeOnlyRTC;
        config.roomID = roomID;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:streamID canvas:canvas config:config];
    } else {
        [[ZegoExpressEngine sharedEngine] startPlayingStream:streamID canvas:canvas];
    }
    ZGLogInfo(@"📥 Start playing stream");
    [self.dataSource onActionLog:@"📥 Start playing stream"];
}


- (void)stopPlayingStream:(NSString *)streamID {
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:streamID];
    ZGLogInfo(@"📥 Stop playing stream");
    [self.dataSource onActionLog:@"📥 Stop playing stream"];
}


- (void)setPlayVolume:(int)volume stream:(NSString *)streamID {
    [[ZegoExpressEngine sharedEngine] setPlayVolume:volume streamID:streamID];
    ZGLogInfo(@"⛏ Set play volume: %d", volume);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"⛏ Set play volume: %d", volume]];
}


- (void)mutePlayStreamAudio:(BOOL)mute streamID:(NSString *)streamID {
    [[ZegoExpressEngine sharedEngine] mutePlayStreamAudio:mute streamID:streamID];
    ZGLogInfo(@"🙊 Mute play stream audio: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🙊 Mute play stream audio: %@", mute ? @"YES" : @"NO"]];
}


- (void)mutePlayStreamVideo:(BOOL)mute streamID:(NSString *)streamID {
    [[ZegoExpressEngine sharedEngine] mutePlayStreamVideo:mute streamID:streamID];
    ZGLogInfo(@"🙈 Mute play stream video: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🙈 Mute play stream video: %@", mute ? @"YES" : @"NO"]];
}


- (void)enableHarewareDecoder:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableHardwareDecoder:enable];
    ZGLogInfo(@"🔧 Enable hardware decoder: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable hardware decoder: %@", enable ? @"YES" : @"NO"]];
}

- (void)enableCheckPoc:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableCheckPoc:enable];
    ZGLogInfo(@"🔧 Enable check poc: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable check poc: %@", enable ? @"YES" : @"NO"]];
}


#pragma mark PreProcess

- (void)enableAEC:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableAEC:enable];
    ZGLogInfo(@"🔧 Enable AEC: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable AEC: %@", enable ? @"YES" : @"NO"]];
}


- (void)setAECMode:(ZegoAECMode)mode {
    [[ZegoExpressEngine sharedEngine] setAECMode:mode];
    ZGLogInfo(@"⛏ Set AEC mode: %d", (int)mode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"⛏ Set AEC mode: %d", (int)mode]];
}


- (void)enableAGC:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableAGC:enable];
    ZGLogInfo(@"🔧 Enable AGC: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable AGC: %@", enable ? @"YES" : @"NO"]];
}


- (void)enableANS:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableANS:enable];
    ZGLogInfo(@"🔧 Enable ANS: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable ANS: %@", enable ? @"YES" : @"NO"]];
}


- (void)enableBeautify:(int)feature {
    [[ZegoExpressEngine sharedEngine] enableBeautify:feature];
    ZGLogInfo(@"⛏ Enable beautify: %d", (int)feature);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"⛏ Enable beautify: %d", (int)feature]];
}


- (void)setBeautifyOption:(ZegoBeautifyOption *)option {
    [[ZegoExpressEngine sharedEngine] setBeautifyOption:option];
    ZGLogInfo(@"🔧 Set eautify option. polishStep: %f, whitenFactor: %f, sharpenFactor: %f", option.polishStep, option.whitenFactor, option.sharpenFactor);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Set eautify option. polishStep: %f, whitenFactor: %f, sharpenFactor: %f", option.polishStep, option.whitenFactor, option.sharpenFactor]];
}


#pragma mark Device

- (void)muteMicrophone:(BOOL)mute {
    [[ZegoExpressEngine sharedEngine] muteMicrophone:mute];
    ZGLogInfo(@"🔧 Mute microphone: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Mute microphone: %@", mute ? @"YES" : @"NO"]];
}


- (void)muteSpeaker:(BOOL)mute {
    [[ZegoExpressEngine sharedEngine] muteSpeaker:mute];
    ZGLogInfo(@"🔧 Mute audio output: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Mute audio output: %@", mute ? @"YES" : @"NO"]];
}


- (void)enableCamera:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableCamera:enable];
    ZGLogInfo(@"🔧 Enable camera: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable camera: %@", enable ? @"YES" : @"NO"]];
}


- (void)useFrontCamera:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] useFrontCamera:enable];
    ZGLogInfo(@"🔧 Use front camera: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Use front camera: %@", enable ? @"YES" : @"NO"]];
}


- (void)enableAudioCaptureDevice:(BOOL)enable {
    [[ZegoExpressEngine sharedEngine] enableAudioCaptureDevice:enable];
    ZGLogInfo(@"🔧 Enable audio capture device: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🔧 Enable audio capture device: %@", enable ? @"YES" : @"NO"]];
}

- (void)startSoundLevelMonitor {
    [[ZegoExpressEngine sharedEngine] startSoundLevelMonitor];
    ZGLogInfo(@"🎼 Start sound level monitor");
    [self.dataSource onActionLog:@"🎼 Start sound level monitor"];
}

- (void)stopSoundLevelMonitor {
    [[ZegoExpressEngine sharedEngine] stopSoundLevelMonitor];
    ZGLogInfo(@"🎼 Stop sound level monitor");
    [self.dataSource onActionLog:@"🎼 Stop sound level monitor"];
}

- (void)startAudioSpectrumMonitor {
    [[ZegoExpressEngine sharedEngine] startAudioSpectrumMonitor];
    ZGLogInfo(@"🎼 Start audio spectrum monitor");
    [self.dataSource onActionLog:@"🎼 Start audio spectrum monitor"];
}

- (void)stopAudioSpectrumMonitor {
    [[ZegoExpressEngine sharedEngine] stopAudioSpectrumMonitor];
    ZGLogInfo(@"🎼 Stop audio spectrum monitor");
    [self.dataSource onActionLog:@"🎼 Stop audio spectrum monitor"];
}

- (void)startPerformanceMonitor {
    [[ZegoExpressEngine sharedEngine] startPerformanceMonitor:2000];
    ZGLogInfo(@"🖥 Start performance monitor");
    [self.dataSource onActionLog:@"🖥 Start performance monitor"];
}

- (void)stopPerformanceMonitor {
    [[ZegoExpressEngine sharedEngine] stopPerformanceMonitor];
    ZGLogInfo(@"🖥 Stop performance monitor");
    [self.dataSource onActionLog:@"🖥 Stop performance monitor"];
}

#pragma mark Mixer

- (void)startMixerTask:(ZegoMixerTask *)task {
    ZGLogInfo(@"🧬 Start mixer task");
    [self.dataSource onActionLog:@"🧬 Start mixer task"];
    __weak typeof(self) weakSelf = self;
    [[ZegoExpressEngine sharedEngine] startMixerTask:task callback:^(int errorCode, NSDictionary * _Nullable extendedData) {
        __strong typeof(self) strongSelf = weakSelf;
        ZGLogInfo(@"🚩 🧬 Start mixer task result errorCode: %d", errorCode);
        [strongSelf.dataSource onActionLog:[NSString stringWithFormat:@"🚩 🧬 Start mixer task result errorCode: %d", errorCode]];
    }];
}

- (void)stopMixerTask:(ZegoMixerTask *)task {
    ZGLogInfo(@"🧬 Stop mixer task");
    [self.dataSource onActionLog:@"🧬 Stop mixer task"];
    __weak typeof(self) weakSelf = self;
    [[ZegoExpressEngine sharedEngine] stopMixerTask:task callback:^(int errorCode) {
        __strong typeof(self) strongSelf = weakSelf;
        ZGLogInfo(@"🚩 🧬 Stop mixer task result errorCode: %d", errorCode);
        [strongSelf.dataSource onActionLog:[NSString stringWithFormat:@"🚩 🧬 Stop mixer task result errorCode: %d", errorCode]];
    }];
}

#pragma mark IM

- (void)sendBroadcastMessage:(NSString *)message roomID:(NSString *)roomID {
    [[ZegoExpressEngine sharedEngine] sendBroadcastMessage:message roomID:roomID callback:^(int errorCode, unsigned long long messageID) {
        ZGLogInfo(@"🚩 ✉️ Send broadcast message result errorCode: %d, messageID: %llu", errorCode, messageID);
    }];
}

- (void)sendCustomCommand:(NSString *)command toUserList:(nullable NSArray<ZegoUser *> *)toUserList roomID:(NSString *)roomID {
    [[ZegoExpressEngine sharedEngine] sendCustomCommand:command toUserList:nil roomID:roomID callback:^(int errorCode) {
        ZGLogInfo(@"🚩 ✉️ Send custom command (to all user) result errorCode: %d", errorCode);
    }];
}

#pragma mark RTSD

- (void)createRealTimeSequentialDataManager:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = [[ZegoExpressEngine sharedEngine] createRealTimeSequentialDataManager:roomID];
    if (manager) {
        self.rtsdManagerMap[roomID] = manager;
        ZGLogInfo(@"💾 Create RTSD manager, roomID: %@, index: %d", roomID, [manager getIndex].intValue);
        [manager setEventHandler:self];
    } else {
        ZGLogError(@"💾 ❌ Create RTSD manager failed, roomID: %@", roomID);
    }
}

- (void)destroyRealTimeSequentialDataManager:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = self.rtsdManagerMap[roomID];
    if (manager) {
        [[ZegoExpressEngine sharedEngine] destroyRealTimeSequentialDataManager:manager];
        [self.rtsdManagerMap removeObjectForKey:roomID];
        ZGLogInfo(@"💾 Destroy RTSD manager, roomID: %@, index: %d", roomID, [manager getIndex].intValue);
    } else {
        ZGLogError(@"💾 ❌ Destroy RTSD manager failed, roomID: %@", roomID);
    }
}

- (void)startBroadcasting:(NSString *)streamID managerRoomID:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = self.rtsdManagerMap[roomID];
    if (manager) {
        [manager startBroadcasting:streamID];
        ZGLogInfo(@"💾 RTSD start broadcasting, streamID: %@, roomID: %@, index: %d", streamID, roomID, [manager getIndex].intValue);
    } else {
        ZGLogError(@"💾 ❌ No RTSD manager for roomID: %@", roomID);
    }
}

- (void)stopBroadcasting:(NSString *)streamID managerRoomID:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = self.rtsdManagerMap[roomID];
    if (manager) {
        [manager stopBroadcasting:streamID];
        ZGLogInfo(@"💾 RTSD stop broadcasting, streamID: %@, roomID: %@, index: %d", streamID, roomID, [manager getIndex].intValue);
    } else {
        ZGLogError(@"💾 ❌ No RTSD manager for roomID: %@", roomID);
    }
}

- (void)sendRealTimeSequentialData:(NSString *)data streamID:(NSString *)streamID managerRoomID:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = self.rtsdManagerMap[roomID];
    if (manager) {
        [manager sendRealTimeSequentialData:[data dataUsingEncoding:NSUTF8StringEncoding] streamID:streamID callback:^(int errorCode) {
            ZGLogInfo(@"🚩 💾 RTSD send data result, errorCode: %d", errorCode);
        }];
        ZGLogInfo(@"💾 RTSD start send data: %@, streamID: %@, roomID: %@, index: %d", data, streamID, roomID, [manager getIndex].intValue);
    } else {
        ZGLogError(@"💾 ❌ No RTSD manager for roomID: %@", roomID);
    }
}

- (void)startSubscribing:(NSString *)streamID managerRoomID:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = self.rtsdManagerMap[roomID];
    if (manager) {
        [manager startSubscribing:streamID];
        ZGLogInfo(@"💾 RTSD start subscribing, streamID: %@, roomID: %@, index: %d", streamID, roomID, [manager getIndex].intValue);
    } else {
        ZGLogError(@"💾 ❌ No RTSD manager for roomID: %@", roomID);
    }
}

- (void)stopSubscribing:(NSString *)streamID managerRoomID:(NSString *)roomID {
    ZegoRealTimeSequentialDataManager *manager = self.rtsdManagerMap[roomID];
    if (manager) {
        [manager stopSubscribing:streamID];
        ZGLogInfo(@"💾 RTSD stop subscribing, streamID: %@, roomID: %@, index: %d", streamID, roomID, [manager getIndex].intValue);
    } else {
        ZGLogError(@"💾 ❌ No RTSD manager for roomID: %@", roomID);
    }
}

#pragma mark Utils

- (void)startNetworkSpeedTest {
    ZGLogInfo(@"🌐 Start network speed test");
    [self.dataSource onActionLog:@"🌐 Start network speed test"];
    ZegoNetworkSpeedTestConfig *config = [[ZegoNetworkSpeedTestConfig alloc] init];
    config.testUplink = YES;
    config.testDownlink = YES;
    config.expectedUplinkBitrate = config.expectedDownlinkBitrate = [[ZegoExpressEngine sharedEngine] getVideoConfig].bitrate;
    [[ZegoExpressEngine sharedEngine] startNetworkSpeedTest:config];

}

- (void)stopNetworkSpeedTest {
    ZGLogInfo(@"🌐 Stop network speed test");
    [self.dataSource onActionLog:@"🌐 Stop network speed test"];
    [[ZegoExpressEngine sharedEngine] stopNetworkSpeedTest];
}


#pragma mark - Callback

- (void)onDebugError:(int)errorCode funcName:(NSString *)funcName info:(NSString *)info {
    ZGLogInfo(@"🚩 ❓ Debug Error Callback: errorCode: %d, FuncName: %@ Info: %@", errorCode, funcName, info);
}

#pragma mark Room Callback

-(void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🚪 Room State Change Callback: %lu, errorCode: %d, roomID: %@", (unsigned long)reason, (int)errorCode, roomID);
}


- (void)onRoomUserUpdate:(ZegoUpdateType)updateType userList:(NSArray<ZegoUser *> *)userList roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🕺 Room User Update Callback: %lu, UsersCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)userList.count, roomID);
}

- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
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
    for (ZegoStreamRelayCDNInfo *info in streamInfoList) {
        ZGLogInfo(@"🚩 📡 --- state: %d, reason: %d, url: %@", (int)info.state, (int)info.updateReason, info.url);
    }
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

- (void)onLocalDeviceExceptionOccurred:(ZegoDeviceExceptionType)exceptionType deviceType:(ZegoDeviceType)deviceType deviceID:(NSString *)deviceID {
    ZGLogInfo(@"🚩 💻 Local Device Exception Occurred Callback: exceptionType: %lu, deviceType: %lu, deviceID: %@", exceptionType, deviceType, deviceID);
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

#pragma mark Device Callback

- (void)onPerformanceStatusUpdate:(ZegoPerformanceStatus *)status {
    ZGLogInfo(@"🚩 🖥 Performance Status Update: CPU-App:%.4f, CPU-Sys:%.4f, MemApp:%.4f, MemSys:%.4f, MemUsedApp:%.1fMB", status.cpuUsageApp, status.cpuUsageSystem, status.memoryUsageApp, status.memoryUsageSystem, status.memoryUsedApp);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🚩 🖥 Performance Status Update: CPU-App:%.4f, CPU-Sys:%.4f, MemApp:%.4f, MemSys:%.1f, MemUsedApp:%.1fMB", status.cpuUsageApp, status.cpuUsageSystem, status.memoryUsageApp, status.memoryUsageSystem, status.memoryUsedApp]];
}

#pragma mark RTSD Callback

- (void)manager:(ZegoRealTimeSequentialDataManager *)manager receiveRealTimeSequentialData:(NSData *)data streamID:(NSString *)streamID {
    NSString *roomID = @"❌";
    for (NSString *key in self.rtsdManagerMap) {
        int idx = [self.rtsdManagerMap[key] getIndex].intValue;
        if (idx == [manager getIndex].intValue) {
            roomID = key;
        }
    }
    ZGLogInfo(@"🚩 💾 Receive RTSD data: %@, manageridx: %d, streamID: %@, roomID: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], [manager getIndex].intValue, streamID, roomID);
}

#pragma mark Utils Callback

- (void)onNetworkModeChanged:(ZegoNetworkMode)mode {
    ZGLogInfo(@"🚩 🌐 Network Mode Changed Callback: mode: %d", (int)mode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🚩 🌐 Network Mode Changed Callback: mode: %d", (int)mode]];
}

- (void)onNetworkSpeedTestError:(int)errorCode type:(ZegoNetworkSpeedTestType)type {
    ZGLogInfo(@"🚩 🌐 Network Speed Test Error Callback: errorCode: %d, type: %d", errorCode, (int)type);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🚩 🌐 Network Speed Test Error Callback: errorCode: %d, type: %d", errorCode, (int)type]];
}

- (void)onNetworkSpeedTestQualityUpdate:(ZegoNetworkSpeedTestQuality *)quality type:(ZegoNetworkSpeedTestType)type {
    ZGLogInfo(@"🚩 🌐 Network Speed Test Quality Update Callback: cost: %d, rtt: %d, plr: %.1f, type: %d", quality.connectCost, quality.rtt, quality.packetLostRate, (int)type);
    [self.dataSource onActionLog:[NSString stringWithFormat:@"🚩 🌐 Network Speed Test Quality Update Callback: cost: %d, rtt: %d, plr: %.1f, type: %d", quality.connectCost, quality.rtt, quality.packetLostRate, (int)type]];
}

@end

#endif

//
//  ZGAudioEffectTopicConfigManager.h
//  LiveRoomPlayGround
//
//  Created by jeffreypeng on 2019/8/27.
//  Copyright © 2019 Zego. All rights reserved.
//
#ifdef _Module_AudioEffect

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 音频混响模式 */
typedef NS_ENUM(NSUInteger, ExpressAPIAudioReverbMode)
{
    ExpressAPIAudioReverbModeNone = 0,
    ExpressAPIAudioReverbModeSoftRoom = 1, //小房间
    ExpressAPIAudioReverbModeLargeRoom = 2, //大房间
    ExpressAPIAudioReverbModeConcertHall = 3, //音乐厅
    ExpressAPIAudioReverbModeValley = 4, //山谷
    
};

/** 无变声音效 值: 0.0 */
static float const EXPRESS_API_VOICE_CHANGER_NONE = 0.0;
/** 女声变男声 值: -3.0*/
static float const EXPRESS_API_VOICE_CHANGER_WOMEN_TO_MEN = -3.0;
/** 男声变女声 值: 4.0*/
static float const EXPRESS_API_VOICE_CHANGER_MEN_TO_WOMEN = 4.0;
/** 女声变童声 值: 6.0*/
static float const EXPRESS_API_VOICE_CHANGER_WOMEN_TO_CHILD = 6.0;
/** 男声变童声 值: 8.0*/
static float const EXPRESS_API_VOICE_CHANGER_MEN_TO_CHILD = 8.0;

@class ZGAudioEffectTopicConfigManager;
@protocol ZGAudioEffectTopicConfigChangedHandler <NSObject>
@optional
- (void)audioEffectTopicConfigManager:(ZGAudioEffectTopicConfigManager *)configManager
               voiceChangerOpenChanged:(BOOL)voiceChangerOpen;

- (void)audioEffectTopicConfigManager:(ZGAudioEffectTopicConfigManager *)configManager
               voiceChangerParamChanged:(float)voiceChangerParam;

- (void)audioEffectTopicConfigManager:(ZGAudioEffectTopicConfigManager *)configManager
              virtualStereoOpenChanged:(BOOL)virtualStereoOpen;

- (void)audioEffectTopicConfigManager:(ZGAudioEffectTopicConfigManager *)configManager
              virtualStereoAngleChanged:(int)virtualStereoAngle;

- (void)audioEffectTopicConfigManager:(ZGAudioEffectTopicConfigManager *)configManager
             reverbOpenChanged:(BOOL)reverbOpen;

- (void)audioEffectTopicConfigManager:(ZGAudioEffectTopicConfigManager *)configManager
             reverbModeChanged:(NSUInteger)reverbMode;

- (void)audioEffectTopicConfigManager:(ZGAudioEffectTopicConfigManager *)configManager
             customReverbRoomSizeChanged:(float)customReverbRoomSize;

- (void)audioEffectTopicConfigManager:(ZGAudioEffectTopicConfigManager *)configManager
           customDryWetRatioChanged:(float)customDryWetRatio;

- (void)audioEffectTopicConfigManager:(ZGAudioEffectTopicConfigManager *)configManager
              customDampingChanged:(float)customDamping;

- (void)audioEffectTopicConfigManager:(ZGAudioEffectTopicConfigManager *)configManager
                  customReverberanceChanged:(float)customReverberance;

@end

/**
 音频处理专题设置管理器。
 
 * 通过实现 `ZGAudioEffectTopicConfigChangedHandler` 并添加到管理器中，可以收到专题设置更新事件。
 */
@interface ZGAudioEffectTopicConfigManager : NSObject

+ (instancetype)sharedInstance;

- (void)addConfigChangedHandler:(id<ZGAudioEffectTopicConfigChangedHandler>)handler;

- (void)removeConfigChangedHandler:(id<ZGAudioEffectTopicConfigChangedHandler>)handler;

#pragma mark - 变声

/**
 保存`是否开启变声`设置
 */
- (void)setVoiceChangerOpen:(BOOL)voiceChangerOpen;

/**
 返回保存的`是否开启变声`。如果不存在，则返回默认
 */
- (BOOL)voiceChangerOpen;

/**
 保存`变声系数`设置
 */
- (void)setVoiceChangerParam:(float)voiceChangerParam;

/**
 返回保存的`变声系数`。如果不存在，则返回默认
 */
- (float)voiceChangerParam;

#pragma mark - 立体声

/**
 保存`是否开启立体声`设置
 */
- (void)setVirtualStereoOpen:(BOOL)virtualStereoOpen;

/**
 返回保存的`是否开启立体声`。如果不存在，则返回默认
 */
- (BOOL)virtualStereoOpen;

/**
 保存`立体声位置角度`设置
 */
- (void)setVirtualStereoAngle:(int)angle;

/**
 返回保存的`立体声位置角度`。如果不存在，则返回默认
 */
- (int)virtualStereoAngle;


#pragma mark - 混响
/**
 保存`是否开启混响`设置
 */
- (void)setReverbOpen:(BOOL)reverbOpen;

/**
 返回保存的`是否开启混响`。如果不存在，则返回默认
 */
- (BOOL)reverbOpen;

/**
 保存`混响模式`设置
 */
- (void)setReverbMode:(NSUInteger)reverbMode;

/**
 返回保存的`混响模式`。如果不存在，则返回 NSNotfound
 */
- (NSUInteger)reverbMode;

/**
 保存`自定义混响的 roomSize`设置
 */
- (void)setCustomReverbRoomSize:(float)roomSize;

/**
 返回保存的`自定义混响的 roomSize`。如果不存在，则返回默认
 */
- (float)customReverbRoomSize;

/**
 保存`自定义混响的 dryWetRatio`设置
 */
- (void)setCustomDryWetRatio:(float)dryWetRatio;

/**
 返回保存的`自定义混响的 dryWetRatio`。如果不存在，则返回默认
 */
- (float)customDryWetRatio;

/**
 保存`自定义混响的 damping`设置
 */
- (void)setCustomDamping:(float)damping;

/**
 返回保存的`自定义混响的 damping`。如果不存在，则返回默认
 */
- (float)customDamping;

/**
 保存`自定义混响的 reverberance（余响）`设置
 */
- (void)setCustomReverberance:(float)reverberance;

/**
 返回保存的`自定义混响的 reverberance（余响）`。如果不存在，则返回默认
 */
- (float)customReverberance;

@end

NS_ASSUME_NONNULL_END
#endif

//
//  ZGAudioEffectTopicHelper.h
//  LiveRoomPlayGround
//
//  Created by jeffreypeng on 2019/8/28.
//  Copyright © 2019 Zego. All rights reserved.
//
#ifdef _Module_AudioEffect

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 专题的配置模式 object
 */
@interface ZGAudioEffectTopicConfigMode : NSObject

// 模式类型
@property (nonatomic) NSNumber *modeValue;

// 模式名称
@property (nonatomic, copy) NSString *modeName;

// 是否为自定义
@property (nonatomic, assign) BOOL isCustom;

+ (instancetype)modeWithModeValue:(NSNumber * _Nullable)modeValue modeName:(NSString *)modeName isCustom:(BOOL)isCustom;

@end

@interface ZGAudioEffectTopicHelper : NSObject

/**
 变声器可选的模式
 */
+ (NSArray<ZGAudioEffectTopicConfigMode*>*)voiceChangerOptionModes;

/**
 混响可选的模式
 */
+ (NSArray<ZGAudioEffectTopicConfigMode*>*)reverbOptionModes;

@end

NS_ASSUME_NONNULL_END
#endif

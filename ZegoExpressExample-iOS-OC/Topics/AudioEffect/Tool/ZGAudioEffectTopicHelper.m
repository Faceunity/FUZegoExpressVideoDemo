//
//  ZGAudioEffectTopicHelper.m
//  LiveRoomPlayGround
//
//  Created by jeffreypeng on 2019/8/28.
//  Copyright © 2019 Zego. All rights reserved.
//
#ifdef _Module_AudioEffect

#import "ZGAudioEffectTopicHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "ZGAudioEffectTopicConfigManager.h"

@implementation ZGAudioEffectTopicConfigMode

+ (instancetype)modeWithModeValue:(NSNumber * _Nullable)modeValue modeName:(NSString *)modeName isCustom:(BOOL)isCustom {
    ZGAudioEffectTopicConfigMode *m = [[ZGAudioEffectTopicConfigMode alloc] init];
    m.modeValue = modeValue;
    m.modeName = modeName;
    m.isCustom = isCustom;
    return m;
}

@end

@implementation ZGAudioEffectTopicHelper

+ (NSArray<ZGAudioEffectTopicConfigMode*>*)voiceChangerOptionModes {
    static dispatch_once_t onceToken;
    static NSArray<ZGAudioEffectTopicConfigMode*> *_voiceChangerOptionModes = nil;
    dispatch_once(&onceToken, ^{
        _voiceChangerOptionModes =
        @[[ZGAudioEffectTopicConfigMode modeWithModeValue:@(EXPRESS_API_VOICE_CHANGER_WOMEN_TO_MEN) modeName:@"Women->Men" isCustom:NO],
          [ZGAudioEffectTopicConfigMode modeWithModeValue:@(EXPRESS_API_VOICE_CHANGER_MEN_TO_WOMEN) modeName:@"Men->Women" isCustom:NO],
          [ZGAudioEffectTopicConfigMode modeWithModeValue:@(EXPRESS_API_VOICE_CHANGER_WOMEN_TO_CHILD) modeName:@"Women->Child" isCustom:NO],
          [ZGAudioEffectTopicConfigMode modeWithModeValue:@(EXPRESS_API_VOICE_CHANGER_MEN_TO_CHILD) modeName:@"Men->Child" isCustom:NO],
          [ZGAudioEffectTopicConfigMode modeWithModeValue:nil modeName:@"Custom" isCustom:YES]];
    });
    return _voiceChangerOptionModes;
}

+ (NSArray<ZGAudioEffectTopicConfigMode*>*)reverbOptionModes {
    static dispatch_once_t onceToken;
    static NSArray<ZGAudioEffectTopicConfigMode*> *_reverbOptionModes = nil;
    dispatch_once(&onceToken, ^{
        _reverbOptionModes =
        @[[ZGAudioEffectTopicConfigMode modeWithModeValue:@(ExpressAPIAudioReverbModeConcertHall) modeName:@"ConcertHall" isCustom:NO],
          [ZGAudioEffectTopicConfigMode modeWithModeValue:@(ExpressAPIAudioReverbModeLargeRoom) modeName:@"LargeRoom" isCustom:NO],
          [ZGAudioEffectTopicConfigMode modeWithModeValue:@(ExpressAPIAudioReverbModeSoftRoom) modeName:@"SoftRoom" isCustom:NO],
          [ZGAudioEffectTopicConfigMode modeWithModeValue:@(ExpressAPIAudioReverbModeValley) modeName:@"Valley" isCustom:NO],
          [ZGAudioEffectTopicConfigMode modeWithModeValue:nil modeName:@"Custom" isCustom:YES]];
    });
    return _reverbOptionModes;
}

@end
#endif

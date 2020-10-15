//
//  ZGAudioEffectTopicConfigManager.m
//  LiveRoomPlayGround
//
//  Created by jeffreypeng on 2019/8/27.
//  Copyright © 2019 Zego. All rights reserved.
//
#ifdef _Module_AudioEffect

#import "ZGAudioEffectTopicConfigManager.h"
#import "ZGUserDefaults.h"
#import "ZGHashTableHelper.h"

NSString* const ZGAudioEffectTopicConfigVoiceChangerOpenKey = @"ZGAudioEffectTopicConfigVoiceChangerOpenKey";
NSString* const ZGAudioEffectTopicConfigVoiceChangerParamKey = @"ZGAudioEffectTopicConfigVoiceChangerParamKey";

NSString* const ZGAudioEffectTopicConfigVirtualStereoOpenKey = @"ZGAudioEffectTopicConfigVirtualStereoOpenKey";
NSString* const ZGAudioEffectTopicConfigVirtualStereoAngleKey = @"ZGAudioEffectTopicConfigVirtualStereoAngleKey";

NSString* const ZGAudioEffectTopicConfigReverbOpenKey = @"ZGAudioEffectTopicConfigReverbOpenKey";
NSString* const ZGAudioEffectTopicConfigReverbModeKey = @"ZGAudioEffectTopicConfigReverbModeKey";
NSString* const ZGAudioEffectTopicConfigCustomReverbRoomSizeKey = @"ZGAudioEffectTopicConfigCustomReverbRoomSizeKey";
NSString* const ZGAudioEffectTopicConfigCustomDryWetRatioKey = @"ZGAudioEffectTopicConfigCustomDryWetRatioKey";
NSString* const ZGAudioEffectTopicConfigCustomDampingKey = @"ZGAudioEffectTopicConfigCustomDampingKey";
NSString* const ZGAudioEffectTopicConfigCustomReverberanceKey = @"ZGAudioEffectTopicConfigCustomReverberanceKey";


@interface ZGAudioEffectTopicConfigManager ()
{
    dispatch_queue_t _configOptQueue;
}

@property (nonatomic) ZGUserDefaults *zgUserDefaults;
@property (nonatomic) NSHashTable *configChangedHandlers;

@end

@implementation ZGAudioEffectTopicConfigManager

static ZGAudioEffectTopicConfigManager *instance = nil;

#pragma mark - public methods

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [ZGAudioEffectTopicConfigManager sharedInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [ZGAudioEffectTopicConfigManager sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        _zgUserDefaults = [[ZGUserDefaults alloc] init];
        _configChangedHandlers = [ZGHashTableHelper createWeakReferenceHashTable];
        _configOptQueue = dispatch_queue_create("com.doudong.ZGAudioEffectTopicConfigOptQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)addConfigChangedHandler:(id<ZGAudioEffectTopicConfigChangedHandler>)handler {
    if (!handler) return;
    dispatch_async(_configOptQueue, ^{
        if (![self.configChangedHandlers containsObject:handler]) {
            [self.configChangedHandlers addObject:handler];
        }
    });
}

- (void)removeConfigChangedHandler:(id<ZGAudioEffectTopicConfigChangedHandler>)handler {
    if (!handler) return;
    dispatch_async(_configOptQueue, ^{
        [self.configChangedHandlers removeObject:handler];
    });
}

- (void)setVoiceChangerOpen:(BOOL)voiceChangerOpen {
    dispatch_async(_configOptQueue, ^{
        NSNumber *obj = @(voiceChangerOpen);
        [self.zgUserDefaults setObject:obj forKey:ZGAudioEffectTopicConfigVoiceChangerOpenKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<ZGAudioEffectTopicConfigChangedHandler> handler in self.configChangedHandlers) {
                if ([handler respondsToSelector:@selector(audioEffectTopicConfigManager:voiceChangerOpenChanged:)]) {
                    [handler audioEffectTopicConfigManager:self voiceChangerOpenChanged:voiceChangerOpen];
                }
            }
        });
    });
}

- (BOOL)voiceChangerOpen {
    __block BOOL isOpen = NO;
    dispatch_sync(_configOptQueue, ^{
        NSNumber *n = [self.zgUserDefaults objectForKey:ZGAudioEffectTopicConfigVoiceChangerOpenKey];
        if (n) {
            isOpen = [n boolValue];
        } else {
            // 设置默认
            isOpen = NO;
        }
    });
    return isOpen;
}

- (void)setVoiceChangerParam:(float)voiceChangerParam {
    dispatch_async(_configOptQueue, ^{
        NSNumber *obj = @(voiceChangerParam);
        [self.zgUserDefaults setObject:obj forKey:ZGAudioEffectTopicConfigVoiceChangerParamKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<ZGAudioEffectTopicConfigChangedHandler> handler in self.configChangedHandlers) {
                if ([handler respondsToSelector:@selector(audioEffectTopicConfigManager:voiceChangerParamChanged:)]) {
                    [handler audioEffectTopicConfigManager:self voiceChangerParamChanged:voiceChangerParam];
                }
            }
        });
    });
}

- (float)voiceChangerParam {
    __block float val = 0;
    dispatch_sync(_configOptQueue, ^{
        NSNumber *n = [self.zgUserDefaults objectForKey:ZGAudioEffectTopicConfigVoiceChangerParamKey];
        if (n) {
            val = [n floatValue];
        } else {
            // 设置默认
            val = 0;
        }
    });
    return val;
}

- (void)setVirtualStereoOpen:(BOOL)virtualStereoOpen {
    dispatch_async(_configOptQueue, ^{
        NSNumber *obj = @(virtualStereoOpen);
        [self.zgUserDefaults setObject:obj forKey:ZGAudioEffectTopicConfigVirtualStereoOpenKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<ZGAudioEffectTopicConfigChangedHandler> handler in self.configChangedHandlers) {
                if ([handler respondsToSelector:@selector(audioEffectTopicConfigManager:virtualStereoOpenChanged:)]) {
                    [handler audioEffectTopicConfigManager:self virtualStereoOpenChanged:virtualStereoOpen];
                }
            }
        });
    });
}

- (BOOL)virtualStereoOpen {
    __block BOOL isOpen = NO;
    dispatch_sync(_configOptQueue, ^{
        NSNumber *n = [self.zgUserDefaults objectForKey:ZGAudioEffectTopicConfigVirtualStereoOpenKey];
        if (n) {
            isOpen = [n boolValue];
        } else {
            // 设置默认
            isOpen = NO;
        }
    });
    return isOpen;
}

- (void)setVirtualStereoAngle:(int)angle {
    dispatch_async(_configOptQueue, ^{
        NSNumber *obj = @(angle);
        [self.zgUserDefaults setObject:obj forKey:ZGAudioEffectTopicConfigVirtualStereoAngleKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<ZGAudioEffectTopicConfigChangedHandler> handler in self.configChangedHandlers) {
                if ([handler respondsToSelector:@selector(audioEffectTopicConfigManager:virtualStereoAngleChanged:)]) {
                    [handler audioEffectTopicConfigManager:self virtualStereoAngleChanged:angle];
                }
            }
        });
    });
}

- (int)virtualStereoAngle {
    __block int val = 0;
    dispatch_sync(_configOptQueue, ^{
        NSNumber *n = [self.zgUserDefaults objectForKey:ZGAudioEffectTopicConfigVirtualStereoAngleKey];
        if (n) {
            val = [n intValue];
        } else {
            // 设置默认
            val = 0;
        }
    });
    return val;
}

- (void)setReverbOpen:(BOOL)reverbOpen {
    dispatch_async(_configOptQueue, ^{
        NSNumber *obj = @(reverbOpen);
        [self.zgUserDefaults setObject:obj forKey:ZGAudioEffectTopicConfigReverbOpenKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<ZGAudioEffectTopicConfigChangedHandler> handler in self.configChangedHandlers) {
                if ([handler respondsToSelector:@selector(audioEffectTopicConfigManager:reverbOpenChanged:)]) {
                    [handler audioEffectTopicConfigManager:self reverbOpenChanged:reverbOpen];
                }
            }
        });
    });
}

- (BOOL)reverbOpen {
    __block BOOL isOpen = NO;
    dispatch_sync(_configOptQueue, ^{
        NSNumber *n = [self.zgUserDefaults objectForKey:ZGAudioEffectTopicConfigReverbOpenKey];
        if (n) {
            isOpen = [n boolValue];
        } else {
            // 设置默认
            isOpen = NO;
        }
    });
    return isOpen;
}

- (void)setReverbMode:(NSUInteger)reverbMode {
    dispatch_async(_configOptQueue, ^{
        NSNumber *obj = @(reverbMode);
        [self.zgUserDefaults setObject:obj forKey:ZGAudioEffectTopicConfigReverbModeKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<ZGAudioEffectTopicConfigChangedHandler> handler in self.configChangedHandlers) {
                if ([handler respondsToSelector:@selector(audioEffectTopicConfigManager:reverbModeChanged:)]) {
                    [handler audioEffectTopicConfigManager:self reverbModeChanged:reverbMode];
                }
            }
        });
    });
}

- (NSUInteger)reverbMode {
    __block NSUInteger val = NSNotFound;
    dispatch_sync(_configOptQueue, ^{
        NSNumber *n = [self.zgUserDefaults objectForKey:ZGAudioEffectTopicConfigReverbModeKey];
        if (n) {
            val = [n unsignedIntegerValue];
        } else {
            // 设置默认
            val = NSNotFound;
        }
    });
    return val;
}

- (void)setCustomReverbRoomSize:(float)roomSize {
    dispatch_async(_configOptQueue, ^{
        NSNumber *obj = @(roomSize);
        [self.zgUserDefaults setObject:obj forKey:ZGAudioEffectTopicConfigCustomReverbRoomSizeKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<ZGAudioEffectTopicConfigChangedHandler> handler in self.configChangedHandlers) {
                if ([handler respondsToSelector:@selector(audioEffectTopicConfigManager:customReverbRoomSizeChanged:)]) {
                    [handler audioEffectTopicConfigManager:self customReverbRoomSizeChanged:roomSize];
                }
            }
        });
    });
}

- (float)customReverbRoomSize {
    __block float val = 0;
    dispatch_sync(_configOptQueue, ^{
        NSNumber *n = [self.zgUserDefaults objectForKey:ZGAudioEffectTopicConfigCustomReverbRoomSizeKey];
        if (n) {
            val = [n floatValue];
        } else {
            // 设置默认
            val = 0;
        }
    });
    return val;
}

- (void)setCustomDryWetRatio:(float)dryWetRatio {
    dispatch_async(_configOptQueue, ^{
        NSNumber *obj = @(dryWetRatio);
        [self.zgUserDefaults setObject:obj forKey:ZGAudioEffectTopicConfigCustomDryWetRatioKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<ZGAudioEffectTopicConfigChangedHandler> handler in self.configChangedHandlers) {
                if ([handler respondsToSelector:@selector(audioEffectTopicConfigManager:customDryWetRatioChanged:)]) {
                    [handler audioEffectTopicConfigManager:self customDryWetRatioChanged:dryWetRatio];
                }
            }
        });
    });
}

- (float)customDryWetRatio {
    __block float val = 0;
    dispatch_sync(_configOptQueue, ^{
        NSNumber *n = [self.zgUserDefaults objectForKey:ZGAudioEffectTopicConfigCustomDryWetRatioKey];
        if (n) {
            val = [n floatValue];
        } else {
            // 设置默认
            val = 0;
        }
    });
    return val;
}

- (void)setCustomDamping:(float)damping {
    dispatch_async(_configOptQueue, ^{
        NSNumber *obj = @(damping);
        [self.zgUserDefaults setObject:obj forKey:ZGAudioEffectTopicConfigCustomDampingKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<ZGAudioEffectTopicConfigChangedHandler> handler in self.configChangedHandlers) {
                if ([handler respondsToSelector:@selector(audioEffectTopicConfigManager:customDampingChanged:)]) {
                    [handler audioEffectTopicConfigManager:self customDampingChanged:damping];
                }
            }
        });
    });
}

- (float)customDamping {
    __block float val = 0;
    dispatch_sync(_configOptQueue, ^{
        NSNumber *n = [self.zgUserDefaults objectForKey:ZGAudioEffectTopicConfigCustomDampingKey];
        if (n) {
            val = [n floatValue];
        } else {
            // 设置默认
            val = 0;
        }
    });
    return val;
}

- (void)setCustomReverberance:(float)reverberance {
    dispatch_async(_configOptQueue, ^{
        NSNumber *obj = @(reverberance);
        [self.zgUserDefaults setObject:obj forKey:ZGAudioEffectTopicConfigCustomReverberanceKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (id<ZGAudioEffectTopicConfigChangedHandler> handler in self.configChangedHandlers) {
                if ([handler respondsToSelector:@selector(audioEffectTopicConfigManager:customReverberanceChanged:)]) {
                    [handler audioEffectTopicConfigManager:self customReverberanceChanged:reverberance];
                }
            }
        });
    });
}

- (float)customReverberance {
    __block float val = 0;
    dispatch_sync(_configOptQueue, ^{
        NSNumber *n = [self.zgUserDefaults objectForKey:ZGAudioEffectTopicConfigCustomReverberanceKey];
        if (n) {
            val = [n floatValue];
        } else {
            // 设置默认
            val = 0;
        }
    });
    return val;
}

@end
#endif

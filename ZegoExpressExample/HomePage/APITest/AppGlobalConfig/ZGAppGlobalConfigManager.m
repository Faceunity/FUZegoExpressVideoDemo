//
//  ZGAppGlobalConfigManager.m
//  ZegoExpressExample-iOS-OC
//
//  Created by jeffreypeng on 2019/8/6.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGAppGlobalConfigManager.h"
#import "ZGJsonHelper.h"
#import "ZGHashTableHelper.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"

// Save the global settings key
NSString* const ZGAppGlobalConfigKey = @"kZGAppGlobalConfig";

@interface ZGAppGlobalConfigManager ()
{
    dispatch_queue_t _configOptQueue;
}

@property (nonatomic, copy) NSString *cachedConfigStr;

@property (nonatomic) NSHashTable *configChangedHandlers;

@end

@implementation ZGAppGlobalConfigManager

static ZGAppGlobalConfigManager *instance = nil;

#pragma mark - public methods

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [ZGAppGlobalConfigManager sharedManager];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [ZGAppGlobalConfigManager sharedManager];
}

- (instancetype)init {
    if (self = [super init]) {
        _configOptQueue = dispatch_queue_create("com.doudong.ZGAppGlobalConfigOptQueue", DISPATCH_QUEUE_SERIAL);
        _configChangedHandlers = [ZGHashTableHelper createWeakReferenceHashTable];
    }
    return self;
}

+ (ZGAppGlobalConfig *)defaultGlobalConfig {
    ZGAppGlobalConfig *conf = [[ZGAppGlobalConfig alloc] init];
    conf.appID = KeyCenter.appID;
    conf.userID = [ZGUserIDHelper userID];
    conf.appSign = KeyCenter.appSign;
    conf.scenario = ZegoScenarioDefault;
    return conf;
}

- (void)setGlobalConfig:(ZGAppGlobalConfig *)confObj {
    dispatch_async(_configOptQueue, ^{
        // Delete settings when confObj is nil
        if (!confObj) {

            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ZGAppGlobalConfigKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.cachedConfigStr = nil;
            [self notifyGlobalConfigChanged:nil];
            return;
        }
        
        NSDictionary *confDic = [confObj toDictionary];
        NSString *configStr = [ZGJsonHelper encodeToJSON:confDic];
        if (configStr) {
            self.cachedConfigStr = configStr;
            [[NSUserDefaults standardUserDefaults] setObject:configStr forKey:ZGAppGlobalConfigKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self notifyGlobalConfigChanged:confObj];
        }
    });
}

- (ZGAppGlobalConfig *)globalConfig {
    __block ZGAppGlobalConfig *conf = nil;
    dispatch_sync(_configOptQueue, ^{
        NSString *configStr = self.cachedConfigStr;
        if (configStr == nil || configStr.length == 0) {
            configStr = [[NSUserDefaults standardUserDefaults] stringForKey:ZGAppGlobalConfigKey];
        }
        
        ZGAppGlobalConfig *confObj = nil;
        NSDictionary *confDic = [ZGJsonHelper decodeFromJSON:configStr];
        if ([confDic isKindOfClass:[NSDictionary class]]) {
            confObj = [ZGAppGlobalConfig fromDictionary:confDic];
        }
        
        // Return to default configuration if it does not exist or fails to get
        if (!confObj) {
            confObj = [[self class] defaultGlobalConfig];
        }
        conf = confObj;
    });
    return conf;
}

- (void)addGlobalConfigChangedHandler:(id<ZGAppGlobalConfigChangedHandler>)handler {
    if (![self.configChangedHandlers containsObject:handler]) {
        [self.configChangedHandlers addObject:handler];
    }
}

- (void)removeGlobalConfigChangedHandler:(id<ZGAppGlobalConfigChangedHandler>)handler {
    [self.configChangedHandlers removeObject:handler];
}

#pragma mark - private methods

- (void)notifyGlobalConfigChanged:(ZGAppGlobalConfig *)configInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id handler in self.configChangedHandlers) {
            if ([handler conformsToProtocol:@protocol(ZGAppGlobalConfigChangedHandler)]
                && [handler respondsToSelector:@selector(configManager:appGlobalConfigChanged:)]) {
                [handler configManager:self appGlobalConfigChanged:configInfo];
            }
        }
    });
}

@end

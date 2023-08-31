//
//  ZGAppGlobalConfigManager.h
//  ZegoExpressExample-iOS-OC
//
//  Created by jeffreypeng on 2019/8/6.
//  Copyright © 2019 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZGAppGlobalConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class ZGAppGlobalConfigManager;

/// App Global Settings Update Event Processing Protocol
@protocol ZGAppGlobalConfigChangedHandler <NSObject>

- (void)configManager:(ZGAppGlobalConfigManager *)configManager appGlobalConfigChanged:(ZGAppGlobalConfig *)configInfo;

@end

/// App Global Settings Manager
/// You can receive the App Global Settings update event by implementing `ZGAppGlobalConfigChangedHandler` and adding it to the manager
@interface ZGAppGlobalConfigManager : NSObject


+ (instancetype)sharedManager;

/// Default global configuration
+ (ZGAppGlobalConfig *)defaultGlobalConfig;

/// Update global configuration
/// @param config new configuration
- (void)setGlobalConfig:(ZGAppGlobalConfig *)config;

/// Get the saved global configuration
/// Returns the default if there are no saved settings or if the acquisition fails
- (ZGAppGlobalConfig *)globalConfig;

/// Add a global settings update event handler. Weak reference implementation
- (void)addGlobalConfigChangedHandler:(id<ZGAppGlobalConfigChangedHandler>)handler;

/// Remove global settings update event handler
- (void)removeGlobalConfigChangedHandler:(id<ZGAppGlobalConfigChangedHandler>)handler;

@end

NS_ASSUME_NONNULL_END

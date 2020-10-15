//
//  AppDelegate.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/7.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "AppDelegate.h"
#import "ZegoLog.h"
#import "ZegoTTYLogger.h"
#import "ZegoDiskLogger.h"
#import "ZegoRAMStoreLogger.h"
#import <Bugly/Bugly.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Bugly startWithAppId:@"87434a25df"];
    [self configZegoLog];
    return YES;
}

- (void)configZegoLog {
    ZegoTTYLogger *ttyLogger = [ZegoTTYLogger new];
    ttyLogger.level = kZegoLogLevelDebug;
    ZegoRAMStoreLogger *ramLogger = [ZegoRAMStoreLogger new];
    ramLogger.level = kZegoLogLevelDebug;
    ZegoDiskLogger *diskLogger = [ZegoDiskLogger new];
    diskLogger.level = kZegoLogLevelDebug;
    
    [ZegoLog addLogger:ttyLogger];
    [ZegoLog addLogger:ramLogger];
    [ZegoLog addLogger:diskLogger];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

@end

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
#import <ZegoExpressEngine/ZegoExpressEngine.h>

#ifndef TARGET_OS_MACCATALYST
#import <Bugly/Bugly.h>
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configZegoLog];
    self.restrictRotation = UIInterfaceOrientationMaskPortrait;
#ifndef TARGET_OS_MACCATALYST
    [Bugly startWithAppId:@"5298cd65c1"];
#endif
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
    return self.restrictRotation;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options API_AVAILABLE(ios(13.0)) {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions API_AVAILABLE(ios(13.0)) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end

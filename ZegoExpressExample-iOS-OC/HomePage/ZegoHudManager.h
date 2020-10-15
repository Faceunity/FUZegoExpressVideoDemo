//
//  ZegoHudManager.h
//  Chatroom-iOS
//
//  Created by Sky on 2019/3/13.
//  Copyright © 2019 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZegoHudManager : NSObject

/// Remove all HUDs
+ (void)hideAllHUD;

/// Display a message
/// @param message message content
+ (void)showMessage:(NSString *)message;

/// Display a message
/// @param message message content
/// @param doneHandler done callback
+ (void)showMessage:(NSString *)message done:(void(^)(void))doneHandler;

/// Show prompt task in progress message
/// @param message message content
/// @param doneHandler done callback
+ (void)showIndeterminateMessage:(NSString *)message done:(void(^)(void))doneHandler;

/// Show prompts for custom Views and messages
/// @param message message content
/// @param customView custom view
/// @param doneHandler done callback
+ (void)showCustomMessage:(NSString *)message customView:(UIView *)customView done:(void(^)(void))doneHandler;

/// Display network loading HUD
+ (void)showNetworkLoading;

/// Remove network loading HUD
+ (void)hideNetworkLoading;

@end

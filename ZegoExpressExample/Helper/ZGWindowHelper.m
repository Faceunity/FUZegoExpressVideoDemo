//
//  ZGWindowHelper.m
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2021/12/6.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGWindowHelper.h"

@implementation ZGWindowHelper

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

+ (nullable UIWindow *)keyWindow {
    if (@available(iOS 13.0, macCatalyst 13.0, *)) {
        NSSet<UIWindowScene *> *scenes = (NSSet<UIWindowScene *> *)[[UIApplication sharedApplication] connectedScenes];
        for (UIWindowScene *scene in scenes) {
            if (scene.activationState != UISceneActivationStateForegroundActive) {
                break;
            }
            for (UIWindow *window in [scene windows]) {
                if ([window isKeyWindow]) {
                    return window;
                }
            }
        }
        return nil;
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
}

+ (CGRect)statusBarFrame {
    if (@available(iOS 13.0, macCatalyst 13.0, *)) {
        return [[[[ZGWindowHelper keyWindow] windowScene] statusBarManager] statusBarFrame];
    } else {
        return [[UIApplication sharedApplication] statusBarFrame];
    }
}

+ (UIInterfaceOrientation)statusBarOrientation {
    if (@available(iOS 13.0, macCatalyst 13.0, *)) {
        return [[[ZGWindowHelper keyWindow] windowScene] interfaceOrientation];
    } else {
        return [[UIApplication sharedApplication] statusBarOrientation];
    }
}

#pragma clang diagnostic pop

@end

//
//  ZGWindowHelper.h
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2021/12/6.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGWindowHelper : NSObject

+ (nullable UIWindow *)keyWindow;

+ (CGRect)statusBarFrame;

+ (UIInterfaceOrientation)statusBarOrientation;

@end

NS_ASSUME_NONNULL_END

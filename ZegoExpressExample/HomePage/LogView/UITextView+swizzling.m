//
//  UITextView+swizzling.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "UITextView+swizzling.h"
#import <objc/runtime.h>
#import "NSObject+Swizzling.h"
#import "ZegoLogView.h"


@implementation UITextView (swizzling)
+ (void)load {
    [super load];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        // 原方法名和替换方法名
        SEL originalSelector = @selector(awakeFromNib);
        SEL swizzledSelector = @selector(swizzle_awakeFromNib);
        
        [NSObject ff_swizzleInstanceMethodWithSrcClass:class srcSel:originalSelector swizzledSel:swizzledSelector];
    });
}

- (void)swizzle_awakeFromNib {
    [self swizzle_awakeFromNib];
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapSelf)];
    [self addGestureRecognizer:gr];
}

- (void)onTapSelf {
    [ZegoLogView show];
}
@end

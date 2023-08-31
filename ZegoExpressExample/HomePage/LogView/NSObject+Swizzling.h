//
//  NSObject+Swizzling.h
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Swizzling)
+ (void)ff_swizzleInstanceMethodWithSrcClass:(Class)srcClass
                                      srcSel:(SEL)srcSel
                                 swizzledSel:(SEL)swizzledSel;
@end

NS_ASSUME_NONNULL_END

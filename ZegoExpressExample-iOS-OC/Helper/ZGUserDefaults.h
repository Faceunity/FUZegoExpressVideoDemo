//
//  ZGUserDefaults.h
//  ZegoExpressExample-iOS-OC
//
//  Created by jeffreypeng on 2019/7/23.
//  Copyright © 2019 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Subclass NSUserDefaults, the specific suitename specified in the implementation specifies the project
@interface ZGUserDefaults : NSUserDefaults

+ (NSUserDefaults *)standardUserDefaults NS_UNAVAILABLE;

- (instancetype)initWithSuiteName:(nullable NSString *)suitename NS_UNAVAILABLE;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END

//
//  KeyCenter.h
//  ZegoExpressExample
//
//  Created by Sky on 2019/5/10.
//  Copyright © 2019 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyCenter : NSObject

+ (unsigned int)appID;

+ (void)setAppID:(unsigned int)appID;

+ (NSString *)appSign;

+ (void)setAppSign:(NSString *)appSign;

@end

NS_ASSUME_NONNULL_END

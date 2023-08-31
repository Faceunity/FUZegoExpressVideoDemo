//
//  ZGAppGlobalConfig.h
//  ZegoExpressExample-iOS-OC
//
//  Created by jeffreypeng on 2019/8/6.
//  Copyright © 2019 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Global Config Model
 *
 */
@interface ZGAppGlobalConfig : NSObject

/// App ID
@property (nonatomic, assign) unsigned int appID;

/// user ID
@property (nonatomic, copy) NSString *userID;

/// appSign
@property (nonatomic, copy) NSString *appSign;

/// Scenraio
@property (nonatomic, assign) ZegoScenario scenario;

/// Convert from a dictionary to a current type instance
+ (instancetype)fromDictionary:(NSDictionary *)dic;

/// Convert to dictionary
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END

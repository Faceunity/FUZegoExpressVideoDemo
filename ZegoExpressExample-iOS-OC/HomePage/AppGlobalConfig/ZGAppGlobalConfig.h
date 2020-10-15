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

/// App Sign
@property (nonatomic, copy) NSString *appSign;

/// Environment
@property (nonatomic, assign) BOOL isTestEnv;

/// Scenraio
@property (nonatomic, assign) ZegoScenario scenario;

/// Convert from a dictionary to a current type instance
+ (instancetype)fromDictionary:(NSDictionary *)dic;

/// Convert to dictionary
- (NSDictionary *)toDictionary;

@end

NS_ASSUME_NONNULL_END

//
//  ZGAppGlobalConfig.m
//  ZegoExpressExample-iOS-OC
//
//  Created by jeffreypeng on 2019/8/6.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGAppGlobalConfig.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"

@implementation ZGAppGlobalConfig

- (unsigned int)appID {
    return KeyCenter.appID;
}

- (NSString *)userID {
    return [ZGUserIDHelper userID];
}

- (NSString *)appSign {
    return KeyCenter.appSign;
}

+ (instancetype)fromDictionary:(NSDictionary *)dic {
    if (dic == nil) {
        return nil;
    }
    ZGAppGlobalConfig *obj = [[ZGAppGlobalConfig alloc] init];
    obj.appID = KeyCenter.appID;
    obj.userID = [ZGUserIDHelper userID];
    obj.appSign = KeyCenter.appSign;
    obj.scenario = ZegoScenarioDefault;
    return obj;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dic[NSStringFromSelector(@selector(appID))] = @(self.appID);
    dic[NSStringFromSelector(@selector(userID))] = self.userID ? self.userID : @"";
    dic[NSStringFromSelector(@selector(appSign))] = self.appSign ? self.appSign : @"";
    dic[NSStringFromSelector(@selector(scenario))] = @(self.scenario);
    
    return [dic copy];
}

+ (BOOL)checkIsNSStringOrNSNumber:(id)obj {
    return ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]);
}

@end

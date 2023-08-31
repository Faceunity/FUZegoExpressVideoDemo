//
//  KeyCenter.m
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2019/11/11.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "KeyCenter.h"

@implementation KeyCenter

// Developers can get appID from admin console.
// https://console.zego.im/dashboard
// for example: 123456789;
static unsigned int _appID = 0;

// AppSign only meets simple authentication requirements.
// If you need to upgrade to a more secure authentication method,
// please refer to [Guide for upgrading the authentication mode from using the AppSign to Token](https://docs.zegocloud.com/faq/token_upgrade)
// Developers can get AppSign from admin [console](https://console.zego.im/dashboard)
// for example: @"abcdefghijklmnopqrstuvwxyz0123456789abcdegfhijklmnopqrstuvwxyz01";
static NSString *_appSign = @"";

+ (unsigned int)appID {
    return _appID;
}

+ (void)setAppID:(unsigned int)appID {
    _appID = appID;
}

+ (NSString *)appSign {
    return _appSign;
}

+ (void)setAppSign:(NSString *)appSign {
    _appSign = appSign;
}

@end

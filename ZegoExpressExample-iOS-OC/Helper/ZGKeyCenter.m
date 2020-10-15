//
//  ZGKeyCenter.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/11.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGKeyCenter.h"

@implementation ZGKeyCenter

// Apply AppID and AppSign from Zego
+ (unsigned int)appID {
// for example:
//     return 1234567890;
    return 721912524;
}

// Apply AppID and AppSign from Zego
+ (NSString *)appSign {
// for example:
//     return @"abcdefghijklmnopqrstuvwzyv123456789abcdefghijklmnopqrstuvwzyz123";
    
    return @"6d630288fe13c7e8055ea8fd41d67bcdb5e125d21526dd957722b8660a3d431b";
}

@end

//
//  ZGUserIDHelper.m
//  ZegoExpressExample-iOS-OC
//
//  Copyright © 2018 Zego. All rights reserved.
//

#import "ZGUserIDHelper.h"
#import "KeyCenter.h"

#if TARGET_OS_OSX
#import <IOKit/IOKitLib.h>
#import <sys/sysctl.h>
#elif TARGET_OS_IOS
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#endif

NSString* kZGUserIDKey = @"user_id";
NSString* kZGUserNameKey = @"user_name";

@interface ZGUserIDHelper ()

@end

static NSString *_userID = nil;
static NSString *_userName = nil;

@implementation ZGUserIDHelper

+ (NSString *)userID {
    if (_userID.length == 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *userID = [ud stringForKey:kZGUserIDKey];
        if (userID.length > 0) {
            _userID = userID;
        } else {
            srand((unsigned)time(0));
            userID = [NSString stringWithFormat:@"%@@%u", [ZGUserIDHelper getDeviceModel], (unsigned)rand()%100000];
            _userID = userID;
            [ud setObject:userID forKey:kZGUserIDKey];
            [ud synchronize];
        }
    }
    
    return _userID;
}

+ (void)setUserID:(NSString *)userID {
    _userID = userID;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:userID forKey:kZGUserIDKey];
    [ud synchronize];
}

+ (NSString *)userName {
    if (_userName.length == 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *userName = [ud stringForKey:kZGUserNameKey];
        if (userName.length > 0) {
            _userName = userName;
        } else {
            userName = [ZGUserIDHelper getDeviceModel];
            _userName = userName;
            [ud setObject:userName forKey:kZGUserNameKey];
            [ud synchronize];
        }
    }
    
    return _userName;
}

#if TARGET_OS_OSX
+ (NSString *)getDeviceUUID {
    io_service_t platformExpert;
    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    if (platformExpert) {
        CFTypeRef serialNumberAsCFString;
        serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, CFSTR("IOPlatformUUID"), kCFAllocatorDefault, 0);
        IOObjectRelease(platformExpert);
        if (serialNumberAsCFString) {
            return (__bridge_transfer NSString*)(serialNumberAsCFString);
        }
    }
    
    return @"hello";
}

+ (NSString *)getDeviceModel {
    NSString *result=@"Mac";
    size_t len=0;
    sysctlbyname("hw.model", NULL, &len, NULL, 0);
    if (len) {
        NSMutableData *data=[NSMutableData dataWithLength:len];
        sysctlbyname("hw.model", [data mutableBytes], &len, NULL, 0);
        result=[NSString stringWithUTF8String:[data bytes]];
    }
    return result;
}

#elif TARGET_OS_IOS
+ (NSString *)getDeviceUUID {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSString *)getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
}
#endif

@end

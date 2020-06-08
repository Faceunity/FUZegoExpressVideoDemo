//
//  ZGApiManager.m
//  LiveRoomPlayground
//
//  Copyright © 2018年 Zego. All rights reserved.
//

#import "ZGApiManager.h"
#import "ZGKeyCenter.h"
#import "ZGAppSignHelper.h"

static ZegoLiveRoomApi *s_apiInstance = nil;

@implementation ZGApiManager

+ (ZegoLiveRoomApi*)api {
    if (!s_apiInstance) {
        ZGAppGlobalConfig *config = [[ZGAppGlobalConfigManager sharedInstance] globalConfig];
        [self initApiWithAppID:config.appID appSign:[ZGAppSignHelper convertAppSignFromString:config.appSign] completionBlock:nil];
        
        NSString *userID = ZGUserIDHelper.userID;
        [ZegoLiveRoomApi setUserID:userID userName:userID];
    }
    
    return s_apiInstance;
}

/**
 * 释放zegoSDK
 * 当开发者不再需要使用到sdk时, 可以释放sdk。
 * 注意!!! 请根据业务需求来释放sdk。
 */
+ (void)releaseApi {
    ZGLogInfo(@"销毁SDK");
    s_apiInstance = nil;
}

+ (BOOL)initApiWithAppID:(unsigned int)appID appSign:(NSData *)appSign completionBlock:(nullable ZegoInitSDKCompletionBlock)blk {
    if (s_apiInstance) {
        ZGLogInfo(@"初始化SDK，但已存在SDK实例");
        [self releaseApi];
    }
    
    //设置环境的接口需要在 SDK 初始化前调用才会生效
    //建议开发者在开发阶段设置为测试环境，使用由 ZEGO 提供的测试环境，上线前需切换为正式环境运营
    //注意!!! 如果没有向 ZEGO 申请正式环境的 AppID, 则需设置成测试环境, 否则 SDK 会初始化失败
    ZGAppGlobalConfig *config = [[ZGAppGlobalConfigManager sharedInstance] globalConfig];
    [ZegoLiveRoomApi setUseTestEnv:config.environment == ZGAppEnvironmentTest];
    
    //AppID:Zego 分配的AppID, 可通过 https://console.zego.im/acount/login 申请
    //AppSign:Zego 分配的签名, 用来校验对应 AppID 的合法性。 可通过 https://console.zego.im/acount/login 申请
    s_apiInstance = [[ZegoLiveRoomApi alloc] initWithAppID:appID appSignature:appSign completionBlock:^(int errorCode) {
        //errorCode 非0 代表初始化sdk失败
        //具体错误码说明请查看 https://doc.zego.im/CN/308.html
        BOOL success = errorCode == 0;
        
        if (success) {
            ZGLogInfo(@"SDK初始化成功.");
        }
        else {
            ZGLogError(@"SDK初始化失败,errorCode:%d",errorCode);
        }
        
        if (blk) {
            blk(errorCode);
        }
    }];
    
    // 设置硬编硬解
    [ZegoLiveRoomApi requireHardwareEncoder:config.openHardwareEncode];
    [ZegoLiveRoomApi requireHardwareDecoder:config.openHardwareDecode];
    
    ZGLogInfo(@"初始化SDK，AppID:%u,AppSign:%@", appID, appSign);
    return s_apiInstance != nil;
}

@end


//
//  SampleHandler.m
//  ZegoExpressExample-iOS-OC-Broadcast
//
//  Created by Patrick Fu on 2020/9/16.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "SampleHandler.h"
#import "../ZGScreenCaptureDefines.h"
#import <ZegoExpressEngine/ZegoExpressDefines.h>
#import <ZegoExpressEngine/ZegoExpressEventHandler.h>

@interface SampleHandler () <ZegoReplayKitExtHandler>

@end

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.

    // Note:
    // If you want to experience this feature, please click the [ZegoExpressExample-iOS-OC] project in the project
    // navigator on the left of Xcode, find the [App Groups] column in the [Signing & Capabilities] tab of
    // both Target [ZegoExpressExample-iOS-OC] and [ZegoExpressExample-iOS-OC-Broadcast], click the `+` to add a custom
    // App Group ID and enable it; then fill in this App Group ID into the [APP_GROUP] macro in file [ZGScreenCaptureDefines.h]
    //
    // This demo has encapsulated the logic of calling the ZegoExpressEngine SDK in the [ZGScreenCaptureManager] class.
    // Please refer to it to implement [SampleHandler] class in your own project
    //
    //
    // 注意：
    // 若需要体验此功能，请点击 Xcode 左侧项目导航栏中的 [ZegoExpressExample-iOS-OC] 工程项目，
    // 找到 Target [ZegoExpressExample-iOS-OC] 以及 [ZegoExpressExample-iOS-OC-Broadcast] 的
    // [Signing & Capabilities] 选项中的 App Groups 栏目，点击 `+` 号添加一个您自定义的 App Group ID 并启用；
    // 然后将此 ID 填写到 [ZGScreenCaptureDefines.h] 文件中的 APP_GROUP 宏内
    //
//    [ZegoReplayKitExt.sharedInstance setupWithDelegate:self];
    [ZegoReplayKitExt.sharedInstance setupWithDelegate:self appGroup:@"group.im.zego.express"];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    [ZegoReplayKitExt.sharedInstance finished];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    [ZegoReplayKitExt.sharedInstance sendSampleBuffer:sampleBuffer withType:sampleBufferType];
}

#pragma mark - Zego Replay Kit Ext Handler
- (void)broadcastFinished:(ZegoReplayKitExt *)broadcast reason:(ZegoReplayKitExtReason)reason {
    
    switch (reason) {
        case ZegoReplayKitExtReasonHostStop:
            {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Host app stop srceen capture"};
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:userInfo];
                [self finishBroadcastWithError:error];
            }
            break;
        case ZegoReplayKitExtReasonConnectFail:
            {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Connect host app fail need startScreenCapture in host app"};
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:userInfo];
                [self finishBroadcastWithError:error];
            }
            break;
        case ZegoReplayKitExtReasonDisconnect:
            {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"disconnect with host app"};
                NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:userInfo];
                [self finishBroadcastWithError:error];
            }
            break;
    }
}

@end

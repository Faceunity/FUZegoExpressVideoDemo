//
//  ZGShareLogViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Sky on 2019/4/16.
//  Copyright © 2019 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../../Examples/Others/ScreenSharing/ZGScreenCaptureDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZGShareLogViewController : UIViewController

- (void)shareMainAppLogs;

- (void)shareReplayKitExtensionLogs;

@end

NS_ASSUME_NONNULL_END

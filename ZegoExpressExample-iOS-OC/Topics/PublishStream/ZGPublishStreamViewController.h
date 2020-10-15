//
//  ZGPublishStreamViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/5/29.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_PublishStream

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGPublishStreamViewController : UIViewController

@property (nonatomic, assign) BOOL enableCamera;
@property (nonatomic, assign) BOOL enableHardwareEncoder;
@property (nonatomic, assign) int captureVolume;
@property (nonatomic, copy) NSString *streamExtraInfo;
@property (nonatomic, copy) NSString *roomExtraInfoKey;
@property (nonatomic, copy) NSString *roomExtraInfoValue;

- (void)appendLog:(NSString *)tipText;

@end

NS_ASSUME_NONNULL_END

#endif

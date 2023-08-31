//
//  ZGPublishStreamViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/5/29.
//  Copyright © 2020 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGPublishStreamViewController : UIViewController

@property (nonatomic, assign) BOOL enableCamera;
@property (nonatomic, assign) BOOL useFrontCamera;
@property (nonatomic, assign) int captureVolume;
@property (nonatomic, assign) float maxZoomFactor;
@property (nonatomic, assign) float currentZoomFactor;
@property (nonatomic, copy) NSString *streamExtraInfo;
@property (nonatomic, copy) NSString *roomExtraInfoKey;
@property (nonatomic, copy) NSString *roomExtraInfoValue;
@property (nonatomic, copy) NSString *encryptionKey;

- (void)appendLog:(NSString *)tipText;

@end

NS_ASSUME_NONNULL_END

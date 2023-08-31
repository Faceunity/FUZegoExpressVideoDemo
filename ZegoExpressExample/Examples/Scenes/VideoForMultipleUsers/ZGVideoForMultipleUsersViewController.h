//
//  ZGVideoForMultipleUsersViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/30.
//  Copyright © 2019 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGVideoForMultipleUsersViewController : UIViewController
/// room ID
@property (nonatomic, copy) NSString *roomID;
/// user ID
@property (nonatomic, copy) NSString *localUserID;
/// user Name
@property (nonatomic, copy) NSString *localUserName;

@property (nonatomic, assign) CGSize captureResolution;
@property (nonatomic, assign) CGSize encodeResolution;

@property (nonatomic, assign) CGFloat videoFps;

@property (nonatomic, assign) CGFloat videoBitrate;

@end

NS_ASSUME_NONNULL_END

//
//  ZGCustomAudioIOViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_CustomAudioIO

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGCustomAudioIOViewController : UIViewController

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *localPublishStreamID;
@property (nonatomic, copy) NSString *remotePlayStreamID;

@end

NS_ASSUME_NONNULL_END

#endif

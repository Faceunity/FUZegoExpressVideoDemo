//
//  ZGAudioMixingViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/15.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_AudioMixing

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGAudioMixingViewController : UIViewController

@property (nonatomic, assign) BOOL enableAudioMixing;
@property (nonatomic, assign) BOOL muteLocalAudioMixing;
@property (nonatomic, assign) int audioMixingVolume;

@end

NS_ASSUME_NONNULL_END

#endif

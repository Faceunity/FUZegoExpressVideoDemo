//
//  ZGAudioMixingSettingTableViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/15.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_AudioMixing

#import <UIKit/UIKit.h>
#import "ZGAudioMixingViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZGAudioMixingSettingTableViewController : UITableViewController

+ (instancetype)instanceFromStoryboard;

@property (nonatomic, weak) ZGAudioMixingViewController *presenter;

@property (nonatomic, assign) BOOL enableAudioMixing;
@property (nonatomic, assign) BOOL muteLocalAudioMixing;
@property (nonatomic, assign) int audioMixingVolume;

@property (nonatomic, strong) void(^enableAudioMixingBlock)(BOOL enable);
@property (nonatomic, strong) void(^muteLocalAudioMixingBlock)(BOOL mute);
@property (nonatomic, strong) void(^setAudioMixingVolumeBlock)(int volume);

@end

NS_ASSUME_NONNULL_END

#endif

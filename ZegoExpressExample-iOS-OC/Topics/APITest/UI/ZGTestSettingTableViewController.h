//
//  ZGTestSettingTableViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/24.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_Test

#import <UIKit/UIKit.h>
#import "ZGTestTopicManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ZGTestViewDelegate <NSObject>

@required

- (UIView *)getPublishView;
- (UIView *)getPlayView;

@end

@interface ZGTestSettingTableViewController : UITableViewController

@property (nonatomic, strong) id<ZGTestManager> manager;

- (void)setZGTestViewDelegate:(id<ZGTestViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END

#endif

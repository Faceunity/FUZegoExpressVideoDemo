//
//  ZGMediaPlayerViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/25.
//  Copyright © 2019 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZGMediaPlayerMediaItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZGMediaPlayerViewController : UITableViewController

@property (nonatomic, strong) ZGMediaPlayerMediaItem *mediaItem;
@property (nonatomic, assign) BOOL alphaBlend;
@property (nonatomic, assign) int alphaLayout;
@property (nonatomic, assign) BOOL mediaPlayerHardwareDecode;

@end

NS_ASSUME_NONNULL_END

//
//  ZGMediaPlayerViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/25.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_MediaPlayer

#import <UIKit/UIKit.h>
#import "ZGMediaPlayerMediaItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZGMediaPlayerViewController : UITableViewController

@property (nonatomic, strong) ZGMediaPlayerMediaItem *mediaItem;

@end

NS_ASSUME_NONNULL_END

#endif

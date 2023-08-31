//
//  ZGVideoChatViewController.h
//  ZegoExpressExample
//
//  Created by 王鑫 on 2021/11/29.
//  Copyright © 2021 Zego. All rights reserved.
//

#ifndef ZGVideoChatViewController_h
#define ZGVideoChatViewController_h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGVideoChatViewController : UIViewController

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *publishStreamID;


@end

NS_ASSUME_NONNULL_END

#endif /* ZGVideoChatViewController_h */

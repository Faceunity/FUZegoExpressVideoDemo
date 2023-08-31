//
//  ZGRoomMessageSelectUsersTableViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/22.
//  Copyright © 2019 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGRoomMessageSelectUsersTableViewController : UITableViewController

@property (nonatomic, readonly) NSArray<ZegoUser *> *selectedUsers;

- (void)updateRoomUserList:(NSArray<ZegoUser *> *)userList;

@end

NS_ASSUME_NONNULL_END

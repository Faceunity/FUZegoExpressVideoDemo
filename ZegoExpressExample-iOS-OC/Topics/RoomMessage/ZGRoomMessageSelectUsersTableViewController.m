//
//  ZGRoomMessageSelectUsersTableViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/22.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_RoomMessage

#import "ZGRoomMessageSelectUsersTableViewController.h"

@interface ZGRoomMessageSelectUsersTableViewController ()

@property (nonatomic) NSMutableDictionary<NSString *,ZegoUser *> *userIDKeyedUserDic;
@property (nonatomic, copy) NSArray<ZegoUser *> *userList;

@end

@implementation ZGRoomMessageSelectUsersTableViewController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userIDKeyedUserDic = [NSMutableDictionary dictionary];
    self.title = @"Select Remote Users";
}

- (void)updateRoomUserList:(NSArray<ZegoUser *> *)userList {
    self.userList = userList;
    
    NSArray<NSString *> *userIds = [userList valueForKeyPath:@"userID"];
    NSArray<ZegoUser *> *selUsers = [self.userIDKeyedUserDic.allValues copy];
    for (ZegoUser *selUser in selUsers) {
        if (![userIds containsObject:selUser.userID]) {
            [self deselectUser:selUser];
        }
    }
    [self.tableView reloadData];
}

- (NSArray<ZegoUser *> *)selectedUsers {
    return [[self.userIDKeyedUserDic allValues] copy];
}

- (void)selectUser:(ZegoUser *)user {
    if (![self.userIDKeyedUserDic.allKeys containsObject:user.userID]) {
        self.userIDKeyedUserDic[user.userID] = user;
    }
}

- (void)deselectUser:(ZegoUser *)user {
    if ([self.userIDKeyedUserDic.allKeys containsObject:user.userID]) {
        [self.userIDKeyedUserDic removeObjectForKey:user.userID];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    ZegoUser *userInfo = self.userList[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", userInfo.userName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"User ID: %@", userInfo.userID];
    cell.accessoryType = [self.userIDKeyedUserDic.allKeys containsObject:userInfo.userID] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZegoUser *userInfo = self.userList[indexPath.row];
    
    // toggle select or deselect this user
    if ([self.self.userIDKeyedUserDic.allKeys containsObject:userInfo.userID]) {
        [self deselectUser:userInfo];
    } else {
        [self selectUser:userInfo];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}



@end

#endif

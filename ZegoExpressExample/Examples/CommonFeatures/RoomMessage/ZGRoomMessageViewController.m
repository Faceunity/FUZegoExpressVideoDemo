//
//  ZGRoomMessageViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/22.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGRoomMessageViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import "ZGRoomMessageSelectUsersTableViewController.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGRoomMessageViewController () <ZegoEventHandler, UITextFieldDelegate>

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *streamID;

@property (nonatomic, strong) NSMutableArray<ZegoUser *> *userList;
@property (nonatomic) ZGRoomMessageSelectUsersTableViewController *selectUsersVC;

@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

// PublishStream
// Preview View
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;

@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;

// PlayStream
@property (weak, nonatomic) IBOutlet UILabel *playStreamLabel;

@property (weak, nonatomic) IBOutlet UIView *remotePlayView;
@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;

@property (weak, nonatomic) IBOutlet UITextView *receivedMessageTextView;

@property (weak, nonatomic) IBOutlet UITextField *broadcastMessageTextField;
@property (weak, nonatomic) IBOutlet UITextField *customCommandTextField;
@property (weak, nonatomic) IBOutlet UITextField *barrageMessageTextField;

@property (weak, nonatomic) IBOutlet UITextField *roomExtraInfoTextField;

@end

@implementation ZGRoomMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.roomID = @"0007";
    self.streamID = @"0007";
    self.userID = [ZGUserIDHelper userID];
    self.userName = [ZGUserIDHelper userName];

    self.userList = [NSMutableArray array];
    self.title = [NSString stringWithFormat:@"Room Message"];
    
    self.publishStreamIDTextField.text = self.streamID;
    self.playStreamIDTextField.text = self.streamID;
    self.receivedMessageTextView.text = @"";
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.roomStateLabel.text = @"Not Connected 🔴";

    self.userIDLabel.text = [NSString stringWithFormat:@"UserID: %@", self.userID];
    self.userNameLabel.text = [NSString stringWithFormat:@"UserName: %@", self.userName];
    
    [self createEngineAndLoginRoom];
    [self setupUI];
}

- (void)setupUI {
    self.previewLabel.text = NSLocalizedString(@"PreviewLabel", nil);
    self.playStreamLabel.text = NSLocalizedString(@"PlayStreamLabel", nil);
    [self.startPlayingButton setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.startPlayingButton setTitle:@"Stop Playing" forState:UIControlStateSelected];
    
    [self.startPublishingButton setTitle:@"Start Publishing" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"Stop Publishing" forState:UIControlStateSelected];
    
    self.broadcastMessageTextField.placeholder = NSLocalizedString(@"MessageMaxBytes1024", nil);
    
    self.customCommandTextField.placeholder = NSLocalizedString(@"MessageMaxBytes1024", nil);
    
    self.barrageMessageTextField.placeholder = NSLocalizedString(@"MessageMaxBytes1024", nil);
    
    self.roomExtraInfoTextField.placeholder = NSLocalizedString(@"MessageMaxBytes128", nil);
}

- (void)createEngineAndLoginRoom {
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    
    // Here we use the high quality video call scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    profile.scenario = ZegoScenarioHighQualityVideoCall;
    
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
    
    ZegoUser *user = [ZegoUser userWithUserID:self.userID userName:self.userName];
    
    // To receive the onRoomUserUpdate:userList:room: callback, you need to set the isUserStatusNotify parameter to YES.
    ZegoRoomConfig *roomConfig = [[ZegoRoomConfig alloc] init];
    roomConfig.isUserStatusNotify = YES;
    
    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user config:roomConfig];
}

#pragma mark - Actions

- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop publishing
        [self appendMessage:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.publishStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
    } else {
        // Start preview
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
        [self appendMessage:@"🔌 Start preview"];
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        
        // Start publishing
        [self appendMessage:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.publishStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.publishStreamIDTextField.text];
    }
    sender.selected = !sender.isSelected;
    
}
- (IBAction)onStartPlayingButtonTappd:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop playing
        [self appendMessage:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", self.playStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] stopPlayingStream: self.playStreamIDTextField.text];
    } else {
        
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
        [self appendMessage:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.playStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:playCanvas];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)selectUsersButtonClick:(UIButton *)sender {
    [self.navigationController pushViewController:self.selectUsersVC animated:YES];
}

- (IBAction)sendBroadcastMessageButtonClick:(UIButton *)sender {
    [self sendBroadcastMessage];
    [self.view endEditing:YES];
}

- (IBAction)sendCustomCommandButtonClick:(UIButton *)sender {
    [self sendCustomCommand];
    [self.view endEditing:YES];
}
- (IBAction)sendBarrageMessageButtonClick:(UIButton *)sender {
    [self sendBarrageMessage];
    [self.view endEditing:YES];
}

- (IBAction)onSendExtraInfoButtonTapped:(id)sender {
    [[ZegoExpressEngine sharedEngine] setRoomExtraInfo:self.roomExtraInfoTextField.text forKey:@"key" roomID:self.roomID callback:^(int errorCode) {
        ZGLogInfo(@"🚩 🗯 Set RoomExtraInfo result, errorCode: %d, Key:%@ RoomExtraInfo: %@", errorCode, @"key", self.roomExtraInfoTextField.text);
        [self appendMessage:[NSString stringWithFormat:@"🚩 🗯 Set RoomExtraInfo result, errorCode: %d, Key:%@ RoomExtraInfo: %@", errorCode, @"key", self.roomExtraInfoTextField.text]];
    }];
    [self.view endEditing:YES];
}



- (void)sendBroadcastMessage {
    NSString *message = self.broadcastMessageTextField.text;
    [[ZegoExpressEngine sharedEngine] sendBroadcastMessage:message roomID:self.roomID callback:^(int errorCode, unsigned long long messageID) {
        ZGLogInfo(@"🚩 💬 Send broadcast message result, errorCode: %d, messageID: %llu", errorCode, messageID);
        [self appendMessage:[NSString stringWithFormat:@"💬 📤 Sent: %@", message]];
    }];
}

- (void)sendCustomCommand {
    NSString *command = self.customCommandTextField.text;
    NSArray<ZegoUser *> *toUserList = self.selectUsersVC.selectedUsers;
    [[ZegoExpressEngine sharedEngine] sendCustomCommand:command toUserList:toUserList roomID:self.roomID callback:^(int errorCode) {
        ZGLogInfo(@"🚩 💭 Send custom command to %d users result, errorCode: %d", (int)toUserList.count, errorCode);
        [self appendMessage:[NSString stringWithFormat:@"💭 📤 Sent to %d users: %@", (int)toUserList.count, command]];
    }];
}

- (void)sendBarrageMessage {
    NSString *message = self.barrageMessageTextField.text;
    [[ZegoExpressEngine sharedEngine] sendBarrageMessage:message roomID:self.roomID callback:^(int errorCode, NSString * _Nonnull messageID) {
        ZGLogInfo(@"🚩 🗯 Send barrage message result, errorCode: %d, messageID: %@", errorCode, messageID);
        [self appendMessage:[NSString stringWithFormat:@"🗯 📤 Sent: %@", message]];
    }];
}

- (void)appendMessage:(NSString *)message {
    if (!message || message.length == 0) {
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *oldText = self.receivedMessageTextView.text;
    NSString *newLine = oldText.length == 0 ? @"" : @"\n";
    NSString *newText = [NSString stringWithFormat:@"%@%@[%@] %@", oldText, newLine, currentTime, message];
    
    self.receivedMessageTextView.text = newText;
    if(newText.length > 0 ) {
        UITextView *textView = self.receivedMessageTextView;
        NSRange bottom = NSMakeRange(newText.length -1, 1);
        [textView scrollRangeToVisible:bottom];
        // an iOS bug, see https://stackoverflow.com/a/20989956/971070
        [textView setScrollEnabled:NO];
        [textView setScrollEnabled:YES];
    }
}

- (IBAction)clearBuffer:(UIButton *)sender {
    self.receivedMessageTextView.text = @"";
}




#pragma mark - Access SelectUserVC

- (ZGRoomMessageSelectUsersTableViewController *)selectUsersVC {
    if (!_selectUsersVC) {
        _selectUsersVC = [[ZGRoomMessageSelectUsersTableViewController alloc] init];
    }
    [_selectUsersVC updateRoomUserList:[self.userList copy]];
    return _selectUsersVC;
}

#pragma mark - ZegoEventHandler

-(void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if(reason == ZegoRoomStateChangedReasonLogining)
    {
        ZGLogInfo(@"🚩 🚪 Logining room");
        self.roomStateLabel.text = @"🟡 RoomState: Logining";
    }
    else if(reason == ZegoRoomStateChangedReasonLogined)
    {
        ZGLogInfo(@"🚩 🚪 Login room success");
        self.roomStateLabel.text = @"🟢 RoomState: Logined";
    }
    else if (reason == ZegoRoomStateChangedReasonLoginFailed)
    {
        ZGLogInfo(@"🚩 🚪 Login room failed");
        self.roomStateLabel.text = @"🔴 RoomState: Login failed";
    }
    else if(reason == ZegoRoomStateChangedReasonKickOut)
    {
        ZGLogInfo(@"🚩 🚪 Kick out of room");
        self.roomStateLabel.text = @"🔴 RoomState: Kick out";
    }
    else if(reason == ZegoRoomStateChangedReasonReconnecting)
    {
        ZGLogInfo(@"🚩 🚪 Reconnecting room");
        self.roomStateLabel.text = @"🟡 RoomState: Reconnecting";
    }
    else if(reason == ZegoRoomStateChangedReasonReconnectFailed)
    {
        ZGLogInfo(@"🚩 🚪 Reconnect room failed");
        self.roomStateLabel.text = @"🔴 RoomState: Reconnect failed";
    }
    else if(reason == ZegoRoomStateChangedReasonReconnected)
    {
        ZGLogInfo(@"🚩 🚪 Reconnect room success");
        self.roomStateLabel.text = @"🟢 RoomState: Reconnected";
    }
    else
    {
        // Logout
        // Logout failed
    }
}


- (void)onRoomUserUpdate:(ZegoUpdateType)updateType userList:(NSArray<ZegoUser *> *)userList roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🕺 Room User Update Callback: %lu, UsersCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)userList.count, roomID);
    
    if (updateType == ZegoUpdateTypeAdd) {
        for (ZegoUser *user in userList) {
            ZGLogInfo(@"🚩 🕺 --- [Add] UserID: %@, UserName: %@", user.userID, user.userName);
            if (![self.userList containsObject:user]) {
                [self.userList addObject:user];
            }
        }
    } else if (updateType == ZegoUpdateTypeDelete) {
        for (ZegoUser *user in userList) {
            ZGLogInfo(@"🚩 🕺 --- [Delete] UserID: %@, UserName: %@", user.userID, user.userName);
            __block ZegoUser *delUser = nil;
            [self.userList enumerateObjectsUsingBlock:^(ZegoUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.userID isEqualToString:user.userID] && [obj.userName isEqualToString:user.userName]) {
                    delUser = obj;
                    *stop = YES;
                }
            }];
            [self.userList removeObject:delUser];
        }
    }
    
    // Update Title
    self.title = [NSString stringWithFormat:@"%@  ( %d Users )", self.roomID, (int)self.userList.count + 1];
}

- (void)onIMRecvBroadcastMessage:(NSArray<ZegoBroadcastMessageInfo *> *)messageList roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 💬 IM Recv Broadcast Message Callback: roomID: %@", roomID);
    
    for (int idx = 0; idx < messageList.count; idx ++) {
        ZegoBroadcastMessageInfo *info = messageList[idx];
        ZGLogInfo(@"🚩 💬 --- message: %@, fromUserID: %@, sendTime: %llu, messageID: %llu", info.message, info.fromUser.userID, info.sendTime, info.messageID);
        
        [self appendMessage:[NSString stringWithFormat:@"💬 %@ [FromUserID: %@]", info.message, info.fromUser.userID]];
    }
}

- (void)onIMRecvCustomCommand:(NSString *)command fromUser:(ZegoUser *)fromUser roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 💭 IM Recv Custom Command Callback: roomID: %@", roomID);
    ZGLogInfo(@"🚩 💭 --- command: %@, fromUserID: %@", command, fromUser.userID);
    
    [self appendMessage:[NSString stringWithFormat:@"💭 %@ [FromUserID: %@]", command, fromUser.userID]];
}

- (void)onIMRecvBarrageMessage:(NSArray<ZegoBarrageMessageInfo *> *)messageList roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🗯 IM Recv Barrage Message Callback: roomID: %@", roomID);

    for (int idx = 0; idx < messageList.count; idx ++) {
        ZegoBarrageMessageInfo *info = messageList[idx];
        ZGLogInfo(@"🚩 🗯 --- message: %@, fromUserID: %@, sendTime: %llu, messageID: %@", info.message, info.fromUser.userID, info.sendTime, info.messageID);

        [self appendMessage:[NSString stringWithFormat:@"🗯 %@ [FromUserID: %@]", info.message, info.fromUser.userID]];
    }
}

- (void)onRoomExtraInfoUpdate:(NSArray<ZegoRoomExtraInfo *> *)roomExtraInfoList roomID:(NSString *)roomID {
    for (ZegoRoomExtraInfo *info in roomExtraInfoList) {
        ZGLogInfo(@"🚩 🗯 --- RoomExtraInfo Key: %@, Value: %@, UpdateTime: %llu, from {UserID: %@ UserName: %@", info.key, info.value, info.updateTime, info.updateUser.userID,info.updateUser.userName);
    }
//    ZGLogInfo(@"🚩 🗯 --- message: %@, fromUserID: %@, sendTime: %llu, messageID: %@", info.message, info.fromUser.userID, info.sendTime, info.messageID);

//    [self appendMessage:[NSString stringWithFormat:@"🗯 %@ [FromUserID: %@]", info.message, info.fromUser.userID]];
}

#pragma mark - Exit

- (void)viewDidDisappear:(BOOL)animated {
    if (self.isBeingDismissed || self.isMovingFromParentViewController
        || (self.navigationController && self.navigationController.isBeingDismissed)) {
        
        ZGLogInfo(@"🚪 Exit the room");
        [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
        
        // Can destroy the engine when you don't need audio and video calls
        ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
        [ZegoExpressEngine destroyEngine:nil];
    }
    [super viewDidDisappear:animated];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.broadcastMessageTextField) {
        [self sendBroadcastMessage];
    } else if (textField == self.customCommandTextField) {
        [self sendCustomCommand];
    }
    return YES;
}

#pragma mark - NoticeAction

- (IBAction)onBroadCastMessageNoticeTapped:(id)sender {
    [self showNotice:NSLocalizedString(@"BroadcastMessageNotice", nil) sender:sender];
}

- (IBAction)onCustomCommandNoticeTapped:(id)sender {
    [self showNotice:NSLocalizedString(@"CustomCommandNotice", nil) sender:sender];
}

- (IBAction)onBarrageMessageNoticeTapped:(id)sender {
    [self showNotice:NSLocalizedString(@"BarrageMessageNotice", nil) sender:sender];
}

- (IBAction)onRoomExtraInfoNoticeTapped:(id)sender {
    [self showNotice:NSLocalizedString(@"RoomExtraInfoNotice", nil) sender:sender];
}

- (void)showNotice:(NSString *)notice sender:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    alertController.message = notice;
    UIAlertAction *sureButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:sureButton];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

@end

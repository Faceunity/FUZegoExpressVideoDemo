//
//  ZGMultipleRoomsViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/13.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGMultipleRoomsViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import "PopupView/ZGMultipleRoomPopupView.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
@interface ZGMultipleRoomsViewController ()<ZegoEventHandler>

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

// LoginRoom
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;

@property (weak, nonatomic) IBOutlet UITextField *roomID1TextField;
@property (weak, nonatomic) IBOutlet UITextField *roomID2TextField;
@property (weak, nonatomic) IBOutlet UIButton *room1LoginButton;
@property (weak, nonatomic) IBOutlet UIButton *room2LoginButton;


// PublishStream
// Preview and Play View
@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UITextField *publishRoomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;

// PlayStream

@property (weak, nonatomic) IBOutlet UIView *remotePlayView;
@property (weak, nonatomic) IBOutlet UITextField *playStreamRoomIDTextField;

@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;

@property (nonatomic, strong) ZGMultipleRoomPopupView *room1StreamPopupView;
@property (nonatomic, strong) ZGMultipleRoomPopupView *room1UserPopupView;
@property (nonatomic, strong) ZGMultipleRoomPopupView *room2StreamPopupView;
@property (nonatomic, strong) ZGMultipleRoomPopupView *room2UserPopupView;

@property (weak, nonatomic) IBOutlet UIButton *room1StreamsButton;
@property (weak, nonatomic) IBOutlet UIButton *room2StreamsButton;
@property (weak, nonatomic) IBOutlet UIButton *room1UsersButton;
@property (weak, nonatomic) IBOutlet UIButton *room2UsersButton;

@property (nonatomic, strong) NSMutableDictionary<NSString*, ZegoStream *> *room1StreamsList;
@property (nonatomic, strong) NSMutableDictionary<NSString*, ZegoStream *> *room2StreamsList;
@property (nonatomic, strong) NSMutableDictionary<NSString*, ZegoUser *> *room1UsersList;
@property (nonatomic, strong) NSMutableDictionary<NSString*, ZegoUser *> *room2UsersList;

@end

@implementation ZGMultipleRoomsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userIDTextField.text = [ZGUserIDHelper userID];
    self.playStreamIDTextField.text = @"0029";
    self.publishStreamIDTextField.text = @"0029";
    
    self.room1StreamsList = [NSMutableDictionary<NSString*, ZegoStream *> dictionary];
    self.room2StreamsList = [NSMutableDictionary<NSString*, ZegoStream *> dictionary];
    self.room1UsersList = [NSMutableDictionary<NSString*, ZegoUser *> dictionary];
    self.room2UsersList = [NSMutableDictionary<NSString*, ZegoUser *> dictionary];
    
    [self createEngine];
    // Do any additional setup after loading the view.
}

- (void)createEngine {
    [self appendLog:@"🚀 Create ZegoExpressEngine"];
    
    [ZegoExpressEngine setRoomMode:ZegoRoomModeMultiRoom];
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)

    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    
    // Here we use the high quality video call scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    profile.scenario = ZegoScenarioHighQualityVideoCall;
    
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
}

- (IBAction)onLoginRoom1ButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // LogoutRoom1
        [self appendLog:[NSString stringWithFormat:@"📤 Logout Room roomID: %@", self.roomID1TextField.text]];
        [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID1TextField.text];
    } else {
        // Login Room1
        [self appendLog:[NSString stringWithFormat:@"🚪Login Room roomID: %@", self.roomID1TextField.text]];

        ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];
        config.isUserStatusNotify = true;
        [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID1TextField.text user:[ZegoUser userWithUserID:self.userIDTextField.text] config:config];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onLoginRoom2ButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // LogoutRoom2
        [self appendLog:[NSString stringWithFormat:@"📤 Logout Room roomID: %@", self.roomID2TextField.text]];

        [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID2TextField.text];
    } else {
        // Login Room2
        [self appendLog:[NSString stringWithFormat:@"🚪Login Room roomID: %@", self.roomID2TextField.text]];
        
        ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];
        config.isUserStatusNotify = true;
        [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID2TextField.text user:[ZegoUser userWithUserID:self.userIDTextField.text] config:config];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    // Start preview
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
    [self appendLog:@"🔌 Start preview"];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
    
    // Start publishing
    // Use userID as streamID
    [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.publishStreamIDTextField.text]];
    
    ZegoPublisherConfig *config = [[ZegoPublisherConfig alloc] init];
    config.roomID = self.publishRoomIDTextField.text;
    
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.publishStreamIDTextField.text config:config channel:ZegoPublishChannelMain];
}
- (IBAction)onStopPublishingButtonTappd:(UIButton *)sender {
    // Stop publishing
    // Use userID as streamID
    [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.publishStreamIDTextField.text]];

    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [[ZegoExpressEngine sharedEngine] stopPreview];
}

- (IBAction)onStartPlayingButtonTappd:(UIButton *)sender {
    // Start playing
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
    [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.playStreamIDTextField.text]];
    
    ZegoPlayerConfig *config = [[ZegoPlayerConfig alloc] init];
    config.roomID = self.playStreamRoomIDTextField.text;

    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:playCanvas config:config];
}

- (IBAction)onStopPlayingButtonTappd:(UIButton *)sender {
    // Stop playing
    [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", self.playStreamIDTextField.text]];
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
}

- (IBAction)onRoom1StreamsButtonTappd:(UIButton *)sender {
    self.room1StreamPopupView = [ZGMultipleRoomPopupView show];
    [self updateRoom1StreamPopupViewInfo];
}

- (IBAction)onRoom2StreamsButtonTappd:(UIButton *)sender {
    self.room2StreamPopupView = [ZGMultipleRoomPopupView show];
    [self updateRoom2StreamPopupViewInfo];
}

- (IBAction)onRoom1UsersButtonTappd:(UIButton *)sender {
    self.room1UserPopupView = [ZGMultipleRoomPopupView show];
    [self updateRoom1UserPopupViewInfo];
}

- (IBAction)onRoom2UsersButtonTappd:(UIButton *)sender {
    self.room2UserPopupView = [ZGMultipleRoomPopupView show];
    [self updateRoom2UserPopupViewInfo];
}

#pragma mark - SDKCallback
/// Refresh the remote user list

- (void)onRoomUserUpdate:(ZegoUpdateType)updateType
                userList:(NSArray<ZegoUser *> *)userList
                  roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🌊 Room user update, updateType:%lu, userCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)userList.count, roomID);

    if (roomID == self.roomID1TextField.text) {
        if (updateType == ZegoUpdateTypeAdd) {
            for (ZegoUser *user in userList) {
                if (![[self.room1UsersList allKeys] containsObject:user.userID]) {
                    self.room1UsersList[user.userID] = user;
                }
            }
        } else if (updateType == ZegoUpdateTypeDelete) {
            for (ZegoUser *user in userList) {
                [self.room1UsersList removeObjectForKey:user.userID];
            }
        }
        [self updateRoom1UserPopupViewInfo];
    } else if (roomID == self.roomID2TextField.text) {
        if (updateType == ZegoUpdateTypeAdd) {
            for (ZegoUser *user in userList) {
                if (![[self.room2UsersList allKeys] containsObject:user.userID]) {
                    self.room2UsersList[user.userID] = user;
                }
            }
        } else if (updateType == ZegoUpdateTypeDelete) {
            for (ZegoUser *user in userList) {
                [self.room2UsersList removeObjectForKey:user.userID];
            }
        }
        [self updateRoom2UserPopupViewInfo];
    }
}

/// Refresh the remote streams list
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType
                streamList:(NSArray<ZegoStream *> *)streamList
              extendedData:(nullable NSDictionary *)extendedData
                    roomID:(NSString *)roomID {
    
    ZGLogInfo(@"🚩 🌊 Room stream update, updateType:%lu, streamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);
    if (roomID == self.roomID1TextField.text) {
        if (updateType == ZegoUpdateTypeAdd) {
            for (ZegoStream *stream in streamList) {
                if (![[self.room1StreamsList allKeys] containsObject:stream.streamID]) {
                    self.room1StreamsList[stream.streamID] = stream;
                }
            }
        } else if (updateType == ZegoUpdateTypeDelete) {
            for (ZegoStream *stream in streamList) {
                [self.room1StreamsList removeObjectForKey:stream.streamID];
            }
        }
        [self updateRoom1StreamPopupViewInfo];
    } else if (roomID == self.roomID2TextField.text) {
        if (updateType == ZegoUpdateTypeAdd) {
            for (ZegoStream *stream in streamList) {
                if (![[self.room2StreamsList allKeys] containsObject:stream.streamID]) {
                    self.room2StreamsList[stream.streamID] = stream;
                }
            }
        } else if (updateType == ZegoUpdateTypeDelete) {
            for (ZegoStream *stream in streamList) {
                [self.room2StreamsList removeObjectForKey:stream.streamID];
            }
        }
        [self updateRoom2StreamPopupViewInfo];
    }
}

/// This method is called back every 30 seconds, can be used to show the current number of online user in the room
- (void)onRoomOnlineUserCountUpdate:(int)count roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 👥 Room online user count update, count: %d, roomID: %@", count, roomID);
}

- (void)onRoomStateUpdate:(ZegoRoomState)state
                errorCode:(int)errorCode
             extendedData:(nullable NSDictionary *)extendedData
                   roomID:(NSString *)roomID {
    if (roomID == self.roomID1TextField.text) {
        if (state != ZegoRoomStateDisconnected) {
            [self.roomID1TextField setEnabled:NO];
            if (state == ZegoRoomStateConnected) {
                self.room1UsersList[self.userIDTextField.text] = [ZegoUser userWithUserID:self.userIDTextField.text];
            }
        } else {
            [self.roomID1TextField setEnabled:YES];
            [self.room1UsersList removeObjectForKey:self.userIDTextField.text];
        }
        [self updateRoom1UserPopupViewInfo];
    } else if (roomID == self.roomID2TextField.text) {
        if (state != ZegoRoomStateDisconnected) {
            [self.roomID2TextField setEnabled:NO];
            if (state == ZegoRoomStateConnected) {
                self.room2UsersList[self.userIDTextField.text] = [ZegoUser userWithUserID:self.userIDTextField.text];
            }
        } else {
            [self.roomID2TextField setEnabled:YES];
            [self.room2UsersList removeObjectForKey:self.userIDTextField.text];
        }
        [self updateRoom2UserPopupViewInfo];
    }
}

- (void)onPublisherStateUpdate:(ZegoPublisherState)state
                     errorCode:(int)errorCode
                  extendedData:(nullable NSDictionary *)extendedData
                      streamID:(NSString *)streamID {
    if (self.publishRoomIDTextField.text == self.roomID1TextField.text) {
        if (state == ZegoPublisherStatePublishing) {
            ZegoStream *stream = [[ZegoStream alloc] init];
            stream.user = [ZegoUser userWithUserID:self.userIDTextField.text];
            stream.streamID = streamID;
            self.room1StreamsList[streamID] = stream;
        }
    } else if (self.publishRoomIDTextField.text == self.roomID2TextField.text) {
        if (state != ZegoRoomStateDisconnected) {
            ZegoStream *stream = [[ZegoStream alloc] init];
            stream.user = [ZegoUser userWithUserID:self.userIDTextField.text];
            stream.streamID = streamID;
            self.room2StreamsList[streamID] = stream;
        }
    }
                          
    if (state == ZegoPublisherStateNoPublish) {
        [self.room1StreamsList removeObjectForKey:streamID];
        [self.room2StreamsList removeObjectForKey:streamID];
    }
    [self updateRoom1StreamPopupViewInfo];
    [self updateRoom2StreamPopupViewInfo];
}

#pragma mark - PopupInfo
- (void)updateRoom1StreamPopupViewInfo {
    NSMutableArray *allStreamInfoList = [NSMutableArray array];
    for (NSString *streamID in self.room1StreamsList) {
        ZegoStream *stream = [self.room1StreamsList valueForKey:streamID];
        [allStreamInfoList addObject:[NSString stringWithFormat:@"StreamID:%@ UserID:%@ UserName:%@",streamID, stream.user.userID, stream.user.userName]];
    }
    [self.room1StreamsButton setTitle:[NSString stringWithFormat:@"Room1 Streams(%lu)", (unsigned long)self.room1StreamsList.count] forState:UIControlStateNormal];
    [self.room1StreamPopupView updateWithTitle:@"Room1 Stream List" textList:allStreamInfoList];
}

- (void)updateRoom2StreamPopupViewInfo {
    NSMutableArray *allStreamInfoList = [NSMutableArray array];
    for (NSString *streamID in self.room2StreamsList) {
        ZegoStream *stream = [self.room2StreamsList valueForKey:streamID];
        [allStreamInfoList addObject:[NSString stringWithFormat:@"StreamID:%@ UserID:%@ UserName:%@",streamID, stream.user.userID, stream.user.userName]];
    }
    [self.room2StreamsButton setTitle:[NSString stringWithFormat:@"Room2 Streams(%lu)", (unsigned long)self.room2StreamsList.count] forState:UIControlStateNormal];
    [self.room2StreamPopupView updateWithTitle:@"Room2 Stream List" textList:allStreamInfoList];
}

- (void)updateRoom1UserPopupViewInfo {
    NSMutableArray *allUserInfoList = [NSMutableArray array];
    for (NSString *userID in self.room1UsersList) {
        ZegoUser *user = [self.room1UsersList valueForKey:userID];
        [allUserInfoList addObject:[NSString stringWithFormat:@"UserID:%@ UserName:%@", user.userID, user.userName]];
    }
    [self.room1UsersButton setTitle:[NSString stringWithFormat:@"Room1 Users(%lu)", (unsigned long)self.room1UsersList.count] forState:UIControlStateNormal];

    [self.room1UserPopupView updateWithTitle:@"Room1 User List" textList:allUserInfoList];
}

- (void)updateRoom2UserPopupViewInfo {
    NSMutableArray *allUserInfoList = [NSMutableArray array];
    for (NSString *userID in self.room2UsersList) {
        ZegoUser *user = [self.room2UsersList valueForKey:userID];
        [allUserInfoList addObject:[NSString stringWithFormat:@"UserID:%@ UserName:%@", user.userID, user.userName]];
    }
    [self.room2UsersButton setTitle:[NSString stringWithFormat:@"Room2 Users(%lu)", (unsigned long)self.room2UsersList.count] forState:UIControlStateNormal];

    [self.room2UserPopupView updateWithTitle:@"Room2 User List" textList:allUserInfoList];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/// Append Log to Top View
- (void)appendLog:(NSString *)tipText {
    if (!tipText || tipText.length == 0) {
        return;
    }
    
    ZGLogInfo(@"%@", tipText);
    
    NSString *oldText = self.logTextView.text;
    NSString *newLine = oldText.length == 0 ? @"" : @"\n";
    NSString *newText = [NSString stringWithFormat:@"%@%@ %@", oldText, newLine, tipText];
    
    self.logTextView.text = newText;
    if(newText.length > 0 ) {
        UITextView *textView = self.logTextView;
        NSRange bottom = NSMakeRange(newText.length -1, 1);
        [textView scrollRangeToVisible:bottom];
        // an iOS bug, see https://stackoverflow.com/a/20989956/971070
        [textView setScrollEnabled:NO];
        [textView setScrollEnabled:YES];
    }
}

#pragma mark - Exit

- (void)dealloc {
    ZGLogInfo(@"🚪 Exit the room");
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:^{
        [ZegoExpressEngine setRoomMode:ZegoRoomModeSingleRoom];
    }];
}


@end

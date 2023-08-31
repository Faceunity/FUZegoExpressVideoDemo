//
//  ZGVideoForMultipleUsersViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/30.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGVideoForMultipleUsersViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import "ZGVideoTalkViewObject.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "ZGVideoForMultipleUsersPublisherView.h"
#import "ZGVideoForMultipleUsersUserView.h"
#import "ZGVideoForMultipleUsersPopupView.h"

// The number of displays per row of the stream view
NSInteger const ZGVideoTalkStreamViewColumnPerRow = 2;
CGFloat const ZGVideoTalkStreamViewHeight = 300;
// Stream view spacing
CGFloat const ZGVideoTalkStreamViewSpacing = 8.f;


@interface ZGVideoForMultipleUsersViewController () <ZegoEventHandler>

/// User canvas object of participating video call users
@property (nonatomic, strong) NSMutableArray<ZGVideoTalkViewObject *> *allUserViewObjectList;

/// Local user view object
@property (nonatomic, strong) ZGVideoTalkViewObject *localUserViewObject;

@property (nonatomic, strong) NSMutableArray<ZegoStream *> *allStreamList;

/// Local stream ID
@property (nonatomic, copy) NSString *localStreamID;

@property (nonatomic, assign) ZegoRoomState roomState;
@property (nonatomic, assign) ZegoPublisherState publishState;

/// Label
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLabel;


/// Container
@property (nonatomic, weak) IBOutlet UIScrollView *containerView;

@property (nonatomic, strong) ZGVideoForMultipleUsersPopupView *streamPopupView;
@property (nonatomic, strong) ZGVideoForMultipleUsersPopupView *userPopupView;
@property (weak, nonatomic) IBOutlet UIButton *streamListButton;
@property (weak, nonatomic) IBOutlet UIButton *userListButton;


@end

@implementation ZGVideoForMultipleUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.localStreamID = @((NSInteger)(arc4random() * 100000)).stringValue;
    
    self.allUserViewObjectList = [NSMutableArray<ZGVideoTalkViewObject *> array];
    
    self.allStreamList = [NSMutableArray<ZegoStream *> array];
    
    [self setupUI];
    
    [self createEngine];
    
    [self loginRoom];
}


- (void)setupUI {
   
    self.title = @"VideoForMultipleUsers";
    
    self.userInfoLabel.text = [NSString stringWithFormat:@"UserID:%@  UserName:%@", self.localUserID, self.localUserName];
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@ StreamID:%@", _roomID, self.localStreamID];
    self.roomStateLabel.text = @"Not Connected 🔴";
    
    // Add local user video view object
    [self.allUserViewObjectList addObject:self.localUserViewObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self rearrangeVideoTalkViewObjects];
    });
}

#pragma mark - Actions

- (void)createEngine {
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
    
    //Set Video Config Before StartPreview And StartPublishing
    ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] init];
    videoConfig.captureResolution = self.captureResolution;
    videoConfig.encodeResolution = self.encodeResolution;
    
    if(self.videoFps < 0)
        videoConfig.fps = 15;
    else
        videoConfig.fps = self.videoFps;
    
    if(self.videoBitrate < 0)
        videoConfig.bitrate = 600;
    else
        videoConfig.bitrate = self.videoBitrate;
    
    
    
    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
}

- (void)loginRoom {
    // Login room
    ZGLogInfo(@"🚪 Login room, roomID: %@", _roomID);
    ZegoRoomConfig *roomConfig = [ZegoRoomConfig defaultConfig];
    roomConfig.isUserStatusNotify = YES;
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:self.localUserID userName:self.localUserName] config:roomConfig];
}

- (IBAction)onStreamListButtonTapped:(id)sender {
    
    self.streamPopupView = [ZGVideoForMultipleUsersPopupView show];
    [self updateStreamPopupViewInfo];
}

- (IBAction)onUserListButtonTapped:(id)sender {
    self.userPopupView = [ZGVideoForMultipleUsersPopupView show];
    [self updateUserPopupViewInfo];
}

// It is recommended to logout room when stopping the video call.
// And you can destroy the engine when there is no need to call.
- (void)exitRoom {
    ZGLogInfo(@"🚪 Logout room, roomID: %@", _roomID);
    [[ZegoExpressEngine sharedEngine] logoutRoom:_roomID];
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

/// Exit room when VC dealloc
- (void)dealloc {
    [self exitRoom];
}

#pragma mark - ViewObject Methods

/// Rearrange participant flow view
- (void)rearrangeVideoTalkViewObjects {
    for (ZGVideoTalkViewObject *obj in _allUserViewObjectList) {
        if (obj.view != nil) {
            [obj.view removeFromSuperview];
        }
    }
    
    NSInteger columnPerRow = ZGVideoTalkStreamViewColumnPerRow;
    CGFloat viewSpacing = ZGVideoTalkStreamViewSpacing;
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat playViewWidth = (screenWidth - (columnPerRow + 1)*viewSpacing) /columnPerRow;
    CGFloat playViewHeight = self.containerView.bounds.size.height / 2 - viewSpacing * 2;
    
    NSInteger i = 0;
    for (ZGVideoTalkViewObject *obj in _allUserViewObjectList) {
        if (obj.view == nil) {
            continue;
        }
        
        NSInteger cloumn = i % columnPerRow;
        NSInteger row = i / columnPerRow;
        
        CGFloat x = viewSpacing + cloumn * (playViewWidth + viewSpacing);
        CGFloat y = viewSpacing + row * (playViewHeight + viewSpacing);
        obj.view.frame = CGRectMake(x, y, playViewWidth, playViewHeight);
        
        [self.containerView addSubview:obj.view];
        i++;
    }
    NSInteger rowCount = (_allUserViewObjectList.count - 1) / columnPerRow + 1;
    CGFloat contentHeight = MAX((playViewHeight + viewSpacing) * rowCount, self.containerView.bounds.size.height);
    CGFloat contentWidth = self.view.frame.size.width;
    self.containerView.contentSize = CGSizeMake(contentWidth, contentHeight);
    
}

- (ZGVideoTalkViewObject *)getViewObjectWithUserID:(NSString *)userID {
    __block ZGVideoTalkViewObject *existObj = nil;
    [self.allUserViewObjectList enumerateObjectsUsingBlock:^(ZGVideoTalkViewObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userID isEqualToString:userID]) {
            existObj = obj;
            *stop = YES;
        }
    }];
    return existObj;
}

/// Add a view of user who has entered the room and play the user stream
- (void)addRemoteViewObjectIfNeedWithUserID:(NSString *)userID {
    ZGVideoTalkViewObject *viewObject = [self getViewObjectWithUserID:userID];
    if (!viewObject) {
        viewObject = [ZGVideoTalkViewObject new];
        viewObject.isLocal = NO;
        viewObject.userID = userID;
        viewObject.userName = userID;
        ZGVideoForMultipleUsersUserView *itemView = [ZGVideoForMultipleUsersUserView itemViewWithViewModel:viewObject owner:self];
        viewObject.view = itemView;
        
        for (ZegoStream *stream in self.allStreamList) {
            if ([stream.user.userID isEqualToString:userID]) {
                viewObject.streamID = stream.streamID;
            }
        }
        [self.allUserViewObjectList addObject:viewObject];
    }
}

/// Remove view of user who has left the room and stop playing stream
- (void)removeViewObjectWithUserID:(NSString *)userID {
    ZGVideoTalkViewObject *obj = [self getViewObjectWithUserID:userID];
    if (obj) {
        [self.allUserViewObjectList removeObject:obj];
        [obj.view removeFromSuperview];
        if (!(obj.streamID == nil || [obj.streamID isEqualToString:@""])) {
            [[ZegoExpressEngine sharedEngine] stopPlayingStream:obj.streamID];
        }
    }
}

#pragma mark - PopupInfo
- (void)updateStreamPopupViewInfo {
    NSMutableArray *allStreamInfoList = [NSMutableArray array];
    for (ZegoStream *stream in self.allStreamList) {
        [allStreamInfoList addObject:[NSString stringWithFormat:@"StreamID:%@ UserName:%@ UserID:%@",stream.streamID, stream.user.userName, stream.user.userID]];
    }
    if (self.publishState == ZegoPublisherStatePublishing) {
        [allStreamInfoList addObject:[NSString stringWithFormat:@"StreamID:%@ UserName:%@ UserID:%@", self.localStreamID, self.localUserName, self.localUserID]];
    }
    [self.streamListButton setTitle:[NSString stringWithFormat:@"StreamList(%lu)", (unsigned long)self.allStreamList.count + (unsigned long)(self.publishState == ZegoPublisherStatePublishing ? 1 : 0)] forState:UIControlStateNormal];
    [self.streamPopupView updateWithTitle:@"Stream List" textList:allStreamInfoList];
}

- (void)updateUserPopupViewInfo {
    NSMutableArray *allUserInfoList = [NSMutableArray array];
    for (ZGVideoTalkViewObject *viewObject in self.allUserViewObjectList) {
//        if (!viewObject.isLocal) {
        [allUserInfoList addObject:[NSString stringWithFormat:@"UserName:%@ UserID:%@", viewObject.userName, viewObject.userID]];
//        }
    }
    [self.userListButton setTitle:[NSString stringWithFormat:@"UserList(%lu)", (unsigned long)self.allUserViewObjectList.count] forState:UIControlStateNormal];

    [self.userPopupView updateWithTitle:@"User List" textList:allUserInfoList];
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
    [self updateUserPopupViewInfo];
}

/// Refresh the remote user list

- (void)onRoomUserUpdate:(ZegoUpdateType)updateType userList:(NSArray<ZegoUser *> *)userList roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🌊 Room user update, updateType:%lu, userCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)userList.count, roomID);

    NSArray<NSString *> *allUserIDList = [_allUserViewObjectList valueForKeyPath:@"userID"];
    
    if (updateType == ZegoUpdateTypeAdd) {
        for (ZegoUser *user in userList) {
            if (![allUserIDList containsObject:user.userID]) {
                [self addRemoteViewObjectIfNeedWithUserID:user.userID];
            }
        }
    } else if (updateType == ZegoUpdateTypeDelete) {
        for (ZegoUser *user in userList) {
            [self removeViewObjectWithUserID:user.userID];
        }
    }
    
    [self updateUserPopupViewInfo];
    [self rearrangeVideoTalkViewObjects];
}

/// Refresh the remote streams list
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    
    ZGLogInfo(@"🚩 🌊 Room stream update, updateType:%lu, streamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);
    for (ZGVideoTalkViewObject *viewObject in self.allUserViewObjectList) {
        for (ZegoStream *stream in streamList) {
            if ([viewObject.userID isEqualToString:stream.user.userID]) {
                if (updateType == ZegoUpdateTypeAdd) {
                    viewObject.streamID = stream.streamID;
                } else if (updateType == ZegoUpdateTypeDelete) {
                    [[ZegoExpressEngine sharedEngine] stopPlayingStream:stream.streamID];
                    viewObject.streamID = @"";
                }
            }
        }
    }
    if (updateType == ZegoUpdateTypeAdd) {
        [self.allStreamList addObjectsFromArray:streamList];
    } else if (updateType == ZegoUpdateTypeDelete) {
        for (ZegoStream *deleteStream in streamList) {
            for (ZegoStream *stream in self.allStreamList) {
                if ([stream.streamID isEqualToString:deleteStream.streamID]) {
                    [self.allStreamList removeObject:stream];
                    break;
                }
            }
        }
    }
    [self updateStreamPopupViewInfo];
    [self rearrangeVideoTalkViewObjects];
}

/// This method is called back every 30 seconds, can be used to show the current number of online user in the room
- (void)onRoomOnlineUserCountUpdate:(int)count roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 👥 Room online user count update, count: %d, roomID: %@", count, roomID);
}

- (void)onNetworkQuality:(NSString *)userID upstreamQuality:(ZegoStreamQualityLevel)upstreamQuality downstreamQuality:(ZegoStreamQualityLevel)downstreamQuality {
    NSString *networkQuality = @"";
    switch (upstreamQuality) {
        case ZegoStreamQualityLevelExcellent:
            networkQuality = @"☀️";
            break;
        case ZegoStreamQualityLevelGood:
            networkQuality = @"⛅️";
            break;
        case ZegoStreamQualityLevelMedium:
            networkQuality = @"☁️";
            break;
        case ZegoStreamQualityLevelBad:
            networkQuality = @"🌧";
            break;
        case ZegoStreamQualityLevelDie:
            networkQuality = @"❌";
            break;
        case ZegoStreamQualityLevelUnknown:
            networkQuality = @"❓";
            break;
    }
    NSString *text = [NSString stringWithFormat:@"NetworkQuality: %@", networkQuality];
    if ([userID length] == 0) {
        userID = self.localUserID; // Empty means local user
    }
    for (ZGVideoTalkViewObject *viewObject in self.allUserViewObjectList) {
        if ([viewObject.userID isEqualToString:userID]) {
            ZGVideoForMultipleUsersUserView *view = (ZGVideoForMultipleUsersUserView *)viewObject.view;
            [view updateNetworkQuility:text];
            break;
        }
    }
}

- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality streamID:(NSString *)streamID {
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"VideoBitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"VideoRecvFPS: %.1f fps \n", quality.videoRecvFPS];
    [text appendFormat:@"RTT: %d ms \n", quality.rtt];
    [text appendFormat:@"Delay: %d ms \n", quality.delay];
    [text appendFormat:@"PackageLostRate: %.1f%% \n", quality.packetLostRate * 100.0];
    for (ZGVideoTalkViewObject *viewObject in self.allUserViewObjectList) {
        if ([viewObject.streamID isEqualToString:streamID]) {
            ZGVideoForMultipleUsersUserView *view = (ZGVideoForMultipleUsersUserView *)viewObject.view;
            [view updateStreamQuility:text];
            break;
        }
    }
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"VideoBitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"VideoSendFPS: %.1f fps \n", quality.videoSendFPS];
    [text appendFormat:@"RTT: %d ms \n", quality.rtt];
    [text appendFormat:@"PackageLostRate: %.1f%% \n", quality.packetLostRate * 100.0];
    for (ZGVideoTalkViewObject *viewObject in self.allUserViewObjectList) {
        if (viewObject.isLocal) {
            ZGVideoForMultipleUsersPublisherView *view = (ZGVideoForMultipleUsersPublisherView *)viewObject.view;
            [view updateStreamQuility:text];
            break;
        }
    }
}

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    self.publishState = state;
    [self updateStreamPopupViewInfo];
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    NSString *text = [NSString stringWithFormat:@"%dx%d",(int)size.width,(int)size.height];
    for (ZGVideoTalkViewObject *viewObject in self.allUserViewObjectList) {
        if (viewObject.isLocal) {
            ZGVideoForMultipleUsersPublisherView *view = (ZGVideoForMultipleUsersPublisherView *)viewObject.view;
            [view updateResolution:text];
            break;
        }
    }
}

- (void)onPlayerVideoSizeChanged:(CGSize)size streamID:(NSString *)streamID {
    NSString *text = [NSString stringWithFormat:@"%dx%d",(int)size.width,(int)size.height];
    for (ZGVideoTalkViewObject *viewObject in self.allUserViewObjectList) {
        if ([viewObject.streamID isEqualToString:streamID]) {
            ZGVideoForMultipleUsersUserView *view = (ZGVideoForMultipleUsersUserView *)viewObject.view;
            [view updateResolution:text];
            break;
        }
    }
}

#pragma mark - Getter

- (ZGVideoTalkViewObject *)localUserViewObject {
    if (!_localUserViewObject) {
        _localUserViewObject = [ZGVideoTalkViewObject new];
        _localUserViewObject.isLocal = YES;
        _localUserViewObject.streamID = _localStreamID;
        _localUserViewObject.userID = _localUserID;
        _localUserViewObject.userName = _localUserName;
        _localUserViewObject.view = [ZGVideoForMultipleUsersPublisherView itemViewWithViewModel:_localUserViewObject owner:self];
    }
    return _localUserViewObject;
}

@end

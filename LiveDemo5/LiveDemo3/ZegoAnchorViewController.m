//
//  ZegoAnchorViewController.m
//  LiveDemo3
//
//  Created by Strong on 16/6/22.
//  Copyright © 2016年 ZEGO. All rights reserved.
//

#import "ZegoAnchorViewController.h"
#import "ZegoAVKitManager.h"
#import "ZegoSettings.h"
#import "ZegoAnchorOptionViewController.h"
#import "ZegoLiveToolViewController.h"

#import <FUAPIDemoBar/FUAPIDemoBar.h>
#import "FUFaceUnityManager.h"

@interface ZegoAnchorViewController () <ZegoRoomDelegate, ZegoLivePublisherDelegate, ZegoIMDelegate, ZegoLiveToolViewControllerDelegate, FUAPIDemoBarDelegate>

@property (weak, nonatomic) IBOutlet UIView *playViewContainer;
@property (weak, nonatomic) IBOutlet UIView *toolView;

@property (nonatomic, weak) ZegoLiveToolViewController *toolViewController;

@property (nonatomic, weak) UIButton *stopPublishButton;
@property (nonatomic, weak) UIButton *mutedButton;
@property (nonatomic, weak) UIButton *sharedButton;

@property (nonatomic, copy) NSString *streamID;

@property (nonatomic, strong) NSMutableDictionary *viewContainersDict;

@property (nonatomic, assign) BOOL isPublishing;

@property (nonatomic, strong) UIColor *defaultButtonColor;
@property (nonatomic, strong) UIColor *disableButtonColor;

@property (nonatomic, copy) NSString *sharedHls;
@property (nonatomic, copy) NSString *sharedRtmp;
@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, assign) UIInterfaceOrientation orientation;


@property (nonatomic, strong)UIButton *demoBtn ;
@property (nonatomic, strong)FUAPIDemoBar *demoBar ;
@end

@implementation ZegoAnchorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupLiveKit];
    [self loginChatRoom];
    
    _viewContainersDict = [[NSMutableDictionary alloc] initWithCapacity:self.maxStreamCount];
    
    for (UIViewController *viewController in self.childViewControllers)
    {
        if ([viewController isKindOfClass:[ZegoLiveToolViewController class]])
        {
            self.toolViewController = (ZegoLiveToolViewController *)viewController;
            self.toolViewController.delegate = self;
            break;
        }
    }
    
    self.stopPublishButton = self.toolViewController.stopPublishButton;
    self.mutedButton = self.toolViewController.mutedButton;
    self.sharedButton = self.toolViewController.shareButton;
    
    self.stopPublishButton.enabled = NO;
    self.sharedButton.enabled = NO;
    
    self.mutedButton.enabled = NO;
    self.defaultButtonColor = [self.mutedButton titleColorForState:UIControlStateNormal];
    self.disableButtonColor = [self.mutedButton titleColorForState:UIControlStateDisabled];
    
    self.orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (self.publishView)
    {
        [self updatePublishView:self.publishView];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isShowFaceUnity) {
        [self.view addSubview:self.demoBtn];
        [self.view addSubview:self.demoBar];
        //        [self loadItem:@"tiara"];
        
        [FUFaceUnityManager shareManager].selectedFilter = self.demoBar.filtersDataSource[0] ;
        [FUFaceUnityManager shareManager].selectedBlur = self.demoBar.selectedBlur;
        [FUFaceUnityManager shareManager].redLevel = self.demoBar.redLevel ;
        [FUFaceUnityManager shareManager].faceShapeLevel = self.demoBar.faceShapeLevel ;
        [FUFaceUnityManager shareManager].faceShape = self.demoBar.faceShape ;
        [FUFaceUnityManager shareManager].beautyLevel = self.demoBar.beautyLevel ;
        [FUFaceUnityManager shareManager].thinningLevel = self.demoBar.thinningLevel ;
        [FUFaceUnityManager shareManager].enlargingLevel = self.demoBar.enlargingLevel ;
        
        [[FUFaceUnityManager shareManager] loadItem:self.demoBar.itemsDataSource[1]];
        [[FUFaceUnityManager shareManager] loadFilter];
        
        [FUFaceUnityManager shareManager].isShown = YES ;
    }
}

-(UIButton *)demoBtn {
    if (!_demoBtn) {
        _demoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _demoBtn.frame  = CGRectMake(self.view.frame.size.width - 130 - 16, 100, 130, 55);
//        [_demoBtn setImage:[UIImage imageNamed:@"camera_btn_filter_normal"] forState:UIControlStateNormal];
        [_demoBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_demoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_demoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [_demoBtn setTitle:@"隐藏 FaceUnity" forState:UIControlStateNormal];
        [_demoBtn setTitle:@"显示 FaceUnity" forState:UIControlStateSelected];
        [_demoBtn addTarget:self action:@selector(showDemoBar) forControlEvents:UIControlEventTouchUpInside];
    }
    return _demoBtn ;
}

-(FUAPIDemoBar *)demoBar{
    if (!_demoBar) {
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 208, self.view.frame.size.width, 208)];
        
        _demoBar.itemsDataSource = @[@"noitem", @"yuguan", @"lixiaolong", @"mask_matianyu",   @"yazui", @"EatRabbi", @"Mood" ];
        
        
        _demoBar.selectedItem = _demoBar.itemsDataSource[1];
        _demoBar.filtersDataSource = @[@"nature", @"delta", @"electric", @"slowlived", @"tokyo", @"warm"];
        _demoBar.selectedFilter = _demoBar.filtersDataSource[1];
        _demoBar.selectedBlur = 6;
        _demoBar.beautyLevel = 0.2;
        _demoBar.thinningLevel = 1.0;
        _demoBar.enlargingLevel = 0.5;
        _demoBar.faceShapeLevel = 0.5;
        _demoBar.faceShape = 3;
        _demoBar.redLevel = 0.5;
        
        _demoBar.delegate = self;
    }
    return _demoBar ;
}

- (void)showDemoBar {
    if (self.demoBtn.selected) {
        [UIView animateWithDuration:0.35 animations:^{
            self.demoBar.frame = CGRectMake(0, self.view.frame.size.height - 208, self.view.frame.size.width, 208);
        }];
    }else {
        [UIView animateWithDuration:0.35 animations:^{
            self.demoBar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 208);
        }];
    }
    self.demoBtn.selected = !self.demoBtn.selected ;
}

- (void)demoBarDidSelectedItem:(NSString *)item {
    NSLog(@"------------- %@ ~",item);
    [[FUFaceUnityManager shareManager] loadItem:item];
}

- (void)demoBarDidSelectedFilter:(NSString *)filter {
    
    [FUFaceUnityManager shareManager].selectedFilter = filter ;
}

- (void)demoBarBeautyParamChanged {
    
    [FUFaceUnityManager shareManager].selectedBlur = self.demoBar.selectedBlur;
    [FUFaceUnityManager shareManager].redLevel = self.demoBar.redLevel ;
    [FUFaceUnityManager shareManager].faceShapeLevel = self.demoBar.faceShapeLevel ;
    [FUFaceUnityManager shareManager].faceShape = self.demoBar.faceShape ;
    [FUFaceUnityManager shareManager].beautyLevel = self.demoBar.beautyLevel ;
    [FUFaceUnityManager shareManager].thinningLevel = self.demoBar.thinningLevel ;
    [FUFaceUnityManager shareManager].enlargingLevel = self.demoBar.enlargingLevel ;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.orientation == UIInterfaceOrientationPortrait)
        return UIInterfaceOrientationMaskPortrait;
    else if (self.orientation == UIInterfaceOrientationLandscapeLeft)
        return UIInterfaceOrientationMaskLandscapeLeft;
    else if (self.orientation == UIInterfaceOrientationLandscapeRight)
        return UIInterfaceOrientationMaskLandscapeRight;
    
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - ZegoLiveRoom

- (void)setupLiveKit
{
    [[ZegoDemoHelper api] setRoomDelegate:self];
    [[ZegoDemoHelper api] setPublisherDelegate:self];
    [[ZegoDemoHelper api] setIMDelegate:self];
}

- (bool)doPublish
{
    //登录成功后配置直播参数，开始直播 创建publishView
    if (self.publishView.superview == nil)
        self.publishView = nil;
    
    if (self.publishView == nil)
    {
        self.publishView = [self createPublishView];
        if (self.publishView)
        {
            [self setAnchorConfig:self.publishView];
            [[ZegoDemoHelper api] startPreview];
        }
    }
    
    self.viewContainersDict[self.streamID] = self.publishView;
    
    bool b = [[ZegoDemoHelper api] startPublishing:self.streamID title:self.liveTitle flag:ZEGOAPI_SINGLE_ANCHOR];
    if (b)
    {
        [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"开始直播，流ID:%@", nil), self.streamID]];
    }
    return b;
}

- (void)stopPublishing
{
    [[ZegoDemoHelper api] stopPreview];
    [[ZegoDemoHelper api] setPreviewView:nil];
    [[ZegoDemoHelper api] stopPublishing];

    [self removeStreamViewContainer:self.streamID];
    self.publishView = nil;
    
    self.isPublishing = NO;
}

- (void)loginChatRoom
{
    self.roomID = [ZegoDemoHelper getMyRoomID:SinglePublisherRoom];
    self.streamID = [ZegoDemoHelper getPublishStreamID];

    [[ZegoDemoHelper api] loginRoom:self.roomID roomName:self.liveTitle role:ZEGO_ANCHOR  withCompletionBlock:^(int errorCode, NSArray<ZegoStream *> *streamList) {
        
        NSLog(@"%s, error: %d", __func__, errorCode);
        if (errorCode == 0)
        {
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"登录房间成功. roomId %@", nil), self.roomID];
            [self addLogString:logString];
            [self doPublish];
        }
        else
        {
            NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"登录房间失败. error: %d", nil), errorCode];
            [self addLogString:logString];
        }
         
     }];
    
    [self addLogString:[NSString stringWithFormat:NSLocalizedString(@"开始登录房间", nil)]];
}

#pragma mark - ZegoRoomDelegate

- (void)onDisconnect:(int)errorCode roomID:(NSString *)roomID
{
    NSString *logString = [NSString stringWithFormat:NSLocalizedString(@"连接失败, error: %d", nil), errorCode];
    [self addLogString:logString];
}

- (void)onKickOut:(int)reason roomID:(NSString *)roomID
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"被踢出房间", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    
    [self onCloseButton:nil];
}

#pragma mark - ZegoLivePublisherDelegate

- (void)onPublishStateUpdate:(int)stateCode streamID:(NSString *)streamID streamInfo:(NSDictionary *)info
{
    NSLog(@"%s, stream: %@, state: %d", __func__, streamID, stateCode);
    
    NSString *logString = nil;
    
    if (stateCode == 0)
    {
        self.isPublishing = YES;
        
        [self.stopPublishButton setTitle:NSLocalizedString(@"停止直播", nil) forState:UIControlStateNormal];
        
        self.sharedHls = [info[kZegoHlsUrlListKey] firstObject];
        self.sharedRtmp = [info[kZegoRtmpUrlListKey] firstObject];
        
        [self addLogString:[NSString stringWithFormat:@"Hls %@", self.sharedHls]];
        [self addLogString:[NSString stringWithFormat:@"Rtmp %@", self.sharedRtmp]];
        
        logString = [NSString stringWithFormat:NSLocalizedString(@"发布直播成功,流ID:%@", nil), streamID];
        
        if (self.sharedHls.length > 0 && self.sharedRtmp.length > 0)
        {
            self.sharedButton.enabled = YES;
            
            NSDictionary *dict = @{kHlsKey: self.sharedHls, kRtmpKey: self.sharedRtmp};
            NSString *jsonString = [self encodeDictionaryToJSON:dict];
            if (jsonString)
                [[ZegoDemoHelper api] updateStreamExtraInfo:jsonString];
        }
        else
        {
            self.sharedButton.enabled = NO;
        }
    }
    else
    {
        self.isPublishing = NO;
        [self removeStreamViewContainer:streamID];
        self.publishView = nil;
        self.sharedButton.enabled = NO;
        
        [self.stopPublishButton setTitle:NSLocalizedString(@"开始直播", nil) forState:UIControlStateNormal];
        
        logString = [NSString stringWithFormat:NSLocalizedString(@"直播结束,流ID：%@, error:%d", nil), streamID, stateCode];
    }
    
    [self addLogString:logString];
    
    self.stopPublishButton.enabled = YES;
}

- (void)onPublishQualityUpdate:(NSString *)streamID quality:(ZegoApiPublishQuality)quality
{
    UIView *view = self.viewContainersDict[streamID];
    if (view)
        [self updateQuality:quality.quality view:view];
    
    [self addStaticsInfo:YES stream:streamID fps:quality.fps kbs:quality.kbps];
}

- (void)onAuxCallback:(void *)pData dataLen:(int *)pDataLen sampleRate:(int *)pSampleRate channelCount:(int *)pChannelCount
{
    [self auxCallback:pData dataLen:pDataLen sampleRate:pSampleRate channelCount:pChannelCount];
}

#pragma mark - ZegoIMDelegate
- (void)onRecvRoomMessage:(NSString *)roomId messageList:(NSArray<ZegoRoomMessage *> *)messageList
{
    [self.toolViewController updateLayout:messageList];
}

#pragma mark -

#pragma mark close publish

- (void)closeAllStream
{
    [self stopPublishing];
}

#pragma mark ZegoLiveToolViewControllerDelegate
- (void)onCloseButton:(id)sender
{
    // FaceUnity
    [FUFaceUnityManager shareManager].isShown = NO ;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[FUFaceUnityManager shareManager] removeAllEffect];
    });
    
    
    [self closeAllStream];
    [[ZegoDemoHelper api] logoutRoom];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onMutedButton:(id)sender
{
    if (self.enableSpeaker)
    {
        self.enableSpeaker = NO;
        [self.mutedButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    else
    {
        self.enableSpeaker = YES;
        [self.mutedButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    }
}

- (void)onOptionButton:(id)sender
{
    [self showPublishOption];
}

- (void)onStopPublishButton:(id)sender
{
    if (self.isPublishing)
    {
        [self stopPublishing];
        
        // * update button
        [self.stopPublishButton setTitle:NSLocalizedString(@"开始直播", nil) forState:UIControlStateNormal];
        self.stopPublishButton.enabled = YES;
    }
    else if ([[self.stopPublishButton currentTitle] isEqualToString:NSLocalizedString(@"开始直播", nil)])
    {
        [self doPublish];
        
        self.stopPublishButton.enabled = NO;
    }
}

- (void)onLogButton:(id)sender
{
    [self showLogViewController];
}

- (void)onShareButton:(id)sender
{
    if (self.sharedHls.length == 0)
        return;
    
    [self shareToQQ:self.sharedHls rtmp:self.sharedRtmp bizToken:nil bizID:self.roomID streamID:self.streamID];
}

- (void)onSendComment:(NSString *)comment
{
    bool ret = [[ZegoDemoHelper api] sendRoomMessage:comment type:ZEGO_TEXT category:ZEGO_CHAT priority:ZEGO_DEFAULT completion:nil];
    if (ret)
    {
        ZegoRoomMessage *roomMessage = [ZegoRoomMessage new];
        roomMessage.fromUserId = [ZegoSettings sharedInstance].userID;
        roomMessage.fromUserName = [ZegoSettings sharedInstance].userName;
        roomMessage.content = comment;
        roomMessage.type = ZEGO_TEXT;
        roomMessage.category = ZEGO_CHAT;
        roomMessage.priority = ZEGO_DEFAULT;
        
        [self.toolViewController updateLayout:@[roomMessage]];
    }
}

- (void)onSendLike
{
//    [[ZegoDemoHelper api] likeAnchor:1 count:10];
    NSDictionary *likeDict = @{@"likeType": @(1), @"likeCount": @(10)};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:likeDict options:0 error:nil];
    NSString *content = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    bool ret = [[ZegoDemoHelper api] sendRoomMessage:content type:ZEGO_TEXT category:ZEGO_LIKE priority:ZEGO_DEFAULT completion:nil];
    if (ret)
    {
        ZegoRoomMessage *roomMessage = [ZegoRoomMessage new];
        roomMessage.fromUserId = [ZegoSettings sharedInstance].userID;
        roomMessage.fromUserName = [ZegoSettings sharedInstance].userName;
        roomMessage.content = @"点赞了主播";
        roomMessage.type = ZEGO_TEXT;
        roomMessage.category = ZEGO_CHAT;
        roomMessage.priority = ZEGO_DEFAULT;
        
        [self.toolViewController updateLayout:@[roomMessage]];
    }
}

#pragma mark PublishView create

- (BOOL)updatePublishView:(UIView *)publishView
{
    publishView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.playViewContainer addSubview:publishView];
    
    BOOL bResult = [self setContainerConstraints:publishView containerView:self.playViewContainer viewCount:self.playViewContainer.subviews.count - 1];
    if (bResult == NO)
    {
        [publishView removeFromSuperview];
        return NO;
    }
    
    [self.playViewContainer bringSubviewToFront:publishView];
    return YES;
}

- (UIView *)createPublishView
{
    UIView *publishView = [[UIView alloc] init];
    publishView.translatesAutoresizingMaskIntoConstraints = NO;
    
    BOOL result = [self updatePublishView:publishView];
    if (result == NO)
        return nil;
    
    return publishView;
}

- (void)removeStreamViewContainer:(NSString *)streamID
{
    UIView *view = self.viewContainersDict[streamID];
    if (view == nil)
        return;
    
    [self updateContainerConstraintsForRemove:view containerView:self.playViewContainer];
    
    [self.viewContainersDict removeObjectForKey:streamID];
}

@end

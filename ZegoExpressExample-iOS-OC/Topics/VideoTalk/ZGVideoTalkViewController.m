//
//  ZGVideoTalkViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/30.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_VideoTalk

#import "ZGVideoTalkViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"
#import "ZGVideoTalkViewObject.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

#import "ZGCaptureDeviceCamera.h"

/**faceU */
#import "FUManager.h"
#import "FUAPIDemoBar.h"
#import "FUTestRecorder.h"
/**faceU */

// The number of displays per row of the stream view
NSInteger const ZGVideoTalkStreamViewColumnPerRow = 3;
// Stream view spacing
CGFloat const ZGVideoTalkStreamViewSpacing = 8.f;


@interface ZGVideoTalkViewController () <ZegoEventHandler,ZegoCustomVideoCaptureHandler,  ZGCaptureDeviceDataOutputPixelBufferDelegate,FUAPIDemoBarDelegate>

/// Login room ID
@property (nonatomic, copy) NSString *roomID;

/// User canvas object of participating video call users
@property (nonatomic, strong) NSMutableArray<ZGVideoTalkViewObject *> *allUserViewObjectList;

/// Local user view object
@property (nonatomic, strong) ZGVideoTalkViewObject *localUserViewObject;

/// Local user ID
@property (nonatomic, copy) NSString *localUserID;

/// Local stream ID
@property (nonatomic, copy) NSString *localStreamID;

/// Label
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;

/// Container
@property (nonatomic, weak) IBOutlet UIView *containerView;

/// Whether to enable the camera
@property (nonatomic, assign) BOOL enableCamera;
@property (weak, nonatomic) IBOutlet UISwitch *cameraSwitch;

/// Whether to mute the microphone
@property (nonatomic, assign) BOOL muteMicrophone;
@property (weak, nonatomic) IBOutlet UISwitch *microphoneSwitch;

/// Whether to enable audio output
@property (nonatomic, assign) BOOL muteSpeaker;
@property (weak, nonatomic) IBOutlet UISwitch *speakerSwitch;

@property (nonatomic, strong) id<ZGCaptureDevice> captureDevice;
@property(nonatomic, strong) FUAPIDemoBar *demoBar;


@end

@implementation ZGVideoTalkViewController


- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    self.demoBar.frame = CGRectMake(0, self.view.frame.size.height - 164 - 231, self.view.frame.size.width, 195);
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
        [[FUTestRecorder shareRecorder] setupRecord];
    
    self.roomID = @"ly123";
    
    // Use user ID as stream ID
    self.localUserID = ZGUserIDHelper.userID;
    self.localStreamID = [NSString stringWithFormat:@"s-%@", _localUserID];
    
    self.allUserViewObjectList = [NSMutableArray<ZGVideoTalkViewObject *> array];
    
    self.enableCamera = YES;
    self.muteMicrophone = [[ZegoExpressEngine sharedEngine] isMicrophoneMuted];
    self.muteSpeaker = [[ZegoExpressEngine sharedEngine] isSpeakerMuted];
    
    [self setupUI];
    
    [[FUManager shareManager] loadFilter];
    [FUManager shareManager].isRender = YES;
    [FUManager shareManager].flipx = YES;
    [FUManager shareManager].trackFlipx = YES;
    [self.view addSubview:self.demoBar];
    
    [self createEngine];
    [self joinTalkRoom];
}


#pragma mark --------------FaceUnity

-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 164 - 195, self.view.frame.size.width, 195)];
        
        _demoBar.mDelegate = self;
    }
    return _demoBar ;
}

/// 销毁道具
- (void)destoryFaceunityItems
{

    [[FUManager shareManager] destoryItems];
    
}

#pragma -FUAPIDemoBarDelegate
-(void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
}

-(void)switchRenderState:(BOOL)state{
    [FUManager shareManager].isRender = state;
}

-(void)bottomDidChange:(int)index{
    if (index < 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeBeautify];
    }
    if (index == 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeStrick];
    }
    
    if (index == 4) {
        [[FUManager shareManager] setRenderType:FUDataTypeMakeup];
    }
    if (index == 5) {
        
        [[FUManager shareManager] setRenderType:FUDataTypebody];
    }
}

- (id<ZGCaptureDevice>)captureDevice {
    if (!_captureDevice) {

        _captureDevice = [[ZGCaptureDeviceCamera alloc] initWithPixelFormatType:kCVPixelFormatType_32BGRA];
        _captureDevice.delegate = self;
    }
    return _captureDevice;
}


- (void)setupUI {
    self.cameraSwitch.on = _enableCamera;
    self.microphoneSwitch.on = !_muteMicrophone;
    self.speakerSwitch.on = !_muteSpeaker;
    self.title = @"VideoTalk";
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", _roomID];
    self.roomStateLabel.text = @"Not Connected 🔴";
    
    // Add local user video view object
    [self.allUserViewObjectList addObject:self.localUserViewObject];
    [self rearrangeVideoTalkViewObjects];
}

#pragma mark - Actions

- (void)createEngine {
    
    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    [ZegoExpressEngine createEngineWithAppID:appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];
    
    ZegoCustomVideoCaptureConfig *captureConfig = [[ZegoCustomVideoCaptureConfig alloc] init];
    // 选择 CVPixelBuffer 类型视频帧数据
    captureConfig.bufferType = ZegoVideoBufferTypeCVPixelBuffer;
    
    // Enable custom video capture
    [[ZegoExpressEngine sharedEngine] enableCustomVideoCapture:YES config:captureConfig channel:ZegoPublishChannelMain];
    
    // 将自身作为自定义视频采集回调对象
    [[ZegoExpressEngine sharedEngine] setCustomVideoCaptureHandler:self];
    
    // 设置无镜像
    [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:(ZegoVideoMirrorModeNoMirror) channel:ZegoPublishChannelMain];
    
}

- (void)joinTalkRoom {
    // Login room
    ZGLogInfo(@"🚪 Login room, roomID: %@", _roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:_roomID user:[ZegoUser userWithUserID:_localUserID]];
    
    // Set the publish video configuration
    [[ZegoExpressEngine sharedEngine] setVideoConfig:[ZegoVideoConfig configWithPreset:ZegoVideoConfigPreset720P]];
    
    // Get the local user's preview view and start preview
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localUserViewObject.view];
    previewCanvas.viewMode = ZegoViewModeAspectFill;
    ZGLogInfo(@"🔌 Start preview");
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
    
    // Local user start publishing
    ZGLogInfo(@"📤 Start publishing stream, streamID: %@", _localStreamID);
    [[ZegoExpressEngine sharedEngine] startPublishingStream:_localStreamID];
}


#pragma mark - ZegoCustomVideoCaptureHandler

- (void)onStart:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 🟢 ZegoCustomVideoCaptureHandler onStart, channel: %d", (int)channel);
    [self.captureDevice startCapture];
}

// Note: This callback is not in the main thread. If you have UI operations, please switch to the main thread yourself.
- (void)onStop:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 🔴 ZegoCustomVideoCaptureHandler onStop, channel: %d", (int)channel);
    [self.captureDevice stopCapture];
}



#pragma mark - ZGCustomVideoCapturePixelBufferDelegate

- (void)captureDevice:(id<ZGCaptureDevice>)device didCapturedData:(CMSampleBufferRef)data {
     [[FUTestRecorder shareRecorder] processFrameWithLog];
    // BufferType: CVPixelBuffer
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(data);
    CMTime timeStamp = CMSampleBufferGetPresentationTimeStamp(data);
    CVPixelBufferRef fuBuffer = [[FUManager shareManager] renderItemsToPixelBuffer:buffer];
    [[ZegoExpressEngine sharedEngine] sendCustomVideoCapturePixelBuffer:fuBuffer timestamp:timeStamp];
    
}



// It is recommended to logout room when stopping the video call.
// And you can destroy the engine when there is no need to call.
- (void)exitRoom {
    ZGLogInfo(@"🚪 Logout room, roomID: %@", _roomID);
    [[ZegoExpressEngine sharedEngine] logoutRoom:_roomID];
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
    
    // 销毁道具
    [[FUManager shareManager] destoryItems];
    
}

/// Exit room when VC dealloc
- (void)dealloc {
    [self exitRoom];
}

- (IBAction)onToggleCameraSwitch:(UISwitch *)sender {
    _enableCamera = sender.on;
    [[ZegoExpressEngine sharedEngine] enableCamera:_enableCamera];
}

- (IBAction)onToggleMicrophoneSwitch:(UISwitch *)sender {
    _muteMicrophone = !sender.on;
    [[ZegoExpressEngine sharedEngine] muteMicrophone:_muteMicrophone];
}

- (IBAction)onToggleEnableSpeakerSwitch:(UISwitch *)sender {
    _muteSpeaker = !sender.on;
    [[ZegoExpressEngine sharedEngine] muteSpeaker:_muteSpeaker];
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
    CGFloat screenWidth = CGRectGetWidth(UIScreen.mainScreen.bounds);
    CGFloat playViewWidth = (screenWidth - (columnPerRow + 1)*viewSpacing) /columnPerRow;
    CGFloat playViewHeight = 1.5f * playViewWidth;
    
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
}

- (ZGVideoTalkViewObject *)getViewObjectWithStreamID:(NSString *)streamID {
    __block ZGVideoTalkViewObject *existObj = nil;
    [self.allUserViewObjectList enumerateObjectsUsingBlock:^(ZGVideoTalkViewObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.streamID isEqualToString:streamID]) {
            existObj = obj;
            *stop = YES;
        }
    }];
    return existObj;
}

/// Add a view of user who has entered the room and play the user stream
- (void)addRemoteViewObjectIfNeedWithStreamID:(NSString *)streamID {
    ZGVideoTalkViewObject *viewObject = [self getViewObjectWithStreamID:streamID];
    if (!viewObject) {
        viewObject = [ZGVideoTalkViewObject new];
        viewObject.isLocal = NO;
        viewObject.streamID = streamID;
        viewObject.view = [UIView new];
        [self.allUserViewObjectList addObject:viewObject];
    }
    
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:viewObject.view];
    playCanvas.viewMode = ZegoViewModeAspectFill;
    
    [[ZegoExpressEngine sharedEngine] startPlayingStream:streamID canvas:playCanvas];
    ZGLogInfo(@"📥 Start playing stream, streamID: %@", streamID);
}

/// Remove view of user who has left the room and stop playing stream
- (void)removeViewObjectWithStreamID:(NSString *)streamID {
    ZGVideoTalkViewObject *obj = [self getViewObjectWithStreamID:streamID];
    if (obj) {
        [self.allUserViewObjectList removeObject:obj];
        [obj.view removeFromSuperview];
    }
    
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:streamID];
    ZGLogInfo(@"📥 Stop playing stream, streamID: %@", streamID);
}

#pragma mark - ZegoEventHandler

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (errorCode != 0) {
        ZGLogError(@"🚩 ❌ 🚪 Room state error, errorCode: %d", errorCode);
    } else {
        if (state == ZegoRoomStateConnected) {
            ZGLogInfo(@"🚩 🚪 Login room success");
            self.roomStateLabel.text = @"Connected 🟢";
        } else if (state == ZegoRoomStateConnecting) {
            ZGLogInfo(@"🚩 🚪 Requesting login room");
            self.roomStateLabel.text = @"Connecting 🟡";
        } else if (state == ZegoRoomStateDisconnected) {
            ZGLogInfo(@"🚩 🚪 Logout room");
            self.roomStateLabel.text = @"Not Connected 🔴";
        }
    }
}

/// Refresh the remote streams list
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🌊 Room stream update, updateType:%lu, streamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);
    NSArray<NSString *> *allStreamIDList = [_allUserViewObjectList valueForKeyPath:@"streamID"];
    
    if (updateType == ZegoUpdateTypeAdd) {
        for (ZegoStream *stream in streamList) {
            ZGLogInfo(@"🚩 🌊 --- [Add] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID);
            if (![allStreamIDList containsObject:stream.streamID]) {
                [self addRemoteViewObjectIfNeedWithStreamID:stream.streamID];
            }
        }
    } else if (updateType == ZegoUpdateTypeDelete) {
        for (ZegoStream *stream in streamList) {
            ZGLogInfo(@"🚩 🌊 --- [Delete] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID);
            [self removeViewObjectWithStreamID:stream.streamID];
        }
    }
    
    [self rearrangeVideoTalkViewObjects];
}

/// This method is called back every 30 seconds, can be used to show the current number of online user in the room
- (void)onRoomOnlineUserCountUpdate:(int)count roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 👥 Room online user count update, count: %d, roomID: %@", count, roomID);
}

#pragma mark - Getter

- (ZGVideoTalkViewObject *)localUserViewObject {
    if (!_localUserViewObject) {
        _localUserViewObject = [ZGVideoTalkViewObject new];
        _localUserViewObject.isLocal = YES;
        _localUserViewObject.streamID = _localStreamID;
        _localUserViewObject.view = [UIView new];
    }
    return _localUserViewObject;
}

@end

#endif

//
//  ZGPublishStreamViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/5/29.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_PublishStream

#import "ZGPublishStreamViewController.h"
#import "ZGPublishStreamSettingTableViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import <Masonry.h>
#import "ZGCaptureDeviceCamera.h"
#import "ZGCaptureDeviceImage.h"

/**fuceU */
#import "FUDemoManager.h"
#import "FUTestRecorder.h"
/**faceU */

NSString* const ZGPublishStreamTopicRoomID = @"ZGPublishStreamTopicRoomID";
NSString* const ZGPublishStreamTopicStreamID = @"ZGPublishStreamTopicStreamID";

@interface ZGPublishStreamViewController () <ZegoEventHandler, UIPopoverPresentationControllerDelegate,ZegoCustomVideoCaptureHandler,ZGCaptureDeviceDataOutputPixelBufferDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIView *startPublishConfigView;

@property (weak, nonatomic) IBOutlet UIButton *startLiveButton;
@property (weak, nonatomic) IBOutlet UIButton *stopLiveButton;
@property (nonatomic, strong) UIBarButtonItem *settingButton;

@property (weak, nonatomic) IBOutlet UILabel *roomIDAndStreamIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishQualityLabel;

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;

@property (nonatomic) ZegoRoomState roomState;
@property (nonatomic) ZegoPublisherState publisherState;

@property (nonatomic, strong) id<ZGCaptureDevice> captureDevice;

@end

@implementation ZGPublishStreamViewController


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];

    /**faceU */
    /**销毁全部道具*/
    [[FUManager shareManager] destoryItems];
    
    ZGLogInfo(@"🔌 Stop preview");
    [[ZegoExpressEngine sharedEngine] stopPreview];

    // Stop publishing before exiting
    if (self.publisherState != ZegoPublisherStateNoPublish) {
        ZGLogInfo(@"📤 Stop publishing stream");
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    }

    // Logout room before exiting
    if (self.roomState != ZegoRoomStateDisconnected) {
        ZGLogInfo(@"🚪 Logout room");
        [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    }

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
    
}

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PublishStream" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGPublishStreamViewController class])];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];

    [self createEngine];

    self.enableCamera = YES;
    self.enableHardwareEncoder = NO;
    self.captureVolume = 100;
    self.startLiveButton.enabled = YES;
    self.stopLiveButton.enabled = YES;
    

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    // faceunity
    CGFloat safeAreaBottom = 150;
    if (@available(iOS 11.0, *)) {
        safeAreaBottom = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom + 150;
    }
    [FUDemoManager setupFaceUnityDemoInController:self originY:CGRectGetHeight(self.view.frame) - FUBottomBarHeight - safeAreaBottom];
}




- (void)setupUI {
    self.navigationItem.title = @"Publish Stream";

    self.settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Setting"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettingController)];

    self.navigationItem.rightBarButtonItem = self.settingButton;

    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];

    self.roomStateLabel.text = @"🔴 RoomState: Disconnected";
    self.roomStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.roomStateLabel.textColor = [UIColor whiteColor];

    self.publisherStateLabel.text = @"🔴 PublisherState: NoPublish";
    self.publisherStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.publisherStateLabel.textColor = [UIColor whiteColor];

    self.publishResolutionLabel.text = @"";
    self.publishResolutionLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.publishResolutionLabel.textColor = [UIColor whiteColor];

    self.publishQualityLabel.text = @"";
    self.publishQualityLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.publishQualityLabel.textColor = [UIColor whiteColor];

    self.stopLiveButton.alpha = 0;
    self.startPublishConfigView.alpha = 1;
    
    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: | StreamID: "];
    self.roomIDAndStreamIDLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.roomIDAndStreamIDLabel.textColor = [UIColor whiteColor];
}

#pragma mark - Actions


/**
 
 创建 ZegoExpressEngine 引擎
 开启自定义视频采集功能
 设置自定义视频采集回调对象并实现对应方法
 登录房间并推流，将收到自定义视频采集回调通知开始采集
 调用发送视频帧方法向 SDK 提供视频帧数据
 结束推流，将收到自定义视频采集回调通知停止采集
 
 */
- (void)createEngine {
    
    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];
    [self appendLog:@"🚀 Create ZegoExpressEngine"];

    [ZegoExpressEngine createEngineWithAppID:(unsigned int)appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];
    
    // Init capture config
    ZegoCustomVideoCaptureConfig *captureConfig = [[ZegoCustomVideoCaptureConfig alloc] init];
    // 选择 CVPixelBuffer 类型视频帧数据
    captureConfig.bufferType = ZegoVideoBufferTypeCVPixelBuffer;
    
    // Enable custom video capture
    [[ZegoExpressEngine sharedEngine] enableCustomVideoCapture:YES config:captureConfig channel:ZegoPublishChannelMain];

    // Set self as custom video capture handler
    [[ZegoExpressEngine sharedEngine] setCustomVideoCaptureHandler:self];
    
    ZegoVideoConfig *videoConfig = [ZegoVideoConfig configWithPreset:ZegoVideoConfigPreset720P];
    videoConfig.fps = 30;
    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
    
    [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:(ZegoVideoMirrorModeNoMirror)];
    
    
    // 加入房间
    [self appendLog:@"🚪 Start login room"];
    
    self.roomID = [NSString stringWithFormat:@"%d",arc4random() % 1000000 + 1];
    self.streamID = [NSString stringWithFormat:@"%.0f",CACurrentMediaTime() * 1000];

    // This demonstrates simply using the device model as the userID. In actual use, you can set the business-related userID as needed.
    NSString *userID = ZGUserIDHelper.userID;
    NSString *userName = ZGUserIDHelper.userName;

    ZegoRoomConfig *config = [ZegoRoomConfig defaultConfig];

    // Login room
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:userID userName:userName] config:config];
    
    // Start preview
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
    previewCanvas.viewMode = ZegoViewModeAspectFill;
    [self appendLog:@"🔌 Start preview"];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
}

- (IBAction)startLiveButtonClick:(id)sender {
    [self startLive];
}

- (IBAction)stopLiveButtonClick:(id)sender {
    [self stopLive];
}

- (void)startLive {

    [self appendLog:@"📤 Start publishing stream"];
    // Start publishing
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];

    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: %@ | StreamID: %@", self.roomID, self.streamID];
}

- (void)stopLive {
    // Stop publishing
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [self appendLog:@"📤 Stop publishing stream"];

    // Logout room
//    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
//    [self appendLog:@"🚪 Logout room"];

    self.publishQualityLabel.text = @"";
}

#pragma mark - Helper

- (void)invalidateLiveStateUILayout {
    if (self.roomState == ZegoRoomStateConnected &&
        self.publisherState == ZegoPublisherStatePublishing) {
        [self showLiveStartedStateUI];
    } else if (self.roomState == ZegoRoomStateDisconnected &&
               self.publisherState == ZegoPublisherStateNoPublish) {
        [self showLiveStoppedStateUI];
    } else {
        [self showLiveRequestingStateUI];
    }
}

- (void)showLiveRequestingStateUI {
    [self.startLiveButton setEnabled:YES];
    [self.stopLiveButton setEnabled:YES];
}

- (void)showLiveStartedStateUI {

    [UIView animateWithDuration:0.5 animations:^{
        self.startPublishConfigView.alpha = 0;
        self.stopLiveButton.alpha = 1;
    }];
}

- (void)showLiveStoppedStateUI {
    [UIView animateWithDuration:0.5 animations:^{
        self.startPublishConfigView.alpha = 1;
        self.stopLiveButton.alpha = 0;
    }];
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

- (void)showSettingController {
    ZGPublishStreamSettingTableViewController *vc = [ZGPublishStreamSettingTableViewController instanceFromStoryboard];
    vc.preferredContentSize = CGSizeMake(250.0, 150.0);
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.delegate = self;
    vc.popoverPresentationController.barButtonItem = self.settingButton;
    vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;

    vc.presenter = self;
    vc.enableCamera = _enableCamera;
    vc.enableHardwareEncoder = _enableHardwareEncoder;
    vc.captureVolume = _captureVolume;
    vc.roomID = _roomID;
    vc.streamExtraInfo = _streamExtraInfo;
    vc.roomExtraInfoKey = _roomExtraInfoKey;
    vc.roomExtraInfoValue = _roomExtraInfoValue;

    [self presentViewController:vc animated:YES completion:nil];
}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)orientationChanged:(NSNotification *)notification {
    UIDevice *device = notification.object;

    ZegoVideoConfig *videoConfig = [[ZegoExpressEngine sharedEngine] getVideoConfig];
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;

    switch (device.orientation) {
        // Note that UIInterfaceOrientationLandscapeLeft is equal to UIDeviceOrientationLandscapeRight (and vice versa).
        // This is because rotating the device to the left requires rotating the content to the right.
        case UIDeviceOrientationLandscapeLeft:
            orientation = UIInterfaceOrientationLandscapeRight;
            videoConfig.encodeResolution = CGSizeMake(720, 1280);
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = UIInterfaceOrientationLandscapeLeft;
            videoConfig.encodeResolution = CGSizeMake(720, 1280);
            break;
        case UIDeviceOrientationPortrait:
            orientation = UIInterfaceOrientationPortrait;
            videoConfig.encodeResolution = CGSizeMake(720, 1280);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = UIInterfaceOrientationPortraitUpsideDown;
            videoConfig.encodeResolution = CGSizeMake(720, 1280);
            break;
        default:
            // Unknown / FaceUp / FaceDown
            break;
    }

    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
    [[ZegoExpressEngine sharedEngine] setAppOrientation:orientation];
}


#pragma mark - ZegoExpress EventHandler Room Event

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 🚪 Room state error, errorCode: %d", errorCode]];
    } else {
        switch (state) {
            case ZegoRoomStateConnected:
                [self appendLog:@"🚩 🚪 Login room success"];
                self.roomStateLabel.text = @"🟢 RoomState: Connected";
                break;

            case ZegoRoomStateConnecting:
                [self appendLog:@"🚩 🚪 Requesting login room"];
                self.roomStateLabel.text = @"🟡 RoomState: Connecting";
                break;

            case ZegoRoomStateDisconnected:
                [self appendLog:@"🚩 🚪 Logout room"];
                self.roomStateLabel.text = @"🔴 RoomState: Disconnected";

                // After logout room, the preview will stop. You need to re-start preview.
                ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
                //            previewCanvas.viewMode = self.previewViewMode;
                [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
                break;
        }
    }
    self.roomState = state;
//    [self invalidateLiveStateUILayout];
}

#pragma mark - ZegoExpress EventHandler Publish Event

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📤 Publishing stream error of streamID: %@, errorCode:%d", streamID, errorCode]];
    } else {
        switch (state) {
            case ZegoPublisherStatePublishing:{
                
                [self appendLog:@"🚩 📤 Publishing stream"];
                self.publisherStateLabel.text = @"🟢 PublisherState: Publishing";
                [self showLiveStartedStateUI];
                
            }
  
                break;

            case ZegoPublisherStatePublishRequesting:
                [self appendLog:@"🚩 📤 Requesting publish stream"];
                self.publisherStateLabel.text = @"🟡 PublisherState: Requesting";
                break;

            case ZegoPublisherStateNoPublish:{
                
                [self appendLog:@"🚩 📤 No publish stream"];
                self.publisherStateLabel.text = @"🔴 PublisherState: NoPublish";
                [self showLiveStoppedStateUI];
            }

                break;
        }
    }
    self.publisherState = state;
//    [self invalidateLiveStateUILayout];
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    NSString *networkQuality = @"";
    switch (quality.level) {
        case 0:
            networkQuality = @"☀️";
            break;
        case 1:
            networkQuality = @"⛅️";
            break;
        case 2:
            networkQuality = @"☁️";
            break;
        case 3:
            networkQuality = @"🌧";
            break;
        case 4:
            networkQuality = @"❌";
            break;
        default:
            break;
    }
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"FPS: %d fps \n", (int)quality.videoSendFPS];
    [text appendFormat:@"Bitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"HardwareEncode: %@ \n", quality.isHardwareEncode ? @"✅" : @"❎"];
    [text appendFormat:@"NetworkQuality: %@", networkQuality];
    self.publishQualityLabel.text = [text copy];
}

- (void)onPublisherCapturedAudioFirstFrame {
    [self appendLog:@"🚩 🎶 onPublisherCapturedAudioFirstFrame"];
}

- (void)onPublisherCapturedVideoFirstFrame:(ZegoPublishChannel)channel {
    [self appendLog:@"🚩 📷 onPublisherCapturedVideoFirstFrame"];
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    if (channel == ZegoPublishChannelAux) {
        return;
    }
    self.publishResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

#pragma mark - ZegoCustomVideoCaptureHandler

// Note: This callback is not in the main thread. If you have UI operations, please switch to the main thread yourself.
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
    
    // BufferType: CVPixelBuffer
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(data);
    CMTime timeStamp = CMSampleBufferGetPresentationTimeStamp(data);
    if ([FUManager shareManager].isRender) {
        [[FUTestRecorder shareRecorder] processFrameWithLog];
        [[FUManager shareManager] updateBeautyBlurEffect];
        FURenderInput *input = [[FURenderInput alloc] init];
        input.renderConfig.imageOrientation = FUImageOrientationUP;
        input.pixelBuffer = buffer;
        //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
        input.renderConfig.gravityEnable = YES;
        FURenderOutput *output = [[FURenderKit shareRenderKit] renderWithInput:input];
        if (output) {
            [[ZegoExpressEngine sharedEngine] sendCustomVideoCapturePixelBuffer:output.pixelBuffer timestamp:timeStamp];
        }
    }
}




#pragma mark - Getter

- (id<ZGCaptureDevice>)captureDevice {
    if (!_captureDevice) {
        
        // BGRA32 or NV12
        _captureDevice = [[ZGCaptureDeviceCamera alloc] initWithPixelFormatType:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange];
        _captureDevice.delegate = self;
    }
    return _captureDevice;
}


@end

#endif

//
//  ZGCustomVideoCapturePublishStreamViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/12.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_CustomVideoCapture

#import "ZGCustomVideoCapturePublishStreamViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"

#import "ZGCaptureDeviceCamera.h"
#import "ZGCaptureDeviceImage.h"

#import "ZGVideoFrameEncoder.h"

#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import <Masonry.h>


/**fuceU */
#import "FUDemoManager.h"
#import "FUTestRecorder.h"
/**faceU */


@interface ZGCustomVideoCapturePublishStreamViewController () <ZegoEventHandler, ZegoCustomVideoCaptureHandler, ZGCaptureDeviceDataOutputPixelBufferDelegate, ZGVideoFrameEncoderDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (nonatomic, strong) UIBarButtonItem *startLiveButton;
@property (nonatomic, strong) UIBarButtonItem *stopLiveButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *streamIDLabel;

@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;

@property (nonatomic, strong) id<ZGCaptureDevice> captureDevice;

@property (nonatomic, strong) ZegoVideoEncodedFrameParam *encodeFrameParam;
@property (nonatomic, strong) ZGVideoFrameEncoder *encoder;

/**房间状态 */
@property (nonatomic, assign) ZegoRoomState roomState;

/** 推流状态 */
@property (nonatomic, assign) ZegoPublisherState publisherState;

@property (nonatomic, strong) FUDemoManager *demoManager;


@end

@implementation ZGCustomVideoCapturePublishStreamViewController


- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self createEngineAndLoginRoom];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    // faceunity
    CGFloat safeAreaBottom = 150;
    if (@available(iOS 11.0, *)) {
        safeAreaBottom = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom + 150;
    }
    self.demoManager =  [[FUDemoManager alloc] initWithTargetController:self originY:CGRectGetHeight(self.view.frame) - FUBottomBarHeight - safeAreaBottom];
    
    [self startLive];
}

#pragma mark --------------FaceUnity

- (void)setupUI {
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.streamIDLabel.text = [NSString stringWithFormat:@"StreamID: %@", self.streamID];

    self.startLiveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startLive)];
    self.stopLiveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(stopLive)];
    self.navigationItem.rightBarButtonItem = self.startLiveButton;

    if (self.captureSourceType == ZGCustomVideoCaptureSourceTypeImage) {
        self.switchCameraButton.hidden = YES;
    }

    if (self.captureBufferType == ZGCustomVideoCaptureBufferTypeEncodedFrame) {
        // The ZegoExpressEngine cannot render and preview the encoded video frame
        [self.previewView addSubview:({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.previewView.frame.size.width - 40, self.previewView.frame.size.height)];
            label.text = NSLocalizedString(@"CustomVideoCapture.RenderPreview", nil);
            label.font = [UIFont boldSystemFontOfSize:30];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label;
        })];
    }
}

- (IBAction)switchCamera:(UIButton *)sender {
    if ([self.captureDevice respondsToSelector:@selector(switchCameraPosition)]) {
        [self.captureDevice switchCameraPosition];
        
        /**faceU 切换摄像头 */
        [[FUManager shareManager] onCameraChange];
        
    }
    
    
}

- (void)createEngineAndLoginRoom {

    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];

    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    [ZegoExpressEngine createEngineWithAppID:(unsigned int)appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];

    // Init capture config
    ZegoCustomVideoCaptureConfig *captureConfig = [[ZegoCustomVideoCaptureConfig alloc] init];

    if (self.captureBufferType == ZGCustomVideoCaptureBufferTypeCVPixelBuffer) {
        captureConfig.bufferType = ZegoVideoBufferTypeCVPixelBuffer;
    } else if (self.captureBufferType == ZGCustomVideoCaptureBufferTypeEncodedFrame) {
        captureConfig.bufferType = ZegoVideoBufferTypeEncodedData;
    }

    // Enable custom video capture
    [[ZegoExpressEngine sharedEngine] enableCustomVideoCapture:YES config:captureConfig channel:ZegoPublishChannelMain];
    
    // 设置无镜像
    [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:(ZegoVideoMirrorModeNoMirror) channel:ZegoPublishChannelMain];

    // Set self as custom video capture handler
    [[ZegoExpressEngine sharedEngine] setCustomVideoCaptureHandler:self];
    
    // Set video config
    ZegoVideoConfig *videoConfig = [ZegoVideoConfig configWithPreset:ZegoVideoConfigPreset720P];
    videoConfig.fps = 30;
    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
    

    // Login room
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user config:[ZegoRoomConfig defaultConfig]];

    ZGLogInfo(@"🔌 Start preview");
    [[ZegoExpressEngine sharedEngine] startPreview:[ZegoCanvas canvasWithView:self.previewView]];
    
}

- (void)startLive {
    // The engine supports rendering the preview when the capture type is CVPixelBuffer.
    // Not supported when the capture type is EncodedData.

    ZGLogInfo(@"📤 Start publishing stream. streamID: %@", self.streamID);
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];
}

- (void)stopLive {
    ZGLogInfo(@"🔌 Stop preview");
//    [[ZegoExpressEngine sharedEngine] stopPreview];

    ZGLogInfo(@"📤 Stop publishing stream");
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
}


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



#pragma mark - Getter

- (id<ZGCaptureDevice>)captureDevice {
    if (!_captureDevice) {
        if (self.captureSourceType == ZGCustomVideoCaptureSourceTypeCamera) {
            // BGRA32 or NV12
            OSType pixelFormat = self.captureDataFormat == ZGCustomVideoCaptureDataFormatBGRA32 ? kCVPixelFormatType_32BGRA : kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
            _captureDevice = [[ZGCaptureDeviceCamera alloc] initWithPixelFormatType:pixelFormat];
        } else if (self.captureSourceType == ZGCustomVideoCaptureSourceTypeImage) {
            _captureDevice = [[ZGCaptureDeviceImage alloc] initWithMotionImage:[UIImage imageNamed:@"ZegoLogo"].CGImage contentSize:CGSizeMake(720, 1280)];
        }

        _captureDevice.delegate = self;
    }
    return _captureDevice;
}

- (ZGVideoFrameEncoder *)encoder {
    if (!_encoder) {
        _encoder = [[ZGVideoFrameEncoder alloc] initWithResolution:CGSizeMake(720, 1280) maxBitrate:(int)(3000 * 1000 * 1.5) averageBitrate:(int)(3000 * 1000) fps:15];
        _encoder.delegate = self;
    }
    return _encoder;
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

- (void)onEncodedDataTrafficControl:(ZegoTrafficControlInfo *)trafficControlInfo channel:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 🚦 onEncodedDataTrafficControl, should adjust to w: %d, h: %d, bitrate: %d, fps: %d", (int)trafficControlInfo.resolution.width, (int)trafficControlInfo.resolution.height, trafficControlInfo.bitrate, trafficControlInfo.fps);

    [self.encoder setMaxBitrate:trafficControlInfo.bitrate*1.5 averageBitrate:trafficControlInfo.bitrate fps:trafficControlInfo.fps];
    [self.captureDevice setFramerate:trafficControlInfo.fps];
}


#pragma mark - ZGCustomVideoCapturePixelBufferDelegate

- (void)captureDevice:(id<ZGCaptureDevice>)device didCapturedData:(CMSampleBufferRef)data {

    if (self.captureBufferType == ZGCustomVideoCaptureBufferTypeCVPixelBuffer) {
        [self.demoManager faceUnityManagerCheckAI];
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
            if (output && output.pixelBuffer) {
                // [[ZegoExpressEngine sharedEngine] enableCamera:YES];
                [[ZegoExpressEngine sharedEngine] sendCustomVideoCapturePixelBuffer:output.pixelBuffer timestamp:timeStamp];
            }
        }
    } else if (self.captureBufferType == ZGCustomVideoCaptureBufferTypeEncodedFrame) {

        // BufferType: Encoded frame (H.264)

        // Need to encode frame
        [self.encoder encodeBuffer:data];
    }
}


#pragma mark - ZGVideoFrameEncoderDelegate

// BufferType: Encoded frame (H.264)
- (void)encoder:(ZGVideoFrameEncoder *)encoder encodedData:(NSData *)data isKeyFrame:(BOOL)isKeyFrame timestamp:(CMTime)timestamp {

    self.encodeFrameParam.isKeyFrame = isKeyFrame;

    // Send encoded frame to ZEGO SDK
    [[ZegoExpressEngine sharedEngine] sendCustomVideoCaptureEncodedData:data params:self.encodeFrameParam timestamp:timestamp];
}

- (ZegoVideoEncodedFrameParam *)encodeFrameParam {
    if (!_encodeFrameParam) {
        _encodeFrameParam = [[ZegoVideoEncodedFrameParam alloc] init];
        _encodeFrameParam.size = CGSizeMake(720, 1280);
        _encodeFrameParam.format = ZegoVideoEncodedFrameFormatAVCC; // The VideoToolBox default compression format is AVCC
    }
    return _encodeFrameParam;
}


#pragma mark - ZegoEventHandler

#pragma mark - ZegoExpress EventHandler Room Event

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (errorCode != 0) {
       
    } else {
        switch (state) {
            case ZegoRoomStateConnected:
               
                break;

            case ZegoRoomStateConnecting:
              
                break;

            case ZegoRoomStateDisconnected:
                

                ZGLogInfo(@"🔌 Start preview");
                [[ZegoExpressEngine sharedEngine] startPreview:[ZegoCanvas canvasWithView:self.previewView]];
                break;
        }
    }
    self.roomState = state;

}



- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📤 Publisher State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);

    switch (state) {
        case ZegoPublisherStateNoPublish:
            self.title = @"🔴 No Publish";
            self.navigationItem.rightBarButtonItem = self.startLiveButton;
            break;
        case ZegoPublisherStatePublishRequesting:
            self.title = @"🟡 Publish Requesting";
            self.navigationItem.rightBarButtonItem = self.stopLiveButton;
            break;
        case ZegoPublisherStatePublishing:
            self.title = @"🟢 Publishing";
            self.navigationItem.rightBarButtonItem = self.stopLiveButton;
            break;
    }
    
    self.publisherState = state;
    
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    self.resolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %d fps \n", (int)quality.videoSendFPS];
    self.bitrateLabel.text = [NSString stringWithFormat:@"Bitrate: %.2f kb/s \n", quality.videoKBPS];
}

@end

#endif

//
//  ZGAuxPublisherPublishViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/2/27.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_AuxPublisher

#import "ZGAuxPublisherPublishViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import "ZGCaptureDeviceImage.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NSString* const ZGAuxPublisherPublishVCKey_mainStreamID = @"kMainStreamID";
NSString* const ZGAuxPublisherPublishVCKey_auxStreamID = @"kAuxStreamID";

@interface ZGAuxPublisherPublishViewController () <ZegoEventHandler, ZegoCustomVideoCaptureHandler, ZGCaptureDeviceDataOutputPixelBufferDelegate>

@property (nonatomic, strong) id<ZGCaptureDevice> captureDevice;

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *mainStreamID;
@property (nonatomic, copy) NSString *auxStreamID;

@property (nonatomic, assign) ZegoRoomState roomState;
@property (nonatomic, assign) ZegoPublisherState mainPublisherState;
@property (nonatomic, assign) ZegoPublisherState auxPublisherState;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainStreamStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *auxStreamStateLabel;

@property (weak, nonatomic) IBOutlet UIView *mainPreviewView;
@property (weak, nonatomic) IBOutlet UIImageView *auxPreviewView;

@property (weak, nonatomic) IBOutlet UITextField *mainStreamIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *auxStreamIDTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *mainStartButton;
@property (weak, nonatomic) IBOutlet UIButton *auxStartButton;

@end

@implementation ZGAuxPublisherPublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomID = @"AuxPublisherRoom-1";
    
    self.mainStreamID = [self savedValueForKey:ZGAuxPublisherPublishVCKey_mainStreamID];
    self.auxStreamID = [self savedValueForKey:ZGAuxPublisherPublishVCKey_auxStreamID];
    
    [self setupUI];
    [self createEngineAndLoginRoom];
}

#pragma mark - Setup

- (void)setupUI {
    self.title = @"AuxPublisher";
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", _roomID];
    self.roomStateLabel.text = @"Not Connected 🔴";
    
    self.mainStreamStateLabel.text = @"🔴 No Publish";
    self.mainStreamStateLabel.textColor = [UIColor whiteColor];
    
    self.auxStreamStateLabel.text = @"🔴 No Publish";
    self.auxStreamStateLabel.textColor = [UIColor whiteColor];
    
    [self hidePublishButtonAndTextField:YES];
    
    self.mainStreamIDTextField.text = self.mainStreamID;
    self.auxStreamIDTextField.text = self.auxStreamID;
}

- (void)hidePublishButtonAndTextField:(BOOL)hide {
    self.mainStartButton.hidden = hide;
    self.auxStartButton.hidden = hide;
    self.mainStreamIDTextField.hidden = hide;
    self.auxStreamIDTextField.hidden = hide;
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
    
    // Set capture config for aux publish channel
    ZegoCustomVideoCaptureConfig *captureConfig = [[ZegoCustomVideoCaptureConfig alloc] init];
    captureConfig.bufferType = ZegoVideoBufferTypeCVPixelBuffer;
    
    // Enable custom video capture for aux channel
    // Only the aux channel use custom video capture, and the main channel uses the SDK's own capture
    [[ZegoExpressEngine sharedEngine] enableCustomVideoCapture:YES config:captureConfig channel:ZegoPublishChannelAux];
    
    [[ZegoExpressEngine sharedEngine] setCustomVideoCaptureHandler:self];
    
    [[ZegoExpressEngine sharedEngine] setVideoConfig:[ZegoVideoConfig configWithPreset:ZegoVideoConfigPreset720P] channel:ZegoPublishChannelMain];
    [[ZegoExpressEngine sharedEngine] setVideoConfig:[ZegoVideoConfig configWithPreset:ZegoVideoConfigPreset720P] channel:ZegoPublishChannelAux];
}

#pragma mark - Login/Logout Room

- (IBAction)loginRoomButtonClick:(UIButton *)sender {
    switch (self.roomState) {
        case ZegoRoomStateConnected:
            [self logoutRoom];
            break;
        case ZegoRoomStateDisconnected:
            [self loginRoom];
            break;
        case ZegoRoomStateConnecting:
            break;
    }
}

- (void)loginRoom {
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user];
}

- (void)logoutRoom {
    ZGLogInfo(@"🚪 Logout room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
}

#pragma mark - Start/Stop Publishing Main Channel

- (IBAction)mainStartButtonClick:(UIButton *)sender {
    switch (self.mainPublisherState) {
        case ZegoPublisherStatePublishing:
            [self stopPublishMainChannel];
            break;
        case ZegoPublisherStateNoPublish:
            [self startPublishMainChannel];
            break;
        case ZegoPublisherStatePublishRequesting:
            break;
    }
}

- (void)startPublishMainChannel {
    self.mainStreamID = self.mainStreamIDTextField.text;
    
    // Start preview for main channel
    ZGLogInfo(@"🔌 Start preview main channel");
    ZegoCanvas *mainPreviewCanvas = [ZegoCanvas canvasWithView:self.mainPreviewView];
    [[ZegoExpressEngine sharedEngine] startPreview:mainPreviewCanvas];
    
    ZGLogInfo(@"📤 Start publishing stream main channel. streamID: %@", self.mainStreamID);
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.mainStreamID channel:ZegoPublishChannelMain];
}

- (void)stopPublishMainChannel {
    ZGLogInfo(@"📤 Stop publishing stream main channel");
    [[ZegoExpressEngine sharedEngine] stopPublishingStream:ZegoPublishChannelMain];
}

#pragma mark - Start/Stop Publishing Aux Channel

- (IBAction)auxStartButtonClick:(UIButton *)sender {
    switch (self.auxPublisherState) {
        case ZegoPublisherStatePublishing:
            [self stopPublishAuxChannel];
            break;
        case ZegoPublisherStateNoPublish:
            [self startPublishAuxChannel];
            break;
        case ZegoPublisherStatePublishRequesting:
            break;
    }
}

- (void)startPublishAuxChannel {
    self.auxStreamID = self.auxStreamIDTextField.text;
    
    ZGLogInfo(@"📤 Start publishing stream aux channel. streamID: %@", self.auxStreamID);
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.auxStreamID channel:ZegoPublishChannelAux];
}

- (void)stopPublishAuxChannel {
    ZGLogInfo(@"📤 Stop publishing stream aux channel");
    [[ZegoExpressEngine sharedEngine] stopPublishingStream:ZegoPublishChannelAux];
}

#pragma mark - Exit

- (void)dealloc {
    ZGLogInfo(@"🚪 Exit the room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

#pragma mark - Capture device for aux channel

- (id<ZGCaptureDevice>)captureDevice {
    if (!_captureDevice) {
        _captureDevice = [[ZGCaptureDeviceImage alloc] initWithMotionImage:[UIImage imageNamed:@"ZegoLogo"].CGImage contentSize:CGSizeMake(720, 1280)];
        _captureDevice.delegate = self;
    }
    return _captureDevice;
}

#pragma mark - ZegoCustomVideoCaptureHandler

// Note: This callback is not in the main thread. If you have UI operations, please switch to the main thread yourself.
- (void)onStart:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 🟢 ZegoCustomVideoCaptureHandler onStart, channel: %@", channel == ZegoPublishChannelMain ? @"Main" : @"Aux");
    [self.captureDevice startCapture];
}

// Note: This callback is not in the main thread. If you have UI operations, please switch to the main thread yourself.
- (void)onStop:(ZegoPublishChannel)channel {
    ZGLogInfo(@"🚩 🔴 ZegoCustomVideoCaptureHandler onStop, channel: %@", channel == ZegoPublishChannelMain ? @"Main" : @"Aux");
    [self.captureDevice stopCapture];
}


#pragma mark - ZGCustomVideoCapturePixelBufferDelegate

- (void)captureDevice:(nonnull id<ZGCaptureDevice>)device didCapturedData:(nonnull CVPixelBufferRef)data presentationTimeStamp:(CMTime)timeStamp {
    
    // Send pixel buffer to ZEGO SDK for aux channel
    [[ZegoExpressEngine sharedEngine] sendCustomVideoCapturePixelBuffer:data timestamp:timeStamp channel:ZegoPublishChannelAux];
    
    // When custom video capture is enabled, developers need to render the preview by themselves
    [self renderWithCVPixelBuffer:data];
}

- (void)captureDevice:(id<ZGCaptureDevice>)device didCapturedData:(CMSampleBufferRef)data {

    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(data);
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(data);


    // Send pixel buffer to ZEGO SDK for aux channel
    [[ZegoExpressEngine sharedEngine] sendCustomVideoCapturePixelBuffer:pixelBuffer timestamp:timestamp channel:ZegoPublishChannelAux];

    // When custom video capture is enabled, developers need to render the preview by themselves
    [self renderWithCVPixelBuffer:pixelBuffer];
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

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(nullable NSDictionary *)extendedData streamID:(nonnull NSString *)streamID {
    ZGLogInfo(@"🚩 📤 Publisher State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
    
    if (streamID == self.mainStreamID) {
        self.mainPublisherState = state;
        
        switch (state) {
            case ZegoPublisherStateNoPublish:
                self.mainStreamStateLabel.text = @"🔴 No Publish";
                [self.mainStartButton setTitle:@"Start Publish Main" forState:UIControlStateNormal];
                break;
            case ZegoPublisherStatePublishRequesting:
                self.mainStreamStateLabel.text = @"🟡 Requesting";
                [self.mainStartButton setTitle:@"Requesting" forState:UIControlStateNormal];
                break;
            case ZegoPublisherStatePublishing:
                self.mainStreamStateLabel.text = @"🟢 Publishing";
                [self.mainStartButton setTitle:@"Stop Publish Main" forState:UIControlStateNormal];
                break;
        }
    } else if (streamID == self.auxStreamID) {
        self.auxPublisherState = state;
        
        switch (state) {
            case ZegoPublisherStateNoPublish:
                self.auxStreamStateLabel.text = @"🔴 No Publish";
                [self.auxStartButton setTitle:@"Start Publish Aux" forState:UIControlStateNormal];
                break;
            case ZegoPublisherStatePublishRequesting:
                self.auxStreamStateLabel.text = @"🟡 Requesting";
                [self.auxStartButton setTitle:@"Requesting" forState:UIControlStateNormal];
                break;
            case ZegoPublisherStatePublishing:
                self.auxStreamStateLabel.text = @"🟢 Publishing";
                [self.auxStartButton setTitle:@"Stop Publish Aux" forState:UIControlStateNormal];
                break;
        }
    }
}

#pragma mark - Render Preview

- (void)renderWithCVPixelBuffer:(CVPixelBufferRef)buffer {
    CIImage *image = [CIImage imageWithCVPixelBuffer:buffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.auxPreviewView.image = [UIImage imageWithCIImage:image];
    });
}

@end

#endif

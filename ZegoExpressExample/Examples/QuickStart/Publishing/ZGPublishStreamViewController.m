//
//  ZGPublishStreamViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/5/29.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "AppDelegate.h"
#import "ZGPublishStreamViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

#import "FUDemoManager.h"
#import "FUTestRecorder.h"

NSString* const ZGPublishStreamTopicRoomID = @"ZGPublishStreamTopicRoomID";
NSString* const ZGPublishStreamTopicStreamID = @"ZGPublishStreamTopicStreamID";

@interface ZGPublishStreamViewController () <ZegoEventHandler, UITextFieldDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIView *startPublishConfigView;
@property (weak, nonatomic) IBOutlet UIView *notesView;

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;

@property (weak, nonatomic) IBOutlet UIButton *mirrorModeButton;
@property (weak, nonatomic) IBOutlet UIButton *viewModeButton;


@property (weak, nonatomic) IBOutlet UIButton *startLiveButton;
@property (weak, nonatomic) IBOutlet UIButton *stopLiveButton;

@property (weak, nonatomic) IBOutlet UILabel *roomIDAndStreamIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *documentLabel;

@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;
@property (nonatomic, assign) ZegoViewMode previewMode;


@property (nonatomic) ZegoRoomStateChangedReason roomState;
@property (nonatomic) ZegoPublisherState publisherState;

@end

@implementation ZGPublishStreamViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PublishStream" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGPublishStreamViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [self createEngine];

    self.userID = [ZGUserIDHelper userID];
    self.roomIDTextField.text = @"0002";
    self.streamIDTextField.text = @"0002";
    self.enableCamera = YES;
    self.useFrontCamera = YES;
    self.captureVolume = 100;
    self.currentZoomFactor = 1.0;
    self.previewMode = ZegoViewModeAspectFit;
    
    self.userIDLabel.text = [NSString stringWithFormat:@"UserID: %@", self.userID];

    // Support landscape
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskAllButUpsideDown];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    self.currentOrientation = [ZGWindowHelper statusBarOrientation];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(documentLabelTap:)];
    self.documentLabel.userInteractionEnabled = YES;
    [self.documentLabel addGestureRecognizer: tap];
    
    // faceunity
    [FUDemoManager setupFUSDK];
    [[FUDemoManager shared] addDemoViewToView:self.view originY:CGRectGetHeight(self.view.frame) - FUBottomBarHeight - FUSafaAreaBottomInsets() - 150];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    // Reset to portrait
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskPortrait];
    
    [FUDemoManager destory];

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}


- (void)setupUI {
    self.navigationItem.title = @"Publish Stream";

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

    self.roomID = [self savedValueForKey:ZGPublishStreamTopicRoomID];
    self.roomIDTextField.text = self.roomID;
    self.roomIDTextField.delegate = self;

    self.streamID = [self savedValueForKey:ZGPublishStreamTopicStreamID];
    self.streamIDTextField.text = self.streamID;
    self.streamIDTextField.delegate = self;
 
    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: | StreamID: "];
    self.roomIDAndStreamIDLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.roomIDAndStreamIDLabel.textColor = [UIColor whiteColor];
}

- (void)documentLabelTap:(UITapGestureRecognizer *)tap {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://doc-zh.zego.im/article/api?doc=Express_Video_SDK_API~objective-c_ios~enum~ZegoStreamResourceMode"]]];
}

#pragma mark - Actions

- (void)createEngine {

    [self appendLog:@"🚀 Create ZegoExpressEngine"];

    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    
    // Here we use the broadcast scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    profile.scenario = ZegoScenarioBroadcast;

    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
}

- (IBAction)startLiveButtonClick:(id)sender {
    [self startPublishingStream];
}

- (IBAction)stopLiveButtonClick:(id)sender {
    [self stopPublishingStream];
}


- (void)startPublishingStream {
    [self appendLog:@"🚪 Start login room"];

    self.roomID = self.roomIDTextField.text;
    self.streamID = self.streamIDTextField.text;

    // This demonstrates simply using the device model as the userID. In actual use, you can set the business-related userID as needed.
    NSString *userID = self.userID;
    NSString *userName = userID;

    // Login room
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:userID userName:userName]];

    // Start preview
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
    previewCanvas.viewMode = self.previewMode;
    [self appendLog:@"🔌 Start preview"];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];

    [self appendLog:@"📤 Start publishing stream"];

    // Start publishing
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];

    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: %@ | StreamID: %@", self.roomID, self.streamID];
}

- (void)stopPublishingStream {
    // Stop publishing
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [self appendLog:@"📤 Stop publishing stream"];

    [[ZegoExpressEngine sharedEngine] stopPreview];
    [self appendLog:@"🔌 Stop preview"];

    // Logout room
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    [self appendLog:@"🚪 Logout room"];

    self.publishQualityLabel.text = @"";
}

- (IBAction)onMirrorModeButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *onlyPreview = [UIAlertAction actionWithTitle:@"OnlyPreview" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeOnlyPreviewMirror];
        [self.mirrorModeButton setTitle:@"OnlyPreview" forState:UIControlStateNormal];
    }];
    UIAlertAction *onlyPublish = [UIAlertAction actionWithTitle:@"OnlyPublish" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeOnlyPublishMirror];
        [self.mirrorModeButton setTitle:@"OnlyPublish" forState:UIControlStateNormal];

    }];
    UIAlertAction *bothMirror = [UIAlertAction actionWithTitle:@"BothMirror" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeBothMirror];
        [self.mirrorModeButton setTitle:@"BothMirror" forState:UIControlStateNormal];
    }];
    UIAlertAction *noMirror = [UIAlertAction actionWithTitle:@"NoMirror" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeNoMirror];
        [self.mirrorModeButton setTitle:@"NoMirror" forState:UIControlStateNormal];
    }];

    [alertController addAction:cancel];
    [alertController addAction:onlyPreview];
    [alertController addAction:onlyPublish];
    [alertController addAction:bothMirror];
    [alertController addAction:noMirror];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onViewModeButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *aspectFit = [UIAlertAction actionWithTitle:@"AspectFit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
        previewCanvas.viewMode = ZegoViewModeAspectFit;
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        [self.viewModeButton setTitle:@"AspectFit" forState:UIControlStateNormal];
        self.previewMode = ZegoViewModeAspectFit;

    }];
    UIAlertAction *aspectFill = [UIAlertAction actionWithTitle:@"AspectFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
        previewCanvas.viewMode = ZegoViewModeAspectFill;
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        [self.viewModeButton setTitle:@"AspectFill" forState:UIControlStateNormal];
        self.previewMode = ZegoViewModeAspectFill;
    }];
    UIAlertAction *scaleToFill = [UIAlertAction actionWithTitle:@"ScaleToFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
        previewCanvas.viewMode = ZegoViewModeScaleToFill;
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        [self.viewModeButton setTitle:@"ScaleToFill" forState:UIControlStateNormal];
        self.previewMode = ZegoViewModeScaleToFill;
    }];
    [alertController addAction:cancel];
    [alertController addAction:aspectFit];
    [alertController addAction:aspectFill];
    [alertController addAction:scaleToFill];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}


- (IBAction)onSwitchCamera:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] enableCamera:sender.isOn];
}

- (IBAction)onChangeCamera:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [[ZegoExpressEngine sharedEngine] useFrontCamera:NO];
    } else {
        [[ZegoExpressEngine sharedEngine] useFrontCamera:YES];
    }
}

- (IBAction)onSwitchMicrophone:(UISwitch *)sender {
    if (sender.isOn) {
        [[ZegoExpressEngine sharedEngine] muteMicrophone:NO];
    } else {
        [[ZegoExpressEngine sharedEngine] muteMicrophone:YES];
    }
}

- (IBAction)onSwitchMuteVideo:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] mutePublishStreamVideo:sender.isOn];
}

- (IBAction)onSwitchMuteAudio:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] mutePublishStreamAudio:sender.isOn];
}

#pragma mark - Helper

- (void)invalidateLiveStateUILayout {
    if(self.publisherState == ZegoPublisherStatePublishing)
    {
        [self showLiveStartedStateUI];
    }
    else if(self.publisherState == ZegoPublisherStatePublishRequesting)
    {
        [self showLiveRequestingStateUI];
    }
    else
    {
        [self showLiveStoppedStateUI];
    }
}

- (void)showLiveRequestingStateUI {
    [self.startLiveButton setEnabled:NO];
    [self.stopLiveButton setEnabled:NO];
}

- (void)showLiveStartedStateUI {
    [self.startLiveButton setEnabled:NO];
    [self.stopLiveButton setEnabled:YES];
    [UIView animateWithDuration:0.5 animations:^{
        self.startPublishConfigView.alpha = 1;
        self.notesView.alpha = 0;
        self.startLiveButton.alpha = 0;
        self.stopLiveButton.alpha = 1;
    }];
}

- (void)showLiveStoppedStateUI {
    [self.startLiveButton setEnabled:YES];
    [self.stopLiveButton setEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.startPublishConfigView.alpha = 1;
        self.notesView.alpha = 1;
        self.startLiveButton.alpha = 1;

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    if (textField == self.roomIDTextField) {
        [self.streamIDTextField becomeFirstResponder];
    } else if (textField == self.streamIDTextField) {
        [self startPublishingStream];
    }

    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)orientationChanged:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [ZGWindowHelper statusBarOrientation];

    if (_currentOrientation != orientation) {
        _currentOrientation = orientation;
        [[ZegoExpressEngine sharedEngine] setAppOrientation:orientation];

        ZegoVideoConfig *videoConfig = [[ZegoExpressEngine sharedEngine] getVideoConfig];
        CGFloat longSideValue = MAX(videoConfig.encodeResolution.width, videoConfig.encodeResolution.height);
        CGFloat shortSideValue = MIN(videoConfig.encodeResolution.width, videoConfig.encodeResolution.height);

        if (UIInterfaceOrientationIsPortrait(orientation)) {
            videoConfig.encodeResolution = CGSizeMake(shortSideValue, longSideValue);
        } else if (UIInterfaceOrientationIsLandscape(orientation)) {
            videoConfig.encodeResolution = CGSizeMake(longSideValue, shortSideValue);
        }
        [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
    }
}


#pragma mark - ZegoExpress EventHandler Room Event

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

#pragma mark - ZegoExpress EventHandler Publish Event

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📤 Publishing stream error of streamID: %@, errorCode:%d", streamID, errorCode]];
    } else {
        switch (state) {
            case ZegoPublisherStatePublishing:
                [self appendLog:@"🚩 📤 Publishing stream"];
                self.publisherStateLabel.text = @"🟢 PublisherState: Publishing";
                break;

            case ZegoPublisherStatePublishRequesting:
                [self appendLog:@"🚩 📤 Requesting publish stream"];
                self.publisherStateLabel.text = @"🟡 PublisherState: Requesting";
                break;

            case ZegoPublisherStateNoPublish:
                [self appendLog:@"🚩 📤 No publish stream"];
                self.publisherStateLabel.text = @"🔴 PublisherState: NoPublish";
                break;
        }
    }
    self.publisherState = state;
    [self invalidateLiveStateUILayout];
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
    [text appendFormat:@"VideoSendFPS: %.1f fps \n", quality.videoSendFPS];
    [text appendFormat:@"AudioSendFPS: %.1f fps \n", quality.audioSendFPS];
    [text appendFormat:@"VideoBitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"AudioBitrate: %.2f kb/s \n", quality.audioKBPS];
    [text appendFormat:@"RTT: %d ms \n", quality.rtt];
    [text appendFormat:@"VideoCodecID: %d \n", (int)quality.videoCodecID];
    [text appendFormat:@"TotalSend: %.3f MB \n", quality.totalSendBytes / 1024 / 1024];
    [text appendFormat:@"PackageLostRate: %.1f%% \n", quality.packetLostRate * 100.0];
    [text appendFormat:@"HardwareEncode: %@ \n", quality.isHardwareEncode ? @"✅" : @"❎"];
    [text appendFormat:@"NetworkQuality: %@", networkQuality];
    self.publishQualityLabel.text = [text copy];
}

- (void)onPublisherCapturedAudioFirstFrame {
    [self appendLog:@"🚩 🎶 onPublisherCapturedAudioFirstFrame"];
}

- (void)onPublisherCapturedVideoFirstFrame:(ZegoPublishChannel)channel {
    [self appendLog:@"🚩 📷 onPublisherCapturedVideoFirstFrame"];
    self.maxZoomFactor = [[ZegoExpressEngine sharedEngine] getCameraMaxZoomFactor];
    [self appendLog:[NSString stringWithFormat:@"📷 cameraMaxZoomFactor: %.1f", self.maxZoomFactor]];
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    if (channel == ZegoPublishChannelAux) {
        return;
    }
    self.publishResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

- (void)onPublisherSendAudioFirstFrame {
    [self appendLog:@"🚩 🎶 onPublisherSendAudioFirstFrame"];
}

- (void)onPublisherSendVideoFirstFrame:(ZegoPublishChannel)channel {
    [self appendLog:@"🚩 📷 onPublisherSendVideoFirstFrame"];
}

@end

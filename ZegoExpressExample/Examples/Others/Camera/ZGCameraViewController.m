//
//  ZGCameraViewController.m
//  ZegoExpressExample
//
//  Created by zego on 2021/10/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "AppDelegate.h"
#import "ZGCameraViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGCameraViewController () <ZegoEventHandler>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UILabel *roomAndUserIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *supportFocusLabel;
@property (weak, nonatomic) IBOutlet UIButton *streamButton;

@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;

@property (weak, nonatomic) IBOutlet UISwitch *foucsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *exposureSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *focusMode;

@property (weak, nonatomic) IBOutlet UILabel *zoomFactorLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxZoomFactorLabel;
@property (weak, nonatomic) IBOutlet UILabel *exposureCompensationValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *zoomFactorSlider;

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;

@property (nonatomic) ZegoPublisherState publisherState;

@end

@implementation ZGCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0028";
    self.publishStreamIDTextField.text = @"0028";
    
    [self setupEngineAndLogin];
    [self setupUI];
}

- (void)setupEngineAndLogin {
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
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
    [self appendLog:[NSString stringWithFormat:@"🚪Login Room roomID: %@", self.roomID]];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:self.userID]];
    
    [[ZegoExpressEngine sharedEngine] useFrontCamera:NO];
}

- (void)setupUI {
    self.roomAndUserIDLabel.text = [NSString stringWithFormat:@"UserID: %@  RoomID:%@", self.userID, self.roomID];
    
    [self.streamButton setTitle:@"Start Publishing" forState:UIControlStateNormal];
    [self.streamButton setTitle:@"Stop Publishing" forState:UIControlStateSelected];

    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];
}

- (void)dealloc {

    ZGLogInfo(@"🔌 Stop preview");
    [[ZegoExpressEngine sharedEngine] stopPreview];

    // Stop publishing before exiting
    ZGLogInfo(@"📤 Stop publishing stream");
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];

    // Logout room before exiting
    ZGLogInfo(@"🚪 Logout room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

#pragma mark - Actions

- (IBAction)onPublishStreamButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.publishStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
    } else {
        // Start preview
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
        previewCanvas.viewMode = ZegoViewModeAspectFill;
        [self appendLog:@"🔌 Start preview"];
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        
        // Start publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.publishStreamIDTextField.text]];
        
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.publishStreamIDTextField.text];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onChangeCamera:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self appendLog:[NSString stringWithFormat:@"📤 Use front camera"]];
        [[ZegoExpressEngine sharedEngine] useFrontCamera:YES];
    } else {
        [self appendLog:[NSString stringWithFormat:@"📤 Use back camera"]];
        [[ZegoExpressEngine sharedEngine] useFrontCamera:NO];
    }
}


- (IBAction)onCameraFocusSwitch:(UISwitch *)sender {
    [self appendLog:[NSString stringWithFormat:@"🚩 camera focus feature is %@", sender.isOn ? @"on" : @"off"]];
}

- (IBAction)onCameraExposureSwitch:(UISwitch *)sender {
    [self appendLog:[NSString stringWithFormat:@"🚩 camera exposure feature is %@", sender.isOn ? @"on" : @"off"]];
}

- (IBAction)onCameraExposureModeSelected:(UISegmentedControl *)sender {
    [self appendLog:[NSString stringWithFormat:@"📥 camera exposure selected %@", sender.selectedSegmentIndex == 0 ? @"Auto" : @"ContinuousAuto"]];
    [[ZegoExpressEngine sharedEngine] setCameraExposureMode:sender.selectedSegmentIndex channel:ZegoPublishChannelMain];
}

- (IBAction)onCameraFocusModeSelected:(UISegmentedControl *)sender {
    [self appendLog:[NSString stringWithFormat:@"📥 camera focus selected %@", sender.selectedSegmentIndex == 0 ? @"Auto" : @"ContinuousAuto"]];
    [[ZegoExpressEngine sharedEngine] setCameraFocusMode:sender.selectedSegmentIndex channel:ZegoPublishChannelMain];
}

- (IBAction)onTapGestureRecognizerInPreview:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:sender.view];
    float x = point.x / sender.view.bounds.size.width;
    float y = point.y / sender.view.bounds.size.height;
    
    if (self.foucsSwitch.isOn) {
        [[ZegoExpressEngine sharedEngine] setCameraFocusPointInPreviewX:x y:y channel:ZegoPublishChannelMain];
    }
    if (self.exposureSwitch.isOn) {
        [[ZegoExpressEngine sharedEngine] setCameraExposurePointInPreviewX:x y:y channel:ZegoPublishChannelMain];
    }
}

- (IBAction)onCameraZoomFactor:(UISlider *)sender {
    [[ZegoExpressEngine sharedEngine] setCameraZoomFactor:sender.value];
    [self appendLog:[NSString stringWithFormat:@"📥 OnZoomFactorChanged: %.1f", sender.value]];

    self.zoomFactorLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
}

- (IBAction)onExposureCompensation:(UISlider *)sender {
    [[ZegoExpressEngine sharedEngine] setCameraExposureCompensation:sender.value];
    
    [self appendLog:[NSString stringWithFormat:@"📥 onExposureCompensationChanged: %.1f", sender.value]];

    self.exposureCompensationValueLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
}

#pragma mark - Helper

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

#pragma mark - ZegoExpress EventHandler Room Event

-(void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if(reason == ZegoRoomStateChangedReasonLogining)
    {
        ZGLogInfo(@"🚩 🚪 Logining room");
    }
    else if(reason == ZegoRoomStateChangedReasonLogined)
    {
        ZGLogInfo(@"🚩 🚪 Login room success");
    }
    else if (reason == ZegoRoomStateChangedReasonLoginFailed)
    {
        ZGLogInfo(@"🚩 🚪 Login room failed");
    }
    else if(reason == ZegoRoomStateChangedReasonKickOut)
    {
        ZGLogInfo(@"🚩 🚪 Kick out of room");
    }
    else if(reason == ZegoRoomStateChangedReasonReconnecting)
    {
        ZGLogInfo(@"🚩 🚪 Reconnecting room");
    }
    else if(reason == ZegoRoomStateChangedReasonReconnectFailed)
    {
        ZGLogInfo(@"🚩 🚪 Reconnect room failed");
    }
    else if(reason == ZegoRoomStateChangedReasonReconnected)
    {
        ZGLogInfo(@"🚩 🚪 Reconnect room success");
    }
    else if(reason == ZegoRoomStateChangedReasonLogout)
    {
        // After logout room, the preview will stop. You need to re-start preview.
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
    }
    else
    {
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
                break;

            case ZegoPublisherStatePublishRequesting:
                [self appendLog:@"🚩 📤 Requesting publish stream"];
                break;

            case ZegoPublisherStateNoPublish:
                [self appendLog:@"🚩 📤 No publish stream"];
                break;
        }
    }
    self.publisherState = state;
}

- (void)onPublisherCapturedVideoFirstFrame:(ZegoPublishChannel)channel {
    [self appendLog:@"🚩 📷 onPublisherCapturedVideoFirstFrame"];
    
    CGFloat maxZoomFactor = [[ZegoExpressEngine sharedEngine] getCameraMaxZoomFactor];
    self.zoomFactorSlider.maximumValue = MIN(maxZoomFactor, 5);
    self.maxZoomFactorLabel.text = [NSString stringWithFormat:@"max: %.1f", self.zoomFactorSlider.maximumValue];

    BOOL isSupported = [[ZegoExpressEngine sharedEngine] isCameraFocusSupported:ZegoPublishChannelMain];
    self.focusMode.enabled = isSupported;
    if (isSupported) {
        self.supportFocusLabel.text = @"Support Focus: 🟢";
    } else {
        self.supportFocusLabel.text = @"Support Focus: 🔴";
    }
}

@end

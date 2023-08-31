//
//  ZGEffectsBeautyViewController.m
//  ZegoExpressExample
//
//  Created by zego on 2021/12/13.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGEffectsBeautyViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGEffectsBeautyViewController () <ZegoEventHandler>

@property (strong, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UILabel *roomInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;

@property (weak, nonatomic) IBOutlet UITextField *encodeWidthTF;
@property (weak, nonatomic) IBOutlet UITextField *encodeHeightTF;
@property (weak, nonatomic) IBOutlet UITextField *fpsTF;
@property (weak, nonatomic) IBOutlet UITextField *bitrateTF;

@property (weak, nonatomic) IBOutlet UISlider *whiteSlider;
@property (weak, nonatomic) IBOutlet UISlider *rosySlider;
@property (weak, nonatomic) IBOutlet UISlider *smoothSlider;
@property (weak, nonatomic) IBOutlet UISlider *sharpenSlider;

@property (weak, nonatomic) IBOutlet UILabel *whitenIntensityLabel;
@property (weak, nonatomic) IBOutlet UILabel *rosyIntensityLabel;
@property (weak, nonatomic) IBOutlet UILabel *smoothIntensityLabel;
@property (weak, nonatomic) IBOutlet UILabel *sharpenIntensityLabel;


@property (weak, nonatomic) IBOutlet UIButton *streamButton;

@property (weak, nonatomic) IBOutlet UILabel *beautyLabel;
@property (weak, nonatomic) IBOutlet UIButton *beautyJumpButton;

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;

@property (nonatomic) ZegoPublisherState publisherState;

@property (nonatomic, strong) ZegoEffectsBeautyParam *beautyParam;
@property (nonatomic, strong) ZegoVideoConfig *videoConfig;

@end

@implementation ZGEffectsBeautyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0024";
    self.streamID = @"0024";
    
    self.beautyParam = [[ZegoEffectsBeautyParam alloc] init];
    self.videoConfig = [ZegoVideoConfig defaultConfig];
    
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
    
    // Initialize the Effects Beauty environment before logging in to the room
    [self appendLog:@"Enable effects beauty environment"];
    [[ZegoExpressEngine sharedEngine] startEffectsEnv];
    
    // LoginRoom
    [self appendLog:[NSString stringWithFormat:@"🚪Login Room roomID: %@", self.roomID]];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:self.userID]];
}

- (void)setupUI {
    self.roomInfoLabel.text = [NSString stringWithFormat:@"UserID: %@  RoomID:%@  StreamID:%@", self.userID, self.roomID, self.streamID];
    
    [self.streamButton setTitle:@"Start Publishing" forState:UIControlStateNormal];
    [self.streamButton setTitle:@"Stop Publishing" forState:UIControlStateSelected];

    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];
    
    self.whiteSlider.value = 50;
    self.rosySlider.value = 50;
    self.smoothSlider.value = 50;
    self.sharpenSlider.value = 50;
    
    [self.beautyJumpButton setTitle:NSLocalizedString(@"BeautifyDocPageButtonTitle", nil) forState:UIControlStateNormal];
    self.beautyLabel.text = NSLocalizedString(@"BeautifyDocPageNote", nil);
}

- (void)dealloc {

    ZGLogInfo(@"🚪 Stop effects environment");
    [[ZegoExpressEngine sharedEngine] stopEffectsEnv];
    
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


- (IBAction)onPublishingButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.streamID]];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
    } else {
        // Start preview
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
        previewCanvas.viewMode = ZegoViewModeAspectFill;
        [self appendLog:@"🔌 Start preview"];
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        
        // Start publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.streamID]];
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onEncodeWidthEditing:(UITextField *)sender {
    [self appendLog:[NSString stringWithFormat:@"📤 Set encode resolution width: %d", [sender.text intValue]]];
    
    CGSize size = self.videoConfig.encodeResolution;
    size.width = [sender.text intValue];
    [[ZegoExpressEngine sharedEngine] setVideoConfig:self.videoConfig];
}

- (IBAction)onEncodeHeightEditing:(UITextField *)sender {
    [self appendLog:[NSString stringWithFormat:@"📤 Set encode resolution Height: %d", [sender.text intValue]]];
    
    CGSize size = self.videoConfig.encodeResolution;
    size.height = [sender.text intValue];
    [[ZegoExpressEngine sharedEngine] setVideoConfig:self.videoConfig];
}

- (IBAction)onFPSEditing:(UITextField *)sender {
    [self appendLog:[NSString stringWithFormat:@"📤 Set video fps: %d", [sender.text intValue]]];
    
    self.videoConfig.fps = [sender.text intValue];
    [[ZegoExpressEngine sharedEngine] setVideoConfig:self.videoConfig];
}

- (IBAction)onBitrateEditing:(UITextField *)sender {
    [self appendLog:[NSString stringWithFormat:@"📤 Set video bitrate: %d", [sender.text intValue]]];
    
    self.videoConfig.bitrate = [sender.text intValue];
    [[ZegoExpressEngine sharedEngine] setVideoConfig:self.videoConfig];
}


- (IBAction)onBeautyEnableSwitch:(UISwitch *)sender {
    [self appendLog:[NSString stringWithFormat:@"📤 Enable effects beauty: %d", sender.isOn]];
    [[ZegoExpressEngine sharedEngine] enableEffectsBeauty:sender.isOn];
}

- (IBAction)onBeautyWhitenSlider:(UISlider *)sender {
    
    self.whitenIntensityLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
    self.beautyParam.whitenIntensity = (int)sender.value;
    [[ZegoExpressEngine sharedEngine] setEffectsBeautyParam:self.beautyParam];
}

- (IBAction)onBeautyRosySlider:(UISlider *)sender {
    
    self.rosyIntensityLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
    self.beautyParam.rosyIntensity = (int)sender.value;
    [[ZegoExpressEngine sharedEngine] setEffectsBeautyParam:self.beautyParam];
}

- (IBAction)onBeautySmoothSlider:(UISlider *)sender {
    
    self.smoothIntensityLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
    self.beautyParam.smoothIntensity = (int)sender.value;
    [[ZegoExpressEngine sharedEngine] setEffectsBeautyParam:self.beautyParam];
}

- (IBAction)onBeautySharpenSlider:(UISlider *)sender {
    
    self.sharpenIntensityLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
    self.beautyParam.sharpenIntensity = (int)sender.value;
    [[ZegoExpressEngine sharedEngine] setEffectsBeautyParam:self.beautyParam];
}

- (IBAction)jumpToAIPage:(id)sender {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://doc-zh.zego.im/article/11256"]]];
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


@end

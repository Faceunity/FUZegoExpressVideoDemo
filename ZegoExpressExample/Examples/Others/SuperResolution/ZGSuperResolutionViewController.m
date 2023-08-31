//
//  UIViewController+ZGSuperResolutionViewController.m
//  ZegoExpressExample
//
//  Created by zego on 2022/10/11.
//  Copyright © 2022 Zego. All rights reserved.
//

#import "ZGSuperResolutionViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGSuperResolutionViewController () <ZegoEventHandler>

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *stream1ID;
@property (nonatomic, copy) NSString *stream2ID;
@property (nonatomic, copy) NSString *srStream1ID;
@property (nonatomic, copy) NSString *srStream2ID;

@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UILabel *roomInfoLabel;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *play1View;
@property (weak, nonatomic) IBOutlet UIView *play2View;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *superResolution1StateLabel;
@property (weak, nonatomic) IBOutlet UITextField *play1StreamIDText;
@property (weak, nonatomic) IBOutlet UITextField *superResolution1StreamIDText;
@property (weak, nonatomic) IBOutlet UIButton *play1Button;
@property (weak, nonatomic) IBOutlet UILabel *player1VideoSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *superResolution2StateLabel;
@property (weak, nonatomic) IBOutlet UITextField *play2StreamIDText;
@property (weak, nonatomic) IBOutlet UITextField *superResolution2StreamIDText;
@property (weak, nonatomic) IBOutlet UIButton *play2Button;
@property (weak, nonatomic) IBOutlet UILabel *player2VideoSizeLabel;
@property (weak, nonatomic) IBOutlet UISwitch *enableVideoSRSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *enableVideoSRSwitch2;
@property (weak, nonatomic) IBOutlet UIButton *initalizeSRButton;
@property (weak, nonatomic) IBOutlet UIButton *uninitSRButton;



@end

@implementation ZGSuperResolutionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0036";
    self.stream1ID = @"0036_1";
    self.stream2ID = @"0036_2";
    self.srStream1ID = @"0036_1";
    self.srStream2ID = @"0036_2";
    
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
    self.roomInfoLabel.text = [NSString stringWithFormat:@"UserID: %@  RoomID:%@", self.userID, self.roomID];
    
    [self.play1Button setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.play1Button setTitle:@"Stop Playing" forState:UIControlStateSelected];
    [self.play2Button setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.play2Button setTitle:@"Stop Playing" forState:UIControlStateSelected];

    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];
    self.superResolution1StateLabel.text = @"Off";
    self.play1StreamIDText.text = self.stream1ID;
    self.superResolution1StreamIDText.text = self.srStream1ID;

    self.superResolution2StateLabel.text = @"Off";
    self.play2StreamIDText.text = self.stream2ID;
    self.superResolution2StreamIDText.text = self.srStream2ID;
    
    [self.initalizeSRButton setTitle:@"Init SR" forState:UIControlStateSelected];
    [self.uninitSRButton setTitle:@"Uninit SR" forState:UIControlStateSelected];
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

- (IBAction)onPlaying1ButtonTapped:(UIButton *)sender {
    if(sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop playing stream. streamID: %@", self.stream1ID]];
        [[ZegoExpressEngine sharedEngine]stopPlayingStream:self.stream1ID];
        self.stream1ID = @"";
        self.srStream1ID = @"";
        self.player1VideoSizeLabel.text = @"";
        self.superResolution1StateLabel.text = @"";
        if(self.enableVideoSRSwitch.isOn){
            [self.enableVideoSRSwitch setOn:NO];
        }
    }
    else {
        self.stream1ID = self.play1StreamIDText.text;
        // Start playing
        [self appendLog:[NSString stringWithFormat:@"📤 Start playing stream. streamID: %@", self.stream1ID]];
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.play1View];
        ZegoPlayerConfig *playerConfig = [[ZegoPlayerConfig alloc]init];
        playerConfig.resourceMode = ZegoStreamResourceModeOnlyRTC;
        [[ZegoExpressEngine sharedEngine]startPlayingStream:self.stream1ID canvas:playCanvas config:playerConfig];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onPlaying2ButtonTapped:(UIButton *)sender {
    if(sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop playing stream. streamID: %@", self.stream2ID]];
        [[ZegoExpressEngine sharedEngine]stopPlayingStream:self.stream2ID];
        self.stream2ID = @"";
        self.srStream2ID = @"";
        self.player2VideoSizeLabel.text = @"";
        self.superResolution2StateLabel.text = @"";
        if(self.enableVideoSRSwitch2.isOn){
            [self.enableVideoSRSwitch2 setOn:NO];
        }
    }
    else {
        self.stream2ID = self.play2StreamIDText.text;
        // Start playing
        [self appendLog:[NSString stringWithFormat:@"📤 Start playing stream. streamID: %@", self.stream2ID]];
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.play2View];
        ZegoPlayerConfig *playerConfig = [[ZegoPlayerConfig alloc]init];
        playerConfig.resourceMode = ZegoStreamResourceModeOnlyRTC;
        [[ZegoExpressEngine sharedEngine]startPlayingStream:self.stream2ID canvas:playCanvas config:playerConfig];
    }
    sender.selected = !sender.isSelected;
}
- (IBAction)onSwitchSR1:(UISwitch *)sender {
    if(sender.isOn){
        self.srStream1ID = self.superResolution1StreamIDText.text;
        [self appendLog:[NSString stringWithFormat:@"Enable super resolution.streamID:%@, enable:%d", self.srStream1ID, sender.isOn]];
    }else{
        [self appendLog:[NSString stringWithFormat:@"Enable super resolution.streamID:%@, enable:%d", self.srStream1ID, sender.isOn]];
    }
    [[ZegoExpressEngine sharedEngine]enableVideoSuperResolution:self.srStream1ID enable:sender.isOn];
}

- (IBAction)onSwitchSR2:(UISwitch *)sender {
    if(sender.isOn){
        self.srStream2ID = self.superResolution2StreamIDText.text;
        [self appendLog:[NSString stringWithFormat:@"Enable super resolution.streamID:%@, enable:%d", self.srStream2ID, sender.isOn]];
    }else{
        [self appendLog:[NSString stringWithFormat:@"Enable super resolution.streamID:%@, enable:%d", self.srStream2ID, sender.isOn]];
    }
    [[ZegoExpressEngine sharedEngine]enableVideoSuperResolution:self.srStream2ID enable:sender.isOn];
}
    
- (IBAction)onInitSRTapped:(UIButton *)sender {
    ZGLogInfo(@"initVideoSuperResolution");
    [[ZegoExpressEngine  sharedEngine]initVideoSuperResolution];
    
    sender.selected = YES;
    self.uninitSRButton.selected = NO;
}

- (IBAction)onUninitSRButtonTapped:(UIButton *)sender {
    ZGLogInfo(@"uninitVideoSuperResolution");
    [[ZegoExpressEngine  sharedEngine]uninitVideoSuperResolution];
    
    sender.selected = YES;
    self.initalizeSRButton.selected = NO;
    self.superResolution1StateLabel.text = @"Off";
    self.superResolution2StateLabel.text = @"Off";
    [self.enableVideoSRSwitch setOn:NO];
    [self.enableVideoSRSwitch2 setOn:NO];
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
//    self.publisherState = state;
}

-(void)onPlayerVideoSizeChanged:(CGSize)size streamID:(NSString *)streamID {
    [self appendLog:[NSString stringWithFormat:@"onPlayerVideoSizeChanged. size:%dx%d, streamID:%@", (int)size.width, (int)size.height, streamID]];
    
    if([streamID isEqualToString:self.stream1ID]){
        self.player1VideoSizeLabel.text = [NSString stringWithFormat:@"%dx%d", (int)size.width, (int)size.height];
    }else if([streamID isEqualToString:self.stream2ID]){
        self.player2VideoSizeLabel.text = [NSString stringWithFormat:@"%dx%d", (int)size.width, (int)size.height];
    }
}

-(void)onPlayerVideoSuperResolutionUpdate:(NSString *)streamID state:(ZegoSuperResolutionState)state errorCode:(int)errorCode {
    [self appendLog:[NSString stringWithFormat:@"onPlayerVideoSuperResolutionUpdate. streamID:%@, state:%d, errorCode:%d", streamID, (int)state, errorCode]];
    NSString *state_str;
    if(state == ZegoSuperResolutionStateOn)
    {
        state_str = @"On";
    }
    else
    {
        state_str = @"Off";
    }
    
    if([streamID isEqualToString:self.stream1ID]){
        self.superResolution1StateLabel.text = state_str;
    }else if([streamID isEqualToString:self.stream2ID]){
        self.superResolution2StateLabel.text = state_str;
    }
    

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

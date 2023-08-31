//
//  ZGQuickStartViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/15.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGQuickStartViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGQuickStartViewController () <ZegoEventHandler>

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;
@property (weak, nonatomic) IBOutlet UILabel *playStreamLabel;


// Preview and Play View
@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UIView *remotePlayView;

// CreateEngine
@property (weak, nonatomic) IBOutlet UILabel *appIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *createEngineButton;

// LoginRoom
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginRoomButton;

// PublishStream
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;

// PlayStream
@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;

@end

@implementation ZGQuickStartViewController

#pragma mark - Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomID = @"0001";
    self.playStreamIDTextField.text = @"0001";
    self.publishStreamIDTextField.text = @"0001";
    self.userID = [ZGUserIDHelper userID];
    
    // Print SDK and demo version
    [self appendLog:[NSString stringWithFormat:@"🌞 SDK Version: %@", [ZegoExpressEngine getVersion]]];
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    [self appendLog:[NSString stringWithFormat:@"🌞 Demo Version: %@.%@", [bundleInfo objectForKey:@"CFBundleShortVersionString"], [bundleInfo objectForKey:@"CFBundleVersion"]]];
    
    [self setupUI];
}

- (void)setupUI {
    self.navigationItem.title = @"QuickStart";
    
    self.previewLabel.text = NSLocalizedString(@"PreviewLabel", nil);
    self.playStreamLabel.text = NSLocalizedString(@"PlayStreamLabel", nil);
    
    self.appIDLabel.text = [NSString stringWithFormat:@"AppID: %u", [KeyCenter appID]];
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.userIDLabel.text = [NSString stringWithFormat:@"UserID: %@", self.userID];
}

#pragma mark - Step 1: CreateEngine

- (IBAction)createEngineButtonClick:(UIButton *)sender {
    
    // Create ZegoExpressEngine and set self as a delegate (ZegoEventHandler)
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    
    // Here we use the high quality video call scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    profile.scenario = ZegoScenarioHighQualityVideoCall;

    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
    
    // Print log
    [self appendLog:@"🚀 Create ZegoExpressEngine"];
    
    // Add a flag to the button for successful operation
    [self.createEngineButton setTitle:@"✅ CreateEngine" forState:UIControlStateNormal];
}

#pragma mark - Step 2: LoginRoom

- (IBAction)loginRoomButtonClick:(UIButton *)sender {
    // Instantiate a ZegoUser object
    ZegoUser *user = [ZegoUser userWithUserID:self.userID];
  
    // Login room
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user];
    
    // Print log
    [self appendLog:@"🚪 Start login room"];
}

#pragma mark - Step 3: StartPublishing

- (IBAction)startPublishingButtonClick:(UIButton *)sender {
    // Instantiate a ZegoCanvas for local preview
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
    previewCanvas.viewMode = ZegoViewModeAspectFill;
    
    // Start preview
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
    
    NSString *publishStreamID = self.publishStreamIDTextField.text;
    
    [[ZegoExpressEngine sharedEngine] startPublishingStream:publishStreamID];
    
    // Print log
    [self appendLog:@"📤 Start publishing stream"];
}

#pragma mark - Step 4: StartPlaying

- (IBAction)startPlayingButtonClick:(UIButton *)sender {
    // Instantiate a ZegoCanvas for play view
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
    playCanvas.viewMode = ZegoViewModeAspectFill;
    
    NSString *playStreamID = self.playStreamIDTextField.text;
    
    [[ZegoExpressEngine sharedEngine] startPlayingStream:playStreamID canvas:playCanvas];
    
    // Print log
    [self appendLog:@"📥 Start playing stream"];
}

#pragma mark - Exit

- (IBAction)destroyEngineButtonClick:(UIButton *)sender {
    [self.createEngineButton setTitle:@"CreateEngine" forState:UIControlStateNormal];
    [self.loginRoomButton setTitle:@"LoginRoom" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"StartPublishing" forState:UIControlStateNormal];
    [self.startPlayingButton setTitle:@"StartPlaying" forState:UIControlStateNormal];
    
    // Logout room will automatically stop publishing/playing stream.
    //  [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    //
    // Destroy engine will automatically logout room and stop publishing/playing stream.
    [ZegoExpressEngine destroyEngine:nil];
    
    // Print log
    [self appendLog:@"🏳️ Destroy ZegoExpressEngine"];
}

- (void)dealloc {
    // Logout room will automatically stop publishing/playing stream.
//    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
            
    // Can destroy the engine when you don't need audio and video calls
    //
    // Destroy engine will automatically logout room and stop publishing/playing stream.
    [ZegoExpressEngine destroyEngine:nil];
}

#pragma mark - ZegoEventHandler Delegate

/// Room status change notification
- (void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if(reason == ZegoRoomStateChangedReasonLogined)
    {
        [self appendLog:@"🚩 🚪 Login room success"];
        
        // Add a flag to the button for successful operation
        [self.loginRoomButton setTitle:@"✅ LoginRoom" forState:UIControlStateNormal];
    }
    else if(reason == ZegoRoomStateChangedReasonLoginFailed)
    {
        [self appendLog:@"🚩 ❌ 🚪 Login room fail"];
        
        [self.loginRoomButton setTitle:@"❌ LoginRoom" forState:UIControlStateNormal];
    }
    else if(reason == ZegoRoomStateChangedReasonKickOut)
    {
        [self appendLog:@"🚩 ❌ 🚪 Kick out of room"];
        
        [self.loginRoomButton setTitle:@"❌ LoginRoom" forState:UIControlStateNormal];
    }
    else if(reason == ZegoRoomStateChangedReasonReconnectFailed)
    {
        [self appendLog:@"🚩 ❌ 🚪 Reconnect failed"];
        
        [self.loginRoomButton setTitle:@"❌ LoginRoom" forState:UIControlStateNormal];
    }
    else
    {
        
    }
}

/// Publish stream state callback
- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (state == ZegoPublisherStatePublishing && errorCode == 0) {
        [self appendLog:@"🚩 📤 Publishing stream success"];
        
        // Add a flag to the button for successful operation
        [self.startPublishingButton setTitle:@"✅ StartPublishing" forState:UIControlStateNormal];
    }
    
    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 📤 Publishing stream fail"];
        
        [self.startPublishingButton setTitle:@"❌ StartPublishing" forState:UIControlStateNormal];
    }
}

/// Play stream state callback
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (state == ZegoPlayerStatePlaying && errorCode == 0) {
        [self appendLog:@"🚩 📥 Playing stream success"];
        
        // Add a flag to the button for successful operation
        [self.startPlayingButton setTitle:@"✅ StartPlaying" forState:UIControlStateNormal];
    }
    
    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 📥 Playing stream fail"];
        
        [self.startPlayingButton setTitle:@"❌ StartPlaying" forState:UIControlStateNormal];
    }
}

#pragma mark - Helper Methods

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

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

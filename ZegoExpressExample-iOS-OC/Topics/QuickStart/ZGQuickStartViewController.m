//
//  ZGQuickStartViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/15.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_QuickStart

#import "ZGQuickStartViewController.h"
#import "ZGKeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGQuickStartViewController () <ZegoEventHandler>

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

// Preview and Play View
@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UIView *remotePlayView;

// CreateEngine
@property (nonatomic, assign) BOOL isTestEnv;
@property (weak, nonatomic) IBOutlet UILabel *appIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *isTestEnvLabel;
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
    
    self.isTestEnv = YES;
    self.roomID = @"QuickStartRoom-1";
    self.userID = [ZGUserIDHelper userID];
    
    // Print SDK version
    [self appendLog:[NSString stringWithFormat:@"🌞 SDK Version: %@", [ZegoExpressEngine getVersion]]];
    
    [self setupUI];
}

- (void)setupUI {
    self.navigationItem.title = @"Quick Start";
    
    self.appIDLabel.text = [NSString stringWithFormat:@"AppID: %u", [ZGKeyCenter appID]];
    self.isTestEnvLabel.text = [NSString stringWithFormat:@"isTestEnv: %@", self.isTestEnv ? @"YES" : @"NO"];
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.userIDLabel.text = [NSString stringWithFormat:@"UserID: %@", self.userID];
}

#pragma mark - Step 1: CreateEngine

- (IBAction)createEngineButtonClick:(UIButton *)sender {
    
    unsigned int appID = [ZGKeyCenter appID];
    NSString *appSign = [ZGKeyCenter appSign];
    
    // Create ZegoExpressEngine and set self as a delegate (ZegoEventHandler)
    [ZegoExpressEngine createEngineWithAppID:appID appSign:appSign isTestEnv:self.isTestEnv scenario:ZegoScenarioGeneral eventHandler:self];
    
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
    
    // If streamID is empty @"", SDK will pop up an UIAlertController if "isTestEnv" is set to YES
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
    
    // If streamID is empty @"", SDK will pop up an UIAlertController if "isTestEnv" is set to YES
    [[ZegoExpressEngine sharedEngine] startPlayingStream:playStreamID canvas:playCanvas];
    
    // Print log
    [self appendLog:@"📥 Strat playing stream"];
}

#pragma mark - Exit

- (IBAction)destroyEngineButtonClick:(UIButton *)sender {
    [self.createEngineButton setTitle:@"CreateEngine" forState:UIControlStateNormal];
    [self.loginRoomButton setTitle:@"LoginRoom" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"StartPublishing" forState:UIControlStateNormal];
    [self.startPlayingButton setTitle:@"StartPlaying" forState:UIControlStateNormal];
    
    // Logout room will automatically stop publishing/playing stream.
//    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
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
- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (state == ZegoRoomStateConnected && errorCode == 0) {
        [self appendLog:@"🚩 🚪 Login room success"];
        
        // Add a flag to the button for successful operation
        [self.loginRoomButton setTitle:@"✅ LoginRoom" forState:UIControlStateNormal];
    }
    
    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 🚪 Login room fail"];
        
        [self.loginRoomButton setTitle:@"❌ LoginRoom" forState:UIControlStateNormal];
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

#endif // _Module_QuickStart

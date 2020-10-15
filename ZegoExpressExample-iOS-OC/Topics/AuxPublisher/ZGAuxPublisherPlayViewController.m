//
//  ZGAuxPublisherPlayViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/2/27.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_AuxPublisher

#import "ZGAuxPublisherPlayViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NSString* const ZGAuxPublisherPlayVCKey_firstStreamID = @"kFirstStreamID";
NSString* const ZGAuxPublisherPlayVCKey_secondStreamID = @"kSecondStreamID";

@interface ZGAuxPublisherPlayViewController () <ZegoEventHandler>

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *firstStreamID;
@property (nonatomic, copy) NSString *secondStreamID;

@property (nonatomic, assign) ZegoRoomState roomState;
@property (nonatomic, assign) ZegoPlayerState firstStreamPlayerState;
@property (nonatomic, assign) ZegoPlayerState secondStreamPlayerState;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstStreamStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondStreamStateLabel;

@property (weak, nonatomic) IBOutlet UIView *firstStreamPlayView;
@property (weak, nonatomic) IBOutlet UIView *secondStreamPlayView;

@property (weak, nonatomic) IBOutlet UITextField *firstStreamIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondStreamIDTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *firstStreamStartButton;
@property (weak, nonatomic) IBOutlet UIButton *secondStreamStartButton;

@end

@implementation ZGAuxPublisherPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomID = @"AuxPublisherRoom-1";
    
    self.firstStreamID = [self savedValueForKey:ZGAuxPublisherPlayVCKey_firstStreamID];
    self.secondStreamID = [self savedValueForKey:ZGAuxPublisherPlayVCKey_secondStreamID];
    
    [self setupUI];
    [self createEngineAndLoginRoom];
}

#pragma mark - Setup

- (void)setupUI {
    self.title = @"AuxPublisher";
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", _roomID];
    self.roomStateLabel.text = @"Not Connected 🔴";
    
    self.firstStreamStateLabel.text = @"🔴 No Play";
    self.firstStreamStateLabel.textColor = [UIColor whiteColor];
    
    self.secondStreamStateLabel.text = @"🔴 No Play";
    self.secondStreamStateLabel.textColor = [UIColor whiteColor];
    
    [self hidePlayButtonAndTextField:YES];
    
    self.firstStreamIDTextField.text = self.firstStreamID;
    self.secondStreamIDTextField.text = self.secondStreamID;
}

- (void)hidePlayButtonAndTextField:(BOOL)hide {
    self.firstStreamStartButton.hidden = hide;
    self.secondStreamStartButton.hidden = hide;
    self.firstStreamIDTextField.hidden = hide;
    self.secondStreamIDTextField.hidden = hide;
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)createEngineAndLoginRoom {
    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];
    
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    
    [ZegoExpressEngine createEngineWithAppID:(unsigned int)appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];
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
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user config:[ZegoRoomConfig defaultConfig]];
}

- (void)logoutRoom {
    ZGLogInfo(@"🚪 Logout room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
}

#pragma mark - Start/Stop Playing First Stream

- (IBAction)firstStreamStartButtonClick:(UIButton *)sender {
    switch (self.firstStreamPlayerState) {
        case ZegoPlayerStatePlaying:
            [self stopPlayingFirstSream];
            break;
        case ZegoPlayerStateNoPlay:
            [self startPlayingFirstStream];
            break;
        case ZegoPlayerStatePlayRequesting:
            break;
    }
}

- (void)startPlayingFirstStream {
    self.firstStreamID = self.firstStreamIDTextField.text;
    [self saveValue:self.firstStreamID forKey:ZGAuxPublisherPlayVCKey_firstStreamID];
    
    ZGLogInfo(@"📥 Start playing stream. streamID: %@", self.firstStreamID);
    ZegoCanvas *firstPlayCanvas = [ZegoCanvas canvasWithView:self.firstStreamPlayView];
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.firstStreamID canvas:firstPlayCanvas];
}

- (void)stopPlayingFirstSream {
    ZGLogInfo(@"📥 Stop playing stream");
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.firstStreamID];
}

#pragma mark - Start/Stop Playing Second Stream

- (IBAction)secondStreamStartButtonClick:(UIButton *)sender {
    switch (self.secondStreamPlayerState) {
        case ZegoPlayerStatePlaying:
            [self stopPlayingSecondStream];
            break;
        case ZegoPlayerStateNoPlay:
            [self startPlayingSecondStream];
            break;
        case ZegoPlayerStatePlayRequesting:
            break;
    }
}

- (void)startPlayingSecondStream {
    self.secondStreamID = self.secondStreamIDTextField.text;
    [self saveValue:self.secondStreamID forKey:ZGAuxPublisherPlayVCKey_secondStreamID];
    
    ZGLogInfo(@"📥 Start playing stream. streamID: %@", self.secondStreamID);
    ZegoCanvas *secondPlayCanvas = [ZegoCanvas canvasWithView:self.secondStreamPlayView];
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.secondStreamID canvas:secondPlayCanvas];
}

- (void)stopPlayingSecondStream {
    ZGLogInfo(@"📥 Stop playing stream");
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.secondStreamID];
}

#pragma mark - Exit

- (void)dealloc {
    ZGLogInfo(@"🚪 Exit the room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

#pragma mark - ZegoEventHandler

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    self.roomState = state;
    if (errorCode != 0) {
        ZGLogError(@"🚩 ❌ 🚪 Room state error, errorCode: %d", errorCode);
    } else {
        if (state == ZegoRoomStateConnected) {
            ZGLogInfo(@"🚩 🚪 Login room success");
            self.roomStateLabel.text = @"Connected 🟢";
            [self.loginRoomButton setTitle:@"Logout Room" forState:UIControlStateNormal];
            [self hidePlayButtonAndTextField:NO];
        } else if (state == ZegoRoomStateConnecting) {
            ZGLogInfo(@"🚩 🚪 Requesting login room");
            self.roomStateLabel.text = @"Connecting 🟡";
            [self.loginRoomButton setTitle:@"Connecting" forState:UIControlStateNormal];
        } else if (state == ZegoRoomStateDisconnected) {
            ZGLogInfo(@"🚩 🚪 Logout room");
            self.roomStateLabel.text = @"Not Connected 🔴";
            [self.loginRoomButton setTitle:@"Login Room" forState:UIControlStateNormal];
            [self hidePlayButtonAndTextField:YES];
        }
    }
}

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📥 Player State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
    
    if (streamID == self.firstStreamID) {
        self.firstStreamPlayerState = state;
        
        switch (state) {
            case ZegoPlayerStateNoPlay:
                self.firstStreamStateLabel.text = @"🔴 No Play";
                [self.firstStreamStartButton setTitle:@"Start Play ①" forState:UIControlStateNormal];
                break;
            case ZegoPlayerStatePlayRequesting:
                self.firstStreamStateLabel.text = @"🟡 Requesting";
                [self.firstStreamStartButton setTitle:@"Requesting" forState:UIControlStateNormal];
                break;
            case ZegoPlayerStatePlaying:
                self.firstStreamStateLabel.text = @"🟢 Playing";
                [self.firstStreamStartButton setTitle:@"Stop Play ①" forState:UIControlStateNormal];
                break;
        }
    } else if (streamID == self.secondStreamID) {
        self.secondStreamPlayerState = state;
        
        switch (state) {
            case ZegoPlayerStateNoPlay:
                self.secondStreamStateLabel.text = @"🔴 No Play";
                [self.secondStreamStartButton setTitle:@"Start Play ②" forState:UIControlStateNormal];
                break;
            case ZegoPlayerStatePlayRequesting:
                self.secondStreamStateLabel.text = @"🟡 Requesting";
                [self.secondStreamStartButton setTitle:@"Requesting" forState:UIControlStateNormal];
                break;
            case ZegoPlayerStatePlaying:
                self.secondStreamStateLabel.text = @"🟢 Playing";
                [self.secondStreamStartButton setTitle:@"Stop Play ②" forState:UIControlStateNormal];
                break;
        }
    }
}

@end

#endif

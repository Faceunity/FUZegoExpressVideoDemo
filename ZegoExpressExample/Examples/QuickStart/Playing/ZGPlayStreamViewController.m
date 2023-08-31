//
//  ZGPlayStreamViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGPlayStreamViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"

NSString* const ZGPlayStreamTopicRoomID = @"ZGPlayStreamTopicRoomID";
NSString* const ZGPlayStreamTopicStreamID = @"ZGPlayStreamTopicStreamID";
ZegoPlayerConfig *playerConfig;

@interface ZGPlayStreamViewController () <ZegoEventHandler, UITextFieldDelegate, UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *viewModeButton;
@property (weak, nonatomic) IBOutlet UIButton *resourceModeButton;

@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIView *startPlayConfigView;

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;

@property (weak, nonatomic) IBOutlet UIButton *startLiveButton;
@property (weak, nonatomic) IBOutlet UIButton *stopLiveButton;

@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomIDAndStreamIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *playResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *playQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;
@property (nonatomic) BOOL isPlay;

@end

@implementation ZGPlayStreamViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PlayStream" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGPlayStreamViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [self createEngine];

    self.roomIDTextField.text = @"0003";
    self.streamIDTextField.text = @"0003";
    // This demonstrates simply using the device name as the userID. In actual use, you can set the business-related userID as needed.
    self.userID = [ZGUserIDHelper userID];
    
    self.userIDLabel.text = [NSString stringWithFormat:@"UserID: %@", self.userID];

    self.enableHardwareDecoder = NO;
    self.mutePlayStreamVideo = NO;
    self.mutePlayStreamAudio = NO;
    self.playVolume = 100;
    self.resourceMode = ZegoStreamResourceModeDefault;
    self.isPlay = NO;
    
    playerConfig = [[ZegoPlayerConfig alloc] init];
    playerConfig.resourceMode = ZegoStreamResourceModeOnlyRTC;
}

- (void)dealloc {
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)setupUI {
    self.navigationItem.title = @"Play Stream";

    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];

    self.roomStateLabel.text = @"🔴 RoomState: Disconnected";
    self.roomStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.roomStateLabel.textColor = [UIColor whiteColor];

    self.playerStateLabel.text = @"🔴 PlayerState: NoPlay";
    self.playerStateLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.playerStateLabel.textColor = [UIColor whiteColor];

    self.playResolutionLabel.text = @"";
    self.playResolutionLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.playResolutionLabel.textColor = [UIColor whiteColor];

    self.playQualityLabel.text = @"";
    self.playQualityLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.playQualityLabel.textColor = [UIColor whiteColor];

    self.stopLiveButton.alpha = 0;
    self.startPlayConfigView.alpha = 1;

    self.roomIDTextField.delegate = self;

    self.streamIDTextField.delegate = self;

    self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: | StreamID: "];
    self.roomIDAndStreamIDLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.roomIDAndStreamIDLabel.textColor = [UIColor whiteColor];

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
    [self startPlayingStream];
}

- (IBAction)stopLiveButtonClick:(id)sender {
    [self stopPlayingStream];
}

- (IBAction)onViewModeButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *aspectFit = [UIAlertAction actionWithTitle:@"AspectFit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];
        playCanvas.viewMode = ZegoViewModeAspectFit;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamIDTextField.text canvas:playCanvas];
        [self.viewModeButton setTitle:@"AspectFit" forState:UIControlStateNormal];

    }];
    UIAlertAction *aspectFill = [UIAlertAction actionWithTitle:@"AspectFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];
        playCanvas.viewMode = ZegoViewModeAspectFill;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamIDTextField.text canvas:playCanvas];
        [self.viewModeButton setTitle:@"AspectFill" forState:UIControlStateNormal];
    }];
    UIAlertAction *scaleToFill = [UIAlertAction actionWithTitle:@"ScaleToFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];
        playCanvas.viewMode = ZegoViewModeScaleToFill;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamIDTextField.text canvas:playCanvas];
        [self.viewModeButton setTitle:@"ScaleToFill" forState:UIControlStateNormal];
    }];
    [alertController addAction:cancel];
    [alertController addAction:aspectFit];
    [alertController addAction:aspectFill];
    [alertController addAction:scaleToFill];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onResourceModeButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Default" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        playerConfig.resourceMode = ZegoStreamResourceModeDefault;
        [self.resourceModeButton setTitle:@"Default" forState:UIControlStateNormal];

    }];
    UIAlertAction *rtcAction = [UIAlertAction actionWithTitle:@"RTC" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        playerConfig.resourceMode = ZegoStreamResourceModeOnlyRTC;
        [self.resourceModeButton setTitle:@"RTC" forState:UIControlStateNormal];
    }];
    UIAlertAction *l3Action = [UIAlertAction actionWithTitle:@"L3" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        playerConfig.resourceMode = ZegoStreamResourceModeOnlyL3;
        [self.resourceModeButton setTitle:@"L3" forState:UIControlStateNormal];
    }];
    UIAlertAction *cdnAction = [UIAlertAction actionWithTitle:@"CDN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        playerConfig.resourceMode = ZegoStreamResourceModeOnlyCDN;
        [self.resourceModeButton setTitle:@"CDN" forState:UIControlStateNormal];
    }];
    UIAlertAction *cdnPlusAction = [UIAlertAction actionWithTitle:@"CDN_PLUS" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        playerConfig.resourceMode = ZegoStreamResourceModeCDNPlus;
        [self.resourceModeButton setTitle:@"CDN_PLUS" forState:UIControlStateNormal];
    }];
    [alertController addAction:cancel];
    [alertController addAction:rtcAction];
    [alertController addAction:defaultAction];
    [alertController addAction:l3Action];
    [alertController addAction:cdnAction];
    [alertController addAction:cdnPlusAction];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onSwitchVideo:(UISwitch *)sender {
    self.mutePlayStreamVideo = !sender.isOn;
    [[ZegoExpressEngine sharedEngine] mutePlayStreamVideo:!sender.isOn streamID:self.streamIDTextField.text];
    
    
}

- (IBAction)onSwitchAudio:(UISwitch *)sender {
    self.mutePlayStreamAudio = !sender.isOn;
    [[ZegoExpressEngine sharedEngine] mutePlayStreamAudio:!sender.isOn streamID:self.streamIDTextField.text];
    
}


- (void)startPlayingStream {
    if (self.isPlay) {
        // Stop playing
        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];
        [self appendLog:@"📥 Stop playing stream"];

        // Logout room
        [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
        [self appendLog:@"🚪 Logout room"];

        self.playQualityLabel.text = @"";
        
        self.isPlay = NO;
        [self.startLiveButton setTitle:@"Start Playing" forState:UIControlStateNormal];
    } else {
        self.roomID = self.roomIDTextField.text;
        self.streamID = self.streamIDTextField.text;

        NSString *userID = self.userID;
        NSString *userName = userID;

        // Login room
        [self appendLog:@"🚪 Login room"];
        [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:userID userName:userName]];

        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, resourceMode: %d", (int)self.resourceMode]];

        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];

        [[ZegoExpressEngine sharedEngine] mutePlayStreamVideo:self.mutePlayStreamVideo streamID:self.streamID];
        [[ZegoExpressEngine sharedEngine] mutePlayStreamAudio:self.mutePlayStreamAudio streamID:self.streamID];
        
        // Start playing
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamID canvas:playCanvas config:playerConfig];
        

        self.roomIDAndStreamIDLabel.text = [NSString stringWithFormat:@"RoomID: %@ | StreamID: %@", self.roomID, self.streamID];
        
        self.isPlay = YES;
        [self.startLiveButton setTitle:@"Stop Playing" forState:UIControlStateNormal];
    }
}

- (void)stopPlayingStream {
    // Stop playing
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];
    [self appendLog:@"📥 Stop playing stream"];

    // Logout room
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    [self appendLog:@"🚪 Logout room"];

    self.playQualityLabel.text = @"";
}


#pragma mark - Helper

- (void)showLiveRequestingStateUI {
    [self.startLiveButton setEnabled:NO];
    [self.stopLiveButton setEnabled:NO];
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
        [self startPlayingStream];
    }

    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)updateStreamExtraInfo:(NSArray<ZegoStream *> *)streamList {
    NSMutableString *streamExtraInfoString = [NSMutableString string];
    for (ZegoStream *stream in streamList) {
        [streamExtraInfoString appendFormat:@"streamID:%@,info:%@;\n", stream.streamID, stream.extraInfo];
    }
    self.streamExtraInfo = streamExtraInfoString;
    [self appendLog:[NSString stringWithFormat:@"🚩 💬 Stream extra info update: %@", streamExtraInfoString]];
}

#pragma mark - ZegoExpress EventHandler Room Event

-(void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if(reason == ZegoRoomStateChangedReasonLogining)
    {
        [self appendLog:@"🚩 🚪 Logining room"];
        self.roomStateLabel.text = @"🟡 RoomState: Logining";
    }
    else if(reason == ZegoRoomStateChangedReasonLogined)
    {
        [self appendLog:@"🚩 🚪 Login room success"];
        self.roomStateLabel.text = @"🟢 RoomState: Logined";
    }
    else if (reason == ZegoRoomStateChangedReasonLoginFailed)
    {
        [self appendLog:@"🚩 🚪 Login room failed"];
        self.roomStateLabel.text = @"🔴 RoomState: Login failed";
    }
    else if(reason == ZegoRoomStateChangedReasonKickOut)
    {
        [self appendLog:@"🚩 🚪 Kick out of room"];
        self.roomStateLabel.text = @"🔴 RoomState: Kick out";
    }
    else if(reason == ZegoRoomStateChangedReasonReconnecting)
    {
        [self appendLog:@"🚩 🚪 Reconnecting room"];
        self.roomStateLabel.text = @"🟡 RoomState: Reconnecting";
    }
    else if(reason == ZegoRoomStateChangedReasonReconnectFailed)
    {
        [self appendLog:@"🚩 🚪 Reconnect room failed"];
        self.roomStateLabel.text = @"🔴 RoomState: Reconnect failed";
    }
    else if(reason == ZegoRoomStateChangedReasonReconnected)
    {
        [self appendLog:@"🚩 🚪 Reconnect room success"];
        self.roomStateLabel.text = @"🟢 RoomState: Reconnected";
    }
}

- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    [self appendLog:[NSString stringWithFormat:@"🚩 🌊 Room stream update, updateType:%lu, streamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID]];
    [self updateStreamExtraInfo:streamList];
}

- (void)onRoomStreamExtraInfoUpdate:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    [self updateStreamExtraInfo:streamList];
}

- (void)onRoomExtraInfoUpdate:(NSArray<ZegoRoomExtraInfo *> *)roomExtraInfoList roomID:(NSString *)roomID {
    NSMutableString *roomExtraInfoString = [NSMutableString string];
    for (ZegoRoomExtraInfo *info in roomExtraInfoList) {
        [roomExtraInfoString appendFormat:@"key:%@,value:%@;\n", info.key, info.value];

    }
    self.roomExtraInfo = roomExtraInfoString;
    [self appendLog:[NSString stringWithFormat:@"🚩 💭 Room extra info update: %@", roomExtraInfoString]];
}

- (void)onPlayerRecvSEI:(NSData *)data streamID:(NSString *)streamID {
    NSLog(@"onPlayerRecvSEI");
}

#pragma mark - ZegoExpress EventHandler Play Event

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📥 Playing stream error of streamID: %@, errorCode:%d", streamID, errorCode]];
    } else {
        switch (state) {
            case ZegoPlayerStatePlaying:
                [self appendLog:@"🚩 📥 Playing stream"];
                self.playerStateLabel.text = @"🟢 PlayerState: Playing";
                break;

            case ZegoPlayerStatePlayRequesting:
                [self appendLog:@"🚩 📥 Requesting play stream"];
                self.playerStateLabel.text = @"🟡 PlayerState: Requesting";
                break;

            case ZegoPlayerStateNoPlay:
                [self appendLog:@"🚩 📥 No play stream"];
                self.playerStateLabel.text = @"🔴 PlayerState: NoPlay";
                break;
        }
    }
}

- (void)onPlayerVideoSizeChanged:(CGSize)size streamID:(NSString *)streamID {
    self.playResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality streamID:(NSString *)streamID {
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
    [text appendFormat:@"VideoRecvFPS: %.1f fps \n", quality.videoRecvFPS];
    [text appendFormat:@"AudioRecvFPS: %.1f fps \n", quality.audioRecvFPS];
    [text appendFormat:@"VideoBitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"AudioBitrate: %.2f kb/s \n", quality.audioKBPS];
    [text appendFormat:@"RTT: %d ms \n", quality.rtt];
    [text appendFormat:@"Delay: %d ms \n", quality.delay];
    [text appendFormat:@"P2P Delay: %d ms \n", quality.peerToPeerDelay];
    [text appendFormat:@"VideoCodecID: %d \n", (int)quality.videoCodecID];
    [text appendFormat:@"AV TimestampDiff: %d ms \n", quality.avTimestampDiff];
    [text appendFormat:@"TotalRecv: %.3f MB \n", quality.totalRecvBytes / 1024 / 1024];
    [text appendFormat:@"PackageLostRate: %.1f%% \n", quality.packetLostRate * 100.0];
    [text appendFormat:@"HardwareEncode: %@ \n", quality.isHardwareDecode ? @"✅" : @"❎"];
    [text appendFormat:@"NetworkQuality: %@", networkQuality];
    self.playQualityLabel.text = text;
}

@end

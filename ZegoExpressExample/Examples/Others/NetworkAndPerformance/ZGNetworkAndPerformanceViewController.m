//
//  ZGNetworkAndPerformanceViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/14.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGNetworkAndPerformanceViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGNetworkAndPerformanceViewController ()<ZegoEventHandler>

@property (nonatomic, copy) NSString *streamID;

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

// LoginRoom
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;

@property (weak, nonatomic) IBOutlet UILabel *userIDRoomIDLabel;

@property (weak, nonatomic) IBOutlet UILabel *speedTestNoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *downlinkNoteLabel;

@property (weak, nonatomic) IBOutlet UILabel *uplinkNoteLabel;


@property (weak, nonatomic) IBOutlet UITextView *downlinkTextView;
@property (weak, nonatomic) IBOutlet UITextView *uplinkTextView;
@property (weak, nonatomic) IBOutlet UILabel *expectedDownlinkBitrateLabel;
@property (weak, nonatomic) IBOutlet UITextField *expectedDownlinkBitrateTextField;
@property (weak, nonatomic) IBOutlet UITextField *expectedUplinkBitrateTextField;


@property (weak, nonatomic) IBOutlet UILabel *expectedUplinkBitrateLabel;
@property (weak, nonatomic) IBOutlet UIButton *startNetworkSpeedTestButton;


@property (weak, nonatomic) IBOutlet UILabel *performanceNoteLabel;

@property (weak, nonatomic) IBOutlet UITextView *appPerformanceTextView;

@property (weak, nonatomic) IBOutlet UITextView *systemPerformanceTextView;


@end

@implementation ZGNetworkAndPerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.streamID = @"0031";
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0031";

    self.userIDRoomIDLabel.text = [NSString stringWithFormat:@"UserID: %@  RoomID:%@", self.userID, self.roomID];

    [self setupEngineAndLogin];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)setupEngineAndLogin {
    [self appendLog:@"🚀 Create ZegoExpressEngine"];
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
    
    [[ZegoExpressEngine sharedEngine] startPerformanceMonitor:2000];
}

- (void)setupUI {
    [self.startNetworkSpeedTestButton setTitle:NSLocalizedString(@"StartNetworkSpeedTestButton", nil) forState:UIControlStateNormal];
    [self.startNetworkSpeedTestButton setTitle:NSLocalizedString(@"StopNetworkSpeedTestButton", nil) forState:UIControlStateSelected];
    
    self.speedTestNoteLabel.text = NSLocalizedString(@"NetworkSpeedNoteLabel", nil);
    
    self.downlinkNoteLabel.text = NSLocalizedString(@"DownlinkNoteLabel", nil);
    
    self.uplinkNoteLabel.text = NSLocalizedString(@"UplinkNoteLabel", nil);
    
    self.expectedDownlinkBitrateLabel.text = NSLocalizedString(@"ExpectedDownlinkBitrateLabel", nil);
    
    self.expectedUplinkBitrateLabel.text = NSLocalizedString(@"ExpectedUplinkBitrateLabel", nil);
    
    self.performanceNoteLabel.text = NSLocalizedString(@"PerformanceNoteLabel", nil);
}

- (IBAction)onStartNetworkSpeedTestButtonTapped:(UIButton *)sender {
    ZGLogInfo(@"📥 StartNetworkSpeedTest");
    [self appendLog:@"📥 StartNetworkSpeedTest"];
    ZegoNetworkSpeedTestConfig *config = [[ZegoNetworkSpeedTestConfig alloc] init];
    config.testUplink = YES;
    config.testDownlink = YES;
    config.expectedUplinkBitrate = self.expectedUplinkBitrateTextField.text.intValue;
    config.expectedDownlinkBitrate = self.expectedDownlinkBitrateTextField.text.intValue;
    
    [[ZegoExpressEngine sharedEngine] startNetworkSpeedTest:config];
    sender.selected = !sender.selected;
}




#pragma mark - ZegoEventHandler


- (void)onNetworkSpeedTestQualityUpdate:(ZegoNetworkSpeedTestQuality *)quality type:(ZegoNetworkSpeedTestType)type {
    if (type == ZegoNetworkSpeedTestTypeUplink) {
        self.uplinkTextView.text = [NSString stringWithFormat:@"ConnectCost: %ums \n RTT: %ums \n PacketLostRate: %.4f%% ", quality.connectCost, quality.rtt, quality.packetLostRate * 100];
    } else if(type == ZegoNetworkSpeedTestTypeDownlink) {
        self.downlinkTextView.text = [NSString stringWithFormat:@"ConnectCost: %ums \n RTT: %ums \n PacketLostRate: %.4f%% ", quality.connectCost, quality.rtt, quality.packetLostRate * 100];
    }
}

- (void)onPerformanceStatusUpdate:(ZegoPerformanceStatus *)status {
    self.appPerformanceTextView.text = [NSString stringWithFormat:@"CPU: %.2f%% \nMemory: %.1fMB \nMemory(%%): %.2f%% ", status.cpuUsageApp * 100, status.memoryUsedApp, status.memoryUsageApp * 100];
    
    self.systemPerformanceTextView.text = [NSString stringWithFormat:@"CPU: %.2f%% \nMemory(%%): %.2f%% ", status.cpuUsageSystem * 100, status.memoryUsageSystem * 100];
}

/// Publish stream state callback
- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
//    if (state == ZegoPublisherStatePublishing && errorCode == 0) {
//        [self appendLog:@"🚩 📤 Publishing stream success"];
//        // Add a flag to the button for successful operation
//        self.startPublishingButton.selected = true;
//    }
//    if (errorCode != 0) {
//        [self appendLog:@"🚩 ❌ 📤 Publishing stream fail"];
//    }
}

/// Play stream state callback
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
//    if (state == ZegoPlayerStatePlaying && errorCode == 0) {
//        [self appendLog:@"🚩 📥 Playing stream success"];
//        // Add a flag to the button for successful operation
//        self.startPlayingButton.selected = true;
//    }
//    if (errorCode != 0) {
//        [self appendLog:@"🚩 ❌ 📥 Playing stream fail"];
//    }
}


#pragma mark - Others

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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

#pragma mark - Exit

- (void)dealloc {
    ZGLogInfo(@"🚪 Exit the room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}


@end

//
//  ZGAudioMixingViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/15.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_AudioMixing

#import "ZGAudioMixingViewController.h"
#import "ZGAudioMixingSettingTableViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGAudioMixingViewController () <UIPopoverPresentationControllerDelegate, ZegoEventHandler, ZegoAudioMixingHandler>

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;

@property (nonatomic, strong) UIBarButtonItem *settingButton;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *streamIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *publisherStateLabel;

@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;

// Audio origin data
@property (nonatomic, strong) NSData *audioData;
// Audio origin data position
@property (nonatomic, assign) void *audioDataPosition;
// Audio mixing data
@property (nonatomic, strong) ZegoAudioMixingData *audioMixingData;

@end

@implementation ZGAudioMixingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.roomID = @"AudioMixingRoom-1";

    // Simply use userID as streamID
    self.streamID = [ZGUserIDHelper userID];

    self.enableAudioMixing = YES;
    self.muteLocalAudioMixing = NO;
    self.audioMixingVolume = 50;

    [self setupUI];
    [self startLive];
}

- (void)setupUI {
    self.navigationItem.title = @"AudioMixing";

    self.settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Setting"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettingController)];

    self.navigationItem.rightBarButtonItem = self.settingButton;

    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.streamIDLabel.text = [NSString stringWithFormat:@"StreamID: %@", self.streamID];
    self.roomStateLabel.text = @"RoomState: 🔴";
    self.publisherStateLabel.text = @"PublisherState: 🔴";
}

- (void)startLive {
    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];

    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    [ZegoExpressEngine createEngineWithAppID:appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];

    // Set self as audio mixing handler
    [[ZegoExpressEngine sharedEngine] setAudioMixingHandler:self];

    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];

    ZegoRoomConfig *roomConfig = [ZegoRoomConfig defaultConfig];

    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user config:roomConfig];

    // Start preview
    ZGLogInfo(@"🔌 Start preview");
    [[ZegoExpressEngine sharedEngine] startPreview:[ZegoCanvas canvasWithView:self.view]];

    // Start publishing
    ZGLogInfo(@"📤 Start publishing stream. streamID: %@", self.streamID);
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];

    // Set up audio mixing
    [[ZegoExpressEngine sharedEngine] enableAudioMixing:self.enableAudioMixing];
    [[ZegoExpressEngine sharedEngine] muteLocalAudioMixing:self.muteLocalAudioMixing];
    [[ZegoExpressEngine sharedEngine] setAudioMixingVolume:self.audioMixingVolume];
}

- (void)dealloc {
    ZGLogInfo(@"🚪 Logout room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)showSettingController {
    ZGAudioMixingSettingTableViewController *vc = [ZGAudioMixingSettingTableViewController instanceFromStoryboard];
    vc.preferredContentSize = CGSizeMake(250.0, 150.0);
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.popoverPresentationController.delegate = self;
    vc.popoverPresentationController.barButtonItem = self.settingButton;
    vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;

    vc.presenter = self;

    vc.enableAudioMixing = _enableAudioMixing;
    vc.muteLocalAudioMixing = _muteLocalAudioMixing;
    vc.audioMixingVolume = _audioMixingVolume;

    vc.enableAudioMixingBlock = ^(BOOL enable) {
        ZGLogInfo(@"🎶 %@ audio mixing", enable ? @"Enable" : @"Disable");
        [[ZegoExpressEngine sharedEngine] enableAudioMixing:enable];
    };

    vc.muteLocalAudioMixingBlock = ^(BOOL mute) {
        ZGLogInfo(@"%@ local audio mixing", mute ? @"🔇 Mute" : @"🔈 Unmute");
        [[ZegoExpressEngine sharedEngine] muteLocalAudioMixing:mute];
    };

    vc.setAudioMixingVolumeBlock = ^(int volume) {
        ZGLogInfo(@"🔊 Set audio mixing volume: %d", volume);
        [[ZegoExpressEngine sharedEngine] setAudioMixingVolume:volume];
    };

    [self presentViewController:vc animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}


#pragma mark - ZegoEventHandler

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (errorCode != 0) {
        ZGLogInfo(@"🚩 ❌ 🚪 Room state error, errorCode: %d", errorCode);
    } else {
        switch (state) {
            case ZegoRoomStateConnected:
                ZGLogInfo(@"🚩 🚪 Login room success");
                self.roomStateLabel.text = @"🟢 RoomState: Connected";
                break;

            case ZegoRoomStateConnecting:
                ZGLogInfo(@"🚩 🚪 Requesting login room");
                self.roomStateLabel.text = @"🟡 RoomState: Connecting";
                break;

            case ZegoRoomStateDisconnected:
                ZGLogInfo(@"🚩 🚪 Logout room");
                self.roomStateLabel.text = @"🔴 RoomState: Disconnected";
                break;
        }
    }
}

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        ZGLogInfo(@"🚩 ❌ 📤 Publishing stream error of streamID: %@, errorCode:%d", streamID, errorCode);
    } else {
        switch (state) {
            case ZegoPublisherStatePublishing:
                ZGLogInfo(@"🚩 📤 Publishing stream");
                self.publisherStateLabel.text = @"🟢 PublisherState: Publishing";
                break;

            case ZegoPublisherStatePublishRequesting:
                ZGLogInfo(@"🚩 📤 Requesting publish stream");
                self.publisherStateLabel.text = @"🟡 PublisherState: Requesting";
                break;

            case ZegoPublisherStateNoPublish:
                ZGLogInfo(@"🚩 📤 No publish stream");
                self.publisherStateLabel.text = @"🔴 PublisherState: NoPublish";
                break;
        }
    }
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    self.resolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %d fps \n", (int)quality.videoSendFPS];
    self.bitrateLabel.text = [NSString stringWithFormat:@"Bitrate: %.2f kb/s \n", quality.videoKBPS];
}


#pragma mark - ZegoAudioMixingHandler

// Here's an example of how to loop mixing a local wav file
- (ZegoAudioMixingData *)onAudioMixingCopyData:(unsigned int)expectedDataLength {

    // Initialize audio pcm data
    if (!self.audioData) {
        NSURL *auxURL = [[NSBundle mainBundle] URLForResource:@"test.wav" withExtension:nil];
        self.audioData = [NSData dataWithContentsOfURL:auxURL options:0 error:nil];
        self.audioDataPosition = (void *)[self.audioData bytes];
    }

    // Initialize ZegoAudioMixingData
    if (!self.audioMixingData) {
        self.audioMixingData = [[ZegoAudioMixingData alloc] init];
        self.audioMixingData.param = [[ZegoAudioFrameParam alloc] init];
        self.audioMixingData.param.channel = ZegoAudioChannelMono;
        self.audioMixingData.param.sampleRate = ZegoAudioSampleRate16K;
    }

    // Calculate remaining data length
    unsigned int remainingDataLength = (unsigned int)([self.audioData bytes] + (int)[self.audioData length] - self.audioDataPosition);

    if (remainingDataLength >= expectedDataLength) {
        // When the remaining data length is greater than the expected data length for this callback, construct the expected length of data and move the position backward

        NSData *expectedData = [NSData dataWithBytes:self.audioDataPosition length:expectedDataLength];

        self.audioMixingData.audioData = expectedData;
        self.audioDataPosition = self.audioDataPosition + expectedDataLength;

    } else {
        // When the remaining data length is less than the expected length for this callback, move the position back to the starting point.
        self.audioMixingData.audioData = nil;
        self.audioDataPosition = (void *)[self.audioData bytes];
    }

    return self.audioMixingData;
}


@end

#endif

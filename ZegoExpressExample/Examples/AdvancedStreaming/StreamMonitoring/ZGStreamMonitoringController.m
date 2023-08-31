//
//  ZGStreamMonitoringController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/13.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGStreamMonitoringController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
@interface ZGStreamMonitoringController ()<ZegoEventHandler>

@property (nonatomic, copy) NSString *streamID;

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

// LoginRoom
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;

@property (weak, nonatomic) IBOutlet UILabel *userIDRoomIDLabel;


// PublishStream
// Preview and Play View
@property (weak, nonatomic) IBOutlet UILabel *previewLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishQualityLabel;
@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;

// PlayStream
@property (weak, nonatomic) IBOutlet UILabel *playStreamLabel;
@property (weak, nonatomic) IBOutlet UILabel *playResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *playQualityLabel;

@property (weak, nonatomic) IBOutlet UIView *remotePlayView;
@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;
@end

@implementation ZGStreamMonitoringController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.streamID = @"0008";
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0008";
    self.playStreamIDTextField.text = self.streamID;
    self.publishStreamIDTextField.text = self.streamID;
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
}

- (void)setupUI {
    self.previewLabel.text = NSLocalizedString(@"PreviewLabel", nil);
    self.playStreamLabel.text = NSLocalizedString(@"PlayStreamLabel", nil);
    [self.startPlayingButton setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.startPlayingButton setTitle:@"Stop Playing" forState:UIControlStateSelected];
    
    [self.startPublishingButton setTitle:@"Start Publishing" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"Stop Publishing" forState:UIControlStateSelected];
}

- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.publishStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
    } else {
        // Start preview
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
        [self appendLog:@"🔌 Start preview"];
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        
        // Start publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.publishStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.publishStreamIDTextField.text];
    }
    sender.selected = !sender.isSelected;
    
}
- (IBAction)onStartPlayingButtonTappd:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", self.playStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] stopPlayingStream: self.playStreamIDTextField.text];
    } else {
        
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.playStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:playCanvas];
    }
    sender.selected = !sender.isSelected;
}

#pragma mark - ZegoEventHandler
#pragma mark - Publish
// The callback triggered when the state of stream publishing changes.
- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    // If the state is PUBLISHER_STATE_NO_PUBLISH and the errcode is not 0, it means that stream publishing has failed
    // and no more retry will be attempted by the engine. At this point, the failure of stream publishing can be indicated
    // on the UI of the App.
    
    [self appendLog:[NSString stringWithFormat:@"🚩 Publisher State Update State: %lu", state]];
}

//After calling the [startPublishingStream] successfully, the callback will be received every 3 seconds.
// Through the callback, the collection frame rate, bit rate, RTT, packet loss rate and other quality data
// of the published audio and video stream can be obtained, and the health of the publish stream can be monitored
// in real time.
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
    [text appendFormat:@"VideoSendBitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"VideoSendFPS: %.1f fps \n", quality.videoSendFPS];
    [text appendFormat:@"RTT: %d ms \n", quality.rtt];
    [text appendFormat:@"PackageLost: %.1f%% \n", quality.packetLostRate * 100.0];
    [text appendFormat:@"NetworkQuality: %@", networkQuality];
    self.publishQualityLabel.text = [text copy];
    [self appendLog:[NSString stringWithFormat:@"🚩 Publisher Quality Update : %@", text]];
}

// The callback triggered when the first audio frame is captured.
- (void)onPublisherCapturedAudioFirstFrame {
    [self appendLog:[NSString stringWithFormat:@"🚩 Receive Publisher Captured Audio First Frame"]];
}

- (void)onPublisherCapturedVideoFirstFrame:(ZegoPublishChannel)channel {
    [self appendLog:[NSString stringWithFormat:@"🚩 Receive Publisher Captured Audio First Frame"]];
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    [self appendLog:[NSString stringWithFormat:@"🚩 Publisher Video Size Changed: Size: %@", @(size)]];
    self.publishResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

// The callback triggered when the state of relayed streaming to CDN changes.
- (void)onPublisherRelayCDNStateUpdate:(NSArray<ZegoStreamRelayCDNInfo *> *)infoList streamID:(NSString *)streamID {
    [self appendLog:[NSString stringWithFormat:@"🚩 Publisher RelayCDN State Update, streamID: %@", streamID]];

}

#pragma mark - Play
// The callback triggered when the state of stream playing changes.
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    // If the state is ZegoPlayerStateNoPlay and the errcode is not 0, it means that stream playing has failed and
    // no more retry will be attempted by the engine. At this point, the failure of stream playing can be indicated
    // on the UI of the App.
    
    [self appendLog:[NSString stringWithFormat:@"🚩 Player State Update State: %lu", state]];
}

//After calling the [startPlayingStream] successfully, this callback will be triggered every 3 seconds.
// The collection frame rate, bit rate, RTT, packet loss rate and other quality data can be obtained,
// such the health of the publish stream can be monitored in real time.
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
    [text appendFormat:@"VideoReceiveBitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"VideoRecvFPS: %.1f fps \n", quality.videoRecvFPS];
    [text appendFormat:@"RTT: %d ms \n", quality.rtt];
    [text appendFormat:@"Delay: %d ms \n", quality.delay];
    [text appendFormat:@"NetworkQuality: %@", networkQuality];
    self.playQualityLabel.text = [text copy];
    [self appendLog:[NSString stringWithFormat:@"🚩 Player Quality Update : %@", text]];

}

// The callback triggered when a media event occurs during streaming playing.
- (void)onPlayerMediaEvent:(ZegoPlayerMediaEvent)event streamID:(NSString *)streamID {
    
}

// The callback triggered when the first audio frame is received.
- (void)onPlayerRecvAudioFirstFrame:(NSString *)streamID {
    
}

// The callback triggered when the first video frame is received.
- (void)onPlayerRecvVideoFirstFrame:(NSString *)streamID {
    
}

// The callback triggered when the first video frame is rendered.
- (void)onPlayerRenderVideoFirstFrame:(NSString *)streamID {
    
}

//The callback triggered when the stream playback resolution changes.
- (void)onPlayerVideoSizeChanged:(CGSize)size streamID:(NSString *)streamID {
    self.playResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
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

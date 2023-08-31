//
//  ZGVideoChatViewController.m
//  ZegoExpressExample
//
//  Created by 王鑫 on 2021/11/29.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGVideoChatViewController.h"
#import "KeyCenter.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGVideoChatViewController () <ZegoEventHandler>

@property (strong, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishStreamIDLabel;

@property (nonatomic, copy) NSString *playStreamID;

@property (nonatomic) ZegoPublisherState publisherState;
@property (nonatomic) ZegoPlayerState playerState;

@end

@implementation ZGVideoChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"VideoChatTitle", nil);

    [self createEngineAndLogin];
    [self setupUI];
}

- (void)createEngineAndLogin {
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
    self.roomIDLabel.text = [NSString stringWithFormat:@"roomID:%@", self.roomID];
    self.userIDLabel.text = [NSString stringWithFormat:@"userID:%@", self.userID];
    self.publishStreamIDLabel.text = [NSString stringWithFormat:@"publishStreamID:%@", self.publishStreamID];
    
    self.playView.hidden = YES;
}

- (void)startLive {
    // Start preview
    ZegoCanvas *previewCavas = [ZegoCanvas canvasWithView:self.previewView];
    [self appendLog:@"🔌 Start preview"];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCavas];
    
    // Start publishing
    [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.publishStreamID]];
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.publishStreamID];
}

- (IBAction)stopButnClicked:(id)sender {
    // When you return to the previous level view, you will stopPreview, stopPublishingStream, stopPlayingStream, logoutRoom, and destroyEngine in dealloc
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - ZegoEventHandler

#pragma mark - Room
- (void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 🚪 Room state error, errorCode: %d", errorCode]];
    }
    if(reason == ZegoRoomStateChangedReasonLogined)
    {
        [self startLive];
    }
}

- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (updateType == ZegoUpdateTypeAdd) {
        // When the updateType is Add, stop playing current stream(if exist) and start playing new stream.
        if (self.playerState != ZegoPlayerStateNoPlay) {
            [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamID];
            self.playStreamID = nil;
        }
        
        // No processing, just play the first stream
        ZegoStream *stream = streamList.firstObject;
        self.playStreamID = stream.streamID;
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamID canvas:playCanvas];
        
    } else {
        // When the updateType is Delete, if the stream is being played, stop playing the stream.
        if (self.playerState == ZegoPlayerStateNoPlay) {
            return;
        }
        for (ZegoStream *stream in streamList) {
            if ([self.playStreamID isEqualToString:stream.streamID]) {
                [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamID];
                self.playStreamID = nil;
            }
        }
    }
}

#pragma mark - Publish
// The callback triggered when the state of stream publishing changes.
- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    // If the state is PUBLISHER_STATE_NO_PUBLISH and the errcode is not 0, it means that stream publishing has failed
    // and no more retry will be attempted by the engine. At this point, the failure of stream publishing can be indicated
    // on the UI of the App.
    self.publisherState = state;
    [self appendLog:[NSString stringWithFormat:@"🚩 Publisher State Update State: %lu", state]];
}

#pragma mark - Play
// The callback triggered when the state of stream playing changes.
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    // If the state is ZegoPlayerStateNoPlay and the errcode is not 0, it means that stream playing has failed and
    // no more retry will be attempted by the engine. At this point, the failure of stream playing can be indicated
    // on the UI of the App.
    self.playerState = state;
    [self appendLog:[NSString stringWithFormat:@"🚩 Player State Update State: %lu", state]];
    if (state == ZegoPlayerStatePlaying) {
        self.playView.hidden = NO;
    } else {
        self.playView.hidden = YES;
    }
}

#pragma mark - Exit

- (void)dealloc {
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

@end

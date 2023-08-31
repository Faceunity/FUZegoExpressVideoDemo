//
//  ZGPublishingMultipleStreamsViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/21.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZegoStreamPublisher.h"

#import "ZGPublishingMultipleStreamsViewController.h"
#import "ZGUserIDHelper.h"
#import "KeyCenter.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGPublishingMultipleStreamsViewController () <ZegoEventHandler>
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, copy) NSString *userID;

@property (weak, nonatomic) IBOutlet UIView *mainChannelStreamPreviewView;

@property (weak, nonatomic) IBOutlet UIImageView *auxChannelStreamPreviewView;

@property (weak, nonatomic) IBOutlet UIButton *startPublishingStreamMainChannelButton;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingStreamAuxChannelButton;

@property (weak, nonatomic) IBOutlet UITextField *mainChannelPublishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *auxChannelPublishStreamIDTextField;



@property (weak, nonatomic) IBOutlet UIView *firstStreamPlayView;
@property (weak, nonatomic) IBOutlet UIView *secondStreamPlayView;
@property (weak, nonatomic) IBOutlet UIButton *startPlayFirstStreamButton;

@property (weak, nonatomic) IBOutlet UIButton *startPlaySecStreamButton;

@property (weak, nonatomic) IBOutlet UITextField *firstPlayStreamIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *secondPlayStreamIDTextField;


@property (nonatomic, assign) ZegoPublisherState mainPublisherState;
@property (nonatomic, assign) ZegoPublisherState auxPublisherState;

@property (nonatomic, strong) ZegoStreamPublisher *auxStreamPublisher;

@end

@implementation ZGPublishingMultipleStreamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0005";
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"UserID: %@  RoomID:%@", self.userID, self.roomID];
        
    [self setupUI];
    
    [self setupEngineAndLogin];
    
    self.auxStreamPublisher = [[ZegoStreamPublisher alloc] initWithCanvasView:self.auxChannelStreamPreviewView];
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
    [self.startPublishingStreamMainChannelButton setTitle:@"Publish MainChannel" forState:UIControlStateNormal];
    [self.startPublishingStreamMainChannelButton setTitle:@"Stop Publish MainChannel" forState:UIControlStateSelected];
    [self.startPublishingStreamAuxChannelButton setTitle:@"Publish AuxChannel" forState:UIControlStateNormal];
    [self.startPublishingStreamAuxChannelButton setTitle:@"Stop Publish AuxChannel" forState:UIControlStateSelected];
    
    
    [self.startPlayFirstStreamButton setTitle:@"Play First Stream" forState:UIControlStateNormal];
    [self.startPlayFirstStreamButton setTitle:@"Stop Play First Stream" forState:UIControlStateSelected];
    [self.startPlaySecStreamButton setTitle:@"Play Second Stream" forState:UIControlStateNormal];
    [self.startPlaySecStreamButton setTitle:@"Stop Play Second Stream" forState:UIControlStateSelected];
}


- (IBAction)onStartPublishingStreamToMainChannelButtonTapped:(UIButton *)sender {
    
    if (sender.isSelected) {
        // Stop publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.mainChannelPublishStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream:ZegoPublishChannelMain];
        [[ZegoExpressEngine sharedEngine] stopPreview:ZegoPublishChannelMain];
    } else {
        // Start preview
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.mainChannelStreamPreviewView];
        [self appendLog:@"🔌 Start preview"];
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        
        // Start publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.mainChannelPublishStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.mainChannelPublishStreamIDTextField.text channel:ZegoPublishChannelMain];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onStartPublishingStreamToAuxChannelButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop publishing to aux channel
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream to aux channel. streamID: %@", self.auxChannelPublishStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream:ZegoPublishChannelAux];
    } else {
        // Start publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream to aux channel. streamID: %@", self.mainChannelPublishStreamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.auxChannelPublishStreamIDTextField.text channel:ZegoPublishChannelAux];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onPlayFirstStreamButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", self.firstPlayStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.firstPlayStreamIDTextField.text];
    } else {
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.firstStreamPlayView];
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.firstPlayStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.firstPlayStreamIDTextField.text canvas:playCanvas];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onPlaySecondStreamButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", self.secondPlayStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.secondPlayStreamIDTextField.text];
    } else {
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.secondStreamPlayView];
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.secondPlayStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.secondPlayStreamIDTextField.text canvas:playCanvas];
    }
    sender.selected = !sender.isSelected;
}
#pragma mark - ZegoEventHandler

// Refresh the remote streams list
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🌊 Room Stream Update Callback: %lu, StreamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);
}

-(void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🚪 Room State Changed Callback: %lu, errorCode: %d, roomID: %@", (unsigned long)reason, (int)errorCode, roomID);
}

// Refresh the player state
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📥 Player State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
}

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(nullable NSDictionary *)extendedData streamID:(NSString *)streamID
{
    ZGLogInfo(@"🚩 🚪 publish state: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
    
    [self appendLog:[NSString stringWithFormat:@"📥 publish state: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID]];
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
    ZGLogInfo(@"🚪 Exit the room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

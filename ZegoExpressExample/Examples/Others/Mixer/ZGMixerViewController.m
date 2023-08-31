//
//  ZGMixerViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/21.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGMixerViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NSString* const ZGMixerTopicKey_OutputTarget = @"kOutputTarget";

static const unsigned int ZGMixerFirstStreamSoundLevelID = 100;
static const unsigned int ZGMixerSecondStreamSoundLevelID = 200;

@interface ZGMixerViewController () <ZegoEventHandler, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, strong) NSMutableArray<ZegoStream *> *remoteStreamList;

@property (nonatomic, assign) BOOL isMixing;
@property (nonatomic, assign) ZegoPlayerState playerState;

@property (nonatomic, strong) ZegoMixerTask *mixerTask;

@property (nonatomic, strong) ZegoStream *selectFirstStream;
@property (weak, nonatomic) IBOutlet UILabel *selectFirstStreamLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *firstStreamSoundLevelProgressView;
@property (nonatomic, strong) ZegoStream *selectSecondStream;
@property (weak, nonatomic) IBOutlet UILabel *selectSecondStreamLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *secondStreamSoundLevelProgressView;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UIPickerView *selectStreamsPicker;
@property (weak, nonatomic) IBOutlet UITextField *outputTargetTextField;

@property (weak, nonatomic) IBOutlet UIButton *startMixerTaskButton;
@property (weak, nonatomic) IBOutlet UIButton *startPlayButton;

@property (weak, nonatomic) IBOutlet UITextField *firstMixerImageURI;

@property (weak, nonatomic) IBOutlet UITextField *secondMixerImageURI;

@property (weak, nonatomic) IBOutlet UITextField *whiteboardID;
@property (weak, nonatomic) IBOutlet UITextField *whiteboardLayoutLeft;
@property (weak, nonatomic) IBOutlet UITextField *whiteboardLayoutTop;
@property (weak, nonatomic) IBOutlet UITextField *whiteboardLayoutWidth;
@property (weak, nonatomic) IBOutlet UITextField *whiteboardLayoutHeight;
@property (weak, nonatomic) IBOutlet UITextField *whiteboardLayoutZOrder;
@property (weak, nonatomic) IBOutlet UISwitch *whiteboardPPTAnimation;

@end

@implementation ZGMixerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomID = [NSString stringWithFormat:@"%u", (unsigned)rand()%100000];
    self.outputTargetTextField.text = [NSString stringWithFormat:@"mix_%@", self.roomID];
    
    self.remoteStreamList = [NSMutableArray array];
    
    [self setupUI];
    
    [self createEngineAndLoginRoom];
}

- (void)setupUI {
    self.isMixing = NO;
    self.playerState = ZegoPlayerStateNoPlay;
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    
    // Set up stream picker
    
    self.selectStreamsPicker.dataSource = self;
    self.selectStreamsPicker.delegate = self;
    
    [self.selectStreamsPicker selectRow:0 inComponent:0 animated:YES];
    [self.selectStreamsPicker selectRow:0 inComponent:1 animated:YES];
    
    [self pickerView:self.selectStreamsPicker didSelectRow:0 inComponent:0];
    [self pickerView:self.selectStreamsPicker didSelectRow:0 inComponent:1];
}

- (void)createEngineAndLoginRoom {
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
    
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    
    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user];
}

#pragma mark - Start Mixer Task

- (IBAction)startMixerTaskButtonClick:(UIButton *)sender {
    if (self.isMixing) {
        [self stopMixerTask];
    } else {
        [self startMixerTask];
    }
}

- (void)startMixerTask {
    if (self.outputTargetTextField.text.length <= 0) {
        ZGLogWarn(@"❕ Please enter output target");
        [ZegoHudManager showMessage:@"❕ Please enter output target"];
        return;
    }
    
    ZGLogInfo(@"🧬 Start mixer task");
    
    NSString *taskID = [NSString stringWithFormat:@"mix_%@", self.roomID];
    
    // ① (Required): Create a ZegoMixerTask object
    ZegoMixerTask *task = [[ZegoMixerTask alloc] initWithTaskID:taskID];
    
    
    // ② (Optional): Set video config
    ZegoMixerVideoConfig *videoConfig = [[ZegoMixerVideoConfig alloc] initWithResolution:CGSizeMake(720, 1280) fps:15 bitrate:1500];
    [task setVideoConfig:videoConfig];
    
    
    // ③ (Optional): Set audio config
    [task setAudioConfig:[ZegoMixerAudioConfig defaultConfig]];
    
    
    // ④ (Optional): Set mixer input
    NSMutableArray *inputArray = [[NSMutableArray alloc] init];
    if (self.selectFirstStream.streamID.length > 0) {
        CGRect firstRect = CGRectMake(0, 0, videoConfig.resolution.width, videoConfig.resolution.height/2);
        ZegoMixerInput *firstInput = [[ZegoMixerInput alloc] initWithStreamID:self.selectFirstStream.streamID contentType:ZegoMixerInputContentTypeVideo layout:firstRect soundLevelID:ZGMixerFirstStreamSoundLevelID];
        firstInput.label.text = @"zego";
        firstInput.label.font.border = YES;
        firstInput.imageInfo.url = self.firstMixerImageURI.text;
        
        [inputArray addObject:firstInput];
    }
    if (self.selectSecondStream.streamID.length > 0) {
        CGRect secondRect = CGRectMake(0, videoConfig.resolution.height/2, videoConfig.resolution.width, videoConfig.resolution.height/2);
        ZegoMixerInput *secondInput = [[ZegoMixerInput alloc] initWithStreamID:self.selectSecondStream.streamID contentType:ZegoMixerInputContentTypeVideo layout:secondRect soundLevelID:ZGMixerSecondStreamSoundLevelID];
        secondInput.label.font.border = YES;
        secondInput.label.font.borderColor = 255;
        secondInput.imageInfo.url = self.firstMixerImageURI.text;
        
        [inputArray addObject:secondInput];
    }
    
    if (inputArray.count == 0) {
        ZGLogWarn(@"❕ insufficient input list(at least one)");
        [ZegoHudManager showMessage:@"❕ insufficient input list(at least one)"];
        
        return;
    }
    [task setInputList:inputArray];
    
    // ⑤ (Required): Set mixer output
    NSArray<ZegoMixerOutput *> *outputArray = @[[[ZegoMixerOutput alloc] initWithTarget:self.outputTargetTextField.text]];
    [task setOutputList:outputArray];
    
    // ⑥ (Optional): Set watermark
    ZegoWatermark *watermark = [[ZegoWatermark alloc] initWithImageURL:@"preset-id://zegowp.png" layout:CGRectMake(0, 0, videoConfig.resolution.width/2, videoConfig.resolution.height/20)];
    [task setWatermark:watermark];
    
    // ⑦ (Optional): Set background image
    [task setBackgroundImageURL:@"preset-id://zegobg.png"];

    // ⑧ (Optional): Enable mixer sound level
    [task enableSoundLevel:YES];
    
    // 9 (Optional): Whiteboard config
    unsigned long long whiteboardID = 0;
    if (self.whiteboardID.text.length > 0) {
        whiteboardID = [self.whiteboardID.text longLongValue];
    }
    if (whiteboardID > 0) {
        int left = [self.whiteboardLayoutLeft.text intValue];
        int top = [self.whiteboardLayoutTop.text intValue];
        int width = [self.whiteboardLayoutWidth.text intValue];
        int height = [self.whiteboardLayoutHeight.text intValue];
        CGRect whiteboardLayout = CGRectMake(left, top, width, height);
        ZegoMixerWhiteboard *whiteboard = [[ZegoMixerWhiteboard alloc] initWithWhiteboardID:whiteboardID layout:whiteboardLayout];
        
        int zOrder = [self.whiteboardLayoutZOrder.text intValue];
        [whiteboard setZOrder:zOrder];
        
        BOOL isPPTAnimation = self.whiteboardPPTAnimation.on;
        [whiteboard setIsPPTAnimation:isPPTAnimation];
        
        [task setWhiteboard:whiteboard];
    }
    
    // Start Mixer Task
    [ZegoHudManager showNetworkLoading];
    
    [[ZegoExpressEngine sharedEngine] startMixerTask:task callback:^(int errorCode, NSDictionary * _Nullable extendedData) {
        ZGLogInfo(@"🚩 🧬 Start mixer task result errorCode: %d", errorCode);
        
        [ZegoHudManager hideNetworkLoading];
        
        if (errorCode == 0) {
            self.isMixing = YES;
            
        } else {
            [ZegoHudManager showMessage:[NSString stringWithFormat:@"🚩 🧬 Start mixer errorCode: %d", errorCode]];
        }
    }];
    
    // Save the task object
    self.mixerTask = task;
    
    // Save the output target text field
    [self saveValue:self.outputTargetTextField.text forKey:ZGMixerTopicKey_OutputTarget];
}

- (void)stopMixerTask {
    ZGLogInfo(@"🧬 Stop mixer task");
    [[ZegoExpressEngine sharedEngine] stopMixerTask:self.mixerTask callback:^(int errorCode) {
        ZGLogInfo(@"🚩 🧬 Stop mixer task result errorCode: %d", errorCode);
    }];
    
    self.isMixing = NO;
}

#pragma mark - Play the Mixed Stream

- (IBAction)playMixedStreamButtonClick:(UIButton *)sender {
    if (self.playerState == ZegoPlayerStatePlaying) {
        [self stopPlaying];
    } else {
        [self startPlaying];
    }
}

- (void)startPlaying {
    if (self.outputTargetTextField.text.length > 0) {
        ZGLogInfo(@"📥 Start playing stream: %@", self.outputTargetTextField.text);
        
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.outputTargetTextField.text canvas:[ZegoCanvas canvasWithView:self.playView]];
    } else {
        ZGLogWarn(@"❕ Please enter output target");
        [ZegoHudManager showMessage:@"❕ Please enter output target"];
    }
}

- (void)stopPlaying {
    ZGLogInfo(@"📥 Stop playing stream: %@", self.outputTargetTextField.text);
    
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.outputTargetTextField.text];
}

#pragma mark - Update whiteboard config
- (IBAction)updateWhiteboardConfigButtonClick:(UIButton *)sender {
    if (!self.isMixing) {
        ZGLogWarn(@"❕ Please start mixer task first");
        [ZegoHudManager showMessage:@"❕ Please start mixer task first"];
        
        return;
    }
    
    unsigned long long whiteboardID = 0;
    if (self.whiteboardID.text.length > 0) {
        whiteboardID = [self.whiteboardID.text longLongValue];
    }
    
    ZegoMixerWhiteboard *whiteboard = nil;
    if (whiteboardID > 0) {
        int left = [self.whiteboardLayoutLeft.text intValue];
        int top = [self.whiteboardLayoutTop.text intValue];
        int width = [self.whiteboardLayoutWidth.text intValue];
        int height = [self.whiteboardLayoutHeight.text intValue];
        CGRect whiteboardLayout = CGRectMake(left, top, width, height);
        whiteboard = [[ZegoMixerWhiteboard alloc] initWithWhiteboardID:whiteboardID layout:whiteboardLayout];
        
        int zOrder = [self.whiteboardLayoutZOrder.text intValue];
        [whiteboard setZOrder:zOrder];
        
        BOOL isPPTAnimation = self.whiteboardPPTAnimation.on;
        [whiteboard setIsPPTAnimation:isPPTAnimation];
    }
    [self.mixerTask setWhiteboard:whiteboard];
    
    ZGLogInfo(@"📥 Update whiteboard config");
    [ZegoHudManager showMessage:@"📥 Update whiteboard config"];
    [[ZegoExpressEngine sharedEngine] startMixerTask:self.mixerTask callback:nil];
}

#pragma mark - ZegoEventHandler

// Refresh the remote streams list
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🌊 Room Stream Update Callback: %lu, StreamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);
    
    if (updateType == ZegoUpdateTypeAdd) {
        for (ZegoStream *stream in streamList) {
            ZGLogInfo(@"🚩 🌊 --- [Add] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID);
            if (![self.remoteStreamList containsObject:stream]) {
                [self.remoteStreamList addObject:stream];
            }
        }
    } else if (updateType == ZegoUpdateTypeDelete) {
        for (ZegoStream *stream in streamList) {
            ZGLogInfo(@"🚩 🌊 --- [Delete] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID);
            __block ZegoStream *delStream = nil;
            [self.remoteStreamList enumerateObjectsUsingBlock:^(ZegoStream * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.streamID isEqualToString:stream.streamID] && [obj.user.userID isEqualToString:stream.user.userID]) {
                    delStream = obj;
                    *stop = YES;
                }
            }];
            [self.remoteStreamList removeObject:delStream];
        }
    }
    // Refresh stream picker
    [self.selectStreamsPicker reloadAllComponents];
}

-(void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🚪 Room State Changed Callback: %lu, errorCode: %d, roomID: %@", (unsigned long)reason, (int)errorCode, roomID);
}

// Refresh the player state
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📥 Player State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
    self.playerState = state;
}

- (void)onMixerSoundLevelUpdate:(NSDictionary<NSNumber *,NSNumber *> *)soundLevels {
    for (NSNumber *key in soundLevels) {
        float progress = soundLevels[key].floatValue / 100.0;
        if (key.unsignedIntValue == ZGMixerFirstStreamSoundLevelID) {
            self.firstStreamSoundLevelProgressView.progress = progress;
        } else if (key.unsignedIntValue == ZGMixerSecondStreamSoundLevelID) {
            self.secondStreamSoundLevelProgressView.progress = progress;
        }
    }
}

#pragma mark - Setter, Manage UI State

- (void)setIsMixing:(BOOL)isMixing {
    _isMixing = isMixing;
    
    self.title = _isMixing ? @"🧬 Mixing" : @"Mixer";
    [self.startMixerTaskButton setTitle:_isMixing ? @"🎉 Stop Mixer Task" : @"Step 2️⃣: Start Mixer Task" forState:UIControlStateNormal];
}

- (void)setPlayerState:(ZegoPlayerState)playerState {
    _playerState = playerState;
    
    [self.startPlayButton setTitle:_playerState == ZegoPlayerStatePlaying ? @"🎉 Stop Playing" : @"Step 3️⃣: Play the Mixed Stream" forState:UIControlStateNormal];
}

#pragma mark - UIPickerView DataSource & Delegate

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.remoteStreamList.count + 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (row == 0) {
        if (component == 0) {
            self.selectFirstStream = nil;
            self.selectFirstStreamLabel.text = @"Not selected";
        } else if (component == 1) {
            self.selectSecondStream = nil;
            self.selectSecondStreamLabel.text = @"Not selected";
        }
    } else if (row > 0) {
        if (component == 0) {
            self.selectFirstStream = self.remoteStreamList[row - 1];
            self.selectFirstStreamLabel.text = self.remoteStreamList[row - 1].streamID;
        } else if (component == 1) {
            self.selectSecondStream = self.remoteStreamList[row - 1];
            self.selectSecondStreamLabel.text = self.remoteStreamList[row - 1].streamID;
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return @"Not selected";
    } else if (row > 0) {
        return self.remoteStreamList[row - 1].streamID;
    } else {
        return @"NULL";
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

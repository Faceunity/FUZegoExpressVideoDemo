//
//  ZGAECANSAGCViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/13.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGAECANSAGCViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
@interface ZGAECANSAGCViewController ()<ZegoEventHandler>
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

@property (weak, nonatomic) IBOutlet UIView *localPreviewView;
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;

// PlayStream
@property (weak, nonatomic) IBOutlet UILabel *playStreamLabel;

@property (weak, nonatomic) IBOutlet UIView *remotePlayView;
@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;

@property (weak, nonatomic) IBOutlet UILabel *aecLabel;
@property (weak, nonatomic) IBOutlet UILabel *aecNoticeLabel;
@property (weak, nonatomic) IBOutlet UILabel *aecNoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *headphoneAECLabel;
@property (weak, nonatomic) IBOutlet UILabel *aecModeLabel;
@property (weak, nonatomic) IBOutlet UIButton *aecModeButton;

@property (weak, nonatomic) IBOutlet UILabel *agcLabel;
@property (weak, nonatomic) IBOutlet UILabel *agcNoteLabel;

@property (weak, nonatomic) IBOutlet UILabel *ansLabel;
@property (weak, nonatomic) IBOutlet UILabel *ansNoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *ansModeLabel;
@property (weak, nonatomic) IBOutlet UIButton *ansModeButton;
@property (weak, nonatomic) IBOutlet UISwitch *musicDetectSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *musicDetectRecordSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *ansSwitch;
@property (nonatomic, assign) int ansMode;

@end

@implementation ZGAECANSAGCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.streamID = @"0019";
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0019";
    self.playStreamIDTextField.text = self.streamID;
    self.publishStreamIDTextField.text = self.streamID;
    self.userIDRoomIDLabel.text = [NSString stringWithFormat:@"UserID: %@  RoomID:%@", self.userID, self.roomID];
    self.ansMode = ZegoANSModeMedium;
    [self enableMusicDetect:YES];
    [self setupEngineAndLogin];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)setupEngineAndLogin {
    [self appendLog: [NSString stringWithFormat:@"🚀 Create ZegoExpressEngine"]];
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
    self.aecModeLabel.text = NSLocalizedString(@"AEC", nil);
    self.aecLabel.text = NSLocalizedString(@"AEC", nil);
    self.aecNoteLabel.text = NSLocalizedString(@"AEC", nil);
    self.aecNoticeLabel.text = NSLocalizedString(@"AECNotice", nil);

    self.agcLabel.text = NSLocalizedString(@"AGC", nil);
    self.agcNoteLabel.text = NSLocalizedString(@"AGC", nil);

    self.ansLabel.text = NSLocalizedString(@"ANS", nil);
    self.ansNoteLabel.text = NSLocalizedString(@"ANS", nil);
    self.ansModeLabel.text = NSLocalizedString(@"ANS", nil);

}

#pragma mark - Action

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

        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
    } else {
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.playStreamIDTextField.text]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:playCanvas];
    }
    sender.selected = !sender.isSelected;

}

- (IBAction)onAECSwitchChanged:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] enableAEC:sender.isOn];
    [self appendLog:[NSString stringWithFormat:@"📥 OnAECSwitchChanged %d", sender.isOn]];
}

- (IBAction)onHeadphoneAECSwitchChanged:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] enableHeadphoneAEC:sender.isOn];
    [self appendLog:[NSString stringWithFormat:@"📥 OnHeadphoneAECSwitchChanged %d", sender.isOn]];
}

- (IBAction)onAGCSwitchChanged:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] enableAGC:sender.isOn];
    [self appendLog:[NSString stringWithFormat:@"📥 OnAGCSwitchChanged %d", sender.isOn]];
}

- (IBAction)onANSSwitchChanged:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] enableANS:sender.isOn];
    [self appendLog:[NSString stringWithFormat:@"📥 OnANSSwitchChanged %d", sender.isOn]];
}

- (IBAction)onAECModeButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    UIAlertAction *aggressive  = [UIAlertAction actionWithTitle:@"Aggressive" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setAECMode:ZegoAECModeAggressive];
        [self.aecModeButton setTitle:@"Aggressive" forState:UIControlStateNormal];
    }];
    UIAlertAction *medium = [UIAlertAction actionWithTitle:@"Medium" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [[ZegoExpressEngine sharedEngine] setAECMode:ZegoAECModeMedium];
        [self.aecModeButton setTitle:@"Medium" forState:UIControlStateNormal];
    }];

    UIAlertAction *soft = [UIAlertAction actionWithTitle:@"Soft" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setAECMode:ZegoAECModeSoft];
        [self.aecModeButton setTitle:@"Soft" forState:UIControlStateNormal];
    }];
    [alertController addAction:cancel];
    [alertController addAction:aggressive];
    [alertController addAction:medium];
    [alertController addAction:soft];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onANSModeButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    UIAlertAction *ai  = [UIAlertAction actionWithTitle:@"AI" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [[ZegoExpressEngine sharedEngine] setANSMode: ZegoANSModeAI];
        [self.ansModeButton setTitle:@"AI" forState:UIControlStateNormal];
        self.ansMode = ZegoANSModeAI;
    }];
    UIAlertAction *aggressive  = [UIAlertAction actionWithTitle:@"Aggressive" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [[ZegoExpressEngine sharedEngine] setANSMode: ZegoANSModeAggressive];
        [self.ansModeButton setTitle:@"Aggressive" forState:UIControlStateNormal];
        self.ansMode = ZegoANSModeAggressive;
    }];
    UIAlertAction *medium = [UIAlertAction actionWithTitle:@"Medium" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [[ZegoExpressEngine sharedEngine] setANSMode:ZegoANSModeMedium];
        [self.ansModeButton setTitle:@"Medium" forState:UIControlStateNormal];
        self.ansMode = ZegoANSModeMedium;
    }];

    UIAlertAction *soft = [UIAlertAction actionWithTitle:@"Soft" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [[ZegoExpressEngine sharedEngine] setANSMode:ZegoANSModeSoft];
        [self.ansModeButton setTitle:@"Soft" forState:UIControlStateNormal];
        self.ansMode = ZegoANSModeSoft;
    }];

    [alertController addAction:cancel];
    [alertController addAction:ai];
    [alertController addAction:aggressive];
    [alertController addAction:medium];
    [alertController addAction:soft];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onMusicDetectSwitch:(UISwitch *)sender {
    [self enableMusicDetect:sender.isOn];
    
    [ZegoExpressEngine destroyEngine:nil];

    [self enableMusicDetect:sender.isOn];
    [self enableMusicDetectRecord:self.musicDetectRecordSwitch.isOn];

    [self setupEngineAndLogin];
    [self setupUI];

    [[ZegoExpressEngine sharedEngine]enableANS:self.ansSwitch.isOn];
    [[ZegoExpressEngine sharedEngine]setANSMode:self.ansMode];
}

- (IBAction)onMusicDetectRecordSwitch:(UISwitch *)sender {
    [ZegoExpressEngine destroyEngine:nil];

    [self enableMusicDetectRecord:sender.isOn];
    [self enableMusicDetect:self.musicDetectSwitch.isOn];

    [self setupEngineAndLogin];
    [self setupUI];

    [[ZegoExpressEngine sharedEngine]enableANS:self.ansSwitch.isOn];
    [[ZegoExpressEngine sharedEngine]setANSMode:self.ansMode];
}


-(void)enableMusicDetect:(BOOL)enable{
    NSString *ss = enable?@"true":@"false";
    ZegoEngineConfig *engineConfig = [[ZegoEngineConfig alloc]init];
    engineConfig.advancedConfig = @{@"enable_music_detection":ss};

    [ZegoExpressEngine setEngineConfig:engineConfig];
}

-(void)enableMusicDetectRecord:(BOOL)enable{
    NSString *ss = enable?@"true":@"false";
    ZegoEngineConfig *engineConfig = [[ZegoEngineConfig alloc]init];
    engineConfig.advancedConfig = @{@"enable_dump_file":ss};

    [ZegoExpressEngine setEngineConfig:engineConfig];
}

#pragma mark - ZegoEventHandler

/// Publish stream state callback
- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (state == ZegoPublisherStatePublishing && errorCode == 0) {
        [self appendLog:@"🚩 📤 Publishing stream success"];
        // Add a flag to the button for successful operation
        self.startPublishingButton.selected = true;
    }
    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 📤 Publishing stream fail"];
    }
}

/// Play stream state callback
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (state == ZegoPlayerStatePlaying && errorCode == 0) {
        [self appendLog:@"🚩 📥 Playing stream success"];
        // Add a flag to the button for successful operation
        self.startPlayingButton.selected = true;
    }
    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 📥 Playing stream fail"];
    }
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

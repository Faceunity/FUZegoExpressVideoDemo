//
//  ZGSecurityViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/13.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGSecurityViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
@interface ZGSecurityViewController ()<ZegoEventHandler>

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

@property (weak, nonatomic) IBOutlet UITextField *publishKeyTextField;
@property (weak, nonatomic) IBOutlet UIButton *setPublishStreamDecryptionKeyButton;

@property (weak, nonatomic) IBOutlet UIButton *setPlayStreamDecryptionKeyButton;


@property (weak, nonatomic) IBOutlet UITextField *playKeyTextField;


@end

@implementation ZGSecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0032";
    self.playStreamIDTextField.text = @"0032";
    self.publishStreamIDTextField.text = @"0032";
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
    
    [self.setPublishStreamDecryptionKeyButton setTitle:NSLocalizedString(@"PublishStreamDecryptionKeyButton", nil) forState:UIControlStateNormal];

    [self.setPlayStreamDecryptionKeyButton setTitle:NSLocalizedString(@"PlayStreamDecryptionKeyButton", nil) forState:UIControlStateNormal];

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

        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamIDTextField.text];
    } else {
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
        ZegoPlayerConfig *playConfig = [[ZegoPlayerConfig alloc] init];
        playConfig.resourceMode = ZegoStreamResourceModeOnlyRTC;
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@, resourceMode: %lu", self.playStreamIDTextField.text, playConfig.resourceMode]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:playCanvas config:playConfig];
    }
    sender.selected = !sender.isSelected;
    
}


- (IBAction)onSetPublishStreamEncryptionKeyButtonTapped:(id)sender {
    [self appendLog:[NSString stringWithFormat:@"🔒 Set publish stream encryption key: %@", self.publishKeyTextField.text]];

    [[ZegoExpressEngine sharedEngine] setPublishStreamEncryptionKey:self.publishKeyTextField.text];
}

- (IBAction)onSetPlayStreamEncryptionKeyButtonTapped:(id)sender {
    [self appendLog:[NSString stringWithFormat:@"🔒 Set play stream encryption key: %@", self.playKeyTextField.text]];

    [[ZegoExpressEngine sharedEngine] setPlayStreamDecryptionKey:self.playKeyTextField.text streamID:self.playStreamIDTextField.text];
    
}

- (IBAction)onTapPublishEncryptionHelperButton:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    alertController.message = NSLocalizedString(@"EncryptPublishNotice", nil);
    UIAlertAction *sureButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:sureButton];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onTapPlayEncryptionHelperButton:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    alertController.message = NSLocalizedString(@"EncryptPlayNotice", nil);
    UIAlertAction *sureButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:sureButton];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
    
}

#pragma mark - ZegoEventHandler

- (void)onPlayerRecvSEI:(NSData *)data streamID:(NSString *)streamID {
    [self appendLog:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
}

/// Publish stream state callback
- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (state == ZegoPublisherStatePublishing && errorCode == 0) {
        [self appendLog:@"🚩 📤 Publishing stream success"];
        // Add a flag to the button for successful operation
        self.startPublishingButton.selected = true;
    }
    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 📤 Publishing stream fail"];
        self.startPublishingButton.selected = false;
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
        self.startPlayingButton.selected = false;
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

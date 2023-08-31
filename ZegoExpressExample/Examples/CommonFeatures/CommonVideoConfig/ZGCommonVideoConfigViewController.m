//
//  ZGCommonVideoConfigViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/13.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGCommonVideoConfigViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
@interface ZGCommonVideoConfigViewController ()<ZegoEventHandler>

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
@property (weak, nonatomic) IBOutlet UIButton *previewViewModeButton;
@property (weak, nonatomic) IBOutlet UIButton *mirrorModeButton;

// PlayStream
@property (weak, nonatomic) IBOutlet UILabel *playStreamLabel;

@property (weak, nonatomic) IBOutlet UIView *remotePlayView;
@property (weak, nonatomic) IBOutlet UITextField *playStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;
@property (weak, nonatomic) IBOutlet UIButton *playStreamViewModeButton;

@property (weak, nonatomic) IBOutlet UILabel *encodeResolutionLabel;
@property (weak, nonatomic) IBOutlet UITextField *encodeResolutionWidthTextField;
@property (weak, nonatomic) IBOutlet UITextField *encodeResolutionHeightTextField;

@property (weak, nonatomic) IBOutlet UILabel *captureResolutionLabel;
@property (weak, nonatomic) IBOutlet UITextField *captureResolutionWidthTextField;
@property (weak, nonatomic) IBOutlet UITextField *captureResolutionHeightTextField;

@property (weak, nonatomic) IBOutlet UILabel *videoFPSLabel;
@property (weak, nonatomic) IBOutlet UITextField *videoFPSTextField;

@property (weak, nonatomic) IBOutlet UILabel *videoBitrateLabel;
@property (weak, nonatomic) IBOutlet UITextField *videoBitrateTextField;

@end

@implementation ZGCommonVideoConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playStreamIDTextField.text = @"0005";
    self.publishStreamIDTextField.text = @"0005";
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0005";

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
        //Set Video Config Before StartPreview And StartPublishing
        ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] init];
        
        videoConfig.captureResolution = CGSizeMake(self.captureResolutionWidthTextField.text.intValue, self.captureResolutionHeightTextField.text.intValue);
        videoConfig.encodeResolution = CGSizeMake(self.encodeResolutionWidthTextField.text.intValue, self.encodeResolutionHeightTextField.text.intValue);

        videoConfig.fps = self.videoFPSTextField.text.intValue;
        videoConfig.bitrate = self.videoBitrateTextField.text.intValue;

        [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];


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

- (IBAction)onMirrorModeButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *onlyPreview = [UIAlertAction actionWithTitle:@"OnlyPreview" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeOnlyPreviewMirror];
        [self.mirrorModeButton setTitle:@"OnlyPreview" forState:UIControlStateNormal];
    }];
    UIAlertAction *onlyPublish = [UIAlertAction actionWithTitle:@"OnlyPublish" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeOnlyPublishMirror];
        [self.mirrorModeButton setTitle:@"OnlyPublish" forState:UIControlStateNormal];

    }];
    UIAlertAction *bothMirror = [UIAlertAction actionWithTitle:@"BothMirror" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeBothMirror];
        [self.mirrorModeButton setTitle:@"BothMirror" forState:UIControlStateNormal];
    }];
    UIAlertAction *noMirror = [UIAlertAction actionWithTitle:@"NoMirror" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeNoMirror];
        [self.mirrorModeButton setTitle:@"NoMirror" forState:UIControlStateNormal];
    }];

    [alertController addAction:cancel];
    [alertController addAction:onlyPreview];
    [alertController addAction:onlyPublish];
    [alertController addAction:bothMirror];
    [alertController addAction:noMirror];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onPlayStreamViewModeButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *aspectFit = [UIAlertAction actionWithTitle:@"AspectFit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
        previewCanvas.viewMode = ZegoViewModeAspectFit;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:previewCanvas];
        [self.playStreamViewModeButton setTitle:@"AspectFit" forState:UIControlStateNormal];

    }];
    UIAlertAction *aspectFill = [UIAlertAction actionWithTitle:@"AspectFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
        previewCanvas.viewMode = ZegoViewModeAspectFill;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:previewCanvas];
        [self.playStreamViewModeButton setTitle:@"AspectFill" forState:UIControlStateNormal];
    }];
    UIAlertAction *scaleToFill = [UIAlertAction actionWithTitle:@"ScaleToFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.remotePlayView];
        previewCanvas.viewMode = ZegoViewModeScaleToFill;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamIDTextField.text canvas:previewCanvas];
        [self.playStreamViewModeButton setTitle:@"ScaleToFill" forState:UIControlStateNormal];
    }];
    [alertController addAction:cancel];
    [alertController addAction:aspectFit];
    [alertController addAction:aspectFill];
    [alertController addAction:scaleToFill];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onPreviewViewModeButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *aspectFit = [UIAlertAction actionWithTitle:@"AspectFit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
        previewCanvas.viewMode = ZegoViewModeAspectFit;
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        [self.previewViewModeButton setTitle:@"AspectFit" forState:UIControlStateNormal];

    }];
    UIAlertAction *aspectFill = [UIAlertAction actionWithTitle:@"AspectFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
        previewCanvas.viewMode = ZegoViewModeAspectFill;
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        [self.previewViewModeButton setTitle:@"AspectFill" forState:UIControlStateNormal];
    }];
    UIAlertAction *scaleToFill = [UIAlertAction actionWithTitle:@"ScaleToFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
        previewCanvas.viewMode = ZegoViewModeScaleToFill;
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        [self.previewViewModeButton setTitle:@"ScaleToFill" forState:UIControlStateNormal];
    }];
    [alertController addAction:cancel];
    [alertController addAction:aspectFit];
    [alertController addAction:aspectFill];
    [alertController addAction:scaleToFill];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onVideoBitrateChanged:(UITextField *)sender {
    ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] init];

    videoConfig.encodeResolution = CGSizeMake(self.encodeResolutionWidthTextField.text.intValue, self.encodeResolutionHeightTextField.text.intValue);

    videoConfig.fps = self.videoFPSTextField.text.intValue;
    videoConfig.bitrate = sender.text.intValue;

    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
}

- (IBAction)onVideoFPSChanged:(UITextField *)sender {
    ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] init];

    videoConfig.encodeResolution = CGSizeMake(self.encodeResolutionWidthTextField.text.intValue, self.encodeResolutionHeightTextField.text.intValue);

    videoConfig.fps = sender.text.intValue;
    videoConfig.bitrate = self.videoBitrateTextField.text.intValue;

    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
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

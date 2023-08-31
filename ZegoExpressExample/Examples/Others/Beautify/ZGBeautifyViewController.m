//
//  ZGBeautifyViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/10.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGBeautifyViewController.h"
#import "ZGBeautifyConfigTableViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGBeautifyViewController () <ZegoEventHandler>

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *playView;

@end

@implementation ZGBeautifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomID = @"0024";
    self.streamID = @"0024";
    
    // Create Engine
    [self createEngine];
        
    // Login Room
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    [self appendLog:[NSString stringWithFormat:@"🚪Login Room roomID: %@", self.roomID]];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user];
    
}

- (void)createEngine {
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
}

- (IBAction)onTakePublishStreamSnapshotButtonTapped:(id)sender {
    __weak typeof(self) weakSelf = self;
    [[ZegoExpressEngine sharedEngine] takePublishStreamSnapshot:^(int errorCode, UIImage * _Nullable image) {
        __strong typeof(self) strongSelf = weakSelf;

        [strongSelf appendLog:[NSString stringWithFormat:@"🚩 📸 Take snapshot result, errorCode: %d, w:%.f, h:%.f", errorCode, image.size.width, image.size.height]];

        if (errorCode == ZegoErrorCodeCommonSuccess && image) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width / 2, UIScreen.mainScreen.bounds.size.height / 2)];
            imageView.image = image;
            imageView.contentMode = UIViewContentModeScaleAspectFit;

            [ZegoHudManager showCustomMessage:@"Take Snapshot" customView:imageView done:nil];
        }
    }];

    [self appendLog:[NSString stringWithFormat:@"📸 Take snapshot"]];
}
- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop publishing
        // Use userID as streamID
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.streamID]];

        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        [[ZegoExpressEngine sharedEngine] stopPreview];
    } else {
        // Start preview
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
        [self appendLog:@"🔌 Start preview"];
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        
        // Start publishing
        // Use userID as streamID
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.streamID]];
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];
    }
    sender.selected = !sender.isSelected;
    
}
- (IBAction)onStartPlayingButtonTappd:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", self.streamID]];
        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamID];
    } else {
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.streamID]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamID canvas:playCanvas];
    }
    sender.selected = !sender.isSelected;
    
}

- (IBAction)onTakePlayStreamSnapshotButtonTapped:(id)sender {
    __weak typeof(self) weakSelf = self;
    [[ZegoExpressEngine sharedEngine] takePlayStreamSnapshot:self.streamID callback:^(int errorCode, ZGImage * _Nullable image) {
        __strong typeof(self) strongSelf = weakSelf;

        [strongSelf appendLog:[NSString stringWithFormat:@"🚩 📸 Take snapshot result, errorCode: %d, w:%.f, h:%.f", errorCode, image.size.width, image.size.height]];

        if (errorCode == ZegoErrorCodeCommonSuccess && image) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width / 2, UIScreen.mainScreen.bounds.size.height / 2)];
            imageView.image = image;
            imageView.contentMode = UIViewContentModeScaleAspectFit;

            [ZegoHudManager showCustomMessage:@"Take Snapshot" customView:imageView done:nil];
        }
    }];

    [self appendLog:[NSString stringWithFormat:@"📸 Take snapshot"]];
}

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

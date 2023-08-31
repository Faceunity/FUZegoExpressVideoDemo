//
//  ZGVideoForMultipleUsersItemView.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/21.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGVideoForMultipleUsersPublisherView.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGVideoForMultipleUsersPublisherView ()

@property(weak, nonatomic) ZGVideoTalkViewObject *viewModel;
@property (nonatomic, assign) ZegoViewMode viewMode;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *networkQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *streamQualityLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewModeButton;
@property (weak, nonatomic) IBOutlet UIButton *mirrorModeButton;
@property (weak, nonatomic) IBOutlet UISwitch *cameraSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cameraSegment;

@property (weak, nonatomic) IBOutlet UISwitch *microphoneSwitch;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@property (weak, nonatomic) id owner;

@end

@implementation ZGVideoForMultipleUsersPublisherView

+ (instancetype)itemViewWithViewModel:(ZGVideoTalkViewObject *)viewModel owner:(nullable id)owner{
    ZGVideoForMultipleUsersPublisherView *itemView = [[[NSBundle mainBundle] loadNibNamed:@"ZGVideoForMultipleUsersPublisherView" owner:self options:nil] objectAtIndex:0];
    itemView.viewModel = viewModel;
    itemView.owner = owner;
    itemView.userLabel.text = [NSString stringWithFormat:@"%@(%@)", NSLocalizedString(@"Me", nil),viewModel.userName];
    return itemView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
    self.layer.borderWidth = 1;
}

- (void)updateStreamQuility:(NSString *)quality {
    self.streamQualityLabel.text = quality;
}

- (void)updateNetworkQuility:(NSString *)quality {
    self.networkQualityLabel.text = quality;
}

- (void)updateResolution:(NSString *)resolution {
    self.resolutionLabel.text = resolution;
}

- (IBAction)startPublishingButtonClick:(UIButton *)sender {
    if (!sender.isSelected) {
        [self startPublishingStream];
    } else {
        [self stopPublishingStream];
    }
    sender.selected = !sender.isSelected;
}


- (void)startPublishingStream {
    ZGLogInfo(@"🔌 Start preview");
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self];
    previewCanvas.viewMode = self.viewMode;
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];

    // Local user start publishing
    ZGLogInfo(@"📤 Start publishing stream, streamID: %@", self.viewModel.streamID);
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.viewModel.streamID];
}

- (void)stopPublishingStream {
    [self appendLog:@"📤 Stop preview"];
    [[ZegoExpressEngine sharedEngine] stopPreview];

    // Stop publishing
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [self appendLog:@"📤 Stop publishing stream"];
//    self.publishQualityLabel.text = @"";
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
    [self.owner presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onViewModeButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *aspectFit = [UIAlertAction actionWithTitle:@"AspectFit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self];
        previewCanvas.viewMode = ZegoViewModeAspectFit;
        self.viewMode = ZegoViewModeAspectFit;
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        [self.viewModeButton setTitle:@"AspectFit" forState:UIControlStateNormal];

    }];
    UIAlertAction *aspectFill = [UIAlertAction actionWithTitle:@"AspectFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self];
        previewCanvas.viewMode = ZegoViewModeAspectFill;
        self.viewMode = ZegoViewModeAspectFit;
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        [self.viewModeButton setTitle:@"AspectFill" forState:UIControlStateNormal];
    }];
    UIAlertAction *scaleToFill = [UIAlertAction actionWithTitle:@"ScaleToFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self];
        previewCanvas.viewMode = ZegoViewModeScaleToFill;
        self.viewMode = ZegoViewModeAspectFit;
        [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
        [self.viewModeButton setTitle:@"ScaleToFill" forState:UIControlStateNormal];
    }];
    [alertController addAction:cancel];
    [alertController addAction:aspectFit];
    [alertController addAction:aspectFill];
    [alertController addAction:scaleToFill];
    alertController.popoverPresentationController.sourceView = sender;
    [self.owner presentViewController:alertController animated:true completion:nil];
}


- (IBAction)onSwitchCamera:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] mutePublishStreamVideo:!sender.isOn];

}

- (IBAction)onChangeCamera:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [[ZegoExpressEngine sharedEngine] useFrontCamera:YES];
    } else {
        [[ZegoExpressEngine sharedEngine] useFrontCamera:NO];
    }

}

- (IBAction)onSwitchMicrophone:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] mutePublishStreamAudio:!sender.isOn];
}

/// Append Log to Top View
- (void)appendLog:(NSString *)tipText {
    if (!tipText || tipText.length == 0) {
        return;
    }

    ZGLogInfo(@"%@", tipText);

//    NSString *oldText = self.logTextView.text;
//    NSString *newLine = oldText.length == 0 ? @"" : @"\n";
//    NSString *newText = [NSString stringWithFormat:@"%@%@ %@", oldText, newLine, tipText];
//
//    self.logTextView.text = newText;
//    if(newText.length > 0 ) {
//        UITextView *textView = self.logTextView;
//        NSRange bottom = NSMakeRange(newText.length -1, 1);
//        [textView scrollRangeToVisible:bottom];
//        // an iOS bug, see https://stackoverflow.com/a/20989956/971070
//        [textView setScrollEnabled:NO];
//        [textView setScrollEnabled:YES];
//    }
}

@end

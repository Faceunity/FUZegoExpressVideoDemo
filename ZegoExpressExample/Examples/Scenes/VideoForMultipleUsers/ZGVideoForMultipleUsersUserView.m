//
//  ZGVideoForMultipleUsersItemView.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/21.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGVideoForMultipleUsersUserView.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGVideoForMultipleUsersUserView ()

@property(weak, nonatomic) ZGVideoTalkViewObject *viewModel;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *networkQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *streamQualityLabel;
@property (nonatomic, assign) ZegoViewMode viewMode;
@property (weak, nonatomic) IBOutlet UIButton *viewModeButton;
@property (weak, nonatomic) IBOutlet UISwitch *videoSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *audioSwitch;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@property (weak, nonatomic) UIViewController *owner;

@end

@implementation ZGVideoForMultipleUsersUserView

+ (instancetype)itemViewWithViewModel:(ZGVideoTalkViewObject *)viewModel owner:(nullable UIViewController *)owner {
    ZGVideoForMultipleUsersUserView *itemView = [[[NSBundle mainBundle] loadNibNamed:@"ZGVideoForMultipleUsersUserView" owner:self options:nil] objectAtIndex:0];
    itemView.viewModel = viewModel;
    itemView.owner = owner;
    itemView.userLabel.text = viewModel.userName;
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

- (IBAction)startPlayingButtonClick:(UIButton *)sender {
    if (!sender.isSelected) {
        if (self.viewModel.streamID != nil) {
            [self startPlayingStream];
            sender.selected = !sender.isSelected;
        } else {
            UIAlertController *alertController = [[UIAlertController alloc] init];
            alertController.message = @"❌ The User Is Not Publishing Stream";
            UIAlertAction *sureButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }];
            [alertController addAction:sureButton];
            alertController.popoverPresentationController.sourceView = sender;
            [self.owner presentViewController:alertController animated:true completion:nil];
        }
    } else {
        [self stopPlayingStream];
        sender.selected = !sender.isSelected;
    }
}

- (void)startPlayingStream {
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self];
    playCanvas.viewMode = self.viewMode;

    // Start playing
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.viewModel.streamID canvas:playCanvas];
}

- (void)stopPlayingStream {
    // Stop playing
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.viewModel.streamID];
    [self appendLog:@"📥 Stop playing stream"];
}

- (IBAction)onViewModeButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *aspectFit = [UIAlertAction actionWithTitle:@"AspectFit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *canvas = [ZegoCanvas canvasWithView:self];
        canvas.viewMode = ZegoViewModeAspectFit;
        self.viewMode = ZegoViewModeAspectFit;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.viewModel.streamID canvas:canvas];
        [self.viewModeButton setTitle:@"AspectFit" forState:UIControlStateNormal];

    }];
    UIAlertAction *aspectFill = [UIAlertAction actionWithTitle:@"AspectFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *canvas = [ZegoCanvas canvasWithView:self];
        canvas.viewMode = ZegoViewModeAspectFill;
        self.viewMode = ZegoViewModeAspectFit;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.viewModel.streamID canvas:canvas];
        [self.viewModeButton setTitle:@"AspectFill" forState:UIControlStateNormal];
    }];
    UIAlertAction *scaleToFill = [UIAlertAction actionWithTitle:@"ScaleToFill" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        ZegoCanvas *canvas = [ZegoCanvas canvasWithView:self];
        canvas.viewMode = ZegoViewModeScaleToFill;
        self.viewMode = ZegoViewModeAspectFit;
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.viewModel.streamID canvas:canvas];
        [self.viewModeButton setTitle:@"ScaleToFill" forState:UIControlStateNormal];
    }];
    [alertController addAction:cancel];
    [alertController addAction:aspectFit];
    [alertController addAction:aspectFill];
    [alertController addAction:scaleToFill];
    alertController.popoverPresentationController.sourceView = sender;
    [self.owner presentViewController:alertController animated:true completion:nil];
}


- (IBAction)onSwitchVideo:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] mutePlayStreamVideo:!sender.isOn streamID:self.viewModel.streamID];

}

- (IBAction)onSwitchAudio:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] mutePlayStreamAudio:!sender.isOn streamID:self.viewModel.streamID];
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

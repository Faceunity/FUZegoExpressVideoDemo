//
//  ZGTestMainViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/12.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_Test

#import "ZGTestMainViewController.h"
#import "ZGTestSettingTableViewController.h"
#import "ZGTestTopicManager.h"
#import "ZegoLogView.h"

@interface ZGTestMainViewController () <ZGTestViewDelegate, ZGTestDataSource>


// View
@property (weak, nonatomic) IBOutlet UIView *publishView;
@property (weak, nonatomic) IBOutlet UILabel *publishQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishResolutionLabel;

@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UILabel *playQualityLabel;
@property (weak, nonatomic) IBOutlet UILabel *playResolutionLabel;

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@end

@implementation ZGTestMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TestTableVCSegue"]) {
        ZGTestSettingTableViewController *vc = segue.destinationViewController;
        [vc setZGTestViewDelegate:self];
        self.manager = [[ZGTestTopicManager alloc] init];
        [self.manager setZGTestDataSource:self];
        vc.manager = self.manager;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)setupUI {
    UIBarButtonItem *logButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log" style:UIBarButtonItemStylePlain target:self action:@selector(showLogView)];
    self.navigationItem.rightBarButtonItem = logButtonItem;
    
    self.publishQualityLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.publishQualityLabel.textColor = [UIColor whiteColor];
    
    self.publishResolutionLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.publishResolutionLabel.textColor = [UIColor whiteColor];
    
    self.playQualityLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.playQualityLabel.textColor = [UIColor whiteColor];
    
    self.playResolutionLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.playResolutionLabel.textColor = [UIColor whiteColor];
    
    self.logTextView.text = @"";
    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];
}

- (void)showLogView {
    [ZegoLogView show];
}

- (nonnull UIView *)getPlayView {
    return self.playView;
}

- (nonnull UIView *)getPublishView {
    return self.publishView;
}

- (void)appendLog:(NSString *)tipText {
    if (!tipText || tipText.length == 0) {
        return;
    }
    
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

#pragma mark - ZGTestDataSource

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality {
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
    [text appendFormat:@"FPS: %d fps\n", (int)quality.videoSendFPS];
    [text appendFormat:@"Bitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"HardwareEncode: %@ \n", quality.isHardwareEncode ? @"✅" : @"❎"];
    [text appendFormat:@"NetworkQuality: %@", networkQuality];
    self.publishQualityLabel.text = text;
}

- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality {
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
    [text appendFormat:@"FPS: %d fps\n", (int)quality.videoRecvFPS];
    [text appendFormat:@"Bitrate: %.2f kb/s \n", quality.videoKBPS];
    [text appendFormat:@"HardwareDecode: %@ \n", quality.isHardwareDecode ? @"✅" : @"❎"];
    [text appendFormat:@"NetworkQuality: %@", networkQuality];
    self.playQualityLabel.text = text;
}

- (void)onPublisherVideoSizeChanged:(CGSize)size {
    self.publishResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f", size.width, size.height];
}

- (void)onPlayerVideoSizeChanged:(CGSize)size {
    self.playResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f", size.width, size.height];
}

- (void)onActionLog:(NSString *)logInfo {
    [self appendLog:logInfo];
}

@end

#endif

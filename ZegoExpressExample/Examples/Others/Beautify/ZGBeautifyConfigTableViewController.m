//
//  ZGBeautifyConfigTableViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/10.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGBeautifyConfigTableViewController.h"
#import <UIKit/UITableView.h>


@interface ZGBeautifyConfigTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewRowAction *watermarkSection;


// watermark
@property (nonatomic, strong) ZegoWatermark *watermark;
@property (nonatomic, assign) BOOL enableWatermark;
@property (nonatomic, assign) BOOL watermarkIsPreviewVisble;
@property (weak, nonatomic) IBOutlet UISwitch *watermarkSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *watermarkIsPreviewVisibleSwitch;
@property (weak, nonatomic) IBOutlet UITextField *watermarkFilePathTextField;

@end

@implementation ZGBeautifyConfigTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.watermark = [[ZegoWatermark alloc] init];
    self.enableWatermark = NO;
    self.watermarkIsPreviewVisble = YES;
    
    [self setupUI];
}

- (void)setupUI {
    self.watermarkFilePathTextField.text = @"asset://ZegoLogo";
}


#pragma mark - Watermark

- (void)updateWatermark {
    self.watermark.imageURL = self.watermarkFilePathTextField.text;
    [[ZegoExpressEngine sharedEngine] setPublishWatermark:self.watermark isPreviewVisible:self.watermarkIsPreviewVisble];
}

- (IBAction)watermarkSwitchAction:(UISwitch *)sender {
    if (sender.on) {
        self.watermark.layout = CGRectMake(10, 10, 100, 18.75); // Ratio of ZegoLogo.png
    } else {
        self.watermark.layout = CGRectZero;
    }
    [self updateWatermark];
}

- (IBAction)watermarkIsPreviewVisibleSwitchAction:(UISwitch *)sender {
    self.watermarkIsPreviewVisble = sender.on;
    [self updateWatermark];
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"WatermarkTitle", nil);
    }
    return @"";
}
@end

//
//  ZGCustomVideoProcessLoginViewController.m
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2021/11/15.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGCustomVideoProcessLoginViewController.h"
#import "ZGCustomVideoProcessPublishStreamViewController.h"

typedef NS_ENUM(NSUInteger, ZGCustomVideoProcessFPS) {
    ZGCustomVideoProcessFPS5,
    ZGCustomVideoProcessFPS10,
    ZGCustomVideoProcessFPS15,
    ZGCustomVideoProcessFPS24,
    ZGCustomVideoProcessFPS30,
};

@interface ZGCustomVideoProcessLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *resolutionSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fpsSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *renderBackendSeg;

@end

@implementation ZGCustomVideoProcessLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Custom Video Process";
    self.roomIDTextField.text = @"0015";
    self.streamIDTextField.text = [NSString stringWithFormat:@"%u", arc4random() % 10000];
    
    [self.fpsSeg setSelectedSegmentIndex:2]; // Use 15 FPS by default
}

- (IBAction)publishStream:(UIButton *)sender {
    if (!self.roomIDTextField.text || [self.roomIDTextField.text isEqualToString:@""]) {
        ZGLogError(@"❗️ Please fill in roomID.");
        return;
    }

    if (!self.streamIDTextField.text || [self.streamIDTextField.text isEqualToString:@""]) {
        ZGLogError(@"❗️ Please fill in streamID.");
        return;
    }

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomVideoProcess" bundle:nil];
    ZGCustomVideoProcessPublishStreamViewController *publisherVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGCustomVideoProcessPublishStreamViewController class])];

    publisherVC.roomID = self.roomIDTextField.text;
    publisherVC.streamID = self.streamIDTextField.text;
    
    publisherVC.resolutionPreset = self.resolutionSeg.selectedSegmentIndex + 2;
    publisherVC.fps = [self getFpsByPreset:self.fpsSeg.selectedSegmentIndex];
    publisherVC.filterType = self.filterSeg.selectedSegmentIndex;
    publisherVC.renderBackend = self.renderBackendSeg.selectedSegmentIndex;

    [self.navigationController pushViewController:publisherVC animated:YES];
}

- (int)getFpsByPreset:(ZGCustomVideoProcessFPS)preset {
    switch (preset) {
        case ZGCustomVideoProcessFPS5:
            return 5;
            break;
        case ZGCustomVideoProcessFPS10:
            return 10;
            break;
        case ZGCustomVideoProcessFPS15:
            return 15;
            break;
        case ZGCustomVideoProcessFPS24:
            return 24;
            break;
        case ZGCustomVideoProcessFPS30:
            return 30;
            break;
    }
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

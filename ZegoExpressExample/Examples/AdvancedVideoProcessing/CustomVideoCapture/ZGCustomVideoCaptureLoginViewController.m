//
//  ZGCustomVideoCaptureLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/12.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGCustomVideoCaptureLoginViewController.h"
#import "ZGCustomVideoCapturePublishStreamViewController.h"

NSString* const ZGCustomVideoCaptureLoginVCKey_roomID = @"kRoomID";
NSString* const ZGCustomVideoCaptureLoginVCKey_streamID = @"kStreamID";

@interface ZGCustomVideoCaptureLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *captureSourceTypeSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *captureDataFormatSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *captureBufferTypeSeg;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;


@end

@implementation ZGCustomVideoCaptureLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Custom Video Capture";
    self.roomIDTextField.text = @"0014";
    self.streamIDTextField.text = @"0014";
    [self setupUI];
}

- (void)setupUI {

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

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomVideoCapture" bundle:nil];
    ZGCustomVideoCapturePublishStreamViewController *publisherVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGCustomVideoCapturePublishStreamViewController class])];

    publisherVC.roomID = self.roomIDTextField.text;
    publisherVC.streamID = self.streamIDTextField.text;

    publisherVC.captureSourceType = self.captureSourceTypeSeg.selectedSegmentIndex;
    publisherVC.captureDataFormat = self.captureDataFormatSeg.selectedSegmentIndex;
    publisherVC.captureBufferType = self.captureBufferTypeSeg.selectedSegmentIndex;

    [self.navigationController pushViewController:publisherVC animated:YES];
}

- (IBAction)captureSourceSegValueChanged:(UISegmentedControl *)sender {
    if (self.captureSourceTypeSeg.selectedSegmentIndex == 0) {
        [self.captureDataFormatSeg setEnabled:YES forSegmentAtIndex:1];
        [self.captureDataFormatSeg setSelectedSegmentIndex:0];
    } else {
        [self.captureDataFormatSeg setEnabled:NO forSegmentAtIndex:1];
        [self.captureDataFormatSeg setSelectedSegmentIndex:0];
    }
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

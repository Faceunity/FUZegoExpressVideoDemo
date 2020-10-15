//
//  ZGCustomVideoCaptureLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/12.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_CustomVideoCapture

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


@end

@implementation ZGCustomVideoCaptureLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Custom Video Capture";
    
    [self setupUI];
}

- (void)setupUI {
    self.roomIDTextField.text = [self savedValueForKey:ZGCustomVideoCaptureLoginVCKey_roomID];
    self.streamIDTextField.text = [self savedValueForKey:ZGCustomVideoCaptureLoginVCKey_streamID];
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

    [self saveValue:self.roomIDTextField.text forKey:ZGCustomVideoCaptureLoginVCKey_roomID];
    [self saveValue:self.streamIDTextField.text forKey:ZGCustomVideoCaptureLoginVCKey_streamID];

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
    if (self.captureSourceTypeSeg.selectedSegmentIndex == 1) {
        [self.captureDataFormatSeg setEnabled:NO forSegmentAtIndex:1];
        [self.captureDataFormatSeg setSelectedSegmentIndex:0];
    } else {
        [self.captureDataFormatSeg setEnabled:YES forSegmentAtIndex:1];
        [self.captureDataFormatSeg setSelectedSegmentIndex:0];
    }
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

#endif

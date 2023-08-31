//
//  ZGCustomAudioCaptureAndRenderingLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGCustomAudioCaptureAndRenderingLoginViewController.h"
#import "ZGCustomAudioCaptureAndRenderingViewController.h"

@interface ZGCustomAudioCaptureAndRenderingLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *captureFormatSeg;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sampleRateSeg;
@property (nonatomic, strong) NSDictionary<NSNumber *, NSNumber *> *sampleRateSegMap;
@property (weak, nonatomic) IBOutlet UISwitch *saveAudioDataSwitch;

@end

@implementation ZGCustomAudioCaptureAndRenderingLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.roomIDTextField.text = @"0022";
    self.sampleRateSeg.selectedSegmentIndex = 1;
    self.sampleRateSegMap = @{
        @0: @8000,
        @1: @16000,
        @2: @24000,
        @3: @32000,
        @4: @44100,
        @5: @48000,
    };
}

- (IBAction)startLiveButtonClick:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomAudioCaptureAndRendering"
                                                 bundle:nil];
    ZGCustomAudioCaptureAndRenderingViewController *vc = [sb
        instantiateViewControllerWithIdentifier:@"ZGCustomAudioCaptureAndRenderingViewController"];

    vc.roomID = self.roomIDTextField.text;
    vc.captureFormat = self.captureFormatSeg.selectedSegmentIndex;
    vc.sampleRate = self.sampleRateSegMap[@(self.sampleRateSeg.selectedSegmentIndex)].integerValue;
    vc.saveAudioDataToDocuments = self.saveAudioDataSwitch.on;
    
    [self.navigationController pushViewController:vc animated:YES];
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

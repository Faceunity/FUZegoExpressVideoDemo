//
//  ZGCustomAudioIOLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_CustomAudioIO

#import "ZGCustomAudioIOLoginViewController.h"
#import "ZGCustomAudioIOViewController.h"

NSString* const ZGCustomAudioIORoomID = @"ZGCustomAudioIORoomID";
NSString* const ZGCustomAudioIOLocalPublishStreamID = @"ZGCustomAudioIOLocalPublishStreamID";
NSString* const ZGCustomAudioIORemotePlayStreamID = @"ZGCustomAudioIORemotePlayStreamID";

@interface ZGCustomAudioIOLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *localPublishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *remotePlayStreamIDTextField;

@end

@implementation ZGCustomAudioIOLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.roomIDTextField.text = [self savedValueForKey:ZGCustomAudioIORoomID];
    self.localPublishStreamIDTextField.text = [self savedValueForKey:ZGCustomAudioIOLocalPublishStreamID];
    self.remotePlayStreamIDTextField.text = [self savedValueForKey:ZGCustomAudioIORemotePlayStreamID];
}

- (IBAction)startLiveButtonClick:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomAudioIO" bundle:nil];
    ZGCustomAudioIOViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGCustomAudioIOViewController class])];

    [self saveValue:self.roomIDTextField.text forKey:ZGCustomAudioIORoomID];
    [self saveValue:self.localPublishStreamIDTextField.text forKey:ZGCustomAudioIOLocalPublishStreamID];
    [self saveValue:self.remotePlayStreamIDTextField.text forKey:ZGCustomAudioIORemotePlayStreamID];

    vc.roomID = self.roomIDTextField.text;
    vc.localPublishStreamID = self.localPublishStreamIDTextField.text;
    vc.remotePlayStreamID = self.remotePlayStreamIDTextField.text;

    [self.navigationController pushViewController:vc animated:YES];
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

#endif

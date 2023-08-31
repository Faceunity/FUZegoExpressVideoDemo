//
//  ZGVideoForMultipleUsersLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/12.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGVideoForMultipleUsersLoginViewController.h"
#import "ZGVideoForMultipleUsersViewController.h"
#import "ZGUserIDHelper.h"

@interface ZGVideoForMultipleUsersLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@property (weak, nonatomic) IBOutlet UITextField *captureResolutionWidthTextField;
@property (weak, nonatomic) IBOutlet UITextField *captureResolutionHeightTextField;

@property (weak, nonatomic) IBOutlet UITextField *encodeResolutionWidthTextField;
@property (weak, nonatomic) IBOutlet UITextField *encodeResolutionHeightTextField;

@property (weak, nonatomic) IBOutlet UILabel *videoFPSLabel;
@property (weak, nonatomic) IBOutlet UITextField *videoFPSTextField;

@property (weak, nonatomic) IBOutlet UILabel *videoBitrateLabel;
@property (weak, nonatomic) IBOutlet UITextField *videoBitrateTextField;

@end

@implementation ZGVideoForMultipleUsersLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.roomIDTextField.text = @"0004";
    self.userIDTextField.text = [ZGUserIDHelper userID];
    self.userIDTextField.enabled = false;
    self.userNameTextField.text = [@"Name_%@" stringByAppendingString:[ZGUserIDHelper userID]];
    [self setupUI];
}

- (void)setupUI {

}

- (IBAction)onLoginButtonTapped:(UIButton *)sender {
    if (!self.roomIDTextField.text || [self.roomIDTextField.text isEqualToString:@""]) {
        ZGLogError(@"❗️ Please fill in roomID.");
        return;
    }

    if (!self.userIDTextField.text || [self.userIDTextField.text isEqualToString:@""]) {
        ZGLogError(@"❗️ Please fill in userID.");
        return;
    }

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"VideoForMultipleUsers" bundle:nil];
    ZGVideoForMultipleUsersViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGVideoForMultipleUsersViewController class])];

    vc.roomID = self.roomIDTextField.text;
    vc.localUserID = self.userIDTextField.text;
    vc.localUserName = self.userNameTextField.text;
    
    vc.captureResolution = CGSizeMake(self.captureResolutionWidthTextField.text.floatValue, self.captureResolutionHeightTextField.text.floatValue);
    vc.encodeResolution = CGSizeMake(self.encodeResolutionWidthTextField.text.floatValue, self.encodeResolutionHeightTextField.text.floatValue);
    
    vc.videoFps = self.videoFPSTextField.text.floatValue;
    vc.videoBitrate = self.videoBitrateTextField.text.floatValue;

    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onParamsInput:(UITextField *)sender {
    sender.text = @([sender.text integerValue]).stringValue;
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

//
//  ZGH265LoginViewController.m
//  ZegoExpressExample
//
//  Created by 王鑫 on 2021/8/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGH265LoginViewController.h"
#import "ZGH265ViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"

@interface ZGH265LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;

@end

@implementation ZGH265LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomIDTextField.text = @"H265_Room";
    self.userIDTextField.text = [ZGUserIDHelper userID];
    self.userIDTextField.enabled = false;
}

- (IBAction)loginRoomButtonClick:(id)sender {
    ZGH265ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"H265"];
    
    vc.roomID = self.roomIDTextField.text;
    vc.userID = self.userIDTextField.text;
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end

//
//  ZGVideoChatLoginViewController.m
//  ZegoExpressExample
//
//  Created by 王鑫 on 2021/11/29.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGVideoChatLoginViewController.h"
#import "ZGVideoChatViewController.h"
#import "ZGUserIDHelper.h"

@interface ZGVideoChatLoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UILabel *streamIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;

@end

@implementation ZGVideoChatLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"VideoChatLoginTitle", nil);
    
    self.roomIDLabel.text = NSLocalizedString(@"VideoChatRoomIDNotice", nil);
    self.roomIDTextField.text = @"0001";
    self.userIDLabel.text = NSLocalizedString(@"VideoChatUserIDNotice", nil);
    self.userIDTextField.text = [ZGUserIDHelper userID];
    self.userIDTextField.enabled = false;
    self.streamIDLabel.text = NSLocalizedString(@"VideoChatStreamIDNotice", nil);
    self.publishStreamIDTextField.text = [NSString stringWithFormat:@"s_%@", self.userIDTextField.text];
}

- (IBAction)loginRoomButnClicked:(id)sender {
    ZGVideoChatViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoChat"];
    
    vc.roomID = self.roomIDTextField.text;
    vc.userID = self.userIDTextField.text;
    vc.publishStreamID = self.publishStreamIDTextField.text;
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

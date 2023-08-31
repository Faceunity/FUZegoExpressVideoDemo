//
//  ZGAuxPublisherLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/2/26.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_AuxPublisher

#import "ZGAuxPublisherLoginViewController.h"
#import "ZGAuxPublisherPublishViewController.h"
#import "ZGAuxPublisherPlayViewController.h"

@interface ZGAuxPublisherLoginViewController ()

@end

@implementation ZGAuxPublisherLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)jumpToPublish:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"AuxPublisher" bundle:nil];
    
    ZGAuxPublisherPublishViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGAuxPublisherPublishViewController class])];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)jumpToPlay:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"AuxPublisher" bundle:nil];
    
    ZGAuxPublisherPlayViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGAuxPublisherPlayViewController class])];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end

#endif

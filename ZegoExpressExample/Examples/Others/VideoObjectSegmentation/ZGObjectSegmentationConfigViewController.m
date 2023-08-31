//
//  NSObject+ZGSubjectSegmentationConfigViewController.m
//  ZegoExpressExample
//
//  Created by zego on 2022/12/5.
//  Copyright © 2022 Zego. All rights reserved.
//

#import "ZGObjectSegmentationConfigViewController.h"
#import "ZGObjectSegmentationViewController.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import "AppDelegate.h"

@interface ZGObjectSegmentationConfigViewController () <ZegoEventHandler>
@property (weak, nonatomic) IBOutlet UISwitch *isCustomVideoRenderSwitch;
@property (weak, nonatomic) IBOutlet UIButton *setAppOrientationModeButton;
@property (weak, nonatomic) IBOutlet UIButton *rotateTypeButton;
@property (weak, nonatomic) IBOutlet UISwitch *enableEffectsEnv;
@property (weak, nonatomic) IBOutlet UISwitch *veRenderAlphaSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *veGlkviewSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *veMetalSwitch;

@property(nonatomic, assign) int orientationMode;
@property(nonatomic, assign) RotateType rotationType;
@property (nonatomic, assign) BOOL firstRotate;
@property (nonatomic, assign) BOOL firstRotateFlag;

@end

@implementation ZGObjectSegmentationConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setDefaultValue];
    [self setupUI];
}
-(void)viewDidAppear:(BOOL)animated{
    [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskPortrait];
}

-(void)setDefaultValue{
    self.rotationType = RotateTypeFixedPortrait;
}

- (void)setupUI {

}

- (IBAction)doneButtonClick:(UIButton *)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"VideoObjectSegmentation" bundle:nil];
    ZGObjectSegmentationViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ZGObjectSegmentationViewController"];
    
    vc.enableCustomRender = self.isCustomVideoRenderSwitch.isOn;
    vc.orientationMode = self.orientationMode;
    vc.rotationType = self.rotationType;
    vc.enableEffectsEnv = self.enableEffectsEnv.isOn;
    vc.veGlkView = self.veGlkviewSwitch.isOn;
    vc.veMetal = self.veMetalSwitch.isOn;
    vc.veRenderAlpha = self.veRenderAlphaSwitch.isOn;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onAppOrientationModeButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *customMode = [UIAlertAction actionWithTitle:@"Custom(Default)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.orientationMode = ZegoOrientationModeCustom;
        [self.setAppOrientationModeButton setTitle:@"Custom(Default)" forState:UIControlStateNormal];
    }];
    UIAlertAction *adaptionMode = [UIAlertAction actionWithTitle:@"Adaption" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.orientationMode = ZegoOrientationModeAdaption;
        [self.setAppOrientationModeButton setTitle:@"Adaption" forState:UIControlStateNormal];

    }];
    UIAlertAction *alignmentMode = [UIAlertAction actionWithTitle:@"Alignment" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.orientationMode = ZegoOrientationModeAlignment;
        [self.setAppOrientationModeButton setTitle:@"Alignment" forState:UIControlStateNormal];
    }];
    UIAlertAction *fixedResolutionRatioMode = [UIAlertAction actionWithTitle:@"FixedResolutionRatio" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.orientationMode = ZegoOrientationModeFixedResolutionRatio;
        [self.setAppOrientationModeButton setTitle:@"FixedResolutionRatio" forState:UIControlStateNormal];
    }];

    [alertController addAction:cancel];
    [alertController addAction:customMode];
    [alertController addAction:adaptionMode];
    [alertController addAction:alignmentMode];
    [alertController addAction:fixedResolutionRatioMode];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onRotateTypeButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *fixedProtrait = [UIAlertAction actionWithTitle:@"FixedProtrait" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.rotationType = RotateTypeFixedPortrait;
        [self.rotateTypeButton setTitle:@"FixedProtrait" forState:UIControlStateNormal];
    }];
    UIAlertAction *fixedLandscape = [UIAlertAction actionWithTitle:@"FixedLandscape" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.rotationType = RotateTypeFixedLandscape;
        [self.rotateTypeButton setTitle:@"FixedLandscape" forState:UIControlStateNormal];

    }];
    UIAlertAction *autoRotate = [UIAlertAction actionWithTitle:@"AutoRotate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.rotationType = RotateTypeFixedAutoRotate;
        [self.rotateTypeButton setTitle:@"AutoRotate" forState:UIControlStateNormal];
    }];

    [alertController addAction:cancel];
    [alertController addAction:fixedProtrait];
    [alertController addAction:fixedLandscape];
    [alertController addAction:autoRotate];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

/// Click on other areas outside the keyboard to retract the keyboard
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation {
// only for ios 16 and newer system
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
    if(@available(iOS 16.0, *)){
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
    }
    else
#endif
    {
        UIDevice *device = [UIDevice currentDevice];
        if (device.orientation != (UIDeviceOrientation)orientation && [device respondsToSelector:@selector(setOrientation:)]) {
            SEL selector  = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            [invocation setArgument:&orientation atIndex:2];
            [invocation invoke];
        }
    }
}
@end

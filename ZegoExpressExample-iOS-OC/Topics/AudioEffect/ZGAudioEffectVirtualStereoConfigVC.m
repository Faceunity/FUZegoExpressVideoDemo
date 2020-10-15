//
//  ZGAudioEffectVirtualStereoConfigVC.m
//  LiveRoomPlayground-iOS
//
//  Created by jeffreypeng on 2019/8/27.
//  Copyright © 2019 Zego. All rights reserved.
//
#ifdef _Module_AudioEffect

#import "ZGAudioEffectVirtualStereoConfigVC.h"
#import "ZGAudioEffectTopicConfigManager.h"
#import "ZGAudioEffectTopicHelper.h"

@interface ZGAudioEffectVirtualStereoConfigVC ()

@property (weak, nonatomic) IBOutlet UISwitch *openVirtaulStereoSwitch;
@property (weak, nonatomic) IBOutlet UIView *virtaulStereoConfigContainerView;
@property (weak, nonatomic) IBOutlet UILabel *angleValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *angleValueSlider;

@end

@implementation ZGAudioEffectVirtualStereoConfigVC

+ (instancetype)instanceFromStoryboard {
    return [[UIStoryboard storyboardWithName:@"AudioEffect" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ZGAudioEffectVirtualStereoConfigVC class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Set Virtual Stereo";
    
    BOOL virtualStereoOpen = [ZGAudioEffectTopicConfigManager sharedInstance].virtualStereoOpen;
    
    self.virtaulStereoConfigContainerView.hidden = !virtualStereoOpen;
    self.openVirtaulStereoSwitch.on = virtualStereoOpen;
    
    float virtualStereoAngle = [ZGAudioEffectTopicConfigManager sharedInstance].virtualStereoAngle;
    self.angleValueSlider.minimumValue = 0;
    self.angleValueSlider.maximumValue = 180;
    self.angleValueSlider.value = virtualStereoAngle;
    self.angleValueLabel.text = @(virtualStereoAngle).stringValue;
}

- (IBAction)openVirtaulStereoValueChanged:(UISwitch*)sender {
    float virtualStereoOpen = sender.isOn;
    [[ZGAudioEffectTopicConfigManager sharedInstance] setVirtualStereoOpen:virtualStereoOpen];
    self.virtaulStereoConfigContainerView.hidden = !virtualStereoOpen;
}

- (IBAction)angleValueChanged:(UISlider*)sender {
    float virtualStereoAngle = sender.value;
    [[ZGAudioEffectTopicConfigManager sharedInstance] setVirtualStereoAngle:virtualStereoAngle];
    self.angleValueLabel.text = @(virtualStereoAngle).stringValue;
}

@end
#endif

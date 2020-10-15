//
//  ZGAudioMixingSettingTableViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/15.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_AudioMixing

#import "ZGAudioMixingSettingTableViewController.h"

@interface ZGAudioMixingSettingTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *audioMixingSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *muteLocalSwitch;
@property (weak, nonatomic) IBOutlet UISlider *audioMixingVolumeSlider;

@end

@implementation ZGAudioMixingSettingTableViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"AudioMixing" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGAudioMixingSettingTableViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.audioMixingSwitch.on = _enableAudioMixing;
    self.muteLocalSwitch.on = _muteLocalAudioMixing;
    self.audioMixingVolumeSlider.value = _audioMixingVolume;
}

- (void)viewDidDisappear:(BOOL)animated {
    self.presenter.enableAudioMixing = _enableAudioMixing;
    self.presenter.muteLocalAudioMixing = _muteLocalAudioMixing;
    self.presenter.audioMixingVolume = _audioMixingVolume;
}

- (IBAction)audioMixingSwitchValueChanged:(UISwitch *)sender {
    self.enableAudioMixing = sender.on;
    self.enableAudioMixingBlock(self.enableAudioMixing);
}

- (IBAction)muteLocalSwitchValueChanged:(UISwitch *)sender {
    self.muteLocalAudioMixing = sender.on;
    self.muteLocalAudioMixingBlock(self.muteLocalAudioMixing);

}

- (IBAction)audioMixingVolumeSliderValueChanged:(UISlider *)sender {
    self.audioMixingVolume = (int)sender.value;
    self.setAudioMixingVolumeBlock(self.audioMixingVolume);
}

@end

#endif

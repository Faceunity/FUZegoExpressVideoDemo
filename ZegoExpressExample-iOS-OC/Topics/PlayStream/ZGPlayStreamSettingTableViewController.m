//
//  ZGPlayStreamSettingTableViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_PlayStream

#import "ZGPlayStreamSettingTableViewController.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGPlayStreamSettingTableViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *speakerSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *hardwareDecoderSwitch;
@property (weak, nonatomic) IBOutlet UISlider *playVolumeSlider;
@property (weak, nonatomic) IBOutlet UITextView *streamExtraInfoTextView;
@property (weak, nonatomic) IBOutlet UITextView *roomExtraInfoTextView;

@end

@implementation ZGPlayStreamSettingTableViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PlayStream" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGPlayStreamSettingTableViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI {
    self.speakerSwitch.on = ![[ZegoExpressEngine sharedEngine] isSpeakerMuted];
    self.hardwareDecoderSwitch.on = _enableHardwareDecoder;
    self.playVolumeSlider.continuous = NO;
    self.playVolumeSlider.value = _playVolume;
    self.streamExtraInfoTextView.text = [NSString stringWithFormat:@"StreamExtraInfo\n%@", _streamExtraInfo];
    self.roomExtraInfoTextView.text = [NSString stringWithFormat:@"RoomExtraInfo\n%@", _roomExtraInfo];
}

- (void)viewDidDisappear:(BOOL)animated {
    self.presenter.enableHardwareDecoder = _enableHardwareDecoder;
    self.presenter.playVolume = _playVolume;
}

- (IBAction)speakerSwitchValueChanged:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine] muteSpeaker:!sender.on];

    [self.presenter appendLog:[NSString stringWithFormat:@"📣 Speaker %@", sender.on ? @"on 🟢" : @"off 🔴"]];
}

- (IBAction)hardwareDecoderSwitchValueChanged:(UISwitch *)sender {
    _enableHardwareDecoder = sender.on;
    [[ZegoExpressEngine sharedEngine] enableHardwareDecoder:_enableHardwareDecoder];

    [self.presenter appendLog:[NSString stringWithFormat:@"🎛 HardwareDecoder %@", sender.on ? @"on 🟢" : @"off 🔴"]];
}

- (IBAction)playVolumeSliderValueChanged:(UISlider *)sender {
    _playVolume = (int)sender.value;
    [[ZegoExpressEngine sharedEngine] setPlayVolume:_playVolume streamID:_streamID];

    [self.presenter appendLog:[NSString stringWithFormat:@"🔊 Set play volume: %d", _playVolume]];
}

@end

#endif

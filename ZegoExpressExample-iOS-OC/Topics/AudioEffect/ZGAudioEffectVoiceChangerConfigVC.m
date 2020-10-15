//
//  ZGAudioEffectVoiceChangerConfigVC.m
//  LiveRoomPlayground-iOS
//
//  Created by jeffreypeng on 2019/8/27.
//  Copyright © 2019 Zego. All rights reserved.
//
#ifdef _Module_AudioEffect

#import "ZGAudioEffectVoiceChangerConfigVC.h"
#import "ZGAudioEffectTopicConfigManager.h"
#import "ZGAudioEffectTopicHelper.h"

@interface ZGAudioEffectVoiceChangerConfigVC () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UISwitch *openVoiceChangerSwitch;
@property (weak, nonatomic) IBOutlet UIView *voiceChargerConfigContainerView;
@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;
@property (weak, nonatomic) IBOutlet UILabel *customModeValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *customModeValueSlider;

@property (nonatomic, copy) NSArray<ZGAudioEffectTopicConfigMode*> *voiceChangerOptionModes;

@end

@implementation ZGAudioEffectVoiceChangerConfigVC

+ (instancetype)instanceFromStoryboard {
    return [[UIStoryboard storyboardWithName:@"AudioEffect" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ZGAudioEffectVoiceChangerConfigVC class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.voiceChangerOptionModes = [ZGAudioEffectTopicHelper voiceChangerOptionModes];
    
    self.navigationItem.title = @"Set Voice Changer";
    
    BOOL voiceChangerOpen = [ZGAudioEffectTopicConfigManager sharedInstance].voiceChangerOpen;
    self.voiceChargerConfigContainerView.hidden = !voiceChangerOpen;
    self.openVoiceChangerSwitch.on = voiceChangerOpen;
    self.modePicker.dataSource = self;
    self.modePicker.delegate = self;
    
    float voiceChangerParam = [ZGAudioEffectTopicConfigManager sharedInstance].voiceChangerParam;
    self.customModeValueSlider.minimumValue = -8.f;
    self.customModeValueSlider.maximumValue = 8.f;
    self.customModeValueSlider.value = voiceChangerParam;
    self.customModeValueLabel.text = @(voiceChangerParam).stringValue;
    
    [self.modePicker reloadAllComponents];
    [self invalidateModePickerSelection];
}

- (IBAction)voiceChangerOpenValueChanged:(UISwitch *)sender {
    BOOL voiceChangerOpen = sender.isOn;
    [[ZGAudioEffectTopicConfigManager sharedInstance] setVoiceChangerOpen:voiceChangerOpen];
    self.voiceChargerConfigContainerView.hidden = !voiceChangerOpen;
}

- (IBAction)customModeValueChanged:(UISlider*)sender {
    float voiceChangerParam = sender.value;
    [[ZGAudioEffectTopicConfigManager sharedInstance] setVoiceChangerParam:voiceChangerParam];
    self.customModeValueLabel.text = @(voiceChangerParam).stringValue;
    [self invalidateModePickerSelection];
}

- (void)invalidateModePickerSelection {
    float voiceChangerParam = [ZGAudioEffectTopicConfigManager sharedInstance].voiceChangerParam;
    NSInteger selectionRow = NSNotFound;
    for (NSInteger i=0; i<self.voiceChangerOptionModes.count; i++) {
        ZGAudioEffectTopicConfigMode *mode = self.voiceChangerOptionModes[i];
        if (!mode.isCustom && mode.modeValue.floatValue == voiceChangerParam) {
            selectionRow = i;
        }
    }
    if (selectionRow != NSNotFound) {
        [self.modePicker selectRow:selectionRow inComponent:0 animated:NO];
    } else {
        // 选中到‘自定义’行
        ZGAudioEffectTopicConfigMode *customMode = [self customModeInModeList];
        NSInteger customModeIdx = [self.voiceChangerOptionModes indexOfObject:customMode];
        if (customModeIdx != NSNotFound) {
            [self.modePicker selectRow:customModeIdx inComponent:0 animated:NO];
        }
    }
}

- (ZGAudioEffectTopicConfigMode*)customModeInModeList {
    ZGAudioEffectTopicConfigMode *tarMode =nil;
    for (ZGAudioEffectTopicConfigMode *m in self.voiceChangerOptionModes) {
        if (m.isCustom) {
            tarMode = m;
            break;
        }
    }
    return tarMode;
}

#pragma mark - picker view dataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.voiceChangerOptionModes.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.voiceChangerOptionModes[row].modeName;
}

#pragma mark - picker view delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([ZGAudioEffectTopicConfigManager sharedInstance].voiceChangerOpen) {
        ZGAudioEffectTopicConfigMode *mode = self.voiceChangerOptionModes[row];
        if (!mode.isCustom) {
            [[ZGAudioEffectTopicConfigManager sharedInstance] setVoiceChangerParam:mode.modeValue.floatValue];
        }
    }
}

@end
#endif

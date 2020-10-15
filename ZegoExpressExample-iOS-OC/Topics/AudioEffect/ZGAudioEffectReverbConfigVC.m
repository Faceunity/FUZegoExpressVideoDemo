//
//  ZGAudioEffectReverbConfigVC.m
//  LiveRoomPlayground-iOS
//
//  Created by jeffreypeng on 2019/8/27.
//  Copyright © 2019 Zego. All rights reserved.
//
#ifdef _Module_AudioEffect

#import "ZGAudioEffectReverbConfigVC.h"
#import "ZGAudioEffectTopicConfigManager.h"
#import "ZGAudioEffectTopicHelper.h"

@interface ZGAudioEffectReverbConfigVC () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UISwitch *openReverbSwitch;
@property (weak, nonatomic) IBOutlet UIView *reverbConfigContainerView;
@property (weak, nonatomic) IBOutlet UIPickerView *modePicker;
@property (weak, nonatomic) IBOutlet UILabel *customRoomSizeValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *customRoomSizeSlider;
@property (weak, nonatomic) IBOutlet UILabel *customDryWetRatioValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *customDryWetRatioSlider;
@property (weak, nonatomic) IBOutlet UILabel *customDampingValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *customDampingSlider;
@property (weak, nonatomic) IBOutlet UILabel *customReverberanceValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *customReverberanceSlider;

@property (nonatomic, copy) NSArray<ZGAudioEffectTopicConfigMode*> *reverbOptionModes;

@end

@implementation ZGAudioEffectReverbConfigVC

+ (instancetype)instanceFromStoryboard {
    return [[UIStoryboard storyboardWithName:@"AudioEffect" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ZGAudioEffectReverbConfigVC class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reverbOptionModes = [ZGAudioEffectTopicHelper reverbOptionModes];
    self.navigationItem.title = @"Set Reverberation";
    
    BOOL reverbOpen = [ZGAudioEffectTopicConfigManager sharedInstance].reverbOpen;
    
    self.reverbConfigContainerView.hidden = !reverbOpen;
    self.openReverbSwitch.on = reverbOpen;
    self.modePicker.delegate = self;
    self.modePicker.dataSource = self;
    
    float customReverbRoomSize = [ZGAudioEffectTopicConfigManager sharedInstance].customReverbRoomSize;
    self.customRoomSizeSlider.minimumValue = 0.0f;
    self.customRoomSizeSlider.maximumValue = 1.0f;
    self.customRoomSizeSlider.value = customReverbRoomSize;
    self.customRoomSizeValueLabel.text = @(customReverbRoomSize).stringValue;
    
    float customDryWetRatio = [ZGAudioEffectTopicConfigManager sharedInstance].customDryWetRatio;
    self.customDryWetRatioSlider.minimumValue = 0.0f;
    self.customDryWetRatioSlider.maximumValue = 2.0f;
    self.customDryWetRatioSlider.value = customDryWetRatio;
    self.customDryWetRatioValueLabel.text = @(customDryWetRatio).stringValue;
    
    float customDamping = [ZGAudioEffectTopicConfigManager sharedInstance].customDamping;
    self.customDampingSlider.minimumValue = 0.0f;
    self.customDampingSlider.maximumValue = 2.0f;
    self.customDampingSlider.value = customDamping;
    self.customDampingValueLabel.text = @(customDamping).stringValue;
    
    float customReverberance =[ZGAudioEffectTopicConfigManager sharedInstance].customReverberance;
    self.customReverberanceSlider.minimumValue = 0.0f;
    self.customReverberanceSlider.maximumValue = 0.5f;
    self.customReverberanceSlider.value = customReverberance;
    self.customReverberanceValueLabel.text = @(customReverberance).stringValue;
}

- (IBAction)reverbValueChanged:(UISwitch*)sender {
    BOOL reverbOpen = sender.isOn;
    [[ZGAudioEffectTopicConfigManager sharedInstance] setReverbOpen:reverbOpen];
    self.reverbConfigContainerView.hidden = !reverbOpen;
}

- (IBAction)customRoomSizeValueChanged:(UISlider*)sender {
    float customReverbRoomSize = sender.value;
    [[ZGAudioEffectTopicConfigManager sharedInstance] setCustomReverbRoomSize:customReverbRoomSize];
    self.customRoomSizeValueLabel.text = @(customReverbRoomSize).stringValue;
}

- (IBAction)customDryWetRationValueChanged:(UISlider*)sender {
    float customDryWetRatio = sender.value;
    [[ZGAudioEffectTopicConfigManager sharedInstance] setCustomDryWetRatio:customDryWetRatio];
    self.customDryWetRatioValueLabel.text = @(customDryWetRatio).stringValue;
}

- (IBAction)customDampingValueChanged:(UISlider*)sender {
    float customDamping = sender.value;
    [[ZGAudioEffectTopicConfigManager sharedInstance] setCustomDamping:customDamping];
    self.customDampingValueLabel.text = @(customDamping).stringValue;
}

- (IBAction)customReverberanceChanged:(UISlider*)sender {
    float customReverberance = sender.value;
    [[ZGAudioEffectTopicConfigManager sharedInstance] setCustomReverberance:customReverberance];
    self.customReverberanceValueLabel.text = @(customReverberance).stringValue;
}

#pragma mark - picker view dataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.reverbOptionModes.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.reverbOptionModes[row].modeName;
}

#pragma mark - picker view delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([ZGAudioEffectTopicConfigManager sharedInstance].reverbOpen) {
        ZGAudioEffectTopicConfigMode *mode = self.reverbOptionModes[row];
        if (!mode.isCustom) {
            [[ZGAudioEffectTopicConfigManager sharedInstance] setReverbMode:[mode.modeValue unsignedIntegerValue]];
        } else {
            [[ZGAudioEffectTopicConfigManager sharedInstance] setReverbMode:NSNotFound];
        }
    }
}

@end
#endif

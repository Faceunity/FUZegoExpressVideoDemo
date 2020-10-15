//
//  ZGBeautifyConfigTableViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/10.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_Beautify

#import "ZGBeautifyConfigTableViewController.h"

@interface ZGBeautifyConfigTableViewController ()

// beautify
@property (nonatomic, assign) ZegoBeautifyFeature beautifyFeature;
@property (nonatomic, strong) ZegoBeautifyOption *beautifyOption;

// polish
@property (weak, nonatomic) IBOutlet UISwitch *polishSwitch;
@property (weak, nonatomic) IBOutlet UISlider *polishStepSlider;

// whiten
@property (weak, nonatomic) IBOutlet UISwitch *whitenSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *skinWhitenSwitch;
@property (weak, nonatomic) IBOutlet UISlider *whitenFactorSlider;

// sharpen
@property (weak, nonatomic) IBOutlet UISwitch *sharpenSwitch;
@property (weak, nonatomic) IBOutlet UISlider *sharpenFactorSlider;

// watermark
@property (nonatomic, strong) ZegoWatermark *watermark;
@property (nonatomic, assign) BOOL enableWatermark;
@property (nonatomic, assign) BOOL watermarkIsPreviewVisble;
@property (weak, nonatomic) IBOutlet UISwitch *watermarkSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *watermarkIsPreviewVisibleSwitch;
@property (weak, nonatomic) IBOutlet UITextField *watermarkFilePathTextField;

@end

@implementation ZGBeautifyConfigTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.beautifyFeature = ZegoBeautifyFeatureNone;
    self.beautifyOption = [[ZegoBeautifyOption alloc] init];
    
    self.watermark = [[ZegoWatermark alloc] init];
    self.enableWatermark = NO;
    self.watermarkIsPreviewVisble = YES;
    
    [self setupUI];
}

- (void)setupUI {
    self.polishStepSlider.value = self.beautifyOption.polishStep;
//    self.polishStepSlider.continuous = NO;
    
    self.whitenFactorSlider.value = self.beautifyOption.whitenFactor;
//    self.whitenFactorSlider.continuous = NO;
    
    self.sharpenFactorSlider.value = self.beautifyOption.sharpenFactor;
//    self.sharpenFactorSlider.continuous = NO;
    
    self.watermarkFilePathTextField.text = @"asset://ZegoLogo";
}

#pragma mark - Beautify Feature

- (IBAction)polishSwitchAction:(UISwitch *)sender {
    if (sender.on) {
        _beautifyFeature |= ZegoBeautifyFeaturePolish;
    } else {
        _beautifyFeature ^= ZegoBeautifyFeaturePolish;
    }
    [self.engine enableBeautify:_beautifyFeature];
}

- (IBAction)whitenSwitchAction:(UISwitch *)sender {
    if (sender.on) {
        _beautifyFeature |= ZegoBeautifyFeatureWhiten;
    } else {
        _beautifyFeature ^= ZegoBeautifyFeatureWhiten;
    }
    [self.engine enableBeautify:_beautifyFeature];
}

- (IBAction)skinWhitenSwitchAction:(UISwitch *)sender {
    if (sender.on) {
        _beautifyFeature |= ZegoBeautifyFeatureSkinWhiten;
    } else {
        _beautifyFeature ^= ZegoBeautifyFeatureSkinWhiten;
    }
    [self.engine enableBeautify:_beautifyFeature];
}
- (IBAction)sharpenSwitchAction:(UISwitch *)sender {
    if (sender.on) {
        _beautifyFeature |= ZegoBeautifyFeatureSharpen;
    } else {
        _beautifyFeature ^= ZegoBeautifyFeatureSharpen;
    }
    [self.engine enableBeautify:_beautifyFeature];
}

#pragma mark - Beautify Option

- (IBAction)polishStepSliderValueChanged:(UISlider *)sender {
    _beautifyOption.polishStep = sender.value;
    NSLog(@"PolishStep: %f", _beautifyOption.polishStep);
    [self.engine setBeautifyOption:_beautifyOption];
}

- (IBAction)whitenFactorSliderValueChanged:(UISlider *)sender {
    _beautifyOption.whitenFactor = sender.value;
    NSLog(@"WhitenFactor: %f", _beautifyOption.whitenFactor);
    [self.engine setBeautifyOption:_beautifyOption];
}

- (IBAction)sharpenFactorSliderValueChanged:(UISlider *)sender {
    _beautifyOption.sharpenFactor = sender.value;
    NSLog(@"SharpenFactor: %f", _beautifyOption.sharpenFactor);
    [self.engine setBeautifyOption:_beautifyOption];
}

#pragma mark - Watermark

- (void)updateWatermark {
    self.watermark.imageURL = self.watermarkFilePathTextField.text;
    [self.engine setPublishWatermark:self.watermark isPreviewVisible:self.watermarkIsPreviewVisble];
}

- (IBAction)watermarkSwitchAction:(UISwitch *)sender {
    if (sender.on) {
        self.watermark.layout = CGRectMake(10, 10, 100, 18.75); // Ratio of ZegoLogo.png
    } else {
        self.watermark.layout = CGRectZero;
    }
    [self updateWatermark];
}

- (IBAction)watermarkIsPreviewVisibleSwitchAction:(UISwitch *)sender {
    self.watermarkIsPreviewVisble = sender.on;
    [self updateWatermark];
}

@end

#endif

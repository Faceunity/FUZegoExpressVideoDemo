//
//  ZGCustomVideoRenderLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/1.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_CustomVideoRender

#import "ZGCustomVideoRenderLoginViewController.h"
#import "ZGCustomVideoRenderPublishStreamViewController.h"
#import "ZGCustomVideoRenderPlayStreamViewController.h"

NSString* const ZGCustomVideoRenderLoginVCKey_roomID = @"kRoomID";
NSString* const ZGCustomVideoRenderLoginVCKey_streamID = @"kStreamID";

@interface ZGCustomVideoRenderLoginViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, copy) NSArray<NSString *> *renderBufferTypeList;
@property (nonatomic, copy) NSArray<NSString *> *renderFormatSeriesList;

@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *renderBufferTypeMap;
@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *renderFormatSeriesMap;

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *renderTypeFormatPicker;
@property (weak, nonatomic) IBOutlet UISwitch *engineRenderSwitch;

@end

@implementation ZGCustomVideoRenderLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Custom Video Render";
    
    self.renderBufferTypeList = @[@"Unknown", @"RawData", @"CVPixelBuffer",@"EncodedData"];
    self.renderBufferTypeMap = @{@"Unknown": @(ZegoVideoBufferTypeUnknown), @"RawData": @(ZegoVideoBufferTypeRawData), @"CVPixelBuffer": @(ZegoVideoBufferTypeCVPixelBuffer), @"EncodedData": @(ZegoVideoBufferTypeEncodedData)};
    
    self.renderFormatSeriesList = @[@"RGB", @"YUV"];
    self.renderFormatSeriesMap = @{@"RGB": @(ZegoVideoFrameFormatSeriesRGB), @"YUV": @(ZegoVideoFrameFormatSeriesYUV)};
    
    [self setupUI];
}

- (void)setupUI {
    self.roomIDTextField.text = [self savedValueForKey:ZGCustomVideoRenderLoginVCKey_roomID];
    self.streamIDTextField.text = [self savedValueForKey:ZGCustomVideoRenderLoginVCKey_streamID];
    
    [self.renderTypeFormatPicker setDelegate:self];
    [self.renderTypeFormatPicker setDataSource:self];
    
    [self.renderTypeFormatPicker selectRow:2 inComponent:0 animated:YES]; // Select CVPixelBuffer
    [self.renderTypeFormatPicker selectRow:0 inComponent:1 animated:YES]; // Select RGB
}

- (BOOL)prepareForJump {
    if (!self.roomIDTextField.text || [self.roomIDTextField.text isEqualToString:@""]) {
        ZGLogError(@"❗️ Please fill in roomID.");
        return NO;
    }
    
    if (!self.streamIDTextField.text || [self.streamIDTextField.text isEqualToString:@""]) {
        ZGLogError(@"❗️ Please fill in streamID.");
        return NO;
    }
    
    [self saveValue:self.roomIDTextField.text forKey:ZGCustomVideoRenderLoginVCKey_roomID];
    [self saveValue:self.streamIDTextField.text forKey:ZGCustomVideoRenderLoginVCKey_streamID];
    
    return YES;
}

- (IBAction)publishStream:(UIButton *)sender {
    if (![self prepareForJump]) return;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomVideoRender" bundle:nil];
    ZGCustomVideoRenderPublishStreamViewController *publisherVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGCustomVideoRenderPublishStreamViewController class])];
    
    publisherVC.bufferType = (ZegoVideoBufferType)self.renderBufferTypeMap[self.renderBufferTypeList[[self.renderTypeFormatPicker selectedRowInComponent:0]]].intValue;
    
    publisherVC.frameFormatSeries = (ZegoVideoFrameFormatSeries)self.renderFormatSeriesMap[self.renderFormatSeriesList[[self.renderTypeFormatPicker selectedRowInComponent:1]]].intValue;
    
    publisherVC.enableEngineRender = self.engineRenderSwitch.on;
    publisherVC.roomID = self.roomIDTextField.text;
    publisherVC.streamID = self.streamIDTextField.text;
    [self.navigationController pushViewController:publisherVC animated:YES];
}

- (IBAction)playStream:(UIButton *)sender {
    if (![self prepareForJump]) return;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomVideoRender" bundle:nil];
    ZGCustomVideoRenderPlayStreamViewController *playerVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGCustomVideoRenderPlayStreamViewController class])];
    
    playerVC.bufferType = (ZegoVideoBufferType)self.renderBufferTypeMap[self.renderBufferTypeList[[self.renderTypeFormatPicker selectedRowInComponent:0]]].intValue;
    
    playerVC.frameFormatSeries = (ZegoVideoFrameFormatSeries)self.renderFormatSeriesMap[self.renderFormatSeriesList[[self.renderTypeFormatPicker selectedRowInComponent:1]]].intValue;
    
    playerVC.enableEngineRender = self.engineRenderSwitch.on;
    playerVC.roomID = self.roomIDTextField.text;
    playerVC.streamID = self.streamIDTextField.text;
    [self.navigationController pushViewController:playerVC animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - PickerView

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.renderBufferTypeList.count;
    } else {
        return self.renderFormatSeriesList.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return self.renderBufferTypeList[row];
    } else {
        return self.renderFormatSeriesList[row];
    }
}

@end

#endif

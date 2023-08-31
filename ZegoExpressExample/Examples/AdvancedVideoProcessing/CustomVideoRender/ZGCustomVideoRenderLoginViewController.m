//
//  ZGCustomVideoRenderLoginViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/1.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGCustomVideoRenderLoginViewController.h"
#import "ZGCustomVideoRenderViewController.h"


@interface ZGCustomVideoRenderLoginViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, copy) NSArray<NSString *> *renderBufferTypeList;
@property (nonatomic, copy) NSArray<NSString *> *renderFormatSeriesList;

@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *renderBufferTypeMap;
@property (nonatomic, copy) NSDictionary<NSString *, NSNumber *> *renderFormatSeriesMap;

@property (weak, nonatomic) IBOutlet UIPickerView *renderTypeFormatPicker;

@end

@implementation ZGCustomVideoRenderLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Custom Video Render";
    
    self.renderBufferTypeList = @[@"CVPixelBuffer", @"RawData", @"EncodedData"];
    self.renderBufferTypeMap = @{
        @"Unknown": @(ZegoVideoBufferTypeUnknown),
        @"CVPixelBuffer": @(ZegoVideoBufferTypeCVPixelBuffer),
        @"RawData": @(ZegoVideoBufferTypeRawData),
        @"EncodedData": @(ZegoVideoBufferTypeEncodedData),
    };
    
    self.renderFormatSeriesList = @[@"RGB"];
    self.renderFormatSeriesMap = @{
        @"RGB": @(ZegoVideoFrameFormatSeriesRGB),
        @"YUV": @(ZegoVideoFrameFormatSeriesYUV),
    };
    
    [self.renderTypeFormatPicker setDelegate:self];
    [self.renderTypeFormatPicker setDataSource:self];
}

- (IBAction)onStartButtonClicked:(UIButton *)sender {

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomVideoRender" bundle:nil];
    ZGCustomVideoRenderViewController *viewController = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGCustomVideoRenderViewController class])];
    
    viewController.bufferType = (ZegoVideoBufferType)self.renderBufferTypeMap[self.renderBufferTypeList[[self.renderTypeFormatPicker selectedRowInComponent:0]]].intValue;
    
    viewController.frameFormatSeries = (ZegoVideoFrameFormatSeries)self.renderFormatSeriesMap[self.renderFormatSeriesList[[self.renderTypeFormatPicker selectedRowInComponent:1]]].intValue;
    
    [self.navigationController pushViewController:viewController animated:YES];
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

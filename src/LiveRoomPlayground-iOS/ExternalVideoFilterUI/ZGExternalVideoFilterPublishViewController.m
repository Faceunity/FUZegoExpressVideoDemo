//
//  ZGExternalVideoFilterPublishViewController.m
//  LiveRoomPlayground-iOS
//
//  Created by Paaatrick on 2019/7/22.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_ExternalVideoFilter

#import "ZGExternalVideoFilterPublishViewController.h"
#import "ZGExternalVideoFilterDemo.h"
#import "FUManager.h"
#import <FUAPIDemoBar/FUAPIDemoBar.h>
#import "Masonry.h"

@interface ZGExternalVideoFilterPublishViewController () <ZGExternalVideoFilterDemoProtocol, FUAPIDemoBarDelegate>

// 屏幕底部的 FaceUnity 美颜控制条
@property (nonatomic, strong) FUAPIDemoBar *demoBar;

@property (nonatomic, strong) ZGExternalVideoFilterDemo *demo;

@property (weak, nonatomic) IBOutlet UILabel *publishQualityLabel;
@property (weak, nonatomic) IBOutlet UISwitch *previewMirrorSwitch;

@property (nonatomic, assign) BOOL enablePreviewMirror;

@end

@implementation ZGExternalVideoFilterPublishViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.demo = [[ZGExternalVideoFilterDemo alloc] init];
    self.demo.delegate = self;
    
    // 先加载外部滤镜工厂
    [self.demo initFilterFactoryType:self.selectedFilterBufferType];
    
    // 然后初始化 ZegoLiveRoom SDK
    [self.demo initSDKWithRoomID:self.roomID streamID:self.streamID isAnchor:YES];
    
    // 开启 FaceUnity 的滤镜开关
    [[FUManager shareManager] loadFilter];
    
    
    [self setupUI];
    
    // 默认关闭预览镜像
    self.enablePreviewMirror = NO;
    
    [self.demo loginRoom];
    [self.demo startPreview];
    [self.demo enablePreviewMirror:self.enablePreviewMirror];
    [self.demo startPublish];
}

- (void)dealloc {
    
    [self.demo stopPublish];
    [self.demo stopPreview];
    [self.demo logoutRoom];
    
    self.demo = nil;
    
}

#pragma mark - setup

- (void)setupUI {
    // 设置屏幕底部的 FaceUnity 美颜控制条
    [self.view addSubview:self.demoBar];
    [_demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(231);
    }];
    
    self.previewMirrorSwitch.on = self.enablePreviewMirror;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)onSwitchPreviewMirror:(UISwitch *)sender {
    self.enablePreviewMirror = sender.on;
    [self.demo enablePreviewMirror:self.enablePreviewMirror];
}


#pragma mark - FaceUnity method
// 以下方法都是 FaceUnity 相关的视图和业务逻辑

-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 164 - 126, self.view.frame.size.width, 164)];
        
        _demoBar.itemsDataSource = [FUManager shareManager].itemsDataSource;
        _demoBar.selectedItem = [FUManager shareManager].selectedItem;
        _demoBar.skinDetectEnable = [FUManager shareManager].skinDetectEnable;
        _demoBar.blurShape = [FUManager shareManager].blurShape ;
        _demoBar.blurLevel = [FUManager shareManager].blurLevel ;
        _demoBar.whiteLevel = [FUManager shareManager].whiteLevel ;
        _demoBar.redLevel = [FUManager shareManager].redLevel;
        _demoBar.eyelightingLevel = [FUManager shareManager].eyelightingLevel ;
        _demoBar.beautyToothLevel = [FUManager shareManager].beautyToothLevel ;
        _demoBar.faceShape = [FUManager shareManager].faceShape ;
        
        _demoBar.enlargingLevel = [FUManager shareManager].enlargingLevel ;
        _demoBar.thinningLevel = [FUManager shareManager].thinningLevel ;
        _demoBar.enlargingLevel_new = [FUManager shareManager].enlargingLevel_new ;
        _demoBar.thinningLevel_new = [FUManager shareManager].thinningLevel_new ;
        _demoBar.jewLevel = [FUManager shareManager].jewLevel ;
        _demoBar.foreheadLevel = [FUManager shareManager].foreheadLevel ;
        _demoBar.noseLevel = [FUManager shareManager].noseLevel ;
        _demoBar.mouthLevel = [FUManager shareManager].mouthLevel ;
        
        _demoBar.filtersDataSource = [FUManager shareManager].filtersDataSource ;
        _demoBar.beautyFiltersDataSource = [FUManager shareManager].beautyFiltersDataSource ;
        _demoBar.filtersCHName = [FUManager shareManager].filtersCHName ;
        _demoBar.selectedFilter = [FUManager shareManager].selectedFilter ;
        [_demoBar setFilterLevel:[FUManager shareManager].selectedFilterLevel forFilter:[FUManager shareManager].selectedFilter] ;
        
        _demoBar.delegate = self;
    }
    return _demoBar ;
}


- (void)demoBarDidSelectedItem:(NSString *)itemName {
    
    [[FUManager shareManager] loadItem:itemName];
}

- (void)demoBarBeautyParamChanged {
    
    [FUManager shareManager].skinDetectEnable = _demoBar.skinDetectEnable;
    [FUManager shareManager].blurShape = _demoBar.blurShape;
    [FUManager shareManager].blurLevel = _demoBar.blurLevel ;
    [FUManager shareManager].whiteLevel = _demoBar.whiteLevel;
    [FUManager shareManager].redLevel = _demoBar.redLevel;
    [FUManager shareManager].eyelightingLevel = _demoBar.eyelightingLevel;
    [FUManager shareManager].beautyToothLevel = _demoBar.beautyToothLevel;
    [FUManager shareManager].faceShape = _demoBar.faceShape;
    [FUManager shareManager].enlargingLevel = _demoBar.enlargingLevel;
    [FUManager shareManager].thinningLevel = _demoBar.thinningLevel;
    [FUManager shareManager].enlargingLevel_new = _demoBar.enlargingLevel_new;
    [FUManager shareManager].thinningLevel_new = _demoBar.thinningLevel_new;
    [FUManager shareManager].jewLevel = _demoBar.jewLevel;
    [FUManager shareManager].foreheadLevel = _demoBar.foreheadLevel;
    [FUManager shareManager].noseLevel = _demoBar.noseLevel;
    [FUManager shareManager].mouthLevel = _demoBar.mouthLevel;
    
    [FUManager shareManager].selectedFilter = _demoBar.selectedFilter ;
    [FUManager shareManager].selectedFilterLevel = _demoBar.selectedFilterLevel;
}

#pragma mark - ZGExternalVideoFilterDemoProtocol
- (nonnull UIView *)getPlaybackView {
    return self.view;
}

- (void)onExternalVideoFilterPublishStateUpdate:(NSString *)state {
    self.title = state;
}

- (void)onExternalVideoFilterPublishQualityUpdate:(NSString *)state {
    self.publishQualityLabel.text = state;
}

@end

#endif

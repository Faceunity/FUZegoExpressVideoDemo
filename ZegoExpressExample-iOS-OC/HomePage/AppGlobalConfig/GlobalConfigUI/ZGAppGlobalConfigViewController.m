//
//  ZGAppGlobalConfigViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by jeffreypeng on 2019/8/6.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGAppGlobalConfigViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGAppGlobalConfigViewController ()

@property (weak, nonatomic) IBOutlet UITextField *appIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *appSignTextField;

@property (weak, nonatomic) IBOutlet UISegmentedControl *environmentSegCtrl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scenarioSegCtrl;

@property (weak, nonatomic) IBOutlet UILabel *SDKVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *appVersionLabel;

@end

@implementation ZGAppGlobalConfigViewController

+ (instancetype)instanceFromStoryboard {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"GlobalConfig" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGAppGlobalConfigViewController class])];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (IBAction)copySDKVersion:(id)sender {
    [[UIPasteboard generalPasteboard] setString:[ZegoExpressEngine getVersion]];
}

#pragma mark - private methods

- (void)setupUI {
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.navigationItem.title = @"Setting";
    UIBarButtonItem *resetItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetConfig:)];
    UIBarButtonItem *saveChangeItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveAppGlobalConfig:)];
    self.navigationItem.rightBarButtonItems = @[saveChangeItem,resetItem];
    
    
    self.SDKVersionLabel.text = [NSString stringWithFormat:@"%@", [ZegoExpressEngine getVersion]];
    self.appVersionLabel.text = [NSString stringWithFormat:@"Demo Version: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];

    ZGAppGlobalConfig *config = [[ZGAppGlobalConfigManager sharedManager] globalConfig];
    [self applyConfig:config];
}

- (void)resetConfig:(id)sender {
    [self.view endEditing:YES];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure to reset to the default configuration?" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ZGAppGlobalConfig *config = [ZGAppGlobalConfigManager defaultGlobalConfig];
        [[ZGAppGlobalConfigManager sharedManager] setGlobalConfig:config];
        [ZegoHudManager showMessage:@"Already reset to default configuration"];
        [self applyConfig:config];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)saveAppGlobalConfig:(id)sender {
    [self.view endEditing:YES];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure to save the currently modified configuration?" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ZGAppGlobalConfig *config = [[ZGAppGlobalConfig alloc] init];
        config.appID = (unsigned int)[self.appIDTextField.text longLongValue];
        config.appSign = self.appSignTextField.text;
        config.isTestEnv = self.environmentSegCtrl.selectedSegmentIndex == 0 ? YES : NO;
        config.scenario = (ZegoScenario)self.scenarioSegCtrl.selectedSegmentIndex;
        
        [[ZGAppGlobalConfigManager sharedManager] setGlobalConfig:config];
        [ZegoHudManager showMessage:@"Configuration saved"];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)applyConfig:(ZGAppGlobalConfig *)configInfo {
    if (!configInfo) {
        return;
    }
    self.appIDTextField.text = @(configInfo.appID).stringValue;
    self.appSignTextField.text = configInfo.appSign;
    self.environmentSegCtrl.selectedSegmentIndex = configInfo.isTestEnv ? 0 : 1;
    self.scenarioSegCtrl.selectedSegmentIndex = (int)configInfo.scenario;
}

@end

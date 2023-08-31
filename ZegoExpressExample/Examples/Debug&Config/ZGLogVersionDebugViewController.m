//
//  ZGLogVersionDebugViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/16.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGLogVersionDebugViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import "ZGShareLogViewController.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGLogVersionDebugViewController () <ZegoApiCalledEventHandler>

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UITextField *logPathTextfield;
@property (weak, nonatomic) IBOutlet UITextField *logSizeTextfield;
@property (weak, nonatomic) IBOutlet UITextField *appIDTextfield;
@property (weak, nonatomic) IBOutlet UITextField *userIDTextfield;
@property (weak, nonatomic) IBOutlet UITextField *appSignTextfield;

@property (weak, nonatomic) IBOutlet UILabel *sdkVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *demoVersionLabel;

@end

@implementation ZGLogVersionDebugViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self setupUI];
    
    // Set callback to track the calls of some SDK's static apis
    [ZegoExpressEngine setApiCalledCallback:self];
}

- (void)setupUI {
    NSString *defaultLogPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/ZegoLogs"];
    self.logPathTextfield.text = defaultLogPath;
    
    self.appIDTextfield.text = @([KeyCenter appID]).stringValue;
    self.userIDTextfield.text = [ZGUserIDHelper userID];
    self.appSignTextfield.text = [KeyCenter appSign];
    self.sdkVersionLabel.text = [NSString stringWithFormat:@"SDK: %@", [ZegoExpressEngine getVersion]];
    
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    self.demoVersionLabel.text = [NSString stringWithFormat:@"Demo: %@.%@", [bundleInfo objectForKey:@"CFBundleShortVersionString"], [bundleInfo objectForKey:@"CFBundleVersion"]];
}

#pragma mark - Action

- (IBAction)onSetLogConfigButtonTapped:(id)sender {
    // [setLogConfig] must be set before calling [createEngine]
    // Once you have created engine yet, you should destroy it before "setLogConfig" and setup Again
    [ZegoExpressEngine destroyEngine:nil];
    
    ZegoLogConfig *logConfig = [[ZegoLogConfig alloc] init];
    logConfig.logPath = self.logPathTextfield.text;
    logConfig.logSize = self.logSizeTextfield.text.longLongValue;
    [ZegoExpressEngine setLogConfig:logConfig];
    [self appendLog:[NSString stringWithFormat:@"🔨 SetLogConfig, path: %@ logSize: %llu bytes", logConfig.logPath, logConfig.logSize]];
}

- (IBAction)onCopyLogPathButtonTapped:(UIButton *)sender {
    [[UIPasteboard generalPasteboard] setString:self.logPathTextfield.text];
    [ZegoHudManager showMessage:@"Log path copied!"];
}

- (IBAction)onShareLogConfigButtonTapped:(id)sender {
    ZGShareLogViewController *vc = [[ZGShareLogViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
    [vc shareMainAppLogs];
}

- (IBAction)onSaveButtonTapped:(id)sender {
    unsigned int appID = (unsigned int)self.appIDTextfield.text.longLongValue;
    NSString *appSign = self.appSignTextfield.text;
    [KeyCenter setAppID:appID];
    [KeyCenter setAppSign:appSign];
    [self appendLog:[NSString stringWithFormat:@"🔨 Set appID: %d, appSign: %@", appID, appSign]];
    
    NSString *userID = self.userIDTextfield.text;
    [ZGUserIDHelper setUserID:userID];
    [self appendLog:[NSString stringWithFormat:@"🔨 Set userID: %@", userID]];
}

- (IBAction)onAPITestButtonTapped:(UIButton *)sender {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Test" bundle:nil];
    UIViewController *vc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onApiCalledResult:(int)errorCode funcName:(NSString *)funcName info:(NSString *)info {
    ZGLogInfo(@"🚩 Api Called Result: errorCode: %d, FuncName: %@ Info: %@", errorCode, funcName, info);
}

#pragma mark - Others

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/// Append Log to Top View
- (void)appendLog:(NSString *)tipText {
    if (!tipText || tipText.length == 0) {
        return;
    }
    
    ZGLogInfo(@"%@", tipText);
    
    NSString *oldText = self.logTextView.text;
    NSString *newLine = oldText.length == 0 ? @"" : @"\n";
    NSString *newText = [NSString stringWithFormat:@"%@%@ %@", oldText, newLine, tipText];
    
    self.logTextView.text = newText;
    if(newText.length > 0 ) {
        UITextView *textView = self.logTextView;
        NSRange bottom = NSMakeRange(newText.length -1, 1);
        [textView scrollRangeToVisible:bottom];
        // an iOS bug, see https://stackoverflow.com/a/20989956/971070
        [textView setScrollEnabled:NO];
        [textView setScrollEnabled:YES];
    }
}

#pragma mark - Exit

- (void)viewDidDisappear:(BOOL)animated {
    [ZegoExpressEngine setApiCalledCallback:nil];
    [ZegoExpressEngine destroyEngine:nil];
}

@end

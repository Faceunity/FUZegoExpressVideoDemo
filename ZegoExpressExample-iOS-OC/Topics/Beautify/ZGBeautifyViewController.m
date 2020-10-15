//
//  ZGBeautifyViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/10.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_Beautify

#import "ZGBeautifyViewController.h"
#import "ZGBeautifyConfigTableViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGBeautifyViewController () <ZegoEventHandler>

@property (nonatomic, strong) ZegoExpressEngine *engine;

@property (nonatomic, copy) NSString *roomID;

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *playView;

@end

@implementation ZGBeautifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomID = @"BeautifyRoom-1";
    
    self.title = self.roomID;
    
    [self startLive];
}

- (ZegoExpressEngine *)engine {
    if (!_engine) {
        ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];
        ZGLogInfo(@"🚀 Create ZegoExpressEngine");
        _engine = [ZegoExpressEngine createEngineWithAppID:appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];
    }
    return _engine;
}

- (void)startLive {
    // Login Room
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    [self.engine loginRoom:self.roomID user:user];
    
    // Start preview
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
    ZGLogInfo(@"🔌 Start preview");
    [self.engine startPreview:previewCanvas];
    
    // Start publishing
    // Use userID as streamID
    NSString *streamID = [NSString stringWithFormat:@"%@", user.userID];
    ZGLogInfo(@"📤 Start publishing stream. streamID: %@", streamID);
    [self.engine startPublishingStream:streamID];
    
    // Start playing
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView];
    ZGLogInfo(@"📥 Start playing stream, streamID: %@", streamID);
    [self.engine startPlayingStream:streamID canvas:playCanvas];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ZGBeautifyConfigSegue"]) {
        ZGBeautifyConfigTableViewController *configVC = segue.destinationViewController;
        configVC.engine = self.engine;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Exit

- (void)dealloc {
    ZGLogInfo(@"🚪 Exit the room");
    [self.engine logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

@end

#endif

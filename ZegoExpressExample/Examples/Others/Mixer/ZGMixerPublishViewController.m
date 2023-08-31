//
//  ZGMixerPublishViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/21.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGMixerPublishViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NSString* const ZGMixerTopicKey_PublishStreamID = @"kPublishStreamID";

@interface ZGMixerPublishViewController () <ZegoEventHandler>

@property (nonatomic, copy) NSString *roomID;
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@end

@implementation ZGMixerPublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Publisher";
    self.roomID = @"0025";
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.streamIDTextField.text = [NSString stringWithFormat:@"%@_%@", [ZGUserIDHelper userID],@"0025"];
    self.tipsLabel.hidden = YES;
    
    [self startPreview];
}

- (void)startPreview {
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");

    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)
    
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    
    // Here we use the high quality video call scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    profile.scenario = ZegoScenarioHighQualityVideoCall;
    
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
    
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    
    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user];
    
    ZGLogInfo(@"🔌 Start preview");
    [[ZegoExpressEngine sharedEngine] startPreview:[ZegoCanvas canvasWithView:self.previewView]];
}

- (IBAction)startPublishing {
    if (self.streamIDTextField.text.length > 0) {
        ZGLogInfo(@"📤 Start publishing stream. streamID: %@", self.streamIDTextField.text);
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamIDTextField.text];
    } else {
        ZGLogWarn(@"❕ Please enter stream ID");
        [ZegoHudManager showMessage:@"❕ Please enter stream ID"];
    }
}


#pragma mark - ZegoEventHandler

-(void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🚪 Room State Changed Callback: %lu, errorCode: %d, roomID: %@", (unsigned long)reason, (int)errorCode, roomID);
}

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📤 Publisher State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
    if (state == ZegoPublisherStatePublishing) {
        self.title = @"🔵 Publishing";
        [self.startPublishingButton setTitle:@"🎉 Start Publishing Success" forState:UIControlStateNormal];
        self.tipsLabel.hidden = NO;
    }
}


#pragma mark - Exit

- (void)dealloc {
    ZGLogInfo(@"🚪 Exit the room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

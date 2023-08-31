//
//  ZGMultiVideoSourceViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/9/17.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGMultiVideoSourceViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ReplayKit/ReplayKit.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGMultiVideoSourceViewController ()<ZegoEventHandler>

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UILabel *engineStateTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *engineStateLabel;
@property (weak, nonatomic) IBOutlet UIButton *createEngineButton;

@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginRoomButton;

@property (weak, nonatomic) IBOutlet UILabel *localPreviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainChannelLabel;
@property (weak, nonatomic) IBOutlet UILabel *auxChannelLabel;

@property (weak, nonatomic) IBOutlet UILabel *mainVideoSourceTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *mainVideoSourceTypeButton;

@property (weak, nonatomic) IBOutlet UILabel *mainAudioSourceTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *mainAudioSourceTypeButton;

@property (weak, nonatomic) IBOutlet UILabel *auxVideoSourceTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *auxVideoSourceTypeButton;

@property (weak, nonatomic) IBOutlet UILabel *auxAudioSourceTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *auxAudioSourceTypeButton;

@property (weak, nonatomic) IBOutlet UILabel *sourceRestrictionLabel;

@property (weak, nonatomic) IBOutlet UIView *mainPreviewView;
@property (weak, nonatomic) IBOutlet UILabel *mainPublishStreamIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *mainPublishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *mainPublishStreamButton;
@property (weak, nonatomic) IBOutlet UIView *auxPreviewView;
@property (weak, nonatomic) IBOutlet UILabel *auxPublishStreamIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *auxPublishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *auxPublishStreamButton;

@property (weak, nonatomic) IBOutlet UILabel *playStreamLabel;
@property (weak, nonatomic) IBOutlet UIView *mainPlayView;
@property (weak, nonatomic) IBOutlet UILabel *mainPlayStreamIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *mainPlayStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *mainPlayStreamButton;
@property (weak, nonatomic) IBOutlet UIView *auxPlayView;
@property (weak, nonatomic) IBOutlet UILabel *auxPlayStreamIDLabel;
@property (weak, nonatomic) IBOutlet UITextField *auxPlayStreamIDTextField;
@property (weak, nonatomic) IBOutlet UIButton *auxPlayStreamButton;

@property (nonatomic, assign) BOOL isCreateEngine;
@property (nonatomic, assign) BOOL isLoginRoom;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *mainPublishStreamID;
@property (nonatomic, copy) NSString *auxPublishStreamID;
@property (nonatomic, copy) NSString *mainPlayStreamID;
@property (nonatomic, copy) NSString *auxPlayStreamID;

/// Scenraio
@property (nonatomic, assign) ZegoScenario scenario;

@property (nonatomic, assign) BOOL isMainPublishing;
@property (nonatomic, assign) ZegoVideoSourceType mainCurrentVideoSourceType;
@property (nonatomic, assign) ZegoAudioSourceType mainCurrentAudioSourceType;
@property (nonatomic, assign) BOOL mainEnableMicrophone;
@property (nonatomic, strong) ZegoCanvas *mainPreviewCanvas;

@property (nonatomic, assign) BOOL isAuxPublishing;
@property (nonatomic, assign) ZegoVideoSourceType auxCurrentVideoSourceType;
@property (nonatomic, assign) ZegoAudioSourceType auxCurrentAudioSourceType;
@property (nonatomic, strong) ZegoCanvas *auxPreviewCanvas;

@property (nonatomic, assign) BOOL isMainPlaying;
@property (nonatomic, strong) ZegoCanvas *mainPlayCanvas;
@property (nonatomic, assign) BOOL isAuxPlaying;
@property (nonatomic, strong) ZegoCanvas *auxPlayCanvas;

@property (nonatomic, strong) ZegoScreenCaptureConfig *captureConfig;
@property (nonatomic, strong) ZegoMediaPlayer *mediaPlayer;

@end

@implementation ZGMultiVideoSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isMainPublishing = FALSE;
    self.mainCurrentVideoSourceType = ZegoVideoSourceTypeNone;
    self.mainCurrentAudioSourceType = ZegoAudioSourceTypeNone;
    
    self.isAuxPublishing = FALSE;
    self.auxCurrentVideoSourceType = ZegoVideoSourceTypeNone;
    self.auxCurrentAudioSourceType = ZegoAudioSourceTypeNone;
    
    self.isMainPlaying = FALSE;
    self.isAuxPlaying = FALSE;
    
    self.isCreateEngine = FALSE;
    self.isLoginRoom = FALSE;
    self.roomID = @"0035";
    self.userID = [ZGUserIDHelper userID];
    self.userName = [ZGUserIDHelper userName];
    
    self.mainPublishStreamID = @"0035";
    self.auxPublishStreamID = @"0036";
    self.mainPlayStreamID = @"0035";
    self.auxPlayStreamID = @"0036";
    
    // Here we use the high quality video call scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    self.scenario = ZegoScenarioHighQualityVideoCall;
    
    self.mainPreviewCanvas = [ZegoCanvas canvasWithView:self.mainPreviewView];
    self.auxPreviewCanvas = [ZegoCanvas canvasWithView:self.auxPreviewView];
    self.mainPlayCanvas = [ZegoCanvas canvasWithView:self.mainPlayView];
    self.auxPlayCanvas = [ZegoCanvas canvasWithView:self.auxPlayView];
    
    self.captureConfig = [[ZegoScreenCaptureConfig alloc] init];
    
    [self setupUI];
    
}

- (void)dealloc {
    if (self.isLoginRoom) {
        [self logoutRoom];
    }
    
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)setupUI {
    self.navigationItem.title = NSLocalizedString(@"Topic.MultiVideoSource", nil);
    
    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];
    
    self.engineStateTitleLabel.text = NSLocalizedString(@"MultiVideoSource.EngineState", nil);
    self.engineStateLabel.text = @"Not Created 🔴";
    [self.createEngineButton setTitle: NSLocalizedString(@"MultiVideoSource.CreateEngine", nil) forState: UIControlStateNormal];
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.roomStateLabel.text = @"Not Connected 🔴";
    self.userIDLabel.text = [NSString stringWithFormat:@"UserID: %@", self.userID];
    self.userNameLabel.text = [NSString stringWithFormat:@"UserName: %@", self.userName];
    [self.loginRoomButton setTitle: NSLocalizedString(@"MultiVideoSource.LoginRoom", nil) forState: UIControlStateNormal];
    
    self.localPreviewLabel.text = NSLocalizedString(@"MultiVideoSource.LocalPreview", nil);
    self.mainChannelLabel.text = NSLocalizedString(@"MultiVideoSource.MainChannel", nil);
    self.auxChannelLabel.text = NSLocalizedString(@"MultiVideoSource.AuxChannel", nil);
    
    self.mainVideoSourceTypeLabel.text = NSLocalizedString(@"MultiVideoSource.VideoSourceType", nil);
    [self.mainVideoSourceTypeButton setTitle: NSLocalizedString(@"MultiVideoSource.None", nil) forState: UIControlStateNormal];
    self.mainAudioSourceTypeLabel.text = NSLocalizedString(@"MultiVideoSource.AudioSourceType", nil);
    [self.mainAudioSourceTypeButton setTitle: NSLocalizedString(@"MultiVideoSource.None", nil) forState: UIControlStateNormal];
    self.auxVideoSourceTypeLabel.text = NSLocalizedString(@"MultiVideoSource.VideoSourceType", nil);
    [self.auxVideoSourceTypeButton setTitle: NSLocalizedString(@"MultiVideoSource.None", nil) forState: UIControlStateNormal];
    self.auxAudioSourceTypeLabel.text = NSLocalizedString(@"MultiVideoSource.AudioSourceType", nil);
    [self.auxAudioSourceTypeButton setTitle: NSLocalizedString(@"MultiVideoSource.None", nil) forState: UIControlStateNormal];
    
    self.sourceRestrictionLabel.text = NSLocalizedString(@"MultiVideoSource.SourceRestriction", nil);
    
    self.mainPublishStreamIDLabel.text = NSLocalizedString(@"MultiVideoSource.StreamID", nil);
    self.mainPublishStreamIDTextField.text = self.mainPublishStreamID;
    [self.mainPublishStreamButton setTitle: NSLocalizedString(@"MultiVideoSource.StartPublish", nil) forState: UIControlStateNormal];
    
    self.auxPublishStreamIDLabel.text = NSLocalizedString(@"MultiVideoSource.StreamID", nil);
    self.auxPublishStreamIDTextField.text = self.auxPublishStreamID;
    [self.auxPublishStreamButton setTitle: NSLocalizedString(@"MultiVideoSource.StartPublish", nil) forState: UIControlStateNormal];
    
    self.playStreamLabel.text = NSLocalizedString(@"MultiVideoSource.PlayStream", nil);
    self.mainPlayStreamIDLabel.text = NSLocalizedString(@"MultiVideoSource.StreamID", nil);
    self.mainPlayStreamIDTextField.text = self.mainPlayStreamID;
    [self.mainPlayStreamButton setTitle: NSLocalizedString(@"MultiVideoSource.StartPlay", nil) forState: UIControlStateNormal];
    
    self.auxPlayStreamIDLabel.text = NSLocalizedString(@"MultiVideoSource.StreamID", nil);
    self.auxPlayStreamIDTextField.text = self.auxPlayStreamID;
    [self.auxPlayStreamButton setTitle: NSLocalizedString(@"MultiVideoSource.StartPlay", nil) forState: UIControlStateNormal];
}

- (IBAction)onCreateEngineButtonClick:(UIButton *)sender {
    if (!self.isCreateEngine) {
        [self appendLog:@"🚀 Create ZegoExpressEngine"];
        
        ZegoEngineConfig *config = [[ZegoEngineConfig alloc] init];
        config.advancedConfig = @{@"switch_media_source": @"true"};
        [ZegoExpressEngine setEngineConfig:config];
        
        ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
        profile.appID = [KeyCenter appID];
        profile.appSign = [KeyCenter appSign];
        profile.scenario = self.scenario;
        [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
        
        ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] initWithPreset:ZegoVideoConfigPreset1080P];
        [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
        [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig channel:ZegoPublishChannelAux];
        
        // main channel
        [[ZegoExpressEngine sharedEngine] setVideoSource:self.mainCurrentVideoSourceType];
        [[ZegoExpressEngine sharedEngine] setAudioSource:self.mainCurrentAudioSourceType  channel:ZegoPublishChannelMain];
        
        // aux channel
        if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypePlayer) {
            if (self.mediaPlayer == nil) {
                [self initMediaPlayer];
            }
            
//            [self.mediaPlayer setPlayerCanvas:self.auxPreviewCanvas];
            [[ZegoExpressEngine sharedEngine] setVideoSource:self.auxCurrentVideoSourceType instanceID:self.mediaPlayer.index.intValue channel:ZegoPublishChannelAux];
        } else {
            [[ZegoExpressEngine sharedEngine] setVideoSource:self.auxCurrentVideoSourceType channel:ZegoPublishChannelAux];
        }
        
        if (self.auxCurrentAudioSourceType == ZegoAudioSourceTypeMediaPlayer) {
            if (self.mediaPlayer == nil) {
                [self initMediaPlayer];
            }
        }
        [[ZegoExpressEngine sharedEngine] setAudioSource:self.auxCurrentAudioSourceType channel:ZegoPublishChannelAux];
        
        self.isCreateEngine = TRUE;
        [self.createEngineButton setTitle: NSLocalizedString(@"MultiVideoSource.DestroyEngine", nil) forState: UIControlStateNormal];
        self.engineStateLabel.text = @"Created 🟢";
    } else {
        if (self.isLoginRoom) {
            [self logoutRoom];
        }
        
        if (self.mediaPlayer != nil) {
            [[ZegoExpressEngine sharedEngine] destroyMediaPlayer:self.mediaPlayer];
            
            self.mediaPlayer = nil;
        }
        
        [ZegoExpressEngine destroyEngine:nil];
        
        self.isCreateEngine = FALSE;
        [self.createEngineButton setTitle: NSLocalizedString(@"MultiVideoSource.CreateEngine", nil) forState: UIControlStateNormal];
        self.engineStateLabel.text = @"Not Created 🔴";
    }
}

- (IBAction)onLoginRoomButtonClick:(UIButton *)sender {
    if (!self.isCreateEngine) {
        [self appendLog:@"create engine first!"];
        
        return;
    }
    
    if (!self.isLoginRoom) {
        ZegoUser *user = [ZegoUser userWithUserID:self.userID userName:self.userName];
        
        ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
        [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user];
        
        self.isLoginRoom = TRUE;
        [self.loginRoomButton setTitle: NSLocalizedString(@"MultiVideoSource.LogoutRoom", nil) forState: UIControlStateNormal];
    } else {
        [self logoutRoom];
    }
}

- (IBAction)onMainVideoSourceButtonClick:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    UIAlertAction *actionNone  = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.None", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.mainVideoSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.None", nil) forState: UIControlStateNormal];
        
        if (!self.isMainPublishing) {
            self.mainCurrentVideoSourceType = ZegoVideoSourceTypeNone;
            if (self.isCreateEngine) {
                [[ZegoExpressEngine sharedEngine] setVideoSource:self.mainCurrentVideoSourceType];
            }
        } else if (self.mainCurrentVideoSourceType != ZegoVideoSourceTypeNone) {
            [self appendLog:@"Switch main channel video source type to none"];
            [self mainSwitchVideoSource:ZegoVideoSourceTypeNone];
        }
    }];
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.isMainPublishing && self.isAuxPublishing && self.auxCurrentVideoSourceType == ZegoVideoSourceTypeCamera) {
            [self appendLog:@"Switch main channel video source type to camera failed, the source already used in aux channel!"];
            
            return;
        }
        
        [self.mainVideoSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.Camera", nil) forState: UIControlStateNormal];
        
        if (!self.isMainPublishing) {
            self.mainCurrentVideoSourceType = ZegoVideoSourceTypeCamera;
            if (self.isCreateEngine) {
                [[ZegoExpressEngine sharedEngine] setVideoSource:self.mainCurrentVideoSourceType];
            }
        } else if (self.mainCurrentVideoSourceType != ZegoVideoSourceTypeCamera) {
            [self appendLog:@"Switch main channel video source type to camera"];
            [self mainSwitchVideoSource:ZegoVideoSourceTypeCamera];
        }
    }];
    UIAlertAction *actionScreenSharing = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.ScreenSharing", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.isMainPublishing && self.isAuxPublishing && self.auxCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture) {
            [self appendLog:@"Switch main channel video source type to screen capture failed, the source already used in aux channel!"];
            
            return;
        }
        
        [self.mainVideoSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.ScreenSharing", nil) forState: UIControlStateNormal];
        
        if (!self.isMainPublishing) {
            self.mainCurrentVideoSourceType = ZegoVideoSourceTypeScreenCapture;
            if (self.isCreateEngine) {
                [[ZegoExpressEngine sharedEngine] setVideoSource:self.mainCurrentVideoSourceType];
            }
        } else if (self.mainCurrentVideoSourceType != ZegoVideoSourceTypeScreenCapture) {
            [self appendLog:@"Switch main channel video source type to screen capture"];
            [self mainSwitchVideoSource:ZegoVideoSourceTypeScreenCapture];
        }
    }];
    [alertController addAction:cancel];
    [alertController addAction:actionNone];
    [alertController addAction:actionCamera];
    [alertController addAction:actionScreenSharing];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onMainAudioSourceButtonClick:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    UIAlertAction *actionNone  = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.None", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.mainAudioSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.None", nil) forState: UIControlStateNormal];
        
        self.mainCurrentAudioSourceType = ZegoAudioSourceTypeNone;
        if (self.isCreateEngine) {
            [[ZegoExpressEngine sharedEngine] setAudioSource:self.mainCurrentAudioSourceType];
        }
    }];
    UIAlertAction *actionMicrophone = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.Microphone", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.mainAudioSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.Microphone", nil) forState: UIControlStateNormal];
        
        self.mainCurrentAudioSourceType = ZegoAudioSourceTypeMicrophone;
        if (self.isCreateEngine) {
            [[ZegoExpressEngine sharedEngine] setAudioSource:self.mainCurrentAudioSourceType];
        }
    }];
    
    [alertController addAction:cancel];
    [alertController addAction:actionNone];
    [alertController addAction:actionMicrophone];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onMainStartPublishButtonClick:(UIButton *)sender {
    if (!self.isLoginRoom) {
        [self appendLog:@"login room first!"];
        
        return;
    }
    
    if (self.isMainPublishing) {
        [self stopMainPublish];
    } else {
        if (self.isAuxPublishing && self.auxCurrentVideoSourceType == ZegoVideoSourceTypeCamera && self.mainCurrentVideoSourceType == ZegoVideoSourceTypeCamera) {
            [self appendLog:@"Start publishing main channel failed, video source type camera already used in aux channel!"];
            
            return;
        }
        
        if (self.isAuxPublishing && self.auxCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture && self.mainCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture) {
            [self appendLog:@"Start publishing main channel failed, video source type screen capture already used in aux channel!"];
            
            return;
        }
        
        if (self.mainCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture) {
            [self startScreenCapture];
        }
        
        [[ZegoExpressEngine sharedEngine] startPreview:self.mainPreviewCanvas];
        
        self.mainPublishStreamID = self.mainPublishStreamIDTextField.text;
        [self appendLog:[NSString stringWithFormat:@"Start publishing main channel: streamID:%@", self.mainPublishStreamID]];
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.mainPublishStreamID];
        
        [self.mainPublishStreamButton setTitle: NSLocalizedString(@"MultiVideoSource.StopPublish", nil) forState: UIControlStateNormal];
        
        self.isMainPublishing = TRUE;
    }
}

- (IBAction)onAuxVideoSourceButtonClick:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    UIAlertAction *actionNone  = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.None", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.auxVideoSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.None", nil) forState: UIControlStateNormal];
        
        if (!self.isAuxPublishing) {
            self.auxCurrentVideoSourceType = ZegoVideoSourceTypeNone;
            if (self.isCreateEngine) {
                [[ZegoExpressEngine sharedEngine] setVideoSource:self.auxCurrentVideoSourceType channel:ZegoPublishChannelAux];
            }
        } else if (self.auxCurrentVideoSourceType != ZegoVideoSourceTypeNone) {
            [self appendLog:@"Switch aux channel video source type to none"];
            [self auxSwitchVideoSource:ZegoVideoSourceTypeNone];
        }
    }];
    UIAlertAction *actionCamera = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.isAuxPublishing && self.isMainPublishing && self.mainCurrentVideoSourceType == ZegoVideoSourceTypeCamera) {
            [self appendLog:@"Switch aux channel video source type to camera failed, the source already used in main channel!"];
            
            return;
        }
        
        [self.auxVideoSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.Camera", nil) forState: UIControlStateNormal];
        
        if (!self.isAuxPublishing) {
            self.auxCurrentVideoSourceType = ZegoVideoSourceTypeCamera;
            if (self.isCreateEngine) {
                [[ZegoExpressEngine sharedEngine] setVideoSource:self.auxCurrentVideoSourceType channel:ZegoPublishChannelAux];
            }
        } else if (self.auxCurrentVideoSourceType != ZegoVideoSourceTypeCamera) {
            [self appendLog:@"Switch aux channel video source type to camera"];
            [self auxSwitchVideoSource:ZegoVideoSourceTypeCamera];
        }
    }];
    UIAlertAction *actionMediaPlayer = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.MediaPlayer", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.auxVideoSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.MediaPlayer", nil) forState: UIControlStateNormal];
        
        if (!self.isAuxPublishing) {
            self.auxCurrentVideoSourceType = ZegoVideoSourceTypePlayer;
            if (self.isCreateEngine) {
                if (self.mediaPlayer == nil) {
                    [self initMediaPlayer];
                }
                
                [self.mediaPlayer setPlayerCanvas:self.auxPreviewCanvas];
                [[ZegoExpressEngine sharedEngine] setVideoSource:self.auxCurrentVideoSourceType instanceID:self.mediaPlayer.index.intValue channel:ZegoPublishChannelAux];
            }
        } else if (self.auxCurrentVideoSourceType != ZegoVideoSourceTypePlayer) {
            [self appendLog:@"Switch aux channel video source type to player"];
            [self auxSwitchVideoSource:ZegoVideoSourceTypePlayer];
        }
    }];
    UIAlertAction *actionScreenSharing = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.ScreenSharing", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.isAuxPublishing && self.isMainPublishing && self.mainCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture) {
            [self appendLog:@"Switch aux channel video source type to screen capture failed, the source already used in main channel!"];
            
            return;
        }
        
        [self.auxVideoSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.ScreenSharing", nil) forState: UIControlStateNormal];
        
        if (!self.isAuxPublishing) {
            self.auxCurrentVideoSourceType = ZegoVideoSourceTypeScreenCapture;
            if (self.isCreateEngine) {
                [[ZegoExpressEngine sharedEngine] setVideoSource:self.auxCurrentVideoSourceType channel:ZegoPublishChannelAux];
            }
        } else if (self.auxCurrentVideoSourceType != ZegoVideoSourceTypeScreenCapture) {
            [self appendLog:@"Switch aux channel video source type to screen capture"];
            [self auxSwitchVideoSource:ZegoVideoSourceTypeScreenCapture];
        }
    }];
    UIAlertAction *actionMainPublishChannel = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.MainPublishChannel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.isAuxPublishing && self.isMainPublishing && self.mainCurrentVideoSourceType != ZegoVideoSourceTypeCamera) {
            [self appendLog:@"Can't switch aux channel video source type to main publish channel, main channel must use camera!"];
            
            return;
        }
        
        [self.auxVideoSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.MainPublishChannel", nil) forState: UIControlStateNormal];
        
        if (!self.isAuxPublishing) {
            self.auxCurrentVideoSourceType = ZegoVideoSourceTypeMainPublishChannel;
            if (self.isCreateEngine) {
                [[ZegoExpressEngine sharedEngine] setVideoSource:self.auxCurrentVideoSourceType channel:ZegoPublishChannelAux];
            }
        } else if (self.auxCurrentVideoSourceType != ZegoVideoSourceTypeMainPublishChannel) {
            [self appendLog:@"Switch aux channel video source type to main publish channel"];
            [self auxSwitchVideoSource:ZegoVideoSourceTypeMainPublishChannel];
        }
    }];
    [alertController addAction:cancel];
    [alertController addAction:actionNone];
    [alertController addAction:actionCamera];
    [alertController addAction:actionMediaPlayer];
    [alertController addAction:actionScreenSharing];
    [alertController addAction:actionMainPublishChannel];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onAuxAudioSourceButtonClick:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    UIAlertAction *actionNone  = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.None", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.auxAudioSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.None", nil) forState: UIControlStateNormal];
        
        if (!self.isAuxPublishing) {
            self.auxCurrentAudioSourceType = ZegoAudioSourceTypeNone;
            if (self.isCreateEngine) {
                [[ZegoExpressEngine sharedEngine] setAudioSource:self.auxCurrentAudioSourceType channel:ZegoPublishChannelAux];
            }
        } else if (self.auxCurrentAudioSourceType != ZegoAudioSourceTypeNone) {
            [self appendLog:@"Switch aux channel audio source type to none"];
            [self auxSwitchAudioSource:ZegoAudioSourceTypeNone];
        }
    }];
    UIAlertAction *actionMediaPlayer = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.MediaPlayer", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.auxAudioSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.MediaPlayer", nil) forState: UIControlStateNormal];
        
        if (!self.isAuxPublishing) {
            self.auxCurrentAudioSourceType = ZegoAudioSourceTypeMediaPlayer;
            if (self.isCreateEngine) {
                if (self.mediaPlayer == nil) {
                    [self initMediaPlayer];
                }
                [[ZegoExpressEngine sharedEngine] setAudioSource:self.auxCurrentAudioSourceType channel:ZegoPublishChannelAux];
            }
        } else if (self.auxCurrentAudioSourceType != ZegoAudioSourceTypeMediaPlayer) {
            [self appendLog:@"Switch aux channel audio source type to player"];
            [self auxSwitchAudioSource:ZegoAudioSourceTypeMediaPlayer];
        }
    }];
    UIAlertAction *actionMainPublishChannel = [UIAlertAction actionWithTitle:NSLocalizedString(@"MultiVideoSource.MainPublishChannel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (self.isAuxPublishing && self.isMainPublishing && self.mainCurrentAudioSourceType != ZegoAudioSourceTypeMicrophone) {
            [self appendLog:@"Can't switch aux channel audio source type to main publish channel, main channel must use microphone!"];
            
            return;
        }
        
        [self.auxAudioSourceTypeButton setTitle:NSLocalizedString(@"MultiVideoSource.MainPublishChannel", nil) forState: UIControlStateNormal];
        
        if (!self.isAuxPublishing) {
            self.auxCurrentAudioSourceType = ZegoAudioSourceTypeMainPublishChannel;
            if (self.isCreateEngine) {
                [[ZegoExpressEngine sharedEngine] setAudioSource:self.auxCurrentAudioSourceType channel:ZegoPublishChannelAux];
            }
        } else if (self.auxCurrentAudioSourceType != ZegoAudioSourceTypeMainPublishChannel) {
            [self appendLog:@"Switch aux channel audio source type to main publish channel"];
            [self auxSwitchAudioSource:ZegoAudioSourceTypeMainPublishChannel];
        }
    }];
    [alertController addAction:cancel];
    [alertController addAction:actionNone];
    [alertController addAction:actionMediaPlayer];
    [alertController addAction:actionMainPublishChannel];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onAuxStartPublishButtonClick:(UIButton *)sender {
    if (!self.isLoginRoom) {
        [self appendLog:@"login room first!"];
        
        return;
    }
    
    if (self.isAuxPublishing) {
        [self stopAuxPublish];
    } else {
        if (self.isMainPublishing && self.mainCurrentVideoSourceType == ZegoVideoSourceTypeCamera && self.auxCurrentVideoSourceType == ZegoVideoSourceTypeCamera) {
            [self appendLog:@"Start Publishing aux channel failed, camera source already used in main channel!"];
            
            return;
        }
        
        if (self.isMainPublishing && self.mainCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture && self.auxCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture) {
            [self appendLog:@"Start Publishing aux channel failed, screen capture source already used in main channel!"];
            
            return;
        }
        
        if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypeMainPublishChannel ||
            self.auxCurrentAudioSourceType == ZegoVideoSourceTypeMainPublishChannel) {
            if (!self.isMainPublishing) {
                [self appendLog:@"Start Publishing aux channel failed, main publish channel must started when aux channel use main publish channel!"];
                
                return;
            }
        }
        
        if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypeMainPublishChannel) {
            if (self.mainCurrentVideoSourceType != ZegoVideoSourceTypeCamera) {
                [self appendLog:@"Start Publishing aux channel failed, main publish channel must use camera when aux channel use main publish channel!"];
                
                return;
            }
        }
        
        if (self.auxCurrentAudioSourceType == ZegoAudioSourceTypeMainPublishChannel) {
            if (self.mainCurrentAudioSourceType != ZegoAudioSourceTypeMicrophone) {
                [self appendLog:@"Start Publishing aux channel failed, main publish channel must use microphone when aux channel use main publish channel!"];
                
                return;
            }
        }
        
        [[ZegoExpressEngine  sharedEngine] callExperimentalAPI:@"{\"method\":\"liveroom.video.set_video_fill_mode\",\"params\":{\"mode\":0,\"channel\":1}}"];
        
        [[ZegoExpressEngine sharedEngine] startPreview:self.auxPreviewCanvas channel:ZegoPublishChannelAux];
        
        self.auxPublishStreamID = self.auxPublishStreamIDTextField.text;
        
        [self appendLog:[NSString stringWithFormat:@"Start Publishing aux channel: streamID:%@", self.auxPublishStreamID]];
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.auxPublishStreamID channel:ZegoPublishChannelAux];
        
        if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture) {
            [self startScreenCapture];
        }
        
        if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypePlayer || self.auxCurrentAudioSourceType == ZegoAudioSourceTypeMediaPlayer) {
            if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypePlayer) {
                [self.mediaPlayer setPlayerCanvas:self.auxPreviewCanvas];
            }
            [self.mediaPlayer start];
        }
        
        [self.auxPublishStreamButton setTitle: NSLocalizedString(@"MultiVideoSource.StopPublish", nil) forState: UIControlStateNormal];
        
        self.isAuxPublishing = TRUE;
    }
}

- (IBAction)onMainPlayStreamButtonClick:(UIButton *)sender {
    if (!self.isLoginRoom) {
        [self appendLog:@"login room first!"];
        
        return;
    }
    
    if (self.isMainPlaying) {
        [self stopMainPlay];
    } else {
        self.mainPlayStreamID = self.mainPlayStreamIDTextField.text;
        if ([self.mainPlayStreamID length] == 0) {
            [self appendLog:@"Start playing stream: empty streamID"];
            
            return;
        }
        
        if (self.isAuxPlaying && [self.mainPlayStreamID isEqualToString:self.auxPlayStreamID]) {
            [self appendLog:@"Start playing stream: streamID already played"];
            
            return;
        }
        
        [self appendLog:[NSString stringWithFormat:@"Start playing stream: streamID:%@", self.mainPlayStreamID]];
        
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.mainPlayStreamID canvas:self.mainPlayCanvas];
        
        [self.mainPlayStreamButton setTitle: NSLocalizedString(@"MultiVideoSource.StopPlay", nil) forState: UIControlStateNormal];
        
        self.isMainPlaying = TRUE;
    }
}

- (IBAction)onAuxPlayStreamButtonClick:(UIButton *)sender {
    if (!self.isLoginRoom) {
        [self appendLog:@"login room first!"];
        
        return;
    }
    
    if (self.isAuxPlaying) {
        [self stopAuxPlay];
    } else {
        self.auxPlayStreamID = self.auxPlayStreamIDTextField.text;
        if ([self.auxPlayStreamID length] == 0) {
            [self appendLog:@"Start playing stream: empty streamID"];
            
            return;
        }
        
        if (self.isMainPlaying && [self.auxPlayStreamID isEqualToString:self.mainPlayStreamID]) {
            [self appendLog:@"Start playing stream: streamID already played"];
            
            return;
        }
        
        [self appendLog:[NSString stringWithFormat:@"Start playing stream: streamID:%@", self.auxPlayStreamID]];
        
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.auxPlayStreamID canvas:self.auxPlayCanvas];
        
        [self.auxPlayStreamButton setTitle: NSLocalizedString(@"MultiVideoSource.StopPlay", nil) forState: UIControlStateNormal];
        
        self.isAuxPlaying = TRUE;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/// Append Log to Top View
- (void)appendLog:(NSString *)tipText {
    if (!tipText || tipText.length ==0) {
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

- (void)initMediaPlayer {
    self.mediaPlayer = [[ZegoExpressEngine sharedEngine] createMediaPlayer];
    [self.mediaPlayer enableRepeat:TRUE];
    
    NSString *mp4ResPath = [[NSBundle mainBundle] pathForResource:@"ad" ofType:@"mp4"];
    [self.mediaPlayer loadResource:mp4ResPath callback:nil];
}

- (void)mainSwitchVideoSource:(ZegoVideoSourceType)videoSourceType {
    if (self.mainCurrentVideoSourceType == ZegoVideoSourceTypeCamera) {
        [[ZegoExpressEngine sharedEngine] stopPreview];
    } else if (self.mainCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture) {
        if (@available(iOS 12.0, *)) {
            [[ZegoExpressEngine sharedEngine] stopScreenCapture];
        }
    }
    
    self.mainCurrentVideoSourceType = videoSourceType;
    [[ZegoExpressEngine sharedEngine] setVideoSource:self.mainCurrentVideoSourceType];
    
    if (self.mainCurrentVideoSourceType == ZegoVideoSourceTypeCamera) {
        [[ZegoExpressEngine sharedEngine] startPreview:self.mainPreviewCanvas];
    } else if (self.mainCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture) {
        [self startScreenCapture];
    }
}

- (void)auxSwitchVideoSource:(ZegoVideoSourceType)videoSourceType {
    if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypeCamera) {
        [[ZegoExpressEngine sharedEngine] stopPreview:ZegoPublishChannelAux];
    } else if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypePlayer) {
        if (self.mediaPlayer != nil) {
            [self.mediaPlayer setPlayerCanvas:nil];
            
            if (self.auxCurrentAudioSourceType != ZegoAudioSourceTypeMediaPlayer) {
                [self.mediaPlayer pause];
            }
        }
    } else if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture) {
        if (@available(iOS 12.0, *)) {
            [[ZegoExpressEngine sharedEngine] stopScreenCapture];
        }
    }
    
    self.auxCurrentVideoSourceType = videoSourceType;
    if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypePlayer) {
        if (self.mediaPlayer == nil) {
            [self initMediaPlayer];
        }
        [[ZegoExpressEngine sharedEngine] setVideoSource:self.auxCurrentVideoSourceType instanceID:self.mediaPlayer.index.intValue channel:ZegoPublishChannelAux];
    } else {
        [[ZegoExpressEngine sharedEngine] setVideoSource:self.auxCurrentVideoSourceType channel:ZegoPublishChannelAux];
    }
    
    if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypeCamera) {
        [[ZegoExpressEngine sharedEngine] startPreview:self.auxPreviewCanvas channel:ZegoPublishChannelAux];
    } else if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypePlayer) {
        [self.mediaPlayer setPlayerCanvas:self.auxPreviewCanvas];
        if (self.mediaPlayer.currentState == ZegoMediaPlayerStatePausing) {
            [self.mediaPlayer resume];
        } else if (self.mediaPlayer.currentState != ZegoMediaPlayerStatePlaying) {
            [self.mediaPlayer start];
        }
    } else if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture) {
        [self startScreenCapture];
    }
}

- (void)auxSwitchAudioSource:(ZegoAudioSourceType)audioSourceType {
    if (self.auxCurrentAudioSourceType == ZegoAudioSourceTypeMediaPlayer) {
        if (self.mediaPlayer != nil && self.auxCurrentVideoSourceType != ZegoVideoSourceTypePlayer) {
            [self.mediaPlayer pause];
        }
    }
    
    self.auxCurrentAudioSourceType = audioSourceType;
    [[ZegoExpressEngine sharedEngine] setAudioSource:self.auxCurrentAudioSourceType channel:ZegoPublishChannelAux];
    
    if (self.auxCurrentAudioSourceType == ZegoAudioSourceTypeMediaPlayer) {
        if (self.mediaPlayer == nil) {
            [self initMediaPlayer];
        }
        if (self.mediaPlayer.currentState == ZegoMediaPlayerStatePausing) {
            [self.mediaPlayer resume];
        } else if (self.mediaPlayer.currentState != ZegoMediaPlayerStatePlaying) {
            [self.mediaPlayer start];
        }
    }
}

- (void)startScreenCapture {
    if (@available(iOS 12.0, *)) {
        [[ZegoExpressEngine sharedEngine] setAppGroupID:@"group.im.zego.express"];
        [[ZegoExpressEngine sharedEngine] startScreenCapture:self.captureConfig];
        // Note:
        // When screen recording is enabled, the iOS system w   ill start an independent recording sub-process
        // and callback the methods of the [SampleHandler] class in the file [ ./ZegoExpressExample-iOS-OC-Broadcast/SampleHandler.m ]
        // Please refer to it to implement [SampleHandler] class in your own project
        
        // Note:
        // ⚠️ There is a known issue here: RPSystemBroadcastPickerView does not work on iOS 13
        // when using UIScene lifecycle (SceneDelegate), this issue was fixed since iOS 14. If
        // you want to use it on iOS 13, you should use the UIApplication lifecycle.
        //
        // Ref:
        // https://stackoverflow.com/q/60075142/7027076
        // https://github.com/twilio/video-quickstart-ios/issues/438
        //
        RPSystemBroadcastPickerView *broadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ZegoExpressExample-Broadcast" ofType:@"appex" inDirectory:@"PlugIns"];
        if (!bundlePath) {
            [ZegoHudManager showMessage:@"Can not find bundle `ZegoExpressExample-Broadcast.appex`"];
            return;
        }
        
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        if (!bundle) {
            [ZegoHudManager showMessage:[NSString stringWithFormat:@"Can not find bundle at path: %@", bundlePath]];
            return;
        }
        
        broadcastPickerView.preferredExtension = bundle.bundleIdentifier;
        
        
        // Traverse the subviews to find the button to skip the step of clicking the system view
        
        // This solution is not officially recommended by Apple, and may be invalid in future system updates
        
        // The safe solution is to directly add RPSystemBroadcastPickerView as subView to your view
        
        for (UIView *subView in broadcastPickerView.subviews) {
            if ([subView isMemberOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subView;
                [button sendActionsForControlEvents:UIControlEventAllEvents];
            }
        }
        
    } else {
        [ZegoHudManager showMessage:@"This feature only supports iOS12 or above"];
    }
}

#pragma mark - ZegoEventHandler

-(void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if(reason == ZegoRoomStateChangedReasonLogining)
    {
        ZGLogInfo(@"🚩 🚪 Logining room");
        self.roomStateLabel.text = @"🟡 RoomState: Logining";
    }
    else if(reason == ZegoRoomStateChangedReasonLogined)
    {
        ZGLogInfo(@"🚩 🚪 Login room success");
        self.roomStateLabel.text = @"🟢 RoomState: Logined";
    }
    else if (reason == ZegoRoomStateChangedReasonLoginFailed)
    {
        ZGLogInfo(@"🚩 🚪 Login room failed");
        self.roomStateLabel.text = @"🔴 RoomState: Login failed";
    }
    else if(reason == ZegoRoomStateChangedReasonKickOut)
    {
        ZGLogInfo(@"🚩 🚪 Kick out of room");
        self.roomStateLabel.text = @"🔴 RoomState: Kick out";
    }
    else if(reason == ZegoRoomStateChangedReasonReconnecting)
    {
        ZGLogInfo(@"🚩 🚪 Reconnecting room");
        self.roomStateLabel.text = @"🟡 RoomState: Reconnecting";
    }
    else if(reason == ZegoRoomStateChangedReasonReconnectFailed)
    {
        ZGLogInfo(@"🚩 🚪 Reconnect room failed");
        self.roomStateLabel.text = @"🔴 RoomState: Reconnect failed";
    }
    else if(reason == ZegoRoomStateChangedReasonReconnected)
    {
        ZGLogInfo(@"🚩 🚪 Reconnect room success");
        self.roomStateLabel.text = @"🟢 RoomState: Reconnected";
    }
    else
    {
        // Logout
        // Logout failed
    }
}

- (void)logoutRoom {
    if (self.isMainPlaying) {
        [self stopMainPlay];
    }
    
    if (self.isMainPublishing) {
        [self stopMainPublish];
    }
    
    if (self.isAuxPlaying) {
        [self stopAuxPlay];
    }
    
    if (self.isAuxPublishing) {
        [self stopAuxPublish];
    }
    
    ZGLogInfo(@"🚪 Logout room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
    self.isLoginRoom = FALSE;
    [self.loginRoomButton setTitle: NSLocalizedString(@"MultiVideoSource.LoginRoom", nil) forState: UIControlStateNormal];
    self.roomStateLabel.text = @"Not Connected 🔴";
}

- (void)stopMainPlay {
    [self appendLog:[NSString stringWithFormat:@"Stop playing stream: streamID:%@", self.mainPlayStreamID]];
    
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.mainPlayStreamID];
    
    [self.mainPlayStreamButton setTitle: NSLocalizedString(@"MultiVideoSource.StartPlay", nil) forState: UIControlStateNormal];
    
    self.isMainPlaying = FALSE;
}

- (void)stopMainPublish {
    [self appendLog:[NSString stringWithFormat:@"Stop publishing main channel: streamID:%@", self.mainPublishStreamID]];
    
    if (self.mainCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture) {
        if (@available(iOS 12.0, *)) {
            [[ZegoExpressEngine sharedEngine] stopScreenCapture];
        }
    }
    
    [[ZegoExpressEngine sharedEngine] stopPreview];
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    
    [self.mainPublishStreamButton setTitle: NSLocalizedString(@"MultiVideoSource.StartPublish", nil) forState: UIControlStateNormal];
    
    self.isMainPublishing = FALSE;
}

- (void)stopAuxPlay {
    [self appendLog:[NSString stringWithFormat:@"Stop playing stream: streamID:%@", self.auxPlayStreamID]];
    
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.auxPlayStreamID];
    
    [self.auxPlayStreamButton setTitle: NSLocalizedString(@"MultiVideoSource.StartPlay", nil) forState: UIControlStateNormal];
    
    self.isAuxPlaying = FALSE;
}

- (void)stopAuxPublish {
    [self appendLog:[NSString stringWithFormat:@"Stop Publishing aux channel: streamID:%@", self.auxPublishStreamID]];
    
    if (self.mediaPlayer != nil) {
        [self.mediaPlayer setPlayerCanvas:nil];
        [self.mediaPlayer stop];
    }
    
    if (self.auxCurrentVideoSourceType == ZegoVideoSourceTypeScreenCapture) {
        if (@available(iOS 12.0, *)) {
            [[ZegoExpressEngine sharedEngine] stopScreenCapture];
        }
    }
    
    [[ZegoExpressEngine sharedEngine] stopPreview:ZegoPublishChannelAux];
    [[ZegoExpressEngine sharedEngine] stopPublishingStream:ZegoPublishChannelAux];
    
    [self.auxPublishStreamButton setTitle: NSLocalizedString(@"MultiVideoSource.StartPublish", nil) forState: UIControlStateNormal];
    
    self.isAuxPublishing = FALSE;
}

@end

//
//  ZGH265ViewController.m
//  ZegoExpressExample
//
//  Created by 王鑫 on 2021/8/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGH265ViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGH265ViewController ()<ZegoEventHandler>

// Log View
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

// Preview view
@property (weak, nonatomic) IBOutlet UILabel *localPreviewViewLabel;
@property (weak, nonatomic) IBOutlet UILabel *localPreviewViewVideoCodecLabel;
@property (weak, nonatomic) IBOutlet UILabel *localPreviewViewResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *localPreviewViewVideoQualityLabel;
@property (weak, nonatomic) IBOutlet UIView *localPreviewView;

// Play view 1
@property (weak, nonatomic) IBOutlet UILabel *remotePlayView1Label;
@property (weak, nonatomic) IBOutlet UILabel *remotePlayView1VideoCodecLabel;
@property (weak, nonatomic) IBOutlet UILabel *remotePlayView1ResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *remotePlayView1VideoQualityLabel;
@property (weak, nonatomic) IBOutlet UIView *remotePlayView1;
@property (weak, nonatomic) IBOutlet UITextField *remotePlayStreamID1TextField;
@property (weak, nonatomic) IBOutlet UIButton *remoteStartPlaying1Button;

// Play view 2
@property (weak, nonatomic) IBOutlet UILabel *remotePlayView2Label;
@property (weak, nonatomic) IBOutlet UILabel *remotePlayView2VideoCodecLabel;
@property (weak, nonatomic) IBOutlet UILabel *remotePlayView2ResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *remotePlayView2VideoQualityLabel;
@property (weak, nonatomic) IBOutlet UIView *remotePlayView2;
@property (weak, nonatomic) IBOutlet UITextField *remotePlayStreamID2TextField;
@property (weak, nonatomic) IBOutlet UIButton *remoteStartPlaying2Button;

// Play view 3
@property (weak, nonatomic) IBOutlet UILabel *remotePlayView3Label;
@property (weak, nonatomic) IBOutlet UILabel *remotePlayView3VideoCodecLabel;
@property (weak, nonatomic) IBOutlet UILabel *remotePlayView3ResolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *remotePlayView3VideoQualityLabel;
@property (weak, nonatomic) IBOutlet UIView *remotePlayView3;
@property (weak, nonatomic) IBOutlet UITextField *remotePlayStreamID3TextField;
@property (weak, nonatomic) IBOutlet UIButton *remoteStartPlaying3Button;

// PublishStream
@property (nonatomic, copy) NSString *publishStreamID;
@property (nonatomic, assign) int publishFPS;
@property (nonatomic, assign) CGSize publishResolution;
@property (nonatomic, assign) int publishBitrate;
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *publishBitrateTextField;
@property (weak, nonatomic) IBOutlet UIButton *publishFPSButton;
@property (weak, nonatomic) IBOutlet UIButton *publishResolutionButton;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;

// MixStream
@property (nonatomic, assign) int mixStreamFPS;
@property (nonatomic, assign) CGSize mixStreamResolution;
@property (nonatomic, assign) int mixStreamH264Bitrate;
@property (nonatomic, assign) int mixStreamH265Bitrate;
@property (weak, nonatomic) IBOutlet UITextField *mixStreamBitrateH264TextField;
@property (weak, nonatomic) IBOutlet UITextField *mixStreamIDH264TextField;
@property (weak, nonatomic) IBOutlet UITextField *mixStreamBitrateH265TextField;
@property (weak, nonatomic) IBOutlet UITextField *mixStreamIDH265TextField;
@property (weak, nonatomic) IBOutlet UIButton *mixStreamFPSButton;
@property (weak, nonatomic) IBOutlet UIButton *mixStreamResolutionButton;
@property (weak, nonatomic) IBOutlet UIButton *startMixStreamButton;

@property (nonatomic, strong) ZegoMixerTask *mixerTask;

@property (nonatomic) NSMutableDictionary<NSNumber *,NSString *> *playViewToStreamIDMutableDictionary;
@property (nonatomic, strong) NSMutableArray<ZegoStream *> *remoteStreamList;
@property (nonatomic, assign) ZegoPublisherState publisherState;
@property (nonatomic, assign) BOOL isMixing;

@end

@implementation ZGH265ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.playViewToStreamIDMutableDictionary = [NSMutableDictionary dictionary];
    self.remoteStreamList = [NSMutableArray array];
    [self initVideoConfig];
    [self setupEngineAndLogin];
    [self setupUI];
    [self startPreview];
    // Do any additional setup after loading the view.
}

- (void)initVideoConfig {
    // PublishStream config
    self.publishFPS = 15;
    self.publishResolution = CGSizeMake(360, 600);

    // MixStream config
    self.mixStreamFPS = 15;
    self.mixStreamResolution = CGSizeMake(360, 600);

    // update bitrate
    [self updatePublishingBitrate];
    [self updateMixStreamBitrate];
}

- (void)setupEngineAndLogin {
    [self appendLog:@"🚀 Create ZegoExpressEngine"];
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

    // H265 need hardware encode(publishing) and hardware decoder(playing)
    [[ZegoExpressEngine sharedEngine] enableHardwareEncoder:YES];
    [[ZegoExpressEngine sharedEngine] enableHardwareDecoder:YES];

    if([[ZegoExpressEngine sharedEngine] isVideoEncoderSupported:ZegoVideoCodecIDH265]) {
        [self appendLog:@"🎉 Current device support H265 encoder."];
    } else {
        [self appendLog:@"❕ Current device does not support H265 encoder."];
    }
    if([[ZegoExpressEngine sharedEngine] isVideoDecoderSupported:ZegoVideoCodecIDH265]) {
        [self appendLog:@"🎉 Current device support H265 decoder."];
    } else {
        [self appendLog:@"❕ Current device does not support H265 decoder."];
    }

    [self appendLog:[NSString stringWithFormat:@"🚪Login Room roomID: %@", self.roomID]];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:self.userID]];
}

- (void)setupUI {
    self.publishStreamIDTextField.text = @"0001";
    self.mixStreamIDH264TextField.text = @"h264";
    self.mixStreamIDH265TextField.text = @"h265";
    self.remotePlayStreamID1TextField.text = @"0001";
    self.remotePlayStreamID2TextField.text = @"h264";
    self.remotePlayStreamID3TextField.text = @"h265";

    // Preview view
    self.localPreviewViewLabel.text = NSLocalizedString(@"PreviewLabel", nil);

    // Play view 1
    self.remotePlayView1Label.text = NSLocalizedString(@"PlayStreamLabel", nil);
    [self.remoteStartPlaying1Button setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.remoteStartPlaying1Button setTitle:@"Stop Playing" forState:UIControlStateSelected];

    // Play view 2
    self.remotePlayView2Label.text = NSLocalizedString(@"PlayStreamLabel", nil);
    [self.remoteStartPlaying2Button setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.remoteStartPlaying2Button setTitle:@"Stop Playing" forState:UIControlStateSelected];

    // Play view 3
    self.remotePlayView3Label.text = NSLocalizedString(@"PlayStreamLabel", nil);
    [self.remoteStartPlaying3Button setTitle:@"Start Playing" forState:UIControlStateNormal];
    [self.remoteStartPlaying3Button setTitle:@"Stop Playing" forState:UIControlStateSelected];

    // Publishing
    [self.publishFPSButton setTitle:@"15" forState:UIControlStateNormal];
    [self.publishResolutionButton setTitle:@"360*600" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"Start Publishing" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"Stop Publishing" forState:UIControlStateSelected];

    // Mix Stream
    [self.mixStreamFPSButton setTitle:@"15" forState:UIControlStateNormal];
    [self.mixStreamResolutionButton setTitle:@"360*600" forState:UIControlStateNormal];
    [self.startMixStreamButton setTitle:@"Start Mix Stream" forState:UIControlStateNormal];
    [self.startMixStreamButton setTitle:@"Stop Mix Stream" forState:UIControlStateSelected];
}

- (void)startPreview {
    [self updateVideoConfig];

    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localPreviewView];
    [self appendLog:@"🔌 Start preview"];
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
}

#pragma mark - Actions

#pragma mark - Play view 1
- (IBAction)onRemoteStartPlaying1ButtonTapped:(UIButton *)sender {
    NSString *playStream = self.remotePlayStreamID1TextField.text;
    if (sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", playStream]];

        [[ZegoExpressEngine sharedEngine] stopPlayingStream: playStream];

        self.remotePlayStreamID1TextField.enabled = YES;
        [self.playViewToStreamIDMutableDictionary removeObjectForKey:@(1)];
    } else {
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView1];
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", playStream]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:playStream canvas:playCanvas];

        self.remotePlayStreamID1TextField.enabled = NO;
        [self.playViewToStreamIDMutableDictionary setObject:playStream forKey:@(1)];
    }
    sender.selected = !sender.isSelected;
}


#pragma mark - Play view 2
- (IBAction)onRemoteStartPlaying2ButtonTapped:(UIButton *)sender {
    NSString *playStream = self.remotePlayStreamID2TextField.text;
    if (sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", playStream]];

        [[ZegoExpressEngine sharedEngine] stopPlayingStream: playStream];

        self.remotePlayStreamID2TextField.enabled = YES;
        [self.playViewToStreamIDMutableDictionary removeObjectForKey:@(2)];
    } else {
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView2];
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", playStream]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:playStream canvas:playCanvas];

        self.remotePlayStreamID2TextField.enabled = NO;
        [self.playViewToStreamIDMutableDictionary setObject:playStream forKey:@(2)];
    }
    sender.selected = !sender.isSelected;
}


#pragma mark - Play view 3
- (IBAction)onRemoteStartPlaying3ButtonTapped:(UIButton *)sender {
    NSString *playStream = self.remotePlayStreamID3TextField.text;
    if (sender.isSelected) {
        // Stop playing
        [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", playStream]];

        [[ZegoExpressEngine sharedEngine] stopPlayingStream: playStream];

        self.remotePlayStreamID3TextField.enabled = YES;
        [self.playViewToStreamIDMutableDictionary removeObjectForKey:@(3)];
    } else {
        // Start playing
        ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.remotePlayView3];
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", playStream]];

        [[ZegoExpressEngine sharedEngine] startPlayingStream:playStream canvas:playCanvas];

        self.remotePlayStreamID3TextField.enabled = NO;
        [self.playViewToStreamIDMutableDictionary setObject:playStream forKey:@(3)];
    }
    sender.selected = !sender.isSelected;
}


#pragma mark - Publishing
- (IBAction)onPublishFPSButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *FPS15 = [UIAlertAction actionWithTitle:@"15" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.publishFPS = 15;
        [self.publishFPSButton setTitle:@"15" forState:UIControlStateNormal];
        [self updatePublishingBitrate];
    }];
    UIAlertAction *FPS30 = [UIAlertAction actionWithTitle:@"30" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.publishFPS = 30;
        [self.publishFPSButton setTitle:@"30" forState:UIControlStateNormal];
        [self updatePublishingBitrate];
    }];
    UIAlertAction *FPS60 = [UIAlertAction actionWithTitle:@"60" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.publishFPS = 60;
        [self.publishFPSButton setTitle:@"60" forState:UIControlStateNormal];
        [self updatePublishingBitrate];
    }];
    [alertController addAction:cancel];
    [alertController addAction:FPS15];
    [alertController addAction:FPS30];
    [alertController addAction:FPS60];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onPublishResolutionButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *Resolution360p = [UIAlertAction actionWithTitle:@"360*600" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.publishResolution = CGSizeMake(360, 600);
        [self.publishResolutionButton setTitle:@"360*600" forState:UIControlStateNormal];
        [self updatePublishingBitrate];
    }];
    UIAlertAction *Resolution720p = [UIAlertAction actionWithTitle:@"720*1280" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.publishResolution = CGSizeMake(720, 1280);
        [self.publishResolutionButton setTitle:@"720*1280" forState:UIControlStateNormal];
        [self updatePublishingBitrate];
    }];
    UIAlertAction *Resolution1080p = [UIAlertAction actionWithTitle:@"1080*1920" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.publishResolution = CGSizeMake(1080, 1920);
        [self.publishResolutionButton setTitle:@"1080*1920" forState:UIControlStateNormal];
        [self updatePublishingBitrate];
    }];
    [alertController addAction:cancel];
    [alertController addAction:Resolution360p];
    [alertController addAction:Resolution720p];
    [alertController addAction:Resolution1080p];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    if (self.publisherState == ZegoPublisherStatePublishing) {
        [self stopPublishing];
    } else {
        [self startPublishing];
    }
}

- (void)startPublishing {
    [self updateVideoConfig];
    self.publishStreamID = self.publishStreamIDTextField.text;
    // Start publishing
    [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.publishStreamID]];

    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.publishStreamID];
}

- (void)stopPublishing {
    // Stop publishing
    [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.publishStreamIDTextField.text]];
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];}


#pragma mark - Mix stream
- (IBAction)onMixStreamFPSButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *FPS15 = [UIAlertAction actionWithTitle:@"15" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.mixStreamFPS = 15;
        [self.mixStreamFPSButton setTitle:@"15" forState:UIControlStateNormal];
        [self updateMixStreamBitrate];
    }];
    UIAlertAction *FPS30 = [UIAlertAction actionWithTitle:@"30" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.mixStreamFPS = 30;
        [self.mixStreamFPSButton setTitle:@"30" forState:UIControlStateNormal];
        [self updateMixStreamBitrate];
    }];
    UIAlertAction *FPS60 = [UIAlertAction actionWithTitle:@"60" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.mixStreamFPS = 60;
        [self.mixStreamFPSButton setTitle:@"60" forState:UIControlStateNormal];
        [self updateMixStreamBitrate];
    }];
    [alertController addAction:cancel];
    [alertController addAction:FPS15];
    [alertController addAction:FPS30];
    [alertController addAction:FPS60];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onMixStreamResolutionButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *Resolution360p = [UIAlertAction actionWithTitle:@"360*600" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.mixStreamResolution = CGSizeMake(360, 600);
        [self.mixStreamResolutionButton setTitle:@"360*600" forState:UIControlStateNormal];
        [self updateMixStreamBitrate];
    }];
    UIAlertAction *Resolution720p = [UIAlertAction actionWithTitle:@"720*1280" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.mixStreamResolution = CGSizeMake(720, 1280);
        [self.mixStreamResolutionButton setTitle:@"720*1280" forState:UIControlStateNormal];
        [self updateMixStreamBitrate];
    }];
    UIAlertAction *Resolution1080p = [UIAlertAction actionWithTitle:@"1080*1920" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.mixStreamResolution = CGSizeMake(1080, 1920);
        [self.mixStreamResolutionButton setTitle:@"1080*1920" forState:UIControlStateNormal];
        [self updateMixStreamBitrate];
    }];
    [alertController addAction:cancel];
    [alertController addAction:Resolution360p];
    [alertController addAction:Resolution720p];
    [alertController addAction:Resolution1080p];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onStartMixStreamButtonTapped:(UIButton *)sender {
    if (self.isMixing) {
        [self stopMixerTask];
    } else {
        [self startMixerTask];
    }
}

- (void)startMixerTask {
    ZGLogInfo(@"🧬 Start mixer task");

    NSString *taskID = [NSString stringWithFormat:@"%@_MixStream", self.roomID];

    ZegoMixerTask *task = [[ZegoMixerTask alloc] initWithTaskID:taskID];

    ZegoMixerVideoConfig *videoConfig = [[ZegoMixerVideoConfig alloc] initWithResolution:self.mixStreamResolution fps:self.mixStreamFPS bitrate:3000];
    [task setVideoConfig:videoConfig];

    [task setAudioConfig:[ZegoMixerAudioConfig defaultConfig]];

    int streamCount = [self checkNumberOfStream];
    if (streamCount <= 0) {
        [self appendLog:@"❕ Start mix stream fail, because the number of stream is 0."];
        return;
    }
    NSMutableArray<ZegoMixerInput *> *array = [NSMutableArray new];
    CGRect firstRect = CGRectMake(0, 0, videoConfig.resolution.width/2, videoConfig.resolution.height/2);
    CGRect secondRect = CGRectMake(videoConfig.resolution.width/2, 0, videoConfig.resolution.width/2, videoConfig.resolution.height/2);
    CGRect thirdRect = CGRectMake(0, videoConfig.resolution.height/2, videoConfig.resolution.width/2, videoConfig.resolution.height/2);
    CGRect fourthRect = CGRectMake(videoConfig.resolution.width/2, videoConfig.resolution.height/2, videoConfig.resolution.width/2, videoConfig.resolution.height/2);
    CGRect rectArray[] = {firstRect, secondRect, thirdRect, fourthRect};
    if (self.publisherState == ZegoPublisherStatePublishing) {
        ZegoMixerInput *firstInput = [[ZegoMixerInput alloc] initWithStreamID:self.publishStreamID contentType:ZegoMixerInputContentTypeVideo layout:firstRect];
        [array addObject:firstInput];
        for(int idx = 0; idx < 3 && idx < [self.remoteStreamList count]; ++idx) {
            ZegoMixerInput *input = [[ZegoMixerInput alloc] initWithStreamID:[self.remoteStreamList objectAtIndex:idx].streamID contentType:ZegoMixerInputContentTypeVideo layout:rectArray[idx+1]];
            [array addObject:input];
        }
    } else {
        for(int idx = 0; idx < 4 && idx < [self.remoteStreamList count]; ++idx) {
            ZegoMixerInput *input = [[ZegoMixerInput alloc] initWithStreamID:[self.remoteStreamList objectAtIndex:idx].streamID contentType:ZegoMixerInputContentTypeVideo layout:rectArray[idx]];
            [array addObject:input];
        }
    }
    NSArray<ZegoMixerInput *> *inputArray = [NSArray arrayWithArray:array];
    [task setInputList:inputArray];

    ZegoMixerOutput *outputH264 = [[ZegoMixerOutput alloc] initWithTarget:self.mixStreamIDH264TextField.text];
    ZegoMixerOutputVideoConfig *outputH264VideoConfig = [[ZegoMixerOutputVideoConfig alloc] init];
    [outputH264VideoConfig configWithCodecID:ZegoVideoCodecIDDefault bitrate:self.mixStreamH264Bitrate];
    [outputH264 setVideoConfig:outputH264VideoConfig];

    ZegoMixerOutput *outputH265 = [[ZegoMixerOutput alloc] initWithTarget:self.mixStreamIDH265TextField.text];
    ZegoMixerOutputVideoConfig *outputH265VideoConfig = [ZegoMixerOutputVideoConfig new];
    [outputH265VideoConfig configWithCodecID:ZegoVideoCodecIDH265 bitrate:self.mixStreamH265Bitrate];
    [outputH265 setVideoConfig:outputH265VideoConfig];

    NSArray<ZegoMixerOutput *> *outputArray = @[outputH264, outputH265];
    [task setOutputList:outputArray];

    // Start Mixer Task
    [ZegoHudManager showNetworkLoading];

    [[ZegoExpressEngine sharedEngine] startMixerTask:task callback:^(int errorCode, NSDictionary * _Nullable extendedData) {
        ZGLogInfo(@"🚩 🧬 Start mixer task result errorCode: %d", errorCode);

        [ZegoHudManager hideNetworkLoading];

        if (errorCode == 0) {
            self.isMixing = YES;

        } else {
            [ZegoHudManager showMessage:[NSString stringWithFormat:@"🚩 🧬 Start mixer errorCode: %d", errorCode]];
        }
    }];

    // Save the task object
    self.mixerTask = task;
}

- (void)stopMixerTask {
    ZGLogInfo(@"🧬 Stop mixer task");
    [[ZegoExpressEngine sharedEngine] stopMixerTask:self.mixerTask callback:^(int errorCode) {
        ZGLogInfo(@"🚩 🧬 Stop mixer task result errorCode: %d", errorCode);
    }];

    self.isMixing = NO;
}

- (int)checkNumberOfStream {
    return (int)[self.remoteStreamList count] + (self.publisherState == ZegoPublisherStatePublishing ? 1 : 0);
}

#pragma mark - Private Method
- (void)updatePublishingBitrate {
    self.publishBitrate = [self getBitrateWithFPS:self.publishFPS resolution:self.publishResolution videoCodecID:ZegoVideoCodecIDH265];
    self.publishBitrateTextField.text = [NSString stringWithFormat:@"%@kbps", @(self.publishBitrate)];
}

- (void)updateVideoConfig {
    // Start preview
    /// Capture resolution, control the resolution of camera image acquisition. SDK requires the width and height to be set to even numbers. Only the camera is not started and the custom video capture is not used, the setting is effective. For performance reasons, the SDK scales the video frame to the encoding resolution after capturing from camera and before rendering to the preview view. Therefore, the resolution of the preview image is the encoding resolution. If you need the resolution of the preview image to be this value, Please call [setCapturePipelineScaleMode] first to change the capture pipeline scale mode to [Post]
    ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] initWithPreset:ZegoVideoConfigPreset1080P];

    videoConfig.encodeResolution = self.publishResolution;
    videoConfig.fps = self.publishFPS;
    videoConfig.bitrate = self.publishBitrate;
    videoConfig.codecID = ZegoVideoCodecIDH265;

    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
}

- (void)updateMixStreamBitrate {
    self.mixStreamH264Bitrate = [self getBitrateWithFPS:self.mixStreamFPS resolution:self.mixStreamResolution videoCodecID:ZegoVideoCodecIDDefault];
    self.mixStreamBitrateH264TextField.text = [NSString stringWithFormat:@"%@kbps", @(self.mixStreamH264Bitrate)];
    self.mixStreamH265Bitrate = [self getBitrateWithFPS:self.mixStreamFPS resolution:self.mixStreamResolution videoCodecID:ZegoVideoCodecIDH265];
    self.mixStreamBitrateH265TextField.text = [NSString stringWithFormat:@"%@kbps", @(self.mixStreamH265Bitrate)];
}

- (int)getBitrateWithFPS:(int)fps resolution:(CGSize)resolution videoCodecID:(ZegoVideoCodecID)videoCodecID {
    // contact ZEGO technical support.
    return 0.0901 * [self getCoefficientOfVideoCodec:videoCodecID] * [self getCoefficientOfFPS:fps] * pow(resolution.width * resolution.height, 0.7371);
}

- (double)getCoefficientOfFPS:(int)fps {
    double coefficient = 1.0;
    switch (fps) {
        case 15:
            coefficient = 1.0;
            break;
        case 30:
            coefficient = 1.5;
            break;
        case 60:
            coefficient = 1.8;
            break;
    }
    return coefficient;
}

- (double)getCoefficientOfVideoCodec:(ZegoVideoCodecID)videoCodecID {
    double coefficient = 1.0;
    switch (videoCodecID) {
        case ZegoVideoCodecIDDefault:
            coefficient = 1.0;
            break;
        case ZegoVideoCodecIDH265:
            coefficient = 0.8;
            break;
    }
    return coefficient;
}

#pragma mark - ZegoEventHandler
// Refresh the remote streams list
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🌊 Room Stream Update Callback: %lu, StreamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);

    if (updateType == ZegoUpdateTypeAdd) {
        for (ZegoStream *stream in streamList) {
            ZGLogInfo(@"🚩 🌊 --- [Add] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID);
            if (![self.remoteStreamList containsObject:stream]) {
                [self.remoteStreamList addObject:stream];
            }
        }
    } else if (updateType == ZegoUpdateTypeDelete) {
        for (ZegoStream *stream in streamList) {
            ZGLogInfo(@"🚩 🌊 --- [Delete] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID);
            __block ZegoStream *delStream = nil;
            [self.remoteStreamList enumerateObjectsUsingBlock:^(ZegoStream * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.streamID isEqualToString:stream.streamID] && [obj.user.userID isEqualToString:stream.user.userID]) {
                    delStream = obj;
                    *stop = YES;
                }
            }];
            [self.remoteStreamList removeObject:delStream];
        }
    }
    if(_isMixing) {
        [self stopMixerTask];
        [self startMixerTask];
    }
}

-(void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🚪 Room State Changed Callback: %lu, errorCode: %d, roomID: %@", (unsigned long)reason, (int)errorCode, roomID);
}

#pragma mark - Publish
// The callback triggered when the state of stream publishing changes.
- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    // If the state is PUBLISHER_STATE_NO_PUBLISH and the errcode is not 0, it means that stream publishing has failed
    // and no more retry will be attempted by the engine. At this point, the failure of stream publishing can be indicated
    // on the UI of the App.
    self.publisherState = state;
    [self appendLog:[NSString stringWithFormat:@"🚩 Publisher State Update State: %lu", state]];
}

//After calling the [startPublishingStream] successfully, the callback will be received every 3 seconds.
// Through the callback, the collection frame rate, bit rate, RTT, packet loss rate and other quality data
// of the published audio and video stream can be obtained, and the health of the publish stream can be monitored
// in real time.
- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    NSString *videoCodec = @"";
    switch (quality.videoCodecID) {
        case 0:
            videoCodec = @"H264";
            break;
        case 1:
            videoCodec = @"SVC";
            break;
        case 2:
            videoCodec = @"VP8";
            break;
        case 3:
            videoCodec = @"H265";
            break;
        default:
            break;
    }
    self.localPreviewViewVideoCodecLabel.text = [NSString stringWithFormat:@"VideoCodec: %@", videoCodec];

    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"Bitrate: %.2fkbps \n", quality.videoKBPS];
    [text appendFormat:@"FPS: %.2f", quality.videoEncodeFPS];
    self.localPreviewViewVideoQualityLabel.text = [text copy];
    [self appendLog:[NSString stringWithFormat:@"🚩 Publisher Quality Update : %@", text]];
}

// The callback triggered when the first audio frame is captured.
- (void)onPublisherCapturedAudioFirstFrame {
    [self appendLog:[NSString stringWithFormat:@"🚩 Receive Publisher Captured Audio First Frame"]];
}

- (void)onPublisherCapturedVideoFirstFrame:(ZegoPublishChannel)channel {
    [self appendLog:[NSString stringWithFormat:@"🚩 Receive Publisher Captured Audio First Frame"]];
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    [self appendLog:[NSString stringWithFormat:@"🚩 Publisher Video Size Changed: Size: %@", @(size)]];
    self.localPreviewViewResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
}

// The callback triggered when the state of relayed streaming to CDN changes.
- (void)onPublisherRelayCDNStateUpdate:(NSArray<ZegoStreamRelayCDNInfo *> *)infoList streamID:(NSString *)streamID {
    [self appendLog:[NSString stringWithFormat:@"🚩 Publisher RelayCDN State Update, streamID: %@", streamID]];

}

#pragma mark - Play
// The callback triggered when the state of stream playing changes.
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    // If the state is ZegoPlayerStateNoPlay and the errcode is not 0, it means that stream playing has failed and
    // no more retry will be attempted by the engine. At this point, the failure of stream playing can be indicated
    // on the UI of the App.
    [self appendLog:[NSString stringWithFormat:@"🚩 Player State Update State: %lu", state]];
}

//After calling the [startPlayingStream] successfully, this callback will be triggered every 3 seconds.
// The collection frame rate, bit rate, RTT, packet loss rate and other quality data can be obtained,
// such the health of the publish stream can be monitored in real time.
- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality streamID:(NSString *)streamID {
    NSString *videoCodec = @"videoCodec: ";
    switch (quality.videoCodecID) {
        case 0:
            videoCodec = [videoCodec stringByAppendingString:@"H264"];
            break;
        case 1:
            videoCodec = [videoCodec stringByAppendingString:@"SVC"];
            break;
        case 2:
            videoCodec = [videoCodec stringByAppendingString:@"VP8"];
            break;
        case 3:
            videoCodec = [videoCodec stringByAppendingString:@"H265"];
            break;
        default:
            break;
    }
    NSMutableString *text = [NSMutableString string];
    [text appendFormat:@"Bitrate: %.2fkbps \n", quality.videoKBPS];
    [text appendFormat:@"FPS: %.2f", quality.videoDecodeFPS];
    NSNumber *idx = NULL;
    for(NSNumber *key in self.playViewToStreamIDMutableDictionary) {
        if ([[self.playViewToStreamIDMutableDictionary objectForKey:key] isEqual:streamID]) {
            idx = key;
        }
    }
    switch (idx.intValue) {
        case 1:
            self.remotePlayView1VideoCodecLabel.text = videoCodec;
            self.remotePlayView1VideoQualityLabel.text = text;
            break;
        case 2:
            self.remotePlayView2VideoCodecLabel.text = videoCodec;
            self.remotePlayView2VideoQualityLabel.text = text;
            break;
        case 3:
            self.remotePlayView3VideoCodecLabel.text = videoCodec;
            self.remotePlayView3VideoQualityLabel.text = text;
            break;
        default:
            break;
    }
    [self appendLog:[NSString stringWithFormat:@"🚩 Player Quality Update : %@", text]];

}

// The callback triggered when a media event occurs during streaming playing.
- (void)onPlayerMediaEvent:(ZegoPlayerMediaEvent)event streamID:(NSString *)streamID {

}

// The callback triggered when the first audio frame is received.
- (void)onPlayerRecvAudioFirstFrame:(NSString *)streamID {

}

// The callback triggered when the first video frame is received.
- (void)onPlayerRecvVideoFirstFrame:(NSString *)streamID {

}

// The callback triggered when the first video frame is rendered.
- (void)onPlayerRenderVideoFirstFrame:(NSString *)streamID {

}

//The callback triggered when the stream playback resolution changes.
- (void)onPlayerVideoSizeChanged:(CGSize)size streamID:(NSString *)streamID {
    NSNumber *idx = NULL;
    for(NSNumber *key in self.playViewToStreamIDMutableDictionary) {
        if ([[self.playViewToStreamIDMutableDictionary objectForKey:key] isEqual:streamID]) {
            idx = key;
        }
    }
    switch (idx.intValue) {
        case 1:
            self.remotePlayView1ResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
            break;
        case 2:
            self.remotePlayView2ResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
            break;
        case 3:
            self.remotePlayView3ResolutionLabel.text = [NSString stringWithFormat:@"Resolution: %.fx%.f  ", size.width, size.height];
            break;
        default:
            break;
    }
}

#pragma mark - Setter, Manage UI State

- (void)setIsMixing:(BOOL)isMixing {
    _isMixing = isMixing;

    [self.startMixStreamButton setTitle:_isMixing ? @"Stop Mixer Task" : @"Start Mixer Task" forState:UIControlStateNormal];
}

- (void)setPublisherState:(ZegoPublisherState)publisherState {
    _publisherState = publisherState;

    [self.startPublishingButton setTitle:_publisherState == ZegoPublisherStatePublishing ? @"Stop Publishing" : @"Start Publishing" forState:UIControlStateNormal];
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

- (void)dealloc {
    if (self.isMixing)
        [self stopMixerTask];
    if (self.publisherState == ZegoPublisherStatePublishing)
        [self stopPublishing];
    ZGLogInfo(@"🚪 Exit the room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}


@end

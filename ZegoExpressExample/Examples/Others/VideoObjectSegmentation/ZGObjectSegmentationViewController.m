//
//  ZGObjectSegmentationViewController.m
//  ZegoExpressExample
//
//  Created by zego on 2022/11/2.
//  Copyright © 2022 Zego. All rights reserved.
//

#import "ZGObjectSegmentationViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "AppDelegate.h"

@interface ZGObjectSegmentationViewController () <ZegoEventHandler, ZegoCustomVideoRenderHandler>

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (strong, nonatomic) IBOutlet UIImageView* previewView;
@property (weak, nonatomic) IBOutlet UIImageView *playView1;
@property (weak, nonatomic) IBOutlet UIImageView *playView2;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UILabel *roomInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *hardwareEncodeStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *hardwareDecodeStateLabel;
@property (weak, nonatomic) IBOutlet UITextField *publishStreamIDText;
@property (weak, nonatomic) IBOutlet UITextField *publishCDNUrlText;
@property (weak, nonatomic) IBOutlet UITextField *trafficControlPropertyText;
@property (weak, nonatomic) IBOutlet UIButton *codecIDButton;
@property (weak, nonatomic) IBOutlet UIButton *alphaProfileButton;
@property (weak, nonatomic) IBOutlet UISwitch *hardwareEncodeSwitch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cameraSelectionSegment;
@property (weak, nonatomic) IBOutlet UISwitch *foucsSwitch;
@property (weak, nonatomic) IBOutlet UILabel *exposureCompensationValueLabel;
@property (weak, nonatomic) IBOutlet UISwitch *trafficControlSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *exposureSwitch;
@property (weak, nonatomic) IBOutlet UILabel *zoomFactorLabel;
@property (weak, nonatomic) IBOutlet UITextField *encodeResolutionWText;
@property (weak, nonatomic) IBOutlet UITextField *encodeResolutionHText;
@property (weak, nonatomic) IBOutlet UITextField *captureResolutionWText;
@property (weak, nonatomic) IBOutlet UITextField *captureResolutionHText;
@property (weak, nonatomic) IBOutlet UITextField *videoFPSText;
@property (weak, nonatomic) IBOutlet UITextField *videoBitrateText;
@property (weak, nonatomic) IBOutlet UIButton *mirrorButton;
@property (weak, nonatomic) IBOutlet UITextField *subjectSegmentationHexColorText;
@property (weak, nonatomic) IBOutlet UILabel *whitenIntensityLabel;
@property (weak, nonatomic) IBOutlet UILabel *rosyIntensityLabel;
@property (weak, nonatomic) IBOutlet UILabel *smoothIntensityLabel;
@property (weak, nonatomic) IBOutlet UILabel *sharpenIntensityLabel;
@property (weak, nonatomic) IBOutlet UISwitch *objectSegmentationSwitch;
@property (weak, nonatomic) IBOutlet UIButton *subjectSegmentationTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *subjectSegmentationMaxResolutionButton;
@property (weak, nonatomic) IBOutlet UITextField *playStream1Text;
@property (weak, nonatomic) IBOutlet UITextField *playStream2Text;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *resourceModeButton;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UITextField *playSnapshotStreamText;
@property (weak, nonatomic) IBOutlet UILabel *videoOSStateText;
@property (weak, nonatomic) IBOutlet UIButton *loginRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *startPreviewButton;
@property (weak, nonatomic) IBOutlet UIButton *processTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *blurLevelButton;
@property (weak, nonatomic) IBOutlet UITextField *backgroundColorText;
@property (weak, nonatomic) IBOutlet UIStackView *publishConfigLayout;
@property (weak, nonatomic) IBOutlet UIStackView *cameraLayout;
@property (weak, nonatomic) IBOutlet UIStackView *videoConfigLayout;
@property (weak, nonatomic) IBOutlet UIStackView *backgroundConfigLayout;
@property (weak, nonatomic) IBOutlet UIStackView *osLayout;
@property (weak, nonatomic) IBOutlet UIStackView *beautyLayout;
@property (weak, nonatomic) IBOutlet UIStackView *playLayout;
@property (weak, nonatomic) IBOutlet UISwitch *alphaChannelEncoderSwitch;


@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *streamID;
@property (nonatomic, copy) NSString *playStream1ID;
@property (nonatomic, copy) NSString *playStream2ID;
@property (nonatomic, assign) BOOL firstRotate;
@property (nonatomic, assign) BOOL firstRotateFlag;
@property (nonatomic, assign)ZegoVideoCodecID videoCodecID;
@property (nonatomic, assign)ZegoAlphaLayoutType subjectSegmentationAlphaProfile;
@property (nonatomic, assign) ZegoObjectSegmentationType objectSegmentationType;
@property (nonatomic, assign) int subjectSegmentationMaxResolution;
@property (nonatomic, strong) ZegoEffectsBeautyParam *beautyParam;
@property (nonatomic,assign) BOOL isPlay1;
@property (nonatomic,assign) BOOL isPlay2;
@property (nonatomic, assign) ZegoStreamResourceMode resourceMode;
@property (nonatomic, assign) BOOL isPublish;
@property (nonatomic, assign) BOOL isPreview;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, assign) ZegoBackgroundProcessType backgroundProcessType;
@property (nonatomic,assign) int backgroundColor;
@property (nonatomic, assign) ZegoBackgroundBlurLevel blurLevel;
@property (nonatomic, copy) NSString* backgroundImageURL;
@property (strong, nonatomic) UIImage* backgroundImage;


@end

@implementation ZGObjectSegmentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userID = [ZGUserIDHelper userID];
    self.roomID = @"0035";
    self.streamID = @"0035";
    self.beautyParam = [[ZegoEffectsBeautyParam alloc] init];
    self.isPlay1 = NO;
    self.isPlay2 = NO;
    self.isPublish = NO;
    self.isPreview = NO;
    self.isLogin = NO;
    self.videoCodecID = ZegoVideoCodecIDDefault;
    self.backgroundProcessType = ZegoBackgroundProcessTypeTransparent;
    self.blurLevel = ZegoBackgroundBlurLevelMedium;;
    self.backgroundColor = 0;
    self.backgroundImageURL = @"";
    self.backgroundImage = nil;
    self.roomIDTextField.text = @"0035";
    
    [self setupUI];
    [self setupEngineAndLogin];
    
    [self InitUIOrientation];
    
    [[ZegoExpressEngine sharedEngine] setAppOrientationMode:self.orientationMode];
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation {
// only for ios 16 and newer system
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
    if(@available(iOS 16.0, *)){
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
    }
    else
#endif
    {
        UIDevice *device = [UIDevice currentDevice];
        if (device.orientation != (UIDeviceOrientation)orientation && [device respondsToSelector:@selector(setOrientation:)]) {
            SEL selector  = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            [invocation setArgument:&orientation atIndex:2];
            [invocation invoke];
        }
    }
}

- (void)InitUIOrientation {
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    self.firstRotate = NO;
    self.firstRotateFlag = NO;

    if(self.rotationType == RotateTypeFixedPortrait)
    {
        self.firstRotate = YES;
        self.firstRotateFlag = YES;
        [self setInterfaceOrientation:UIInterfaceOrientationPortrait];

        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskPortrait];
        
        [[ZegoExpressEngine sharedEngine]setAppOrientation:UIInterfaceOrientationPortrait];
    }
    else if (self.rotationType == RotateTypeFixedLandscape){
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskLandscapeLeft];
        
        [self setInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        
        // set video resolution
        self.captureResolutionWText.text = @"640";
        self.captureResolutionHText.text = @"360";
        self.encodeResolutionWText.text = @"640";
        self.encodeResolutionHText.text = @"360";
        
        [[ZegoExpressEngine sharedEngine]setAppOrientation:UIInterfaceOrientationLandscapeLeft];
    }
    else if (self.rotationType == RotateTypeFixedAutoRotate){
        // auto rotate
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskAllButUpsideDown];
    }
}


- (void)setupEngineAndLogin {
    [self.previewView setBackgroundColor:UIColor.clearColor];
    [self.playView1 setBackgroundColor:UIColor.clearColor];
    [self.playView2 setBackgroundColor:UIColor.clearColor];

    ZegoEngineConfig *config = [[ZegoEngineConfig alloc]init];
    if(self.veGlkView){
        config.advancedConfig = @{@"video_display_class":@"glkview"};
    }
    if(self.veMetal){
        config.advancedConfig = @{@"video_render_backend":@"metal"};
    }
    
    [ZegoExpressEngine setEngineConfig:config];
    
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
    
    // If enable custom render
    if(self.enableCustomRender){
        // Init render config
        ZegoCustomVideoRenderConfig *renderConfig = [[ZegoCustomVideoRenderConfig alloc] init];
        renderConfig.bufferType = ZegoVideoBufferTypeRawData;
        renderConfig.frameFormatSeries = ZegoVideoFrameFormatSeriesRGB;

        // Enable custom video render
        [[ZegoExpressEngine sharedEngine] enableCustomVideoRender:YES config:renderConfig];

        // Set custom video render handler
        [[ZegoExpressEngine sharedEngine] setCustomVideoRenderHandler:self];
    }
    
    // Initialize the Effects Beauty environment before logging in to the room
    if(self.enableEffectsEnv){
        [[ZegoExpressEngine sharedEngine] startEffectsEnv];
        [self appendLog:@"Enable effects beauty environment"];
    }
    
    // Set object segmentation
    ZegoAlphaLayoutType layoutType =(ZegoAlphaLayoutType)self.subjectSegmentationAlphaProfile;
    BOOL enableALphaEncoder = self.alphaChannelEncoderSwitch.isOn;
    [[ZegoExpressEngine sharedEngine]enableAlphaChannelVideoEncoder:enableALphaEncoder alphaLayout:(ZegoAlphaLayoutType)self.subjectSegmentationAlphaProfile channel:ZegoPublishChannelMain];
    [self appendLog:[NSString stringWithFormat:@"enableAlphaChannelVideoEncoder, enable:%d,layoutType:%d",enableALphaEncoder,(int)layoutType]];
}

- (void)setupUI {
    self.roomInfoLabel.text = [NSString stringWithFormat:@"UserID: %@  RoomID:%@", self.userID, self.roomID];
    
    //    [self.playButton setTitle:@"Start Playing" forState:UIControlStateNormal];
    //    [self.playButton setTitle:@"Stop Playing" forState:UIControlStateSelected];
    
    self.logTextView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.logTextView.textColor = [UIColor whiteColor];
    //    self.superResolutionStateLabel.text = @"Off";
    //    self.playStreamIDText.text = self.streamID;
    //    self.superResolutionStreamIDText.text = self.streamID;
    self.playStream1Text.text = self.streamID;
    self.playStream2Text.text = self.streamID;
    [self.cameraSelectionSegment setSelectedSegmentIndex:0];
    self.subjectSegmentationMaxResolution = 5;
    self.subjectSegmentationAlphaProfile = ZegoAlphaLayoutTypeBottom;
    self.videoCodecID = ZegoVideoCodecIDDefault;
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.previewView.backgroundColor = [UIColor clearColor];
    self.playView1.backgroundColor = [UIColor clearColor];
    self.playView2.backgroundColor = [UIColor clearColor];
    self.resourceMode = ZegoStreamResourceModeOnlyRTC;
    //    self.subjectSegmentationTypeButton
    [_publishConfigLayout setHidden:YES];
    [_cameraLayout setHidden:YES];
    [_videoConfigLayout setHidden:YES];
    [_backgroundConfigLayout setHidden:YES];
    [_osLayout setHidden:YES];
    [_beautyLayout setHidden:YES];
    [_playLayout setHidden:YES];
}

// iOS 16 not work
- (BOOL)shouldAutorotate{
    if(self.rotationType != RotateTypeFixedAutoRotate){
        if(_firstRotate){
            return NO;
        }
        else{
            _firstRotate = YES;
            return YES;
        }
    }
    else{
        return YES;
    }
}

-(void)loginRoom{
    // LoginRoom
    [self appendLog:[NSString stringWithFormat:@"🚪Login Room roomID: %@", self.roomID]];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:self.userID]];
}

-(void)logoutRoom{
    [self appendLog:[NSString stringWithFormat:@"🚪logoutRoom"]];
    [[ZegoExpressEngine sharedEngine]logoutRoom];
}
- (IBAction)onButtonLoginRoom:(UIButton *)sender {
    if(!self.isLogin){
        [self loginRoom];
        [self.loginRoomButton setTitle:@"Logout Room" forState:UIControlStateNormal];
        self.isLogin = YES;
    }else{
        [self logoutRoom];
        [self.loginRoomButton setTitle:@"Login Room" forState:UIControlStateNormal];
        self.isLogin = NO;
    }
}
- (IBAction)onButtonStartPreview:(UIButton *)sender {
    if(!self.isPreview){
        // Start preview
        ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
        previewCanvas.alphaBlend = self.veRenderAlpha;
        [self appendLog:@"🔌 Start preview"];
        if(self.enableCustomRender){
            [[ZegoExpressEngine sharedEngine] startPreview:nil];
        }else{
            [[ZegoExpressEngine sharedEngine]startPreview:previewCanvas];
        }
        [self.startPreviewButton setTitle:@"Stop Preview" forState:UIControlStateNormal];
        
        self.isPreview = YES;
    }else{
        [[ZegoExpressEngine sharedEngine] stopPreview];
        [self.startPreviewButton setTitle:@"Start Preview" forState:UIControlStateNormal];
        self.isPreview = NO;
    }
}

- (IBAction)onCameraFocusSwitch:(UISwitch *)sender {
    [self appendLog:[NSString stringWithFormat:@"🚩 camera focus feature is %@", sender.isOn ? @"on" : @"off"]];
}

- (IBAction)onCameraExposureSwitch:(UISwitch *)sender {
    [self appendLog:[NSString stringWithFormat:@"🚩 camera exposure feature is %@", sender.isOn ? @"on" : @"off"]];
}

- (IBAction)onCameraExposureModeSelected:(UISegmentedControl *)sender {
    [self appendLog:[NSString stringWithFormat:@"📥 camera exposure selected %@", sender.selectedSegmentIndex == 0 ? @"Auto" : @"ContinuousAuto"]];
    [[ZegoExpressEngine sharedEngine] setCameraExposureMode:sender.selectedSegmentIndex channel:ZegoPublishChannelMain];
}

- (IBAction)onCameraFocusModeSelected:(UISegmentedControl *)sender {
    [self appendLog:[NSString stringWithFormat:@"📥 camera focus selected %@", sender.selectedSegmentIndex == 0 ? @"Auto" : @"ContinuousAuto"]];
    [[ZegoExpressEngine sharedEngine] setCameraFocusMode:sender.selectedSegmentIndex channel:ZegoPublishChannelMain];
}

- (IBAction)onTapGestureRecognizerInPreview:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:sender.view];
    float x = point.x / sender.view.bounds.size.width;
    float y = point.y / sender.view.bounds.size.height;
    
    if (self.foucsSwitch.isOn) {
        [[ZegoExpressEngine sharedEngine] setCameraFocusPointInPreviewX:x y:y channel:ZegoPublishChannelMain];
    }
    if (self.exposureSwitch.isOn) {
        [[ZegoExpressEngine sharedEngine] setCameraExposurePointInPreviewX:x y:y channel:ZegoPublishChannelMain];
    }
}

- (IBAction)onCameraZoomFactor:(UISlider *)sender {
    [[ZegoExpressEngine sharedEngine] setCameraZoomFactor:sender.value];
    [self appendLog:[NSString stringWithFormat:@"📥 OnZoomFactorChanged: %.1f", sender.value]];

    self.zoomFactorLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
}

- (IBAction)onExposureCompensation:(UISlider *)sender {
    [[ZegoExpressEngine sharedEngine] setCameraExposureCompensation:sender.value];
    
    [self appendLog:[NSString stringWithFormat:@"📥 onExposureCompensationChanged: %.1f", sender.value]];

    self.exposureCompensationValueLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
}
- (IBAction)onSetVideoConfigButtonTapped:(id)sender {
    [self setVideoConfig];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setRestrictRotation:UIInterfaceOrientationMaskPortrait];
    ZGLogInfo(@"🚪 Stop effects environment");
    [[ZegoExpressEngine sharedEngine] stopEffectsEnv];

    // Logout room before exiting
    ZGLogInfo(@"🚪 Logout room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];

    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

- (IBAction)onHardwareEncodeChanged:(UISwitch *)sender {
    // enable hardware encode
    [[ZegoExpressEngine sharedEngine]enableHardwareEncoder:sender.isOn];
    [self appendLog:[NSString stringWithFormat:@"enableHardwareEncoder, enable:%d", sender.isOn]];
}
- (IBAction)onTrafficControlChanged:(UISwitch *)sender {
    int property = self.trafficControlPropertyText.text.intValue;
    [[ZegoExpressEngine sharedEngine]enableTrafficControl:sender.isOn property:property];
    [self appendLog:[NSString stringWithFormat:@"enableTrafficControl, enable:%d, property:%d", sender.isOn, property]];
}

- (IBAction)onCodecIDButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *codecDefault = [UIAlertAction actionWithTitle:@"Default(H.264)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.videoCodecID = ZegoVideoCodecIDDefault;
        [self.codecIDButton setTitle:@"Default(H.264)" forState:UIControlStateNormal];
    }];
    UIAlertAction *codecSVC = [UIAlertAction actionWithTitle:@"H.264 SVC" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.videoCodecID = ZegoVideoCodecIDSVC;
        [self.codecIDButton setTitle:@"H.264 SVC" forState:UIControlStateNormal];

    }];
    UIAlertAction *codecVP8 = [UIAlertAction actionWithTitle:@"VP8" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.videoCodecID = ZegoVideoCodecIDVP8;
        [self.codecIDButton setTitle:@"VP8" forState:UIControlStateNormal];
    }];
    UIAlertAction *codecH265 = [UIAlertAction actionWithTitle:@"H.265" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.videoCodecID = ZegoVideoCodecIDH265;
        [self.codecIDButton setTitle:@"H.265" forState:UIControlStateNormal];
    }];

    [alertController addAction:cancel];
    [alertController addAction:codecDefault];
    [alertController addAction:codecSVC];
    [alertController addAction:codecVP8];
    [alertController addAction:codecH265];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}
-(void)setAlphaChannelEncoder:(BOOL)enable{
    ZegoAlphaLayoutType layoutType =(ZegoAlphaLayoutType)self.subjectSegmentationAlphaProfile;
    [[ZegoExpressEngine sharedEngine]enableAlphaChannelVideoEncoder:enable alphaLayout:(ZegoAlphaLayoutType)self.subjectSegmentationAlphaProfile channel:ZegoPublishChannelMain];
    [self appendLog:[NSString stringWithFormat:@"enableAlphaChannelVideoEncoder, enable:%d, layoutType:%d", enable, (int)layoutType]];
}
- (IBAction)onAlphaEncoderSwitch:(UISwitch *)sender {
    BOOL alphaChannelEncoder = [self.alphaChannelEncoderSwitch isOn];
    [self setAlphaChannelEncoder:alphaChannelEncoder];
}
- (IBAction)onAlphaEncoderTypeTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *profileNone = [UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.subjectSegmentationAlphaProfile = ZegoAlphaLayoutTypeNone;
        [self.alphaProfileButton setTitle:@"None" forState:UIControlStateNormal];
        if(self.alphaChannelEncoderSwitch.isOn){
            [self setAlphaChannelEncoder:YES];
        }
    }];
    UIAlertAction *profileLeft = [UIAlertAction actionWithTitle:@"Left" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.subjectSegmentationAlphaProfile = ZegoAlphaLayoutTypeLeft;
        [self.alphaProfileButton setTitle:@"Left" forState:UIControlStateNormal];
        if(self.alphaChannelEncoderSwitch.isOn){
            [self setAlphaChannelEncoder:YES];
        }
    }];
    UIAlertAction *profileRight = [UIAlertAction actionWithTitle:@"Right" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.subjectSegmentationAlphaProfile = ZegoAlphaLayoutTypeRight;
        [self.alphaProfileButton setTitle:@"Right" forState:UIControlStateNormal];
        if(self.alphaChannelEncoderSwitch.isOn){
            [self setAlphaChannelEncoder:YES];
        }
    }];
    UIAlertAction *profileBottom = [UIAlertAction actionWithTitle:@"Bottom" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.subjectSegmentationAlphaProfile = ZegoAlphaLayoutTypeBottom;
        [self.alphaProfileButton setTitle:@"Bottom" forState:UIControlStateNormal];
        if(self.alphaChannelEncoderSwitch.isOn){
            [self setAlphaChannelEncoder:YES];
        }
    }];

    [alertController addAction:cancel];
    [alertController addAction:profileNone];
    [alertController addAction:profileLeft];
    [alertController addAction:profileRight];
    [alertController addAction:profileBottom];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onPublishingButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Stop publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.publishStreamIDText.text]];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
        
        // clear view
//        self.previewView.image = nil;
        self.isPublish = NO;
    } else {
        // Set video config
        [self setVideoConfig];
        
        // set hardware encoder
        [[ZegoExpressEngine sharedEngine]enableHardwareEncoder:self.hardwareEncodeSwitch.isOn];
        [self appendLog:[NSString stringWithFormat:@"enableHardwareEncoder, enable:%d", self.hardwareEncodeSwitch.isOn]];
        
        //Set traffic control
        [[ZegoExpressEngine sharedEngine]enableTrafficControl:self.trafficControlSwitch.isOn property:self.trafficControlPropertyText.text.intValue];
        [self appendLog:[NSString stringWithFormat:@"enableTrafficControl, enable:%d, property:%d", self.trafficControlSwitch.isOn, self.trafficControlPropertyText.text.intValue]];
        if(self.trafficControlSwitch.isOn && (self.trafficControlPropertyText.text.intValue & ZegoTrafficControlPropertyAdaptiveResolution) > 0){
            [[ZegoExpressEngine sharedEngine]setMinVideoResolutionForTrafficControl:180 height:320 channel:ZegoPublishChannelMain];
            [self appendLog:[NSString stringWithFormat:@"setMinVideoResolutionForTrafficControl, 180x320"]];
        }
        
        // codecID
        ZegoVideoConfig *videoConfig = [[ZegoExpressEngine sharedEngine]getVideoConfig];
        videoConfig.codecID = _videoCodecID;
        [[ZegoExpressEngine sharedEngine]setVideoConfig:videoConfig];
        
        // set cdn url
        ZegoCDNConfig *cdnConfig = [[ZegoCDNConfig alloc]init];
        cdnConfig.url = self.publishCDNUrlText.text;
        if(cdnConfig.url.length == 0){
            [[ZegoExpressEngine sharedEngine]enablePublishDirectToCDN:NO config:nil];
        }else{
            [[ZegoExpressEngine sharedEngine]enablePublishDirectToCDN:YES config:cdnConfig];
                
        }

        // Start publishing
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.publishStreamIDText.text]];
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.publishStreamIDText.text];
        self.isPublish = YES;
    }
    sender.selected = !sender.isSelected;
}
- (IBAction)onCameraSwitch:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine]enableCamera:sender.isOn];
    [self appendLog:[NSString stringWithFormat:@"enableCamera, enable:%d", sender.isOn]];
}
- (IBAction)onCameraSelectionSwitch:(UISegmentedControl *)sender {
    int cameraIndex = (int)sender.selectedSegmentIndex;
    BOOL useFrontCamera;
    if(cameraIndex == 0){
        useFrontCamera = YES;
    }else{
        useFrontCamera = NO;
    }
    [[ZegoExpressEngine sharedEngine]useFrontCamera:useFrontCamera];
}

- (IBAction)onObjectSegmentationSwitch:(UISwitch *)sender {
    [self setObjectSegmentation:sender.isOn];
}

- (IBAction)onBeautyEnableSwitch:(UISwitch *)sender {
    [self appendLog:[NSString stringWithFormat:@"📤 Enable effects beauty: %d", sender.isOn]];
    [[ZegoExpressEngine sharedEngine] enableEffectsBeauty:sender.isOn];
}

- (IBAction)onBeautyWhitenSlider:(UISlider *)sender {
    
    self.whitenIntensityLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
    self.beautyParam.whitenIntensity = (int)sender.value;
    [[ZegoExpressEngine sharedEngine] setEffectsBeautyParam:self.beautyParam];
}

- (IBAction)onBeautyRosySlider:(UISlider *)sender {
    
    self.rosyIntensityLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
    self.beautyParam.rosyIntensity = (int)sender.value;
    [[ZegoExpressEngine sharedEngine] setEffectsBeautyParam:self.beautyParam];
}

- (IBAction)onBeautySmoothSlider:(UISlider *)sender {
    
    self.smoothIntensityLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
    self.beautyParam.smoothIntensity = (int)sender.value;
    [[ZegoExpressEngine sharedEngine] setEffectsBeautyParam:self.beautyParam];
}

- (IBAction)onBeautySharpenSlider:(UISlider *)sender {
    
    self.sharpenIntensityLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
    self.beautyParam.sharpenIntensity = (int)sender.value;
    [[ZegoExpressEngine sharedEngine] setEffectsBeautyParam:self.beautyParam];
}
- (IBAction)onObjectSegmentationTypeSwitch:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *typeNormal = [UIAlertAction actionWithTitle:@"Normal" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.objectSegmentationType = ZegoObjectSegmentationTypeAnyBackground;
        [self setObjectSegmentation:self.objectSegmentationSwitch.isOn];
        [self.subjectSegmentationTypeButton setTitle:@"Normal" forState:UIControlStateNormal];
    }];
    UIAlertAction *typeGreenScreen = [UIAlertAction actionWithTitle:@"Green Screen" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.objectSegmentationType = ZegoObjectSegmentationTypeGreenScreenBackground;
        [self setObjectSegmentation:self.objectSegmentationSwitch.isOn];
        [self.subjectSegmentationTypeButton setTitle:@"Green Screen" forState:UIControlStateNormal];

    }];

    [alertController addAction:cancel];
    [alertController addAction:typeNormal];
    [alertController addAction:typeGreenScreen];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}

-(void)setVideoConfig{
    int encodeResolutionW = self.encodeResolutionWText.text.intValue;
    int encodeResolutionH = self.encodeResolutionHText.text.intValue;
    int captureResolutionW = self.captureResolutionWText.text.intValue;
    int captureResolutionH = self.captureResolutionHText.text.intValue;
    int videoFPS = self.videoFPSText.text.intValue;
    int videoBitrate = self.videoBitrateText.text.intValue;
    
    ZegoVideoConfig *config = [[ZegoExpressEngine sharedEngine]getVideoConfig];
    config.encodeResolution = CGSizeMake(encodeResolutionW, encodeResolutionH);
    config.captureResolution = CGSizeMake(captureResolutionW, captureResolutionH);
    config.fps = videoFPS;
    config.bitrate = videoBitrate;
    [[ZegoExpressEngine sharedEngine]setVideoConfig:config];
    [self appendLog:[NSString stringWithFormat:@"setVideoConfig"]];
}

-(void)setObjectSegmentation:(BOOL)enable{
    ZegoObjectSegmentationConfig *config = [[ZegoObjectSegmentationConfig alloc]init];
    config.objectSegmentationType = self.objectSegmentationType;
    const char *hexChar = [self.backgroundColorText.text cStringUsingEncoding:NSUTF8StringEncoding];
    
    int hexNumber;
    sscanf(hexChar, "%x", &hexNumber);
    
    config.backgroundConfig.color = hexNumber;
    config.backgroundConfig.imageURL = self.backgroundImageURL;
    config.backgroundConfig.blurLevel = self.blurLevel;
    config.backgroundConfig.processType = self.backgroundProcessType;
    [[ZegoExpressEngine sharedEngine]enableVideoObjectSegmentation:self.objectSegmentationSwitch.isOn config:config channel:ZegoPublishChannelMain];
    [self appendLog:[NSString stringWithFormat:@"enableVideoObjectSegmentation, type:%d, processType:%d,color:%d,imageURL:%@,blurLevel:%d", (int)config.objectSegmentationType, (int)config.backgroundConfig.processType, config.backgroundConfig.color, config.backgroundConfig.imageURL, (int)config.backgroundConfig.blurLevel]];
    
    if(enable){
        [self UpdateAppBackgroundImage];
    }
}
- (IBAction)onHardwareDecodeSwitch:(UISwitch *)sender {
    [[ZegoExpressEngine sharedEngine]enableHardwareDecoder:sender.isOn];
    [self appendLog:[NSString stringWithFormat:@"enableHardwareDecoder, enable:%d", sender.isOn]];
}
- (IBAction)onStartPlayStream1Tapped:(UIButton *)sender {
    if(sender.isSelected) {
        // Stop playing
        if(_isPlay2 && [self.playStream1ID isEqualToString:self.playStream2ID]){
        }else{
            [self appendLog:[NSString stringWithFormat:@"📤 Stop playing stream. streamID: %@", self.playStream1ID]];
            [[ZegoExpressEngine sharedEngine]stopPlayingStream:self.playStream1ID];
        }
        _isPlay1 = NO;
//        self.playView1.image = nil;
    }
    else {
        // Start playing
        self.playStream1ID = self.playStream1Text.text;
        [self appendLog:[NSString stringWithFormat:@"📤 Start playing stream. streamID: %@", self.playStream1Text.text]];
        
        ZegoPlayerConfig *playerConfig = [[ZegoPlayerConfig alloc]init];
        playerConfig.resourceMode = self.resourceMode;
        if(self.enableCustomRender){
            [[ZegoExpressEngine sharedEngine]startPlayingStream:self.playStream1Text.text canvas:nil config:playerConfig];
        }else{
            ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView1];
            playCanvas.alphaBlend = self.veRenderAlpha;
            [[ZegoExpressEngine sharedEngine]startPlayingStream:self.playStream1Text.text canvas:playCanvas config:playerConfig];
        }
        
        _isPlay1 = YES;
    }
    sender.selected = !sender.isSelected;
}
- (IBAction)onStartPlayStream2Tapped:(UIButton *)sender {
    if(sender.isSelected) {
        // Stop playing
        
        if(_isPlay1 && [self.playStream1ID isEqualToString:self.playStream2ID]){
        }else{
            [self appendLog:[NSString stringWithFormat:@"📤 Stop playing stream. streamID: %@", self.playStream2ID]];
            [[ZegoExpressEngine sharedEngine]stopPlayingStream:self.playStream2ID];
        }
        _isPlay2 = NO;
        self.playView2.image = nil;
    }
    else {
        // Start playing
        self.playStream2ID = self.playStream2Text.text;
        [self appendLog:[NSString stringWithFormat:@"📤 Start playing stream. streamID: %@", self.playStream2Text.text]];
        
        ZegoPlayerConfig *playerConfig = [[ZegoPlayerConfig alloc]init];
        playerConfig.resourceMode = ZegoStreamResourceModeOnlyRTC;
        
        if(self.enableCustomRender){
            [[ZegoExpressEngine sharedEngine]startPlayingStream:self.playStream2ID canvas:nil config:playerConfig];
        }else{
            ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:self.playView2];
            playCanvas.alphaBlend = self.veRenderAlpha;
            [[ZegoExpressEngine sharedEngine]startPlayingStream:self.playStream2Text.text canvas:playCanvas config:playerConfig];
        }
        
        _isPlay2 = YES;
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onResourceButtonTapped:(id)sender {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

        }];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Default" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.resourceMode = ZegoStreamResourceModeDefault;
            [self.resourceModeButton setTitle:@"Default" forState:UIControlStateNormal];

        }];
        UIAlertAction *rtcAction = [UIAlertAction actionWithTitle:@"RTC" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.resourceMode = ZegoStreamResourceModeOnlyRTC;
            [self.resourceModeButton setTitle:@"RTC" forState:UIControlStateNormal];
        }];
        UIAlertAction *l3Action = [UIAlertAction actionWithTitle:@"L3" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.resourceMode = ZegoStreamResourceModeOnlyL3;
            [self.resourceModeButton setTitle:@"L3" forState:UIControlStateNormal];
        }];
        UIAlertAction *cdnAction = [UIAlertAction actionWithTitle:@"CDN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.resourceMode = ZegoStreamResourceModeOnlyCDN;
            [self.resourceModeButton setTitle:@"CDN" forState:UIControlStateNormal];
        }];
        UIAlertAction *cdnPlusAction = [UIAlertAction actionWithTitle:@"CDN_PLUS" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.resourceMode = ZegoStreamResourceModeCDNPlus;
            [self.resourceModeButton setTitle:@"CDN_PLUS" forState:UIControlStateNormal];
        }];
        [alertController addAction:cancel];
        [alertController addAction:defaultAction];
        [alertController addAction:rtcAction];
        [alertController addAction:l3Action];
        [alertController addAction:cdnAction];
        [alertController addAction:cdnPlusAction];
        alertController.popoverPresentationController.sourceView = sender;
        [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)onMirrorModeButtonTapped:(id)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *onlyPreview = [UIAlertAction actionWithTitle:@"OnlyPreview" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeOnlyPreviewMirror];
        [self.mirrorButton setTitle:@"OnlyPreview" forState:UIControlStateNormal];
    }];
    UIAlertAction *onlyPublish = [UIAlertAction actionWithTitle:@"OnlyPublish" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeOnlyPublishMirror];
        [self.mirrorButton setTitle:@"OnlyPublish" forState:UIControlStateNormal];

    }];
    UIAlertAction *bothMirror = [UIAlertAction actionWithTitle:@"BothMirror" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeBothMirror];
        [self.mirrorButton setTitle:@"BothMirror" forState:UIControlStateNormal];
    }];
    UIAlertAction *noMirror = [UIAlertAction actionWithTitle:@"NoMirror" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ZegoExpressEngine sharedEngine] setVideoMirrorMode:ZegoVideoMirrorModeNoMirror];
        [self.mirrorButton setTitle:@"NoMirror" forState:UIControlStateNormal];
    }];

    [alertController addAction:cancel];
    [alertController addAction:onlyPreview];
    [alertController addAction:onlyPublish];
    [alertController addAction:bothMirror];
    [alertController addAction:noMirror];
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}
- (IBAction)onPreocessTypeButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    
    UIAlertAction *transparent = [UIAlertAction actionWithTitle:@"Transparent" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.backgroundProcessType = ZegoBackgroundProcessTypeTransparent;
        [self.processTypeButton setTitle:@"Transparent" forState:UIControlStateNormal];
    }];
    
    UIAlertAction *color = [UIAlertAction actionWithTitle:@"Color" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.backgroundProcessType = ZegoBackgroundProcessTypeColor;
        [self.processTypeButton setTitle:@"Color" forState:UIControlStateNormal];
    }];
    
    UIAlertAction *blur = [UIAlertAction actionWithTitle:@"Blur" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.backgroundProcessType = ZegoBackgroundProcessTypeBlur;
        [self.processTypeButton setTitle:@"Blur" forState:UIControlStateNormal];
    }];
    
    UIAlertAction *image = [UIAlertAction actionWithTitle:@"Image" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.backgroundProcessType = ZegoBackgroundProcessTypeImage;
        [self.processTypeButton setTitle:@"Image" forState:UIControlStateNormal];
    }];
    
    [alertController addAction:cancel];
    [alertController addAction:transparent];
    [alertController addAction:color];
    [alertController addAction:blur];
    [alertController addAction:image];
    
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}
- (IBAction)onBlurLevelButtonTapped:(UIButton *)sender {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    
    UIAlertAction *low = [UIAlertAction actionWithTitle:@"Low" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.blurLevel = ZegoBackgroundBlurLevelLow;
        [self.blurLevelButton setTitle:@"Low" forState:UIControlStateNormal];
    }];
    
    UIAlertAction *medium = [UIAlertAction actionWithTitle:@"Medium" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.blurLevel = ZegoBackgroundBlurLevelMedium;
        [self.blurLevelButton setTitle:@"Medium" forState:UIControlStateNormal];
    }];
    
    UIAlertAction *high = [UIAlertAction actionWithTitle:@"High" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.blurLevel = ZegoBackgroundBlurLevelHigh;
        [self.blurLevelButton setTitle:@"High" forState:UIControlStateNormal];
    }];
    
    [alertController addAction:cancel];
    [alertController addAction:low];
    [alertController addAction:medium];
    [alertController addAction:high];
    
    alertController.popoverPresentationController.sourceView = sender;
    [self presentViewController:alertController animated:true completion:nil];
}
- (IBAction)onBackgroundButtonTapped:(UIButton *)sender {
    if(self.objectSegmentationSwitch.isOn){
        // Update
        [self setObjectSegmentation:YES];
    }
}


- (IBAction)onChooseFileButtonTapped:(id)sender {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    UIImageOrientation ori = selectedImage.imageOrientation;
    if(ori!=UIImageOrientationUp){
        UIGraphicsBeginImageContext(selectedImage.size);
        [selectedImage drawInRect:CGRectMake(0, 0, selectedImage.size.width, selectedImage.size.height)];
        selectedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    if(selectedImage){
        self.backgroundImage = selectedImage;
        if (@available(iOS 11.0, *)) {
            self.backgroundImageURL = [NSString stringWithFormat:@"%@", info[UIImagePickerControllerImageURL]];
        } else {
            // Fallback on earlier versions
            NSURL *url = info[UIImagePickerControllerReferenceURL];
            NSString *imageName = [url.path lastPathComponent];
            NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *localPath = [documentDirectory stringByAppendingPathComponent:imageName];
            self.backgroundImageURL = [NSString stringWithFormat:@"asset:%@",localPath];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)UpdateAppBackgroundImage{
    if(self.backgroundProcessType == ZegoBackgroundProcessTypeTransparent){
        UIImage *image = self.backgroundImage;
        CGFloat width = self.backgroundView.frame.size.width;// self.view表示你的视图的大小
        CGFloat height = self.backgroundView.frame.size.height;
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [image drawInRect:CGRectMake(0, 0, width, height)];//调整
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.backgroundView setBackgroundColor:[UIColor colorWithPatternImage:image]];
    }else{
        [self.backgroundView setBackgroundColor:nil];
    }
}

- (IBAction)onTakePublishSnapshotButtonTapped:(id)sender {
    [[ZegoExpressEngine sharedEngine]takePublishStreamSnapshot:^(int errorCode, ZGImage * _Nullable image) {
        [self appendLog:[NSString stringWithFormat:@"takePublishStreamSnapshot result,errorCode:%d", errorCode]];
        if(errorCode == 0){
            [self saveImageToPhotos:image];
        }
    }];
}

- (IBAction)onTakePlaySnapshotButtonTapped:(id)sender {
    [[ZegoExpressEngine sharedEngine]takePlayStreamSnapshot:self.playSnapshotStreamText.text callback:^(int errorCode, ZGImage * _Nullable image) {
        [self appendLog:[NSString stringWithFormat:@"takePlayStreamSnapshot result,errorCode:%d", errorCode]];
        if(errorCode == 0){
            [self saveImageToPhotos:image];
        }
    }];
}

-(void)saveImageToPhotos:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
}
- (IBAction)onPublishConfigLayoutSwitch:(UISwitch *)sender {
    [_publishConfigLayout setHidden:!sender.isOn];
}
- (IBAction)onCameraLayoutSwitch:(UISwitch *)sender {
    [_cameraLayout setHidden:!sender.isOn];
}
- (IBAction)onVideoConfigLayoutSwitch:(UISwitch *)sender {
    [_videoConfigLayout setHidden:!sender.isOn];
}
- (IBAction)onBackgroundConfigLayoutSwitch:(UISwitch *)sender {
    [_backgroundConfigLayout setHidden:!sender.isOn];
}
- (IBAction)onOSLayoutSwitch:(UISwitch *)sender {
    [_osLayout setHidden:!sender.isOn];
}
- (IBAction)onBeautyLayoutSwitch:(UISwitch *)sender {
    [_beautyLayout setHidden:!sender.isOn];
}
- (IBAction)onPlayerLayoutSwitch:(UISwitch *)sender {
    [_playLayout setHidden:!sender.isOn];
}




#pragma mark - ZegoExpress EventHandler Room Event

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
    else if(reason == ZegoRoomStateChangedReasonLogout)
    {
        // After logout room, the preview will stop. You need to re-start preview.
        
        if(self.isPreview){
            // Start preview
            ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.previewView];
            previewCanvas.alphaBlend = self.veRenderAlpha;
            [self appendLog:@"🔌 Start preview"];
            if(self.enableCustomRender){
                [[ZegoExpressEngine sharedEngine] startPreview:nil];
            }else{
                [[ZegoExpressEngine sharedEngine]startPreview:previewCanvas];
            }
        }
    }
    else
    {
        // Logout failed
    }
}

#pragma mark - ZegoExpress EventHandler Publish Event

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (errorCode != 0) {
        [self appendLog:[NSString stringWithFormat:@"🚩 ❌ 📤 Publishing stream error of streamID: %@, errorCode:%d", streamID, errorCode]];
    } else {
        switch (state) {
            case ZegoPublisherStatePublishing:
                [self appendLog:@"🚩 📤 Publishing stream"];
                break;

            case ZegoPublisherStatePublishRequesting:
                [self appendLog:@"🚩 📤 Requesting publish stream"];
                break;

            case ZegoPublisherStateNoPublish:
                [self appendLog:@"🚩 📤 No publish stream"];
                break;
        }
    }
//    self.publisherState = state;
}

-(void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID{
    if(quality.isHardwareEncode){
        self.hardwareEncodeStateLabel.text = @"On";
    }
    else{
        self.hardwareEncodeStateLabel.text = @"Off";
    }
}
-(void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality streamID:(NSString *)streamID{
    if(quality.isHardwareDecode){
        self.hardwareDecodeStateLabel.text = [NSString stringWithFormat:@"On(%@)", streamID];
    }else{
        self.hardwareDecodeStateLabel.text = [NSString stringWithFormat:@"Off(%@)", streamID];
    }
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(CGSize)scaleSize {
    UIGraphicsBeginImageContext(scaleSize);
    
    [image drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

#pragma mark - ZegoCustomVideoRenderHandler - Local Capture

/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeCVPixelBuffer`, the video frame CVPixelBuffer will be called back from this function
- (void)onCapturedVideoFrameCVPixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param flipMode:(ZegoVideoFlipMode)flipMode channel:(ZegoPublishChannel)channel {
    NSLog(@"pixel buffer video frame callback. format:%d, width:%f, height:%f, isNeedFlip:%d", (int)param.format, param.size.width, param.size.height, (int)flipMode);
    [self renderWithCVPixelBuffer:buffer renderView:0];
}

/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeRawData`, the video frame raw data will be called back from this function
- (void)onCapturedVideoFrameRawData:(unsigned char * _Nonnull *)data dataLength:(unsigned int *)dataLength param:(ZegoVideoFrameParam *)param flipMode:(ZegoVideoFlipMode)flipMode channel:(ZegoPublishChannel)channel {
    if (param.format == ZegoVideoFrameFormatBGRA32) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, data[0], dataLength[0], NULL);

            CGImageRef cgImageFromBytes = CGImageCreate((int)param.size.width, (int)param.size.height, 8, 32, param.strides[0], colorSpace, kCGImageByteOrder32Little|kCGImageAlphaFirst, dataProvider, NULL, NO, kCGRenderingIntentDefault);
            
            UIImage *image = [UIImage imageWithCGImage:cgImageFromBytes];
            
            UIImage *finalImage = nil;
            
            if(flipMode == ZegoVideoFlipModeX){
                finalImage = [UIImage imageWithCGImage:cgImageFromBytes scale:1 orientation:UIImageOrientationUpMirrored];
            }
            else{
                finalImage = image;
            }
            
            UIImageOrientation oo = UIImageOrientationUp;
            if(param.rotation == 90){
                oo = UIImageOrientationLeft;
            }else if(param.rotation == 180){
                oo = UIImageOrientationDown;
            }else if(param.rotation == 270){
                oo = UIImageOrientationRight;
            }
            
//            UIImage *rotateImage = nil;
//            rotateImage = [self rotateImage:finalImage rotation:oo];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.previewView.image = finalImage;
                CGImageRelease(cgImageFromBytes);
                
                //clear view
                if(self.isPreview == NO){
                    self.previewView.image = nil;
                }
            });
    }
}

- (UIImage *)rotateImage:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 33 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}

- (void)onCapturedVideoFrameEncodedData:(unsigned char *)data dataLength:(unsigned int)dataLength param:(ZegoVideoEncodedFrameParam *)param referenceTimeMillisecond:(unsigned long long)referenceTimeMillisecond channel:(ZegoPublishChannel)channel {
    
}

#pragma mark - ZegoCustomVideoRenderHandler - Remote Stream


/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeRawData`, the video frame raw data will be called back from this function
- (void)onRemoteVideoFrameRawData:(unsigned char * _Nonnull *)data dataLength:(unsigned int *)dataLength param:(ZegoVideoFrameParam *)param streamID:(NSString *)streamID {
    if (param.format == ZegoVideoFrameFormatBGRA32) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, data[0], dataLength[0], NULL);
        CGImageRef cgImageFromBytes = CGImageCreate((int)param.size.width, (int)param.size.height, 8, 32, param.strides[0], colorSpace, kCGImageByteOrder32Little|kCGImageAlphaFirst, dataProvider, NULL, NO, kCGRenderingIntentDefault);
        
        UIImage *finalImage = [UIImage imageWithCGImage:cgImageFromBytes];

        dispatch_async(dispatch_get_main_queue(), ^{
            if([streamID isEqualToString:self.playStream1ID] && self.isPlay1){
                self.playView1.image = finalImage;
            }
            if([streamID isEqualToString:self.playStream2ID] && self.isPlay2){
                self.playView2.image = finalImage;
            }
            CGImageRelease(cgImageFromBytes);
            
            if(self.isPlay1 == NO){
                self.playView1.image = nil;
            }
            if(self.isPlay2 == NO){
                self.playView2.image = nil;
            }
        });
    } else if (param.format == ZegoVideoFrameFormatI420) {
        // Grayscale
        unsigned char *uPlanar = data[1];
        unsigned char *vPlanar = data[1];
        memset(uPlanar, 0x80, sizeof(char) * dataLength[1]);
        memset(vPlanar, 0x80, sizeof(char) * dataLength[2]);
    }
}

/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeCVPixelBuffer`, the video frame CVPixelBuffer will be called back from this function
- (void)onRemoteVideoFrameCVPixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param streamID:(NSString *)streamID {
    if(streamID == self.playStream1ID){
        [self renderWithCVPixelBuffer:buffer renderView:1];
    }
    if(streamID == self.playStream2ID){
        [self renderWithCVPixelBuffer:buffer renderView:2];
    }
    
}

- (void)onRemoteVideoFrameEncodedData:(unsigned char *)data dataLength:(unsigned int)dataLength param:(ZegoVideoEncodedFrameParam *)param referenceTimeMillisecond:(unsigned long long)referenceTimeMillisecond streamID:(NSString *)streamID {
    NSLog(@"EEEncodedData Remote video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);

    
}

-(void)onVideoObjectSegmentationStateChanged:(ZegoObjectSegmentationState)state channel:(ZegoPublishChannel)channel errorCode:(int)errorCode{
    NSString *stateStr = @"";
    
    if(state == ZegoObjectSegmentationStateOn){
        stateStr = [NSString stringWithFormat:@"On,channel:%d,err:%d", (int)channel, errorCode];
    }else{
        stateStr = [NSString stringWithFormat:@"Off,channel:%d,err:%d",(int)channel, errorCode];
    }
    self.videoOSStateText.text = stateStr;
}

#pragma mark - Custom Render Method

- (void)renderWithCVPixelBuffer:(CVPixelBufferRef)buffer renderView:(int)renderView {
    CIImage *image = [CIImage imageWithCVPixelBuffer:buffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (renderView == 0) {
            self.previewView.image = [UIImage imageWithCIImage:image];
        } else if(renderView == 1) {
            self.playView1.image = [UIImage imageWithCIImage:image];
        }else if(renderView == 2){
            self.playView2.image = [UIImage imageWithCIImage:image];
        }
    });
}

-(UIImage*)getImageFromRGBA:(GLubyte*)pixel width:(int)w height:(int)h
{
    int perPix = 4;
    int width = w;
    int height = h;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(pixel, width, height, 8,width * perPix,colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);

    CGImageRef frame = CGBitmapContextCreateImage(newContext);
    UIImage* image = [UIImage imageWithCGImage:frame];

    CGImageRelease(frame);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    return image;

}

#pragma mark - Helper

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

//- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
//    return UIModalPresentationNone;
//}

- (void)orientationChanged:(NSNotification *)notification {
    if(self.orientationMode != ZegoOrientationModeCustom){
        return;
    }
    if(self.rotationType != RotateTypeFixedAutoRotate){
        return;
    }
    self.firstRotateFlag = YES;
    
    UIDevice *device = notification.object;
    ZegoVideoConfig *videoConfig = [[ZegoExpressEngine sharedEngine] getVideoConfig];
    UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
    CGFloat width = videoConfig.encodeResolution.width;
    CGFloat height = videoConfig.encodeResolution.height;
    
    CGSize sizePortrait;
    CGSize sizeLandscape;
    if(width >= height){
        sizePortrait = CGSizeMake(height, width);
        sizeLandscape = CGSizeMake(width, height);
    }
    else
    {
        sizePortrait = CGSizeMake(width, height);
        sizeLandscape = CGSizeMake(height, width);
    }
    BOOL setOrientation = YES;
    switch (device.orientation) {
        // Note that UIInterfaceOrientationLandscapeLeft is equal to UIDeviceOrientationLandscapeRight (and vice versa).
        // This is because rotating the device to the left requires rotating the content to the right.
        case UIDeviceOrientationLandscapeLeft:
            orientation = UIInterfaceOrientationLandscapeRight;
            videoConfig.encodeResolution = sizeLandscape;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = UIInterfaceOrientationLandscapeLeft;
            videoConfig.encodeResolution = sizeLandscape;
            break;
        case UIDeviceOrientationPortrait:
            orientation = UIInterfaceOrientationPortrait;
            videoConfig.encodeResolution = sizePortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            setOrientation = NO;
            orientation = UIInterfaceOrientationPortraitUpsideDown;
            videoConfig.encodeResolution = sizePortrait;
            break;
        default:
            // Unknown / FaceUp / FaceDown
            setOrientation = NO;
            break;
    }

    if(setOrientation == YES){
        [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
        [[ZegoExpressEngine sharedEngine] setAppOrientation:orientation];
    }
}

@end

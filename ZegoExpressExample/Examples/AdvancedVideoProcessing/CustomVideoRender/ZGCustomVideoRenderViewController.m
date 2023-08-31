//
//  ZGCustomVideoRenderViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/5/7.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGCustomVideoRenderViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"

@interface ZGCustomVideoRenderViewController ()<ZegoEventHandler, ZegoCustomVideoRenderHandler>

@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UILabel *previewLabel;
@property (weak, nonatomic) IBOutlet UIImageView *previewView;

@property (weak, nonatomic) IBOutlet UILabel *playStreamLabel;
@property (weak, nonatomic) IBOutlet UIImageView *playView;

@property (weak, nonatomic) IBOutlet UIButton *loginRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *startPublishingButton;
@property (weak, nonatomic) IBOutlet UIButton *startPlayingButton;

@property (weak, nonatomic) IBOutlet UITextField *roomIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *streamIDTextField;

@end

@implementation ZGCustomVideoRenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createEngine];
}

- (void)createEngine {
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    
    // Here we use the high quality video call scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    profile.scenario = ZegoScenarioHighQualityVideoCall;
    
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];

    // Init render config
    ZegoCustomVideoRenderConfig *renderConfig = [[ZegoCustomVideoRenderConfig alloc] init];
    renderConfig.bufferType = self.bufferType;
    renderConfig.frameFormatSeries = self.frameFormatSeries;

    // Enable custom video render
    [[ZegoExpressEngine sharedEngine] enableCustomVideoRender:YES config:renderConfig];

    // Set custom video render handler
    [[ZegoExpressEngine sharedEngine] setCustomVideoRenderHandler:self];
    
    [self setupUI];
}

- (void)setupUI {
    
    self.previewLabel.text = NSLocalizedString(@"PreviewLabel", nil);
    self.playStreamLabel.text = NSLocalizedString(@"PlayStreamLabel", nil);
    
    self.roomIDTextField.text = @"0013";
    self.streamIDTextField.text = @"0013";
    
    [self.loginRoomButton setTitle:@"Login Room" forState:UIControlStateNormal];
    [self.loginRoomButton setTitle:@"✅ Logout Room" forState:UIControlStateSelected];
    
    [self.startPublishingButton setTitle:@"Start Publishing Stream" forState:UIControlStateNormal];
    [self.startPublishingButton setTitle:@"✅ Stop Publishing Stream" forState:UIControlStateSelected];
    
    [self.startPlayingButton setTitle:@"Start Playing Stream" forState:UIControlStateNormal];
    [self.startPlayingButton setTitle:@"✅ Stop Playing Stream" forState:UIControlStateSelected];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.isBeingDismissed || self.isMovingFromParentViewController
        || (self.navigationController && self.navigationController.isBeingDismissed)) {
        ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
        [ZegoExpressEngine destroyEngine:^{
            // This callback is only used to notify the completion of the release of internal resources of the engine.
            // Developers cannot release resources related to the engine within this callback.
            //
            // In general, developers do not need to listen to this callback.
            ZGLogInfo(@"🚩 🏳️ Destroy ZegoExpressEngine complete");
        }];
    }
    [super viewDidDisappear:animated];
}

- (IBAction)onLoginRoomButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        // Logout Room
        [self appendLog:@"🚪 Logout room"];
        __weak typeof(self) weakSelf = self;
        [[ZegoExpressEngine sharedEngine] logoutRoomWithCallback:^(int errorCode, NSDictionary * _Nonnull extendedData) {
            weakSelf.loginRoomButton.selected = false;
            weakSelf.startPublishingButton.selected = false;
            weakSelf.startPlayingButton.selected = false;
        }];
    } else {
        // Login Room
        ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
        [self appendLog:[NSString stringWithFormat:@"🚪 Login room. roomID: %@", self.roomIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] loginRoom:self.roomIDTextField.text user:user];
    }
    sender.selected = !sender.isSelected;
}

- (IBAction)onStartPublishingButtonTapped:(UIButton *)sender {
    if (sender.isSelected) {
        [self appendLog:[NSString stringWithFormat:@"📤 Stop publishing stream. streamID: %@", self.streamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] stopPreview];
        [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    } else {
        [self appendLog:[NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.streamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] startPreview:nil];
        [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamIDTextField.text];
    }
}

- (IBAction)onStartPlayingButtonTappd:(UIButton *)sender {
    if (sender.isSelected) {
        [self appendLog:[NSString stringWithFormat:@"Stop playing stream, streamID: %@", self.streamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.streamIDTextField.text];
    } else {
        [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", self.streamIDTextField.text]];
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.streamIDTextField.text canvas:nil];
    }
}

#pragma mark - ZegoEventHandler

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (state == ZegoRoomStateConnected && errorCode == 0) {
        [self appendLog:@"🚩 🚪 Login room success"];
        self.loginRoomButton.selected = true;
    }
    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 🚪 Login room failed!"];
        self.loginRoomButton.selected = false;
    }
}

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (state == ZegoPublisherStatePublishing && errorCode == 0) {
        [self appendLog:@"🚩 📤 Publishing stream success"];
        // Add a flag to the button for successful operation
        self.startPublishingButton.selected = true;
    } else if (state == ZegoPublisherStateNoPublish) {
        self.startPublishingButton.selected = false;
    }

    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 📤 Publishing stream failed!"];
        self.startPublishingButton.selected = false;
    }
}

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    if (state == ZegoPlayerStatePlaying && errorCode == 0) {
        [self appendLog:@"🚩 📥 Playing stream success"];
        // Add a flag to the button for successful operation
        self.startPlayingButton.selected = true;
    } else if (state == ZegoPlayerStateNoPlay) {
        self.startPlayingButton.selected = false;
    }
    
    if (errorCode != 0) {
        [self appendLog:@"🚩 ❌ 📥 Playing stream failed!"];
        self.startPlayingButton.selected = false;
    }
}

#pragma mark - ZegoCustomVideoRenderHandler - Local Capture

/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeCVPixelBuffer`, the video frame CVPixelBuffer will be called back from this function
- (void)onCapturedVideoFrameCVPixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param flipMode:(ZegoVideoFlipMode)flipMode channel:(ZegoPublishChannel)channel {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:buffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewView.image = [UIImage imageWithCIImage:ciImage];
    });
}

/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeRawData`, the video frame raw data will be called back from this function
- (void)onCapturedVideoFrameRawData:(unsigned char *_Nonnull *_Nonnull)data
                         dataLength:(unsigned int *)dataLength
                              param:(ZegoVideoFrameParam *)param
                           flipMode:(ZegoVideoFlipMode)flipMode
                            channel:(ZegoPublishChannel)channel {
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data[0], (size_t)dataLength[0], NULL);
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    CGImageRef cgImage = CGImageCreate(param.size.width, param.size.height, 8, 32, param.strides[0],
                                        CGColorSpaceCreateDeviceRGB(), bitmapInfo,
                                        provider, NULL, NO, kCGRenderingIntentDefault);
    
    UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
    
    CFRelease(provider);
    CFRelease(cgImage);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.previewView.image = uiImage;
    });
}

- (void)onCapturedVideoFrameEncodedData:(unsigned char *)data dataLength:(unsigned int)dataLength param:(ZegoVideoEncodedFrameParam *)param referenceTimeMillisecond:(unsigned long long)referenceTimeMillisecond channel:(ZegoPublishChannel)channel {
    
}

#pragma mark - ZegoCustomVideoRenderHandler - Remote Stream

/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeRawData`, the video frame raw data will be called back from this function
- (void)onRemoteVideoFrameRawData:(unsigned char * _Nonnull *)data dataLength:(unsigned int *)dataLength param:(ZegoVideoFrameParam *)param streamID:(NSString *)streamID {
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data[0], (size_t)dataLength[0], NULL);
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    CGImageRef cgImage = CGImageCreate(param.size.width, param.size.height, 8, 32, param.strides[0],
                                        CGColorSpaceCreateDeviceRGB(), bitmapInfo,
                                        provider, NULL, NO, kCGRenderingIntentDefault);
    UIImage *uiImage = [UIImage imageWithCGImage:cgImage];
    
    CFRelease(provider);
    CFRelease(cgImage);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playView.image = uiImage;
    });
}

/// When `ZegoCustomVideoRenderConfig.bufferType` is set to `ZegoVideoBufferTypeCVPixelBuffer`, the video frame CVPixelBuffer will be called back from this function
- (void)onRemoteVideoFrameCVPixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param streamID:(NSString *)streamID {
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:buffer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playView.image = [UIImage imageWithCIImage:ciImage];
    });
}

- (void)onRemoteVideoFrameEncodedData:(unsigned char *)data dataLength:(unsigned int)dataLength param:(ZegoVideoEncodedFrameParam *)param referenceTimeMillisecond:(unsigned long long)referenceTimeMillisecond streamID:(NSString *)streamID {
    NSLog(@"EncodedData Remote video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);
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


@end

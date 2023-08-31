//
//  ZegoPiPViewController.m
//  ZegoExpressExample
//
//  Created by kebo on 2023/2/9.
//  Copyright © 2023 Zego. All rights reserved.
//

#import "ZegoPiPViewController.h"
#import "KeyCenter.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ZegoPiPViewController () <
    ZegoEventHandler,
    ZegoCustomVideoRenderHandler,
    AVPictureInPictureControllerDelegate,
    AVPictureInPictureSampleBufferPlaybackDelegate>


@property (nonatomic, assign) ZegoVideoBufferType bufferType;
@property (nonatomic, assign) ZegoVideoFrameFormatSeries frameFormatSeries;

@property (nonatomic, weak) IBOutlet UITextField *roomIDTextField;
@property (nonatomic, weak) IBOutlet UITextField *userIDTextField;
@property (nonatomic, weak) IBOutlet UITextField *publishStreamIDTextField;
@property (nonatomic, weak) IBOutlet UITextField *playStreamIDTextField;

@property (nonatomic, weak) IBOutlet UISwitch *hwEncodeSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *hwDecodeSwitch;
@property (nonatomic, weak) IBOutlet UIView *displayView;
@property (nonatomic, weak) IBOutlet UIView *previewView;

@property (nonatomic, strong) AVPictureInPictureController *pipViewController;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *previewLayer;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;

@end

@implementation ZegoPiPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bufferType = ZegoVideoBufferTypeCVPixelBuffer;
    _frameFormatSeries = ZegoVideoFrameFormatSeriesRGB;
    
    _roomIDTextField.text = @"room-1";
    _userIDTextField.text = @"user-1";
    _publishStreamIDTextField.text = @"s0001";
    _playStreamIDTextField.text = @"s0001";
    _hwDecodeSwitch.on = YES;
    _hwEncodeSwitch.on = YES;
    
    [self setupAudioSession];
    [self setupPreviewPipView];
    [self setupDisplayPipView];
    [self setupPipViewController];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [ZegoExpressEngine destroyEngine:nil];
    self.pipViewController = nil;
}

- (void)setupAudioSession
{
    if (@available(iOS 15.0, *)) {
        if ([AVPictureInPictureController isPictureInPictureSupported]) {
            NSError *error = nil;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            if (error) {
                NSLog(@"PermissionFailed to set audio session, error:%@", error);
            }
        }
    }
}

- (void)setupPreviewPipView
{
    if (!self.previewLayer) {
        self.previewLayer = [self createAVSampleBufferDisplayLayer:self.previewView.bounds];
    } else {
        [self transactDisplayLayer:self.previewLayer to:self.previewView.bounds];
    }
    [self.previewView.layer insertSublayer:self.previewLayer atIndex:0];
}

- (void)setupDisplayPipView
{
    if (!self.displayLayer) {
        self.displayLayer = [self createAVSampleBufferDisplayLayer:self.displayView.bounds];
    } else {
        [self transactDisplayLayer:self.displayLayer to:self.displayView.bounds];
    }
    
    [self.displayView.layer insertSublayer:self.displayLayer atIndex:0];
}

- (void)setupPipViewController
{
    if (@available(iOS 15.0, *)) {
        AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:self.displayLayer playbackDelegate:self];
        
        self.pipViewController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
        self.pipViewController.delegate = self;
        self.pipViewController.canStartPictureInPictureAutomaticallyFromInline = YES;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)rebuildDisplayDisplayLayer
{
    @synchronized(self) {
        if (self.displayLayer) {
            [self.displayLayer stopRequestingMediaData];
            [self.displayLayer removeFromSuperlayer];
            self.displayLayer = nil;
        }
        self.displayLayer = [self createAVSampleBufferDisplayLayer:self.displayView.bounds];
        [self.displayView.layer insertSublayer:self.displayLayer atIndex:0];
    }
}

- (AVSampleBufferDisplayLayer *)createAVSampleBufferDisplayLayer:(CGRect)bounds
{
    AVSampleBufferDisplayLayer *layer = [[AVSampleBufferDisplayLayer alloc] init];
    layer.frame = bounds;
    layer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    layer.opaque = YES;
    return layer;
}

- (void)transactDisplayLayer:(AVSampleBufferDisplayLayer *)layer to:(CGRect)bounds
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    layer.frame = bounds;
    layer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    [CATransaction commit];
}


- (IBAction)onCreateEnginePressed:(id)sender
{
    UISwitch *switcher = (UISwitch *)sender;
    if (switcher.isOn) {
        [self createEngine];
    } else {
        [self destroyEngine];
    }
}

- (IBAction)onLoginRoomPressed:(id)sender
{
    UISwitch *switcher = (UISwitch *)sender;
    if (switcher.isOn) {
        [self loginRoom];
    } else {
        [self logoutRoom];
    }
}

- (IBAction)onPublishStreamPressed:(id)sender
{
    UISwitch *switcher = (UISwitch *)sender;
    if (switcher.isOn) {
        [self startPublishStream];
    } else {
        [self stopPublishStream];
    }
}

- (IBAction)onPlayStreamPressed:(id)sender
{
    UISwitch *switcher = (UISwitch *)sender;
    if (switcher.isOn) {
        [self startPlayStream];
    } else {
        [self stopPlayStream];
    }
}

- (IBAction)onDisplayPipPressed:(id)sender
{
    if (@available(iOS 15.0, *)) {
        if (self.pipViewController){
            
            if (self.pipViewController.isPictureInPictureActive) {
                [self.pipViewController stopPictureInPicture];
            } else {
                [self.pipViewController startPictureInPicture];
            }
        }
    }
}

- (void)enableMultiTaskForZegoSDK:(bool)enable
{
    NSString *params = nil;
    if (enable){
        params = @"{\"method\":\"liveroom.video.enable_ios_multitask\",\"params\":{\"enable\":true}}";
        [[ZegoExpressEngine sharedEngine] callExperimentalAPI:params];
    } else {
        params = @"{\"method\":\"liveroom.video.enable_ios_multitask\",\"params\":{\"enable\":false}}";
        [[ZegoExpressEngine sharedEngine] callExperimentalAPI:params];
    }
}

- (void)createEngine
{
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    profile.scenario = ZegoScenarioDefault;
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
    
    ZegoCustomVideoRenderConfig *renderConfig = [[ZegoCustomVideoRenderConfig alloc] init];
    renderConfig.bufferType = _bufferType;
    renderConfig.frameFormatSeries = _frameFormatSeries;
    [[ZegoExpressEngine sharedEngine] enableCustomVideoRender:YES config:renderConfig];
    [[ZegoExpressEngine sharedEngine] setCustomVideoRenderHandler:self];
}

- (void)destroyEngine
{
    [ZegoExpressEngine destroyEngine:nil];
}

- (void)loginRoom
{
    [[ZegoExpressEngine sharedEngine] loginRoom:_roomIDTextField.text user:[ZegoUser userWithUserID:_userIDTextField.text]];
}

- (void)logoutRoom
{
    [[ZegoExpressEngine sharedEngine] logoutRoom];
    
    [self.displayLayer flushAndRemoveImage];
}

- (void)startPublishStream
{
    [[ZegoExpressEngine sharedEngine] enableHardwareDecoder:_hwDecodeSwitch.isOn];
    
    [[ZegoExpressEngine sharedEngine] startPreview:nil];
    [[ZegoExpressEngine sharedEngine] startPublishingStream:_publishStreamIDTextField.text];
}

- (void)stopPublishStream
{
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
}


- (void)startPlayStream
{
    [[ZegoExpressEngine sharedEngine] enableHardwareDecoder:_hwDecodeSwitch.isOn];
    
    ZegoCustomVideoRenderConfig *renderConfig = [[ZegoCustomVideoRenderConfig alloc] init];
    renderConfig.bufferType = _bufferType;
    renderConfig.frameFormatSeries = _frameFormatSeries;
    
    [[ZegoExpressEngine sharedEngine] enableCustomVideoRender:YES config:renderConfig];
    [[ZegoExpressEngine sharedEngine] setCustomVideoRenderHandler:self];
    
    [[ZegoExpressEngine sharedEngine] startPlayingStream:_playStreamIDTextField.text];
}

- (void)stopPlayStream
{
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:_playStreamIDTextField.text];
}


#pragma mark - ZegoCustomVideoRenderHandler
- (void)onRemoteVideoFrameCVPixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param streamID:(NSString *)streamID
{
    CMSampleBufferRef sampleBuffer = [self createSampleBuffer:buffer];
    if (sampleBuffer)
    {
        [self.displayLayer enqueueSampleBuffer:sampleBuffer];
        if (self.displayLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
            if (-11847 == self.displayLayer.error.code) {
                [self rebuildDisplayDisplayLayer];
            }
        }
        CFRelease(sampleBuffer);
    }
}

- (void)onCapturedVideoFrameCVPixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param flipMode:(ZegoVideoFlipMode)flipMode channel:(ZegoPublishChannel)channel
{
    CMSampleBufferRef sampleBuffer = [self createSampleBuffer:buffer];
    if (sampleBuffer)
    {
        [self.previewLayer enqueueSampleBuffer:sampleBuffer];
        CFRelease(sampleBuffer);
    }
}

- (CMSampleBufferRef)createSampleBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (!pixelBuffer) {
        return NULL;
    }
    //不设置具体时间信息
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
    //获取视频信息
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    NSParameterAssert(result == 0 && videoInfo != NULL);
    
    CMSampleBufferRef sampleBuffer = NULL;
    result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    NSParameterAssert(result == 0 && sampleBuffer != NULL);
    CFRelease(videoInfo);
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    return sampleBuffer;
}


#pragma mark - AVPictureInPictureControllerDelegate
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pip WillStart");
    [self enableMultiTaskForZegoSDK:true];
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pip DidStart");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"pip failed: %@", error);
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"pip restore");
    completionHandler(true);
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pip WillStop");
    [self enableMultiTaskForZegoSDK:false];
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pip DidStop");
}


#pragma mark - AVPictureInPictureSampleBufferPlaybackDelegate
- (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pip IsPlaybackPaused");
    return NO;
}

- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pip TimeRangeForPlayback");
    return  CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity); // for live streaming
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
         didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
    NSLog(@"pip didTransitionToRenderSize");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing {
    NSLog(@"pip setPlaying");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
                    skipByInterval:(CMTime)skipInterval
                 completionHandler:(void (^)(void))completionHandler {
    NSLog(@"pip skipByInterval");
}

@end

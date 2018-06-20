# FUZegoLiveDemo

FUZegoLiveDemo 是集成了 [Faceunity](https://github.com/Faceunity/FULiveDemo/tree/dev) 面部跟踪和虚拟道具功能和 Zego 直播功能的 Demo。

本文是  FaceUnity SDK 快速对接 Zego 直播 的导读说明，关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)

注：由于本例为示例 Demo，所以只在单主播模式中加入了 FaceUnity 效果，如有其余过多需要，用户可以自定义接入。

## 快速集成方法

### 一、打开外部采集

首先参照 FUZegoLiveDemo 集成 Zego 直播功能，具体集成方法参照 Zego 集成文档。

**这里首先需要 打开 FUZegoLiveDemo 中的外部采集选项（设置 --> 高级设置 --> 外部采集  打开）**

在 Appdelegate.m 的 `-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions `   方法中添加 

 ` [ZegoDemoHelper setUsingExternalCapture: YES]; ` 即可打开外部采集。

外部采集打开之后在 video_capture_external_demo.m 的  

```C
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
```

方法中就会有视频数据回调。

### 二、导入 SDK

将 FaceUnity 文件夹全部拖入工程中，并且添加依赖库 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`stdc++.tbd`

### 三、添加 FaceUnity 选项

在 ZegoPublishViewController.m 的 `ViewDidLoad:` 方法中修改 _beautifyList 声明为：

```C
_beautifyList = @[
                      NSLocalizedString(@"FaceUnity", nil),
                      NSLocalizedString(@"无美颜", nil),
                      NSLocalizedString(@"磨皮", nil),
                      NSLocalizedString(@"全屏美白", nil),
                      NSLocalizedString(@"磨皮＋全屏美白", nil),
                      NSLocalizedString(@"磨皮+皮肤美白", nil)
                      ];
```

用于判断直播中是否加入 FaceUnity 贴纸和美颜。

### 四、快速加载道具

在 `ViewDidLoad:` 里面判断是否加载道具并初始化 FaceUnity SDK，该函数会创建一个美颜道具及指定的贴纸道具。

```c
if (self.beautifyFeature == 0) {
        
    /**     -----  FaceUnity  ----     **/
    [[FUManager shareManager] loadItems];
    /**     -----  FaceUnity  ----     **/
}
```

注：FUManager 的 shareManager 函数中会对 SDK 进行初始化，并设置默认的美颜参数。

### 五、图像处理

在 video_capture_external_demo.m 视频流回调中处理图像：

```c
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CVImageBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    /**     -----  FaceUnity  ----     **/
    if ([FUManager shareManager].isShown) {
        
        [[FUManager shareManager] renderItemsToPixelBuffer:buffer];
    }
    /**     -----  FaceUnity  ----     **/
    
    CGImageRef img = [self createCGImageFromCVPixelBuffer:buffer];
    
    self.videoImage = [UIImage imageWithCGImage:img];
    
    if (is_take_photo_) {
        [client_ onTakeSnapshot:img];
        is_take_photo_ = false;
    }
    
    CGImageRelease(img);
    
    [client_ onIncomingCapturedData:buffer withPresentationTimeStamp:pts];
}
```

### 六、切换道具及调整美颜参数

本例中通过添加 FUAPIDemoBar 来实现切换道具及调整美颜参数的具体实现，FUAPIDemoBar 是快速集成用的UI，客户可自定义UI。

1、在 ZegoAnchorViewController.m 中添加头文件，并创建 demoBar 属性

```c
#import <FUAPIDemoBar/FUAPIDemoBar.h>

@property (nonatomic, strong) FUAPIDemoBar *demoBar ;
```

2、在 demoBar 的 get 方法中对其进行初始化，并遵循代理  FUAPIDemoBarDelegate，实现代理方法 `demoBarDidSelectedItem:` 和 `demoBarBeautyParamChanged`以进一步实现道具的切换及美颜参数的调整。

初始化

```c
// demobar 初始化
-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 164 - 44, self.view.frame.size.width, 164)];
        
        _demoBar.itemsDataSource = [FUManager shareManager].itemsDataSource;
        _demoBar.selectedItem = [FUManager shareManager].selectedItem ;
        
        _demoBar.filtersDataSource = [FUManager shareManager].filtersDataSource ;
        _demoBar.beautyFiltersDataSource = [FUManager shareManager].beautyFiltersDataSource ;
        _demoBar.filtersCHName = [FUManager shareManager].filtersCHName ;
        _demoBar.selectedFilter = [FUManager shareManager].selectedFilter ;
        [_demoBar setFilterLevel:[FUManager shareManager].selectedFilterLevel forFilter:[FUManager shareManager].selectedFilter] ;
        
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
        _demoBar.enlargingLevel_new = [FUManager shareManager].enlargingLevel ;
        _demoBar.thinningLevel_new = [FUManager shareManager].thinningLevel ;
        _demoBar.jewLevel = [FUManager shareManager].jewLevel ;
        _demoBar.foreheadLevel = [FUManager shareManager].foreheadLevel ;
        _demoBar.noseLevel = [FUManager shareManager].noseLevel ;
        _demoBar.mouthLevel = [FUManager shareManager].mouthLevel ;
        
        _demoBar.delegate = self;
    }
    return _demoBar ;
}
```

切换贴纸代理方法

```c
/**      FUAPIDemoBarDelegate       **/

// 切换贴纸
- (void)demoBarDidSelectedItem:(NSString *)itemName {
    
    [[FUManager shareManager] loadItem:itemName];
}
```

更新美颜参数方法

```c
// 更新美颜参数
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
```

3、在 `viewDidLoad:` 中将 demoBar 添加到页面上

```c
if (self.beautifyFeature == 0) {
        
    /**     -----  FaceUnity  ----     **/
    [self.view addSubview:self.demoBar] ;
    [FUManager shareManager].isShown = YES;
    /**     -----  FaceUnity  ----     **/
}
```

### 五、道具销毁

修改 ZegoAnchorViewController.m 里面 `dealloc`  方法如下：

```c
-(void)dealloc {
    
    [FUManager shareManager].isShown = NO;
    [[FUManager shareManager] destoryItems];
}
```

**快速集成完毕，关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)**
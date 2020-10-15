# Zego Express Video Example Topics iOS (Objective-C)

[English](README.md) | [中文](README_zh.md)

本文是 Zego Express Video iOS (Objective-C) 示例专题 Demo 与 FaceUnity 快速对接的文档 关于 `FaceUnity SDK` 的详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)

示例程序中接入的美颜效果,都是参考自定义采集项

## 快速集成方法

### 一、导入 SDK

将  FaceUnity  文件夹全部拖入工程中，并且添加依赖库 `OpenGLES.framework`、`Accelerate.framework`、`CoreMedia.framework`、`AVFoundation.framework`、`libc++.tbd`、`CoreML.framework`

### FaceUnity 模块简介
```C
-FUManager              //nama 业务类
-FUCamera               //视频采集类(示例程序未用到)    
+Lib                    //nama SDK  
    -authpack.h             //权限文件
    +libCNamaSDK.framework      
        +Headers
            -funama.h          //C 接口
            -FURenderer.h      //OC 接口
    +Resources
        +model              //AI模型
            -ai_face_processor.bundle      // 人脸识别AI能力模型，需要默认加载
            -ai_face_processor_lite.bundle // 人脸识别AI能力模型，轻量版
            -ai_gesture.bundle             // 手势识别AI能力模型
            -ai_human_processor.bundle     // 人体点位AI能力模型
        +graphics        //随库发版的重要模块资源
            -body_slim.bundle              // 美体道具
            -controller.bundle             // Avatar 道具
            -face_beautification.bundle    // 美颜道具
            -face_makeup.bundle            // 美妆道具
            -fuzzytoonfilter.bundle        // 动漫滤镜道具
            -fxaa.bundle                   // 3D 绘制抗锯齿
            -tongue.bundle                 // 舌头跟踪数据包

+FUAPIDemoBar     //美颜工具条,可自定义
+items       //贴纸和美妆资源 xx.bundel文件
      
```

### 二、加入展示 FaceUnity SDK 美颜贴纸效果的UI

1、在 `ZGCustomVideoCapturePublishStreamViewController.m` 中添加头文件，并创建页面属性

```C
/**fuceU */
#import "FUManager.h"
#import "FUAPIDemoBar.h"

@property (nonatomic, strong) FUAPIDemoBar *demoBar;

```

2、初始化 UI，并遵循代理  FUAPIDemoBarDelegate ，实现代理方法 `bottomDidChange:` 切换贴纸 和 `filterValueChange:` 更新美颜参数。

```C
// demobar 初始化
-(FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        
        _demoBar = [[FUAPIDemoBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 164 - 195, self.view.frame.size.width, 195)];
        
        _demoBar.mDelegate = self;
    }
    return _demoBar ;
}

```

#### 切换贴纸

```C
// 切换贴纸
-(void)bottomDidChange:(int)index{
    if (index < 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeBeautify];
    }
    if (index == 3) {
        [[FUManager shareManager] setRenderType:FUDataTypeStrick];
    }
    
    if (index == 4) {
        [[FUManager shareManager] setRenderType:FUDataTypeMakeup];
    }
    if (index == 5) {
        [[FUManager shareManager] setRenderType:FUDataTypebody];
    }
}

```

#### 更新美颜参数

```C
// 更新美颜参数    
- (void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
}
```

### 三、在 `viewDidLoad:` 中初始化 SDK  并将  demoBar 添加到页面上

```C

/**faceU */
[[FUManager shareManager] loadFilter];
[FUManager shareManager].isRender = YES;
[FUManager shareManager].flipx = YES;
[FUManager shareManager].trackFlipx = YES;
[self.view addSubview:self.demoBar];
/**faceU */

```

### 四、图像处理

在 `ZGCustomVideoCapturePixelBufferDelegate` 代理方法中, 实现 `- (void)captureDevice:(id<ZGCaptureDevice>)device didCapturedData:(CMSampleBufferRef)data` 代理方法

```C
if (self.captureBufferType == ZGCustomVideoCaptureBufferTypeCVPixelBuffer) {

    // BufferType: CVPixelBuffer
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(data);
    CMTime timeStamp = CMSampleBufferGetPresentationTimeStamp(data);
    CVPixelBufferRef fuBuffer = [[FUManager shareManager] renderItemsToPixelBuffer:buffer];
        
    [[ZegoExpressEngine sharedEngine] sendCustomVideoCapturePixelBuffer:fuBuffer timestamp:timeStamp];
        
}

```

备注: 实现Faceu美颜效果,目前在视频通话,推流中也有实现,都是参考自定义采集

### 五、道具销毁

结束时需要销毁道具

```c
[[FUManager shareManager] destoryItems]
```

2 切换摄像头需要调用 
```C
[[FUManager shareManager] onCameraChange];
```
        
**快速集成完毕，关于 FaceUnity SDK 的更多详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)**
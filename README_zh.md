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
+Lib                    //nama SDK  
    -authpack.h             //权限文件
    -FURenderKit.framework      
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

1、在相关类比如： `ZGCustomVideoCapturePublishStreamViewController.m` 中添加头文件，并创建页面属性

```C
/**fuceU */
#import "FUDemoManager.h"

```

2、在 `viewDidLoad` 中初始化 FaceUnity的界面和 SDK，FaceUnity界面工具和SDK都放在FUDemoManager中初始化了，也可以自行调用FUAPIDemoBar和FUManager初始化

```objc
    CGFloat safeAreaBottom = 150;
    if (@available(iOS 11.0, *)) {
        safeAreaBottom = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom + 150;
    }
    [FUDemoManager setupFaceUnityDemoInController:self originY:CGRectGetHeight(self.view.frame) - FUBottomBarHeight - safeAreaBottom];
```

#### 更新美颜参数

```C
- (IBAction)filterSliderValueChange:(FUSlider *)sender {
    _seletedParam.mValue = @(sender.value * _seletedParam.ratio);
    /**
     * 这里使用抽象接口，有具体子类决定去哪个业务员模块处理数据
     */
    [self.selectedView.viewModel consumerWithData:_seletedParam viewModelBlock:nil];
}
```

### 三、图像处理

在 `ZGCustomVideoCapturePixelBufferDelegate` 代理方法中, 实现 `- (void)captureDevice:(id<ZGCaptureDevice>)device didCapturedData:(CMSampleBufferRef)data` 代理方法（FURenderInput输入和FURenderOutput输出）

```C
- (void)captureDevice:(id<ZGCaptureDevice>)device didCapturedData:(CMSampleBufferRef)data {
    
    // BufferType: CVPixelBuffer
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(data);
    CMTime timeStamp = CMSampleBufferGetPresentationTimeStamp(data);
    if ([FUManager shareManager].isRender) {
        FURenderInput *input = [[FURenderInput alloc] init];
        input.renderConfig.imageOrientation = FUImageOrientationUP;
        input.pixelBuffer = buffer;
        //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
        input.renderConfig.gravityEnable = YES;
        FURenderOutput *output = [[FURenderKit shareRenderKit] renderWithInput:input];
        if (output) {
            [[ZegoExpressEngine sharedEngine] sendCustomVideoCapturePixelBuffer:output.pixelBuffer timestamp:timeStamp];
        }
    }
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

# FUZegoLiveDemo 快速集成文档

FUZegoLiveDemo 是集成了 Faceunity 面部跟踪和虚拟道具功能 和 [ZegoLive](https://github.com/zegodev/ZegoLive) 功能的 Demo。

本文是 FaceUnity SDK 快速对接融云 videotalk 的导读说明，关于 `FaceUnity SDK` 的详细说明，请参看 [FULiveDemo](https://github.com/Faceunity/FULiveDemo/tree/dev)


## 快速集成方法

### 一、接入 Faceunity SDK

将 **UI**: FUAPIDemoBar **SDK**:libCNamaSDK.framewrok   引入工程中

#### 1、快速加载道具

调用 FUManager 里面的 `[[FUManager shareManager] loadItems]` 加载贴纸道具及美颜道具

#### 2、更新美颜参数
本例中通过添加 FUAPIDemoBar 来实现切换道具及调整美颜参数的具体实现，FUAPIDemoBar 是快速集成用的UI，客户可自定义UI。
在 ZGExternalVideoFilterPublishViewController.m  中添加 demoBar 属性，并实现 demoBar 代理方法，以进一步实现道具的切换及美颜参数的调整。

```C
-(void)filterValueChange:(FUBeautyParam *)param{
    [[FUManager shareManager] filterValueChange:param];
}

-(void)switchRenderState:(BOOL)state{
    [FUManager shareManager].isRender = state;
}
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

### 二、获取视频数据回调

参照官网和源码,[视频外部滤镜](https://www.zego.im/html/document/#Live_Room/Advanced_Feature_Guide/ExternalFilter:ios)
```C
// SDK 回调。App 在此接口中获取 SDK 采集到的视频帧数据，并进行处理
- (void)queueInputBuffer:(CVPixelBufferRef)pixel_buffer timestamp:(unsigned long long)timestamp_100n {
    // * 采集到的图像数据通过这个传进来，这个点需要异步处理
    dispatch_async(queue_, ^ {
                
        /*----------faceU---------数据处理*/
        [[FUManager shareManager] renderItemsToPixelBuffer:pixel_buffer];
    
        [self copyPixelBufferToPool:pixel_buffer timestamp:timestamp_100n];
        self.pendingCount = self.pendingCount - 1;

        CVPixelBufferRelease(pixel_buffer);
    });
}
```

### 三、道具销毁

调用 `[[FUManager shareManager] destoryItems];` 销毁贴纸及美颜道具。



//
//  ZGCustomVideoRenderPlayStreamViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/1.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_CustomVideoRender

#import <UIKit/UIKit.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGCustomVideoRenderPlayStreamViewController : UIViewController

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, copy) NSString *streamID;

@property (nonatomic, assign) ZegoVideoBufferType bufferType;

@property (nonatomic, assign) ZegoVideoFrameFormatSeries frameFormatSeries;

@property (nonatomic, assign) BOOL enableEngineRender;

@end

NS_ASSUME_NONNULL_END

#endif

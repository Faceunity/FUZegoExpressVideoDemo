//
//  ZGCustomVideoRenderViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/5/7.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGCustomVideoRenderViewController : UIViewController

@property (nonatomic, assign) ZegoVideoBufferType bufferType;

@property (nonatomic, assign) ZegoVideoFrameFormatSeries frameFormatSeries;

@end

NS_ASSUME_NONNULL_END

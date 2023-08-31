//
//  ZGCustomVideoProcessPublishStreamViewController.h
//  ZegoExpressExample
//
//  Created by Patrick Fu on 2021/11/15.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZGCustomVideoProcessFilterType) {
    ZGCustomVideoProcessFilterTypeNone,
    ZGCustomVideoProcessFilterTypeInvert,
    ZGCustomVideoProcessFilterTypeGrayscale,
};

typedef NS_ENUM(NSUInteger, ZGCustomVideoProcessRenderBackend) {
    ZGCustomVideoProcessRenderBackendOpenGL,
    ZGCustomVideoProcessRenderBackendMetal,
};

@interface ZGCustomVideoProcessPublishStreamViewController : UIViewController

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamID;

@property (nonatomic, assign) ZegoVideoConfigPreset resolutionPreset;
@property (nonatomic, assign) ZGCustomVideoProcessFilterType filterType;
@property (nonatomic, assign) ZGCustomVideoProcessRenderBackend renderBackend;
@property (nonatomic, assign) int fps;

@end

NS_ASSUME_NONNULL_END

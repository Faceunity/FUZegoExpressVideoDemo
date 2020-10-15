//
//  ZGCustomVideoCapturePublishStreamViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/1/12.
//  Copyright © 2020 Zego. All rights reserved.
//

#ifdef _Module_CustomVideoCapture

#import <UIKit/UIKit.h>
#import "ZGCaptureDeviceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZGCustomVideoCapturePublishStreamViewController : UIViewController

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, copy) NSString *streamID;

/// Capture source type
@property (nonatomic, assign) ZGCustomVideoCaptureSourceType captureSourceType;

/// Capture data format
@property (nonatomic, assign) ZGCustomVideoCaptureDataFormat captureDataFormat;

/// Capture buffer type
@property (nonatomic, assign) ZGCustomVideoCaptureBufferType captureBufferType;

@end

NS_ASSUME_NONNULL_END

#endif

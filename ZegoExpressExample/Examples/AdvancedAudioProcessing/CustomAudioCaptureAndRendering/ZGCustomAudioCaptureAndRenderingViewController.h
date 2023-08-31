//
//  ZGCustomAudioIOViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZGAudioCaptureFormat.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZGCustomAudioCaptureAndRenderingViewController : UIViewController

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, assign) ZGAudioCaptureFormat captureFormat;
@property (nonatomic, assign) Float64 sampleRate;
@property (nonatomic, assign) BOOL saveAudioDataToDocuments;

@end

NS_ASSUME_NONNULL_END

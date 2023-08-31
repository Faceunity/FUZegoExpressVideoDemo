//
//  ZGPlayStreamViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2020/6/30.
//  Copyright © 2020 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGPlayStreamViewController : UIViewController

@property (nonatomic, assign) BOOL enableHardwareDecoder;
@property (nonatomic, assign) BOOL mutePlayStreamVideo;
@property (nonatomic, assign) BOOL mutePlayStreamAudio;
@property (nonatomic, assign) int playVolume;
@property (nonatomic, assign) ZegoStreamResourceMode resourceMode;
@property (nonatomic, copy) NSString *streamExtraInfo;
@property (nonatomic, copy) NSString *roomExtraInfo;
@property (nonatomic, copy) NSString *decryptionKey;

- (void)appendLog:(NSString *)tipText;

@end

NS_ASSUME_NONNULL_END

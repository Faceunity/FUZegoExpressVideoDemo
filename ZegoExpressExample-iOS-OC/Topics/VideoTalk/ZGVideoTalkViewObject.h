//
//  ZGVideoTalkViewObject.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/9.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_VideoTalk

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGVideoTalkViewObject : NSObject

@property (nonatomic, assign) BOOL isLocal;
@property (nonatomic, copy) NSString *streamID;
@property (nonatomic, strong) UIView *view;

@end

NS_ASSUME_NONNULL_END

#endif

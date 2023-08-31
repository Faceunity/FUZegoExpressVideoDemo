//
//  ZGVideoForMultipleUsersItemView.h
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/21.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZGVideoTalkViewObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZGVideoForMultipleUsersPublisherView : UIView
+ (instancetype)itemViewWithViewModel:(ZGVideoTalkViewObject *)viewModel owner:(nullable id)owner;
- (void)updateStreamQuility:(NSString *)quality;
- (void)updateNetworkQuility:(NSString *)quality;
- (void)updateResolution:(NSString *)resolution;
@end

NS_ASSUME_NONNULL_END

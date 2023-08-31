//
//  ZGVideoForMultipleUsersPopupView.h
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/21.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGVideoForMultipleUsersPopupView : UIView
+ (ZGVideoForMultipleUsersPopupView*)show;
- (void)updateWithTitle:(NSString *)title textList:(NSArray<NSString *> *)textList;
@end

NS_ASSUME_NONNULL_END

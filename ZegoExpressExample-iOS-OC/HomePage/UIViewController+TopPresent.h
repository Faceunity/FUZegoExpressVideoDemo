//
//  UIViewController+TopPresent.h
//  QueuingServices-iOS
//
//  Created by Sky on 2019/1/8.
//  Copyright © 2019 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (TopPresent)

/// Easy to modal, if the current controller does not have a modal controller, then return to itself
- (UIViewController *)topPresentedViewController;

@end

NS_ASSUME_NONNULL_END

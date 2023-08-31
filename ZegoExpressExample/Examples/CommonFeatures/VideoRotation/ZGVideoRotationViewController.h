//
//  ZGMultipleRoomsViewController.h
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/13.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RotateType) {
    RotateTypeFixedPortrait = 1,
    RotateTypeFixedLandscape = 3,
    RotateTypeFixedAutoRotate = 10
};

NS_ASSUME_NONNULL_BEGIN

@interface ZGVideoRotationViewController : UIViewController

@end

NS_ASSUME_NONNULL_END

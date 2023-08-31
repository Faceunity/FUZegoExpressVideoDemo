//
//  ZGObjectSegmentationViewController.h
//  ZegoExpressExample
//
//  Created by zego on 2022/11/2.
//  Copyright © 2022 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RotateType) {
    RotateTypeFixedPortrait = 1,
    RotateTypeFixedLandscape = 3,
    RotateTypeFixedAutoRotate = 10
};

@interface ZGObjectSegmentationViewController: UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, copy) NSString *roomID;
@property(nonatomic,assign) BOOL enableCustomRender;
@property(nonatomic, assign) int orientationMode;
@property(nonatomic, assign) RotateType rotationType;
@property(nonatomic, assign) BOOL enableEffectsEnv;
@property(nonatomic, assign) BOOL veRenderAlpha;
@property(nonatomic, assign) BOOL veSetBackgroundColorToColor;
@property(nonatomic, assign) BOOL veGlkView;
@property(nonatomic, assign) BOOL veMetal;
@end

NS_ASSUME_NONNULL_END

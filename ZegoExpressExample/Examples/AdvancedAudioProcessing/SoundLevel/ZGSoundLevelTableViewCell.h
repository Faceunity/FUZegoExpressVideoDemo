//
//  ZGSoundLevelTableViewCell.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Paaatrick on 2019/12/2.
//  Copyright © 2019 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGSoundLevelTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *streamID;
@property (nonatomic, copy) NSArray<NSNumber *> *spectrumList;
@property (nonatomic, copy) NSNumber *soundLevel;
@property (nonatomic, assign) BOOL vad;

@end

NS_ASSUME_NONNULL_END

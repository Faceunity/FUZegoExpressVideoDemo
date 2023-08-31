//
//  ZGRangeAudioUserPositionCell.m
//  ZegoExpressExample
//
//  Created by zego on 2021/8/12.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGRangeAudioUserPositionCell.h"

@interface ZGRangeAudioUserPositionCell ()

@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;

@property (weak, nonatomic) IBOutlet UILabel *positionLabel;

@end

@implementation ZGRangeAudioUserPositionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessage:(NSString *)message userID:(NSString *)userID {
    self.userIDLabel.text = [NSString stringWithFormat:@"UserID: %@", userID];
    self.positionLabel.text = [NSString stringWithFormat:@"Position: %@", message];
}

@end

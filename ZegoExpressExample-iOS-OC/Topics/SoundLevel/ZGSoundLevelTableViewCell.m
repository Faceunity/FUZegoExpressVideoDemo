//
//  ZGSoundLevelTableViewCell.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Paaatrick on 2019/12/2.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_SoundLevel

#import "ZGSoundLevelTableViewCell.h"

@interface ZGSoundLevelTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *streamIDLabel;
@property (weak, nonatomic) IBOutlet UIView *frequencySpectrumView;
@property (weak, nonatomic) IBOutlet UIProgressView *soundLevelView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) CAShapeLayer *spectrumShapeLayer;
@property (nonatomic, strong) CAShapeLayer *soundLevelShapeLayer;

@end

@implementation ZGSoundLevelTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.containerView.layer.borderWidth = 0.5;
    self.containerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.spectrumShapeLayer = [CAShapeLayer layer];
    self.spectrumShapeLayer.fillColor = [UIColor grayColor].CGColor;
    [self.frequencySpectrumView.layer addSublayer:self.spectrumShapeLayer];
    
    self.soundLevelView.transform = CGAffineTransformMakeScale(1.0f, 4.0f);
}

#pragma mark - Setter

// set stream ID tag
- (void)setStreamID:(NSString *)streamID {
    self.streamIDLabel.text = streamID;
    _streamID = streamID;
}

// Set the sound wave UI, the range of the sound wave callback is [0, 100]
- (void)setSoundLevel:(NSNumber *)soundLevel {
    [self.soundLevelView setProgress:(soundLevel.floatValue / 100) animated:YES];
    _soundLevel = soundLevel;
}

// Set audio spectrum layer
- (void)setSpectrumList:(NSArray<NSNumber *> *)spectrumList {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat barWidth = self.frequencySpectrumView.frame.size.width / spectrumList.count * 0.8;
    CGFloat space = self.frequencySpectrumView.frame.size.width / spectrumList.count * 0.2;
    CGFloat spectrumViewHeight =  self.frequencySpectrumView.frame.size.height;
    for (int i = 0; i < _spectrumList.count; i++) {
        CGFloat x = i * (barWidth + space) + space;
        CGFloat y = [self translateAmplitudeToYPosition:spectrumList[i].floatValue];
        UIBezierPath *bar = [UIBezierPath bezierPathWithRect:CGRectMake(x, y, barWidth, spectrumViewHeight - y)];
        [path appendPath:bar];
    }
    self.spectrumShapeLayer.path = path.CGPath;
    _spectrumList = spectrumList;
}

#pragma mark - Helper Method

// Y coordinate of the spectrogram: take the logarithm of the amplitude of the spectrum to display, the amplitude range of the callback is [0, 2^30], but in general, the amplitude is basically around [0, 2^10], in order to show The effect is obvious, so take the logarithm and divide by 10.
- (CGFloat)translateAmplitudeToYPosition:(float)amplitude {
    CGFloat spectrumViewHeight =  self.frequencySpectrumView.frame.size.height;
    amplitude = amplitude < 0 ? 0 : amplitude;
    CGFloat barheight;
    if (amplitude > 100) {
        barheight = log10(amplitude) / 10 * spectrumViewHeight;
    } else {
        barheight = amplitude / 10;
    }
    return spectrumViewHeight - barheight;
}

@end

#endif



#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>

@class ZGAudioToolPlayer;

typedef void (^XBAudioUnitPlayerInputBlock)(ZGAudioToolPlayer *player,
AudioUnitRenderActionFlags *ioActionFlags,
const AudioTimeStamp *inTimeStamp,
UInt32 inBusNumber,
UInt32 inNumberFrames,
AudioBufferList *ioData);

@protocol LYPlayerDelegate <NSObject>

- (void)onPlayToEnd:(ZGAudioToolPlayer *)player;

@end


@interface ZGAudioToolPlayer : NSObject

@property (nonatomic, weak) id<LYPlayerDelegate> delegate;
@property (nonatomic,copy) XBAudioUnitPlayerInputBlock bl_input;

- (instancetype)initWithSampleRate:(Float64)sampleRate bufferSize:(int)bufferSize;

- (void)play;

- (double)getCurrentTime;

- (void)stop;

@end

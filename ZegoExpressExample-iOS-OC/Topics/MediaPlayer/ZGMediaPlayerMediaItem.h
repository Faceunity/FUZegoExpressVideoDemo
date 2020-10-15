//
//  ZGMediaPlayerMediaItem.h
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/25.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_MediaPlayer

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZGMediaPlayerMediaItem : NSObject

@property (nonatomic, copy) NSString *fileURL;
@property (nonatomic, copy) NSString *mediaName;
@property (nonatomic, assign) BOOL isVideo;

+ (instancetype)itemWithFileURL:(NSString*)fileURL mediaName:(NSString*)mediaName isVideo:(BOOL)isVideo;

@end

NS_ASSUME_NONNULL_END

#endif

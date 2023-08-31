//
//  ZGMediaPlayerMediaItem.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/25.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGMediaPlayerMediaItem.h"

@implementation ZGMediaPlayerMediaItem

+ (instancetype)itemWithFileURL:(NSString*)fileURL mediaName:(NSString*)mediaName isVideo:(BOOL)isVideo {
    ZGMediaPlayerMediaItem *item = [[ZGMediaPlayerMediaItem alloc] init];
    item.fileURL = fileURL;
    item.mediaName = mediaName;
    item.isVideo = isVideo;
    return item;
}

@end

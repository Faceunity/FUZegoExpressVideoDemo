//
//  ZGMediaPlayerChooseFileVC.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/25.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_MediaPlayer

#import "ZGMediaPlayerChooseFileVC.h"
#import "ZGMediaPlayerMediaItem.h"
#import "ZGMediaPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ZGMediaPlayerChooseFileVC ()

@property (nonatomic, strong) NSArray<ZGMediaPlayerMediaItem *> *networkItems;
@property (nonatomic, strong) NSArray<ZGMediaPlayerMediaItem *> *localPackageItems;
@property (nonatomic, strong) NSArray<ZGMediaPlayerMediaItem *> *localMediaLibraryItems;

@end

@implementation ZGMediaPlayerChooseFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Choose File";
    
    [self loadNetworkMediaItems];
    [self loadLocalPackageItems];
    [self loadLocalMediaLibraryItems];
}

- (void)loadNetworkMediaItems {
    self.networkItems = @[
        [ZGMediaPlayerMediaItem itemWithFileURL:@"https://storage.zego.im/demo/sample_astrix.mp3" mediaName:@"sample_bgm.mp3" isVideo:NO],
        [ZGMediaPlayerMediaItem itemWithFileURL:@"https://storage.zego.im/demo/201808270915.mp4" mediaName:@"sample.mp4" isVideo:YES]
    ];
    [self.tableView reloadData];
}

- (void)loadLocalPackageItems {
    NSString *wavResPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"wav"];
    NSString *mp3ResPath = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp3"];
    NSString *mp4ResPath = [[NSBundle mainBundle] pathForResource:@"ad" ofType:@"mp4"];
    self.localPackageItems = @[
        [ZGMediaPlayerMediaItem itemWithFileURL:wavResPath mediaName:@"test.wav" isVideo:NO],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp3ResPath mediaName:@"sample.mp3" isVideo:NO],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4ResPath mediaName:@"ad.mp4" isVideo:YES]
    ];
    [self.tableView reloadData];
}

- (void)loadLocalMediaLibraryItems {
    if (@available(iOS 9.3, *)) {
        __block BOOL hasAuth = NO;
        MPMediaLibraryAuthorizationStatus authStatus = [MPMediaLibrary authorizationStatus];
        switch (authStatus) {
            case MPMediaLibraryAuthorizationStatusNotDetermined:
                [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                    NSLog(@"%s, %d", __func__, (int)status);
                    if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                        hasAuth = YES;
                    }
                }];
                break;
                
            case MPMediaLibraryAuthorizationStatusDenied:
            case MPMediaLibraryAuthorizationStatusRestricted:
                break;
            case MPMediaLibraryAuthorizationStatusAuthorized:
                hasAuth = YES;
            default:
                break;
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSMutableArray<ZGMediaPlayerMediaItem*> *songList = nil;
            if (hasAuth) {
                songList = [NSMutableArray array];
                MPMediaQuery *query = [MPMediaQuery songsQuery];
                const int MAX_COUNT = 50;
                int cnt = 0;
                for (MPMediaItemCollection *collection in query.collections) {
                    for (MPMediaItem *item in collection.items) {
                        
                        NSString *title = [item title];
                        NSString *url = [[item valueForProperty:MPMediaItemPropertyAssetURL] absoluteString];
                        if (url.length == 0 || title.length == 0) continue;
                        
                        [songList addObject:[ZGMediaPlayerMediaItem itemWithFileURL:url mediaName:title isVideo:NO]];
                        cnt++;
                        if (cnt >= MAX_COUNT) break;
                    }
                    if (cnt >= MAX_COUNT) break;
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.localMediaLibraryItems = [songList copy];
                [self.tableView reloadData];
            });
        });
    } else {
        ZGLogWarn(@"❕ Cannot load local media library resources under iOS9.3");
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Network Resources";
    } else if (section == 1) {
        return @"Local Package Resources";
    } else if (section == 2) {
        return @"Local Media Library Resources";
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _networkItems.count;
    } else if (section == 1) {
        return _localPackageItems.count;
    } else if (section == 2) {
        return _localMediaLibraryItems.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"MediaPlayerItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    ZGMediaPlayerMediaItem *item = nil;
    if (indexPath.section == 0) {
        item = _networkItems[indexPath.row];
    } else if (indexPath.section == 1) {
        item = _localPackageItems[indexPath.row];
    } else if (indexPath.section == 2) {
        item = _localMediaLibraryItems[indexPath.row];
    }
    
    cell.textLabel.text = item.mediaName;
    cell.detailTextLabel.text = item.isVideo ? @"Video" : @"Audio";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ZGMediaPlayerMediaItem *item = nil;
    
    if (indexPath.section == 0) {
        item = _networkItems[indexPath.row];
    } else if (indexPath.section == 1) {
        item = _localPackageItems[indexPath.row];
    } else if (indexPath.section == 2) {
        item = _localMediaLibraryItems[indexPath.row];
    }
    
    if (item) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MediaPlayer" bundle:nil];
        ZGMediaPlayerViewController *playerVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGMediaPlayerViewController class])];
        playerVC.mediaItem = item;
        [self.navigationController pushViewController:playerVC animated:YES];
    }
}


@end

#endif

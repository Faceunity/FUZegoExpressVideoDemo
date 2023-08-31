//
//  ZGMediaPlayerChooseFileVC.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/12/25.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGMediaPlayerChooseFileVC.h"
#import "ZGMediaPlayerMediaItem.h"
#import "ZGMediaPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ZGMediaPlayerChooseFileVC ()<UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) NSArray<ZGMediaPlayerMediaItem *> *networkItems;
@property (nonatomic, strong) NSArray<ZGMediaPlayerMediaItem *> *localPackageItems;
@property (nonatomic, strong) NSArray<ZGMediaPlayerMediaItem *> *localMediaLibraryItems;

@property (nonatomic, copy) NSString *resourceURL;
@property (nonatomic, assign) BOOL alphaBlend;
@property (nonatomic, assign) int alphaLayout;
@property (nonatomic, assign) BOOL mediaHardwareDecode;

@end

@implementation ZGMediaPlayerChooseFileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Choose File";
    
    [self loadNetworkMediaItems];
    [self loadLocalPackageItems];
    [self loadLocalMediaLibraryItems];
    
    self.alphaBlend = YES;
    self.alphaLayout = 0;
    self.mediaHardwareDecode = YES;
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
    NSString *mp4AlphaResPath1 = [[NSBundle mainBundle] pathForResource:@"source1_complex_rl" ofType:@"mp4"];
    NSString *mp4AlphaResPath2 = [[NSBundle mainBundle] pathForResource:@"source2_complex_rl" ofType:@"mp4"];
    NSString *mp4AlphaResPath3 = [[NSBundle mainBundle] pathForResource:@"source3_complex_rl" ofType:@"mp4"];
    NSString *mp4AlphaResPath4 = [[NSBundle mainBundle] pathForResource:@"source4_complex_rl" ofType:@"mp4"];
    
    NSString *mp4AlphaResPath5 = [[NSBundle mainBundle] pathForResource:@"source1_complex_lr" ofType:@"mp4"];
    NSString *mp4AlphaResPath6 = [[NSBundle mainBundle] pathForResource:@"source2_complex_lr" ofType:@"mp4"];
    NSString *mp4AlphaResPath7 = [[NSBundle mainBundle] pathForResource:@"source3_complex_lr" ofType:@"mp4"];
    NSString *mp4AlphaResPath8 = [[NSBundle mainBundle] pathForResource:@"source4_complex_lr" ofType:@"mp4"];
    
    NSString *mp4AlphaResPath9 = [[NSBundle mainBundle] pathForResource:@"source1_complex_bt" ofType:@"mp4"];
    NSString *mp4AlphaResPath10 = [[NSBundle mainBundle] pathForResource:@"source2_complex_bt" ofType:@"mp4"];
    NSString *mp4AlphaResPath11 = [[NSBundle mainBundle] pathForResource:@"source3_complex_bt" ofType:@"mp4"];
    NSString *mp4AlphaResPath12 = [[NSBundle mainBundle] pathForResource:@"source4_complex_bt" ofType:@"mp4"];

    self.localPackageItems = @[
        [ZGMediaPlayerMediaItem itemWithFileURL:wavResPath mediaName:@"test.wav" isVideo:NO],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp3ResPath mediaName:@"sample.mp3" isVideo:NO],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4ResPath mediaName:@"ad.mp4" isVideo:YES],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4AlphaResPath1 mediaName:@"source1_complex_rl.mp4" isVideo:YES],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4AlphaResPath2 mediaName:@"source2_complex_rl.mp4" isVideo:YES],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4AlphaResPath3 mediaName:@"source3_complex_rl.mp4" isVideo:YES],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4AlphaResPath4 mediaName:@"source4_complex_rl.mp4" isVideo:YES],

        [ZGMediaPlayerMediaItem itemWithFileURL:mp4AlphaResPath5 mediaName:@"source1_complex_lr.mp4" isVideo:YES],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4AlphaResPath6 mediaName:@"source2_complex_lr.mp4" isVideo:YES],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4AlphaResPath7 mediaName:@"source3_complex_lr.mp4" isVideo:YES],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4AlphaResPath8 mediaName:@"source4_complex_lr.mp4" isVideo:YES],
        
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4AlphaResPath9 mediaName:@"source1_complex_bt.mp4" isVideo:YES],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4AlphaResPath10 mediaName:@"source2_complex_bt.mp4" isVideo:YES],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4AlphaResPath11 mediaName:@"source3_complex_bt.mp4" isVideo:YES],
        [ZGMediaPlayerMediaItem itemWithFileURL:mp4AlphaResPath12 mediaName:@"source4_complex_bt.mp4" isVideo:YES],
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

- (IBAction)onEnterTapped:(UIButton *)sender {
    ZGMediaPlayerMediaItem *item = [ZGMediaPlayerMediaItem itemWithFileURL:self.resourceURL mediaName:self.resourceURL isVideo:YES];

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MediaPlayer" bundle:nil];
    ZGMediaPlayerViewController *playerVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGMediaPlayerViewController class])];
    playerVC.mediaItem = item;
    playerVC.alphaBlend = self.alphaBlend;
    playerVC.alphaLayout = self.alphaLayout;
    playerVC.mediaPlayerHardwareDecode = self.mediaHardwareDecode;
    [self.navigationController pushViewController:playerVC animated:YES];
}

- (IBAction)onChooseTapped:(UIButton *)sender {
    if(@available(iOS 11.0, *)){
        [self openDocumentPickerViewController];
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Do not support before iOS 11." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancel];
        [self presentViewController:alertController animated:true completion:nil];
        return;
    }
}

- (IBAction)onURLInput:(UITextField *)sender {
    self.resourceURL = sender.text;
}
- (IBAction)onAlphaBlendValueChanged:(UISwitch *)sender {
    self.alphaBlend = sender.isOn;
}
- (IBAction)onAlphaLayoutValueChanged:(UISegmentedControl *)sender {
    self.alphaLayout = (int)sender.selectedSegmentIndex;
}
- (IBAction)onHardwareDecodeChanged:(UISwitch *)sender {
    self.mediaHardwareDecode = sender.isOn;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Network Resources";
    } else if (section == 1) {
        return @"Local Package Resources";
    } else if (section == 2) {
        return @"Custom Network Resource";
    } else if (section == 3) {
        return @"Local Media Library Resources";
    } else if(section == 4){
        return @"Local File Resource";
    }else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _networkItems.count;
    } else if (section == 1) {
        return _localPackageItems.count;
    } else if (section == 2) {
        return 1;
    } else if (section == 3) {
        return _localMediaLibraryItems.count;
    } else if(section == 4){
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellID = @"MediaPlayerItemCell";
    if (indexPath.section == 2) {
        cellID = @"MediaPlayerCustomCellItem";
    }
    if(indexPath.section == 4){
        cellID = @"MediaPlayerCustomCellItemLocal";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    if (indexPath.section == 2 || indexPath.section == 4) {
        return cell;
    }
    
    ZGMediaPlayerMediaItem *item = nil;
    if (indexPath.section == 0) {
        item = _networkItems[indexPath.row];
    } else if (indexPath.section == 1) {
        item = _localPackageItems[indexPath.row];
    } else if (indexPath.section == 3) {
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
    } else if (indexPath.section == 3) {
        item = _localMediaLibraryItems[indexPath.row];
    }
    
    if (item) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MediaPlayer" bundle:nil];
        ZGMediaPlayerViewController *playerVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGMediaPlayerViewController class])];
        playerVC.mediaItem = item;
        playerVC.alphaBlend = self.alphaBlend;
        playerVC.alphaLayout = self.alphaLayout;
        playerVC.mediaPlayerHardwareDecode = self.mediaHardwareDecode;
        [self.navigationController pushViewController:playerVC animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}


- (void)openDocumentPickerViewController{
    // 设置文件类型
    NSArray *documentTypes = @[@"public.content",
                               @"public.text",
                               @"public.source-code ",
                               @"public.image",
                               @"public.audiovisual-content",
                               @"public.mpeg-4",
                               @"public.avi",
                               @"public.data",
                               @"com.adobe.pdf",
                               @"com.apple.keynote.key",
                               @"com.microsoft.word.doc",
                               @"com.microsoft.excel.xls",
                               @"com.microsoft.powerpoint.ppt"];
    
    // 因为在Appdelegate中我设置了UIScrollViewContentInsetAdjustmentNever，这里需要修改为UIScrollViewContentInsetAdjustmentAutomatic，否则界面会上移
//    if (@available(iOS 11, *)) {
//        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
//    }
    
    UIDocumentPickerViewController *documentPickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeImport];
    documentPickerViewController.delegate = self;
    documentPickerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:documentPickerViewController animated:YES completion:nil];
}

#pragma mark 点击取消文件选择
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    /// 设置回UIScrollViewContentInsetAdjustmentNever
//    if (@available(iOS 11, *)) {
//        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    }
}

#pragma mark 点击选择文件结果
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    /// 设置回UIScrollViewContentInsetAdjustmentNever
//    if (@available(iOS 11, *)) {
//        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    }
    
//    BOOL fileUrlAuthozied = [url startAccessingSecurityScopedResource];
//    if(fileUrlAuthozied){
//        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
//        NSError *error;
//        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
//            NSString *path111 = newURL.path;
//            NSLog(@"选择的文件地址=== %@",path111);
//
//            ZGMediaPlayerMediaItem *item = [ZGMediaPlayerMediaItem itemWithFileURL:path111 mediaName:path111 isVideo:YES];
//
//            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MediaPlayer" bundle:nil];
//            ZGMediaPlayerViewController *playerVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGMediaPlayerViewController class])];
//            playerVC.mediaItem = item;
//            [self.navigationController pushViewController:playerVC animated:YES];
//
//        }];
//        [url stopAccessingSecurityScopedResource];
//    }else{
//        ZGLogWarn(@"❕ Cannot load file");
//    }
//    NSArray *array = [[url absoluteString]componentsSeparatedByString:@"/"];
//    NSString *fileName = [array lastObject];
//    fileName = [fileName stringByRemovingPercentEncoding];
    NSURL *tempURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSData *fileData = [NSData dataWithContentsOfURL:url];
    NSString *filePath = [tempURL.path stringByAppendingPathComponent:url.lastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath]){
        NSError *error = nil;
        [fileManager removeItemAtPath:filePath error:&error];
        
    }
    BOOL success = [fileData writeToFile:filePath atomically:YES];
    if(success){
        NSLog(@"write file success");
    }else{
        NSLog(@"write file fail");
    }
    
    if(success){
        NSString *fileName = filePath;//[url absoluteString];
        NSLog(@"file name:%@", fileName);
        
        ZGMediaPlayerMediaItem *item = [ZGMediaPlayerMediaItem itemWithFileURL:fileName mediaName:fileName isVideo:YES];

        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MediaPlayer" bundle:nil];
        ZGMediaPlayerViewController *playerVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([ZGMediaPlayerViewController class])];
        playerVC.mediaItem = item;
        playerVC.alphaBlend = self.alphaBlend;
        playerVC.alphaLayout = self.alphaLayout;
        playerVC.mediaPlayerHardwareDecode = self.mediaHardwareDecode;
        [self.navigationController pushViewController:playerVC animated:YES];
    }
}

@end

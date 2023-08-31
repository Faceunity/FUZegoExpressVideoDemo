//
//  ZGShareLogViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Sky on 2019/4/16.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGShareLogViewController.h"
#import <ZipArchive/ZipArchive.h>
#import "ZegoHudManager.h"

@interface ZGShareLogViewController () <UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) UIDocumentInteractionController *documentController;

@end

@implementation ZGShareLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)shareMainAppLogs {
    // Compressing files in asynchronous threads
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // Get all files in the Library/Caches/ZegoLogs directory
        NSString *zegologs = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/ZegoLogs"];
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:zegologs];

        NSMutableArray<NSString*> *srcLogs = [NSMutableArray array];
        [files enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * stop) {
            if ([obj hasSuffix:@".txt"]) {
                NSString *logFilePath = [zegologs stringByAppendingPathComponent:obj];
                [srcLogs addObject:logFilePath];
            }
        }];

        NSString *zipPath = [zegologs stringByAppendingPathComponent:@"/ZegoExpressLogs.zip"];
        [self zipAndShare:srcLogs dstPath:zipPath];
    });
}

- (void)shareReplayKitExtensionLogs {
    // Compressing files in asynchronous threads
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // Get all files in the [APP_GROUP]/ZegoLogsReplayKit directory
        NSString *replayKitLogDir = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:APP_GROUP] URLByAppendingPathComponent:@"ZegoLogsReplayKit" isDirectory:YES].path;
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:replayKitLogDir];

        NSMutableArray<NSString*> *srcLogs = [NSMutableArray array];
        [files enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * stop) {
            if ([obj hasSuffix:@".txt"]) {
                NSString *logFilePath = [replayKitLogDir stringByAppendingPathComponent:obj];
                [srcLogs addObject:logFilePath];
            }
        }];

        NSString *zipPath = [replayKitLogDir stringByAppendingPathComponent:@"/ZegoExpressLogs-ReplayKit.zip"];
        [self zipAndShare:srcLogs dstPath:zipPath];
    });
}

#pragma mark - Helper

- (void)zipAndShare:(NSArray<NSString *> *)srcFiles dstPath:(NSString *)dstPath {
    // Compressing files in asynchronous threads
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL result = [SSZipArchive createZipFileAtPath:dstPath withFilesAtPaths:srcFiles];
        NSLog(@"Zip result: %d", result);

        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:dstPath]];
                controller.delegate = self;
                self.documentController = controller;
                NSLog(@"self.view.bounds:%@", NSStringFromCGRect(self.view.bounds));
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    CGRect tarRect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 10);
                    [controller presentOpenInMenuFromRect:tarRect inView:self.view animated:YES];
                } else {
                    bool res = [controller presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
                    if (!res)
                    {
                        [controller presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
                    }
                    
                }
            } else {
                [ZegoHudManager showMessage:@"Compressed file failed"];
            }
        });
    });
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

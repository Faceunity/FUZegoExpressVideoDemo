//
//  ZGShareLogViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Sky on 2019/4/16.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGShareLogViewController.h"
#import <SSZipArchive/SSZipArchive.h>
#import "ZegoHudManager.h"

@interface ZGShareLogViewController () <UIDocumentInteractionControllerDelegate>

@property (strong, nonatomic) UIDocumentInteractionController *documentController;

@end

@implementation ZGShareLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
        [self zipAndShare];
}

- (void)zipAndShare {
    // Compressing files in asynchronous threads
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // Handling paths
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *zegologs = [cachesPath stringByAppendingString:@"/ZegoLogs"];
        
        // Log compressed file path
        NSString *dstLogFilePath = [zegologs stringByAppendingPathComponent:@"/zegoavlog.zip"];
        
        // Get all the files in the Library/Caches/ZegoLogs directory
        NSFileManager *manager = [NSFileManager defaultManager];
        NSArray *files = [manager subpathsAtPath:zegologs];
        
        NSMutableDictionary *logFiles = [NSMutableDictionary dictionaryWithCapacity:1];
        NSMutableArray<NSString*> *srcLogs = [NSMutableArray arrayWithCapacity:1];
        [files enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * stop) {
            // Remove the txt log file under ZegoLogs
            if ([obj hasSuffix:@".txt"]) {
                NSString *logFileDir = [NSString stringWithFormat:@"%@/%@", zegologs, obj];
                [srcLogs addObject:logFileDir];
                [logFiles setObject:logFileDir forKey:obj];
            }
        }];
        
        // Compressed log files in zip format
        BOOL ret = [SSZipArchive createZipFileAtPath:dstLogFilePath withFilesAtPaths:srcLogs];

        NSLog(@"zip ret: %d", ret);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ret) {
                UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:dstLogFilePath]];
                controller.delegate = self;
                self.documentController = controller;
                NSLog(@"self.view.bounds:%@", NSStringFromCGRect(self.view.bounds));
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    CGRect tarRect = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 10);
                    [controller presentOpenInMenuFromRect:tarRect inView:self.view animated:YES];
                } else {
                    [controller presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
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

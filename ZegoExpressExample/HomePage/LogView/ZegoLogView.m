//
//  ZegoLogView.m
//  Chatroom-iOS
//
//  Created by Sky on 2019/3/14.
//  Copyright © 2019 zego. All rights reserved.
//

#import "ZegoLogView.h"
#import "ZegoLog.h"
#import "ZegoRAMStoreLogger.h"
#import "ZegoTTYLogFormatter.h"
#import "ZGShareLogViewController.h"
#import "UIViewController+TopPresent.h"

@interface ZegoLogView () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) ZegoRAMStoreLogger *logger;
@property (strong, nonatomic) ZegoTTYLogFormatter *formatter;

@property (strong, nonatomic) UIView *naviBar;
@property (strong, nonatomic) UIButton *clearBtn;
@property (strong, nonatomic) UIButton *shareBtn;
@property (strong, nonatomic) UIButton *deleteBtn;
@property (strong, nonatomic) UIButton *closeBtn;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIDocumentInteractionController *documentController;

@property (assign, nonatomic) BOOL isDragingList; //Do not scroll to the bottom when viewing the log

@end

static ZegoLogView *view = nil;

@implementation ZegoLogView

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

+ (void)show {
    if (!view) {
        view = [[ZegoLogView alloc] init];
        view.frame = [[ZGWindowHelper keyWindow] bounds];
        view.alpha = 0;
        view.userInteractionEnabled = NO;
        [[ZGWindowHelper keyWindow] addSubview:view];
        [UIView animateWithDuration:0.5 animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            view.userInteractionEnabled = YES;
        }];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.logger = ZegoLog.allLoggers[1];
    self.formatter = [ZegoTTYLogFormatter new];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onLogMessagesUpdate) name:ZegoRAMStoreLoggerLogDidChangeNotification object:nil];
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];

    self.naviBar = [[UIView alloc] init];
    self.naviBar.backgroundColor = [UIColor clearColor];
    
    self.clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.clearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.clearBtn setTitle:@"Clear" forState:UIControlStateNormal];
    [self.clearBtn addTarget:self action:@selector(onClear) forControlEvents:UIControlEventTouchUpInside];
    
    self.shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.shareBtn setTitle:@"Share" forState:UIControlStateNormal];
    [self.shareBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShareMainAppLogs:)]];
    [self.shareBtn addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onShareReplayKitExtensionLogs:)]];

    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.deleteBtn setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteBtn addTarget:self action:@selector(onDelete) forControlEvents:UIControlEventTouchUpInside];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.closeBtn setTitle:@"Exit" forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self addSubview:self.naviBar];
    [self.naviBar addSubview:self.clearBtn];
    [self.naviBar addSubview:self.shareBtn];
    [self.naviBar addSubview:self.deleteBtn];
    [self.naviBar addSubview:self.closeBtn];
    [self addSubview:self.tableView];
    
    //layout
    CGRect scr = [[ZGWindowHelper keyWindow] bounds];
    CGFloat statusH = [ZGWindowHelper statusBarFrame].size.height;
    CGFloat naviH = 44 + statusH;
    CGFloat btnW = 80;
    CGFloat btnH = naviH - statusH;
    self.naviBar.frame = CGRectMake(0, 0, scr.size.width, naviH);
    self.clearBtn.frame = CGRectMake(0, statusH, btnW, btnH);
    self.shareBtn.frame = CGRectMake(btnW, statusH, btnW, btnH);
    self.deleteBtn.frame = CGRectMake(scr.size.width-btnW-btnW, statusH, btnW, btnH);
    self.closeBtn.frame = CGRectMake(scr.size.width-btnW, statusH, btnW, btnH);
    self.tableView.frame = CGRectMake(0, self.naviBar.frame.size.height, scr.size.width, scr.size.height-self.naviBar.frame.size.height);
    
    [self.tableView reloadData];
}

- (void)onClear {
    [self.logger flush];
}

- (void)onShareMainAppLogs:(UIGestureRecognizer *)gesture {
    [self hide];
    ZGShareLogViewController *vc = [[ZGShareLogViewController alloc] init];
    UIViewController *rootVC = [ZGWindowHelper keyWindow].rootViewController;
    [rootVC.topPresentedViewController presentViewController:vc animated:YES completion:nil];
    [vc shareMainAppLogs];
}

- (void)onShareReplayKitExtensionLogs:(UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateBegan) return;
    
    [self hide];
    ZGShareLogViewController *vc = [[ZGShareLogViewController alloc] init];
    UIViewController *rootVC = [ZGWindowHelper keyWindow].rootViewController;
    [rootVC.topPresentedViewController presentViewController:vc animated:YES completion:nil];
    [vc shareReplayKitExtensionLogs];
}

- (void)onDelete {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete SDK log files?" message:@"This operation will delete all log files generated by the ZegoExpressEngine SDK." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            // Delete main app logs
            NSString *mainAppLogPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:@"/ZegoLogs"];
            [[NSFileManager defaultManager] removeItemAtPath:mainAppLogPath error:nil];

            // Delete ReplayKit extension logs
            NSString *replayKitLogDir = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:APP_GROUP] URLByAppendingPathComponent:@"ZegoLogsReplayKit" isDirectory:YES].path;
            [[NSFileManager defaultManager] removeItemAtPath:replayKitLogDir error:nil];
        });

    }]];

    [[ZGWindowHelper keyWindow].rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)hide {
    self.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        view = nil;
    }];
}

#pragma mark - ZegoRoomHelperLogDelegate

- (void)onLogMessagesUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
        if (self.isDragingList) {
            return;
        }
        
        if (self.logger.logs.count > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.logger.logs.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logger.logs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    NSString *logString = @"";
    if (self.logger.logs.count > indexPath.row) {
        ZegoLogMessage *msg = self.logger.logs[indexPath.row];
        logString = [self.formatter formatLogMessage:msg];
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = logString;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        if (indexPath.row >= self.logger.logs.count) {
            return;
        }
        
        ZegoLogMessage *msg = self.logger.logs[indexPath.row];
        NSString *logString = [self.formatter formatLogMessage:msg];
        if (logString) {
            [[UIPasteboard generalPasteboard] setString:logString];
        }
    }
}
#pragma clang diagnostic pop

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDragingList = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.isDragingList = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isDragingList = NO;
}

@end

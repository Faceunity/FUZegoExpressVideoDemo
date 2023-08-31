//
//  ZGAutoMixerViewController.m
//  ZegoExpressExample
//
//  Created by zego on 2021/7/29.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGAutoMixerViewController.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>
#import "ZGUserIDHelper.h"

@interface ZGAutoMixerViewController() <UITableViewDelegate, UITableViewDataSource, ZegoEventHandler>
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *mixOut;
@property (nonatomic, strong) NSMutableArray<ZegoStream *> *remoteStreamList;
@property (nonatomic, assign) BOOL isMixing;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) ZegoPlayerState playerState;
@property (nonatomic, strong) ZegoAutoMixerTask *autoMixerTask;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UITableView *streamListTableView;
@property (weak, nonatomic) IBOutlet UILabel *streamListTitle;
@property (weak, nonatomic) IBOutlet UIButton *startAutoMixerTaskButton;
@property (weak, nonatomic) IBOutlet UIButton *startPlayStreamButton;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@property (weak, nonatomic) IBOutlet UITextField *taskIDText;
@property (weak, nonatomic) IBOutlet UITextField *mixOutText;
@property (weak, nonatomic) IBOutlet UITextField *playStreamID;
@property (weak, nonatomic) IBOutlet UITextField *playCdnUrl;

@end

@implementation ZGAutoMixerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomID = @"0025";
    self.mixOut = @"mix_0025";
    
    self.remoteStreamList = [NSMutableArray array];
    
    [self setupUI];
    
    [self createEngineAndLoginRoom];
}

/// Append Log to Top View
- (void)appendLog:(NSString *)tipText {
    if (!tipText || tipText.length == 0) {
        return;
    }
    
    ZGLogInfo(@"%@", tipText);
    
    NSString *oldText = self.logTextView.text;
    NSString *newLine = oldText.length == 0 ? @"" : @"\n";
    NSString *newText = [NSString stringWithFormat:@"%@%@ %@", oldText, newLine, tipText];
    
    self.logTextView.text = newText;
    if(newText.length > 0 ) {
        UITextView *textView = self.logTextView;
        NSRange bottom = NSMakeRange(newText.length -1, 1);
        [textView scrollRangeToVisible:bottom];
        // an iOS bug, see https://stackoverflow.com/a/20989956/971070
        [textView setScrollEnabled:NO];
        [textView setScrollEnabled:YES];
    }
}

- (void)setupUI {
    self.isMixing = NO;
    self.playerState = ZegoPlayerStateNoPlay;
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    self.taskIDText.text = @"0025";
    self.mixOutText.text = @"mix_0025";
    self.playStreamID.text = @"mix_0025";
    
    self.streamListTableView.backgroundColor = [UIColor clearColor];
//    self.streamListTableView.delegate = self;
//    self.streamListTableView.tableFooterView = [[UIView alloc] init];
    self.streamListTableView.estimatedRowHeight = 44.0;
    self.streamListTableView.rowHeight = UITableViewAutomaticDimension;
    self.streamListTableView.dataSource = self;
    [self.startAutoMixerTaskButton setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"start_auto_stream_mixing", nil)] forState:UIControlStateNormal];
}

- (void)createEngineAndLoginRoom {
    ZGLogInfo(@"🚀 Create ZegoExpressEngine");
    
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)
    
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    
    // Here we use the high quality video call scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    profile.scenario = ZegoScenarioHighQualityVideoCall;
    
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
    
    [self appendLog:[NSString stringWithFormat:@"🚀 Create ZegoExpressEngine，appID: %d, appSign:%@", profile.appID, profile.appSign]];
    
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    
    ZGLogInfo(@"🚪 Login room. roomID: %@", self.roomID);
    [self appendLog:[NSString stringWithFormat:@"🚪 loginRoom, roomID: %@", self.roomID]];
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user];
}

#pragma mark - Start Auto Mixer Task

- (IBAction)startAutoMixButtonClicked:(id)sender {
    if (self.isMixing) {
        [self stopAutoMixerTask];
    } else {
        [self startAutoMixerTask];
    }
}

- (void)startAutoMixerTask {
    ZGLogInfo(@"🧬 Start auto mixer task");
    
    // ① (Required): Create a ZegoMixerTask object
    ZegoAutoMixerTask *task = [[ZegoAutoMixerTask alloc] init];
    
    task.taskID = _taskIDText.text;//[ZGUserIDHelper userID];
    task.roomID = _roomID;
    
    
    // ③ (Optional): Set audio config
    [task setAudioConfig:[ZegoMixerAudioConfig defaultConfig]];
    
    
    // ⑤ (Required): Set mixer output
    _mixOut = _mixOutText.text;
    NSArray<ZegoMixerOutput *> *outputArray = @[[[ZegoMixerOutput alloc] initWithTarget:_mixOut]];
    [task setOutputList:outputArray];

    // ⑧ (Optional): Enable mixer sound level
    task.enableSoundLevel = TRUE;
    
    // Start Mixer Task
    [ZegoHudManager showNetworkLoading];
    
    //disable button
    [self.startAutoMixerTaskButton setEnabled:false];
    [[ZegoExpressEngine sharedEngine] startAutoMixerTask:task callback:^(int errorCode, NSDictionary * _Nullable extendedData) {
        //enable button
        [self.startAutoMixerTaskButton setEnabled:true];
        ZGLogInfo(@"🚩 🧬 Start auto mixer task result errorCode: %d", errorCode);
        [self appendLog:[NSString stringWithFormat:@"🚩 🧬 startAutoMixerTask,errorCode: %d", errorCode]];
        
        [ZegoHudManager hideNetworkLoading];
        
        if (errorCode == 0) {
            self.isMixing = YES;
            [self.startAutoMixerTaskButton setTitle:[NSString stringWithFormat:@"🎉%@",NSLocalizedString(@"stop_auto_stream_mixing", nil)] forState:UIControlStateNormal];
        }
    }];
    
    // Save the task object
    self.autoMixerTask = task;
}

- (void)stopAutoMixerTask {
    ZGLogInfo(@"🧬 Stop auto mixer task");

    // Stop task
    //disable button
    [self.startAutoMixerTaskButton setEnabled:false];
    [[ZegoExpressEngine sharedEngine] stopAutoMixerTask:self.autoMixerTask callback:^(int errorCode) {
        //enable button
        [self.startAutoMixerTaskButton setEnabled:true];
        ZGLogInfo(@"🚩 🧬 stopAutoMixerTask result,errorCode: %d", errorCode);
        [self appendLog:[NSString stringWithFormat:@"🚩 🧬 stopAutoMixerTask,errorCode: %d", errorCode]];
        if(errorCode == 0)
        {
            ZegoAutoMixerTask* taskTemp = self.autoMixerTask;
            taskTemp.taskID = @"";
            self.autoMixerTask = taskTemp;
            self.isMixing = NO;
            [self.startAutoMixerTaskButton setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"start_auto_stream_mixing", nil)] forState:UIControlStateNormal];
        }
    }];
}

#pragma mark - Start play stream

- (IBAction)startPlayClicked:(id)sender {
    if(_isPlaying)
    {
        [self stopPlayingStream];
    }
    else
    {
        [self startPlayingStream];
    }
}

- (void)startPlayingStream {
    [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@, CDN url:%@",self.mixOut,self.playCdnUrl.text]];
    
    // Start playing
    ZegoPlayerConfig *config = [[ZegoPlayerConfig alloc] init];
    ZegoCDNConfig *cdnConfig = [[ZegoCDNConfig alloc] init];
    cdnConfig.url = _playCdnUrl.text;
    config.cdnConfig = cdnConfig;
    if(![cdnConfig.url isEqual:@""])
    {
        config.resourceMode = ZegoStreamResourceModeOnlyCDN;
    }
    
    [[ZegoExpressEngine sharedEngine] startPlayingStream:self.playStreamID.text canvas:Nil config:config];
    
    self.isPlaying = YES;
    [self.playStreamID setEnabled:NO];
    [self.playCdnUrl setEnabled:NO];
    [self.startPlayStreamButton setTitle:@"Stop Playing" forState:UIControlStateNormal];
}

- (void)stopPlayingStream {
    // Stop playing
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.playStreamID.text];
    [self appendLog:@"📥 Stop playing stream"];
    self.isPlaying = NO;
    [self.playStreamID setEnabled:YES];
    [self.playCdnUrl setEnabled:YES];
    [self.startPlayStreamButton setTitle:@"Start Playing" forState:UIControlStateNormal];
}


#pragma mark - ZegoEventHandler

// Refresh the remote streams list
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🌊 Room Stream Update Callback: %lu, StreamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);
    
    if (updateType == ZegoUpdateTypeAdd) {
        for (ZegoStream *stream in streamList) {
            ZGLogInfo(@"🚩 🌊 --- [Add] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID);
            if (![self.remoteStreamList containsObject:stream]) {
                [self.remoteStreamList addObject:stream];
            }
        }
    } else if (updateType == ZegoUpdateTypeDelete) {
        for (ZegoStream *stream in streamList) {
            ZGLogInfo(@"🚩 🌊 --- [Delete] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID);
            __block ZegoStream *delStream = nil;
            [self.remoteStreamList enumerateObjectsUsingBlock:^(ZegoStream * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.streamID isEqualToString:stream.streamID] && [obj.user.userID isEqualToString:stream.user.userID]) {
                    delStream = obj;
                    *stop = YES;
                }
            }];
            [self.remoteStreamList removeObject:delStream];
        }
    }
    // Refresh stream
    [self.streamListTitle setText:[NSString stringWithFormat:@"StreamList(%lu)", [self.remoteStreamList count]]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.streamListTableView reloadData];
        
//        if (self.isDragingList) {
//            return;
//        }
    });
}

-(void)onRoomStateChanged:(ZegoRoomStateChangedReason)reason errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🚪 Room State Changed Callback: %lu, errorCode: %d, roomID: %@", (unsigned long)reason, (int)errorCode, roomID);
}

// Refresh the player state
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@"🚩 📥 Player State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
    self.playerState = state;
}

- (void)onAutoMixerSoundLevelUpdate:(NSDictionary<NSString *,NSNumber *> *)soundLevels {
    for (NSString *key in soundLevels)
    {
        ZGLogInfo(@"onAutoMixerSoundLevelUpdate, streamID: %@, soundLevel:%f",key, [soundLevels valueForKey:key].floatValue);

        [self.remoteStreamList enumerateObjectsUsingBlock:^(ZegoStream * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.streamID isEqualToString:key]) {
                NSString *soundLevel = [NSString stringWithFormat:@"%f",[soundLevels valueForKey:key].floatValue];
                obj.extraInfo = soundLevel;
                *stop = YES;
                [self.streamListTableView reloadData];
            }
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)streamListTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)streamListTableView numberOfRowsInSection:(NSInteger)section {
    return self.remoteStreamList.count;
}

- (UITableViewCell *)tableView:(UITableView *)streamListTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"UITableViewCell";
    UITableViewCell *cell = [streamListTableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    NSString *content = [NSString stringWithFormat:@"userID:%@  streamID:%@ soundLevel:%@",[self.remoteStreamList  objectAtIndex:indexPath.row].user.userID,[self.remoteStreamList objectAtIndex:indexPath.row].streamID,[self.remoteStreamList objectAtIndex:indexPath.row].extraInfo];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = content;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    
    return cell;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return (action == @selector(copy:));
}
#pragma clang diagnostic pop

#pragma mark - Exit

- (void)dealloc {
    //Stop auto mixer task
    if (self.isMixing) {
        [self stopAutoMixerTask];
    }
    ZGLogInfo(@"🚪 Exit the room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

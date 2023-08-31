//
//  ZGSoundLevelViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Paaatrick on 2019/12/2.
//  Copyright © 2019 Zego. All rights reserved.
//

#import "ZGSoundLevelViewController.h"
#import "ZGSoundLevelTableViewCell.h"
#import "KeyCenter.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZGSoundLevelViewController () <ZegoEventHandler, UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *logTextView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, copy) NSString *localStreamID;

@property (weak, nonatomic) IBOutlet UILabel *startSoundLevelMonitorLabel;

@property (weak, nonatomic) IBOutlet UILabel *startAudioSpectrumMonitorLabel;

// Array of other streams in the room
@property (nonatomic, strong) NSMutableArray<ZegoStream *> *remoteStreamList;

@property (nonatomic, assign) BOOL enableSoundLevelMonitor;
@property (nonatomic, assign) BOOL enableAudioSpectrumMonitor;
@property (nonatomic, assign) unsigned int soundLevelInterval;
@property (nonatomic, assign) unsigned int audioSpectrumInterval;

@end

@implementation ZGSoundLevelViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.roomID = @"0018";
    self.remoteStreamList = [NSMutableArray array];

    self.soundLevelInterval = 100;
    self.audioSpectrumInterval = 100;

    [self setupUI];

    [self startLive];
}

- (void)setupUI {
        
    self.startSoundLevelMonitorLabel.text = NSLocalizedString(@"Start SoundLevel Monitor", nil);
    self.startAudioSpectrumMonitorLabel.text = NSLocalizedString(@"Start Audio Spectrum Monitor", nil);
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ZGSoundLevelTableViewCell" bundle:nil] forCellReuseIdentifier:@"ZGSoundLevelTableViewCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)startLive {
    [self appendLog: [NSString stringWithFormat:@"🚀 Create ZegoExpressEngine"]];
    // Create ZegoExpressEngine and set self as delegate (ZegoEventHandler)
    ZegoEngineProfile *profile = [[ZegoEngineProfile alloc] init];
    profile.appID = [KeyCenter appID];
    profile.appSign = [KeyCenter appSign];
    
    // Here we use the high quality chatroom scenario as an example,
    // you should choose the appropriate scenario according to your actual situation,
    // for the differences between scenarios and how to choose a suitable scenario,
    // please refer to https://docs.zegocloud.com/article/14940
    profile.scenario = ZegoScenarioHighQualityChatroom;
    
    [ZegoExpressEngine createEngineWithProfile:profile eventHandler:self];
    
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    
    [self appendLog: [NSString stringWithFormat:@"🚪 Login room. roomID: %@", self.roomID]];

    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user];
    
    // Use userID as streamID
    self.localStreamID = [NSString stringWithFormat:@"%@", user.userID];
    
    // Publish audio only
    [[ZegoExpressEngine sharedEngine] enableCamera:NO];
    
    // Start publishing
    [self appendLog: [NSString stringWithFormat:@"📤 Start publishing stream. streamID: %@", self.localStreamID]];

    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.localStreamID];
    
    // Start monitoring
    [self appendLog: @"🎼 Start sound level monitor, with default interval 100ms"];
    self.enableSoundLevelMonitor = YES;
    
    [self appendLog: @"🎼 Start audio frequency spectrum monitor, with default interval 100ms"];
    self.enableAudioSpectrumMonitor = YES;
}

- (void)setEnableSoundLevelMonitor:(BOOL)enable {
    if (enable) {
        ZegoSoundLevelConfig *config = [[ZegoSoundLevelConfig alloc] init];
        config.millisecond = _soundLevelInterval;
        config.enableVAD = YES;
        [[ZegoExpressEngine sharedEngine] startSoundLevelMonitorWithConfig:config];
    } else {
        [[ZegoExpressEngine sharedEngine] stopSoundLevelMonitor];
    }
}

- (void)setEnableAudioSpectrumMonitor:(BOOL)enable {
    if (enable) {
        [[ZegoExpressEngine sharedEngine] startAudioSpectrumMonitor:_audioSpectrumInterval];
    } else {
        [[ZegoExpressEngine sharedEngine] stopAudioSpectrumMonitor];
    }
}

- (IBAction)soundLevelSwitchValueChanged:(UISwitch *)sender {
    self.enableSoundLevelMonitor = sender.on;
    [self appendLog:[NSString stringWithFormat:@"🎶 %@ sound level monitor, interval: %u", _enableSoundLevelMonitor ? @"Start" : @"Stop", _soundLevelInterval]];
}

- (IBAction)audioSpectrumSwitchValueChanged:(UISwitch *)sender {
    self.enableAudioSpectrumMonitor = sender.on;
    [self appendLog:[NSString stringWithFormat:@"📼 %@ audio spectrum monitor, interval: %u", _enableAudioSpectrumMonitor ? @"Start" : @"Stop", _audioSpectrumInterval]];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

#pragma mark Streams Update Callback

// Refresh the remote streams list
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@"🚩 🌊 Room Stream Update Callback: %lu, StreamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);
    
    if (updateType == ZegoUpdateTypeAdd) {
        for (ZegoStream *stream in streamList) {
            [self appendLog:[NSString stringWithFormat:@"🚩 🌊 --- [Add] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID]];

            if (![self.remoteStreamList containsObject:stream]) {
                [self.remoteStreamList addObject:stream];
            }
            
            // Play remote stream without rendering
            [self appendLog:[NSString stringWithFormat:@"📥 Start playing stream, streamID: %@", stream.streamID]];

            [[ZegoExpressEngine sharedEngine] startPlayingStream:stream.streamID canvas:nil];
        }
    } else if (updateType == ZegoUpdateTypeDelete) {
        for (ZegoStream *stream in streamList) {
            [self appendLog:[NSString stringWithFormat:@"🚩 🌊 --- [Delete] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID]];
            __block ZegoStream *delStream = nil;
            [self.remoteStreamList enumerateObjectsUsingBlock:^(ZegoStream * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.streamID isEqualToString:stream.streamID] && [obj.user.userID isEqualToString:stream.user.userID]) {
                    delStream = obj;
                    *stop = YES;
                }
            }];
            [self.remoteStreamList removeObject:delStream];
            
            // Stop playing the remote stream
            ZGLogInfo(@"📥 Stop playing stream, streamID: %@", stream.streamID);
            [[ZegoExpressEngine sharedEngine] stopPlayingStream:stream.streamID];
        }
    }
    // Refresh tableview
    [self.tableView reloadData];
}

#pragma mark - Sound Level Callback


// Sound level callback for local stream
- (void)onCapturedSoundLevelInfoUpdate:(ZegoSoundLevelInfo *)soundLevelInfo {
    ZGSoundLevelTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.soundLevel = @(soundLevelInfo.soundLevel);
    cell.vad = soundLevelInfo.vad == 1;
}

// Sound level callback for remote streams, key is stream ID, value is the sound level data corresponding to stream ID
- (void)onRemoteSoundLevelInfoUpdate:(NSDictionary<NSString *,ZegoSoundLevelInfo *> *)soundLevelInfos {
    NSInteger rowCount = [self.tableView numberOfRowsInSection:1];
    for (NSInteger row = 0; row < rowCount; row++) {
        ZGSoundLevelTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];
        if ([soundLevelInfos objectForKey:cell.streamID]) {
            cell.soundLevel = @(soundLevelInfos[cell.streamID].soundLevel);
            cell.vad = soundLevelInfos[cell.streamID].vad == 1;
        }
    }
}

#pragma mark - Frequency Spectrum Callback

// Audio frequency spectrum callback for local stream
- (void)onCapturedAudioSpectrumUpdate:(NSArray<NSNumber *> *)audioSpectrum {
    ZGSoundLevelTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.spectrumList = audioSpectrum;
}

// Audio frequency spectrum callback for remote streams, key is stream ID, value is the spectrum data corresponding to stream ID
- (void)onRemoteAudioSpectrumUpdate:(NSDictionary<NSString *,NSArray<NSNumber *> *> *)audioSpectrums {
    NSInteger rowCount = [self.tableView numberOfRowsInSection:1];
    for (NSInteger row = 0; row < rowCount; row++) {
        ZGSoundLevelTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:1]];
        if ([audioSpectrums objectForKey:cell.streamID]) {
            cell.spectrumList = audioSpectrums[cell.streamID];
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.remoteStreamList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZGSoundLevelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZGSoundLevelTableViewCell"];
    cell.userInteractionEnabled = NO;
    if (indexPath.section == 0) {
        cell.streamID = [NSString stringWithFormat:@"(Self) %@", self.localStreamID];
    } else {
        if (self.remoteStreamList.count > indexPath.row) {
            cell.streamID = self.remoteStreamList[indexPath.row].streamID;
        }
    }
    return cell;
}

#pragma mark - Log

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

#pragma mark - Exit

- (void)dealloc {
    ZGLogInfo(@"🚪 Exit the room");
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@"🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

@end

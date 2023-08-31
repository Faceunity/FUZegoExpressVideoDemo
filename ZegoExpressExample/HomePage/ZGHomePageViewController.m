//
//  ZGTopicsTableViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Randy Qiu on 2018/9/27.
//  Copyright © 2018 Zego. All rights reserved.
//

#import "ZGHomePageViewController.h"
#import "ZGLogVersionDebugViewController.h"

@implementation ZGHomePageViewController {
    NSArray<NSArray<NSString*>*>* _topicList;
}

- (void)viewDidAppear:(BOOL)animated {
    [self setInterfaceOrientation:UIInterfaceOrientationPortrait];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *goGlobalConfigItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"home.setting.button", nil) style:UIBarButtonItemStylePlain target:self action:@selector(goGlobalConfigPage:)];
    self.navigationItem.rightBarButtonItem = goGlobalConfigItem;
    
    NSMutableArray *basicTopicList = [NSMutableArray array];
    NSMutableArray *scenesTopicList = [NSMutableArray array];
    NSMutableArray *commonTopicList = [NSMutableArray array];
    NSMutableArray *streamAdvancedTopicList = [NSMutableArray array];
    NSMutableArray *videoAdvancedTopicList = [NSMutableArray array];
    NSMutableArray *audioAdvancedTopicList = [NSMutableArray array];
    NSMutableArray *otherTopicList = [NSMutableArray array];
    NSMutableArray *debugTopicList = [NSMutableArray array];
    NSArray *topicList = @[basicTopicList, scenesTopicList, commonTopicList, streamAdvancedTopicList, videoAdvancedTopicList, audioAdvancedTopicList, otherTopicList,debugTopicList];

    // Basic topics
    [basicTopicList addObject:_Module_QuickStart];
    [basicTopicList addObject:_Module_VideoChat];
    [basicTopicList addObject:_Module_PublishStream];
    [basicTopicList addObject:_Module_PlayStream];
    
    // Scenes topics
    [scenesTopicList addObject:_Module_VideoTalk];

    // Common topics
    [commonTopicList addObject:_Module_CommonVideoConfig];
    [commonTopicList addObject:_Module_VideoRotation];
    [commonTopicList addObject:_Module_RoomMessage];

    // Stream advanced topics
    [streamAdvancedTopicList addObject:_Module_StreamMonitoring];
    [streamAdvancedTopicList addObject:_Module_PublishingMultipleStreams];
    [streamAdvancedTopicList addObject:_Module_StreamByCDN];
    [streamAdvancedTopicList addObject:_Module_H265];

    // Video advanced topics
    [videoAdvancedTopicList addObject:_Module_EncodingDecoding];
    [videoAdvancedTopicList addObject:_Module_CustomVideoRender];
    [videoAdvancedTopicList addObject:_Module_CustomVideoCapture];
    [videoAdvancedTopicList addObject:_Module_CustomVideoProcess];
    [videoAdvancedTopicList addObject:_Module_PictureInPicture];

    // Audio advanced topics
    [audioAdvancedTopicList addObject:_Module_VoiceChangeReverbStereo];
    [audioAdvancedTopicList addObject:_Module_EarReturnAndChannelSettings];
    [audioAdvancedTopicList addObject:_Module_SoundLevel];
    [audioAdvancedTopicList addObject:_Module_AECANSAGC];
    [audioAdvancedTopicList addObject:_Module_AudioEffectPlayer];
    [audioAdvancedTopicList addObject:_Module_OriginalAudioDataAcquisition];
    [audioAdvancedTopicList addObject:_Module_CustomAudioIO];
//    [audioAdvancedTopicList addObject:_Module_AudioMixing]; // Do not use the audio mixing function
    [audioAdvancedTopicList addObject:_Module_RangeAudio];

    // Others
    [otherTopicList addObject:_Module_VideoObjectSegmentation];
    [otherTopicList addObject:_Module_SuperResolution];
    [otherTopicList addObject:_Module_Beautify];
    [otherTopicList addObject:_Module_EffectsBeauty];
    [otherTopicList addObject:_Module_Mixer];
    [otherTopicList addObject:_Module_RecordCapture];
    [otherTopicList addObject:_Module_MediaPlayer];
    [otherTopicList addObject:_Module_Camera];
    [otherTopicList addObject:_Module_MultipleRooms];
    [otherTopicList addObject:_Module_FlowControll];
    [otherTopicList addObject:_Module_NetworkAndPerformance];
    [otherTopicList addObject:_Module_Security];
    [otherTopicList addObject:_Module_ScreenCapture];
    [otherTopicList addObject:_Module_SupplementalEnhancementInformation];
    [otherTopicList addObject:_Module_MultiVideoSource];

    // Debug&Config
    [debugTopicList addObject:_Module_LogVersionDebug];
    
    _topicList = topicList;
}

- (void)goGlobalConfigPage:(id)sender {
    UIViewController *vc;
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"LogVersionDebug" bundle:nil];
    vc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _topicList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _topicList[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ZGTopicCell"];
    NSString* topicName = _topicList[indexPath.section][indexPath.row];
    [cell.textLabel setText:topicName];
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Topic.Module.Basic", @"Basic Module");
    } else if (section == 1) {
        return NSLocalizedString(@"Module.Scenes", nil);
    }  else if (section == 2) {
        return NSLocalizedString(@"Topic.Module.Common", @"Common Module");
    } else if (section == 3) {
        return NSLocalizedString(@"Topic.Module.StreamAdvanced", @"Stream Advanced Module");
    } else if (section == 4) {
        return NSLocalizedString(@"Topic.Module.VideoAdvanced", @"Video Advanced Module");
    } else if (section == 5) {
        return NSLocalizedString(@"Topic.Module.AudioAdvanced", @"Audio Advanced Module");
    } else if (section == 6) {
       return NSLocalizedString(@"Topic.Module.Others", nil);
    } else {
        return NSLocalizedString(@"Debug & Config", nil);;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= _topicList.count || indexPath.row >= _topicList[indexPath.section].count){
        return;
    }
    
    NSString* topicName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    UIViewController* vc = nil;

    // Basic topics
    if ([topicName isEqualToString:_Module_QuickStart]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"QuickStart" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_PublishStream]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"PublishStream" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_PlayStream]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"PlayStream" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_VideoChat]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"VideoChat" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }

    if ([topicName isEqualToString:_Module_VideoTalk]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"VideoForMultipleUsers" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }

    // Common topics
    
    if ([topicName isEqualToString:_Module_CommonVideoConfig]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"CommonVideoConfig" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    if ([topicName isEqualToString:_Module_VideoRotation]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"VideoRotation" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_RoomMessage]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"RoomMessage" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }

    // Stream advanced topics
    
    if ([topicName isEqualToString:_Module_StreamMonitoring]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"StreamMonitoring" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_PublishingMultipleStreams]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PublishingMultipleStreams" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_StreamByCDN]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"StreamByCDN" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_H265]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"H265" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    // Video advanced topics
    
    if ([topicName isEqualToString:_Module_EncodingDecoding]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"EncodingDecoding" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_CustomVideoRender]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomVideoRender" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }

    if ([topicName isEqualToString:_Module_CustomVideoCapture]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomVideoCapture" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_CustomVideoProcess]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomVideoProcess" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_PictureInPicture]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PictureInPicture" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }

    // Audio advanced topics
    if ([topicName isEqualToString:_Module_VoiceChangeReverbStereo]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"VoiceChangeReverbStereo" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_EarReturnAndChannelSettings]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"EarReturnAndChannelSettings" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_SoundLevel]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"SoundLevel" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_AECANSAGC]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"AECANSAGC" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_AudioEffectPlayer]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"AudioEffectPlayer" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_OriginalAudioDataAcquisition]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"OriginalAudioDataAcquisition" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_CustomAudioIO]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomAudioCaptureAndRendering" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_AudioMixing]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"AudioMixing" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_RangeAudio]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"RangeAudio" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    // Other topics
    if ([topicName isEqualToString:_Module_SuperResolution]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"SuperResolution" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    if ([topicName isEqualToString:_Module_EffectsBeauty]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"EffectsBeauty" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_Beautify]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Beautify" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_RecordCapture]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"RecordCapture" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_Mixer]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Mixer" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_MediaPlayer]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"MediaPlayer" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_Camera]) {
        
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Camera" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_MultipleRooms]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MultipleRooms" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_FlowControll]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"FlowControll" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_NetworkAndPerformance]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"NetworkAndPerformance" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_Security]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Security" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }

    if ([topicName isEqualToString:_Module_ScreenCapture]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ScreenCapture" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_SupplementalEnhancementInformation]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SupplementalEnhancementInformation" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if([topicName isEqualToString:_Module_VideoObjectSegmentation]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"VideoObjectSegmentation" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_LogVersionDebug]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"LogVersionDebug" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if ([topicName isEqualToString:_Module_MultiVideoSource]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MultiVideoSource" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - Access

- (void)setTopicList:(NSArray<NSArray<NSString*>*>*)topics {
    _topicList = topics;
    [self.tableView reloadData];
}

#pragma mark - Helper

- (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation {
// only for ios 16 and newer system
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
    if(@available(iOS 16.0, *)){
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
    }
    else
#endif
    {
        UIDevice *device = [UIDevice currentDevice];
        if (device.orientation != (UIDeviceOrientation)orientation && [device respondsToSelector:@selector(setOrientation:)]) {
            SEL selector  = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            [invocation setArgument:&orientation atIndex:2];
            [invocation invoke];
        }
    }
}

@end

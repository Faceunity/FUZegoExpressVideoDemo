//
//  ZGTopicsTableViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Randy Qiu on 2018/9/27.
//  Copyright © 2018 Zego. All rights reserved.
//

#import "ZGTopicsTableViewController.h"
#import "ZGAppGlobalConfigViewController.h"
#import "ZGTestMainViewController.h"

@implementation ZGTopicsTableViewController {
    NSArray<NSArray<NSString*>*>* _topicList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *goGlobalConfigItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"home.setting.button", nil) style:UIBarButtonItemStylePlain target:self action:@selector(goGlobalConfigPage:)];
    self.navigationItem.rightBarButtonItem = goGlobalConfigItem;
    
    NSMutableArray *basicTopicList = [NSMutableArray array];
    NSMutableArray *commonTopicList = [NSMutableArray array];
    NSMutableArray *advancedTopicList = [NSMutableArray array];
    NSArray *topicList = @[basicTopicList, commonTopicList, advancedTopicList];

#ifdef _Module_QuickStart
    [basicTopicList addObject:_Module_QuickStart];
#endif
#ifdef _Module_PublishStream
    [basicTopicList addObject:_Module_PublishStream];
#endif
#ifdef _Module_PlayStream
    [basicTopicList addObject:_Module_PlayStream];
#endif
#ifdef _Module_RecordCapture
    [advancedTopicList addObject:_Module_RecordCapture];
#endif
#ifdef _Module_Test
    [basicTopicList addObject:_Module_Test];
#endif
#ifdef _Module_VideoTalk
    [commonTopicList addObject:_Module_VideoTalk];
#endif
#ifdef _Module_RoomMessage
    [commonTopicList addObject:_Module_RoomMessage];
#endif
#ifdef _Module_Mixer
    [advancedTopicList addObject:_Module_Mixer];
#endif
#ifdef _Module_AudioMixing
    [advancedTopicList addObject:_Module_AudioMixing];
#endif
#ifdef _Module_SoundLevel
    [advancedTopicList addObject:_Module_SoundLevel];
#endif
#ifdef _Module_Beautify
    [advancedTopicList addObject:_Module_Beautify];
#endif
#ifdef _Module_MediaPlayer
    [advancedTopicList addObject:_Module_MediaPlayer];
#endif
#ifdef _Module_MediaSideInfo
    [advancedTopicList addObject:_Module_MediaSideInfo];
#endif
#ifdef _Module_ScalableVideoCoding
    [advancedTopicList addObject:_Module_ScalableVideoCoding];
#endif
#ifdef _Module_CustomVideoCapture
    [advancedTopicList addObject:_Module_CustomVideoCapture];
#endif
#ifdef _Module_CustomVideoRender
    [advancedTopicList addObject:_Module_CustomVideoRender];
#endif
#ifdef _Module_CustomAudioIO
    [advancedTopicList addObject:_Module_CustomAudioIO];
#endif
#ifdef _Module_AuxPublisher
    [advancedTopicList addObject:_Module_AuxPublisher];
#endif
#ifdef _Module_AudioEffect
    [advancedTopicList addObject:_Module_AudioEffect];
#endif
    
    _topicList = topicList;
}

- (void)jumpToWeb:(NSString *)url {
    NSURL *targetURL = [NSURL URLWithString:url];
    if (targetURL && [[UIApplication sharedApplication] canOpenURL:targetURL]) {
        [[UIApplication sharedApplication] openURL:targetURL];
    }
}

- (IBAction)onOpenDocWeb {
    [self jumpToWeb:ZGOpenDocURL];
}

- (IBAction)onOpenSourceCodeWeb {
    [self jumpToWeb:ZGOpenSourceCodeURL];
}

- (IBAction)onOpenQuestionWeb {
    [self jumpToWeb:ZGOpenQuestionURL];
}

- (void)goGlobalConfigPage:(id)sender {
    ZGAppGlobalConfigViewController *vc = [ZGAppGlobalConfigViewController instanceFromStoryboard];
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
        return @"Basic Module";
    } else if (section == 1) {
        return @"Common Module";
    }
    return @"Advanced Module";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= _topicList.count || indexPath.row >= _topicList[indexPath.section].count){
        return;
    }
    
    NSString* topicName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    UIViewController* vc = nil;
    
    #ifdef _Module_QuickStart
    if ([topicName isEqualToString:_Module_QuickStart]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"QuickStart" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_PublishStream
    if ([topicName isEqualToString:_Module_PublishStream]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"PublishStream" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_PlayStream
    if ([topicName isEqualToString:_Module_PlayStream]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"PlayStream" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_RecordCapture
    if ([topicName isEqualToString:_Module_RecordCapture]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"RecordCapture" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_Test
    if ([topicName isEqualToString:_Module_Test]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Test" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_VideoTalk
    if ([topicName isEqualToString:_Module_VideoTalk]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"VideoTalk" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_RoomMessage
    if ([topicName isEqualToString:_Module_RoomMessage]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"RoomMessage" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif

    #ifdef _Module_Mixer
    if ([topicName isEqualToString:_Module_Mixer]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Mixer" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_AudioMixing
    if ([topicName isEqualToString:_Module_AudioMixing]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"AudioMixing" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_SoundLevel
    if ([topicName isEqualToString:_Module_SoundLevel]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"SoundLevel" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_Beautify
    if ([topicName isEqualToString:_Module_Beautify]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Beautify" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_MediaPlayer
    if ([topicName isEqualToString:_Module_MediaPlayer]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"MediaPlayer" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_MediaSideInfo
    if ([topicName isEqualToString:_Module_MediaSideInfo]) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"MediaSideInfo" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_ScalableVideoCoding
    if ([topicName isEqualToString:_Module_ScalableVideoCoding]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"SVC" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_MediaRecord
    if ([topicName isEqualToString:_Module_MediaRecord]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MediaRecord" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_CustomVideoCapture
    if ([topicName isEqualToString:_Module_CustomVideoCapture]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomVideoCapture" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_CustomVideoRender
    if ([topicName isEqualToString:_Module_CustomVideoRender]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomVideoRender" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif

    #ifdef _Module_CustomAudioIO
    if ([topicName isEqualToString:_Module_CustomAudioIO]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"CustomAudioIO" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_AuxPublisher
    if ([topicName isEqualToString:_Module_AuxPublisher]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"AuxPublisher" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_ExternalVideoFilter
    if ([topicName isEqualToString:_Module_ExternalVideoFilter]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ExternalVideoFilter" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    #ifdef _Module_AudioEffect
    if ([topicName isEqualToString:_Module_AudioEffect]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"AudioEffect" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    #endif
    
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - Access

- (void)setTopicList:(NSArray<NSArray<NSString*>*>*)topics {
    _topicList = topics;
    [self.tableView reloadData];
}


@end

//
//  ZGVideoForMultipleUsersPopupView.m
//  ZegoExpressExample-iOS-OC
//
//  Created by joey on 2021/4/21.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZGMultipleRoomPopupView.h"

@interface ZGMultipleRoomPopupView ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSArray<NSString *>* textList;
@end

@implementation ZGMultipleRoomPopupView

- (void)awakeFromNib {
    [super awakeFromNib];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"myCell"];

    _tableView.delegate = self;
    _tableView.dataSource = self;
}

+ (ZGMultipleRoomPopupView*)show {
    ZGMultipleRoomPopupView* popupView = [[[NSBundle mainBundle] loadNibNamed:@"ZGVideoForMultipleUsersPopupView" owner:self options:nil] objectAtIndex:0];
    popupView.frame = UIScreen.mainScreen.bounds;
    popupView.alpha = 0;
    popupView.userInteractionEnabled = NO;
    [[ZGWindowHelper keyWindow] addSubview:popupView];
    [UIView animateWithDuration:0.5 animations:^{
        popupView.alpha = 1;
    } completion:^(BOOL finished) {
        popupView.userInteractionEnabled = YES;
    }];
    return popupView;
}

- (void)updateWithTitle:(NSString *)title textList:(NSArray<NSString *> *)textList {
    self.titleLabel.text = title;
    self.textList = textList;
    [self.tableView reloadData];
}

- (IBAction)onCloseButtonTapped:(id)sender {
    self.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // 实例化一个UITableViewCell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell" forIndexPath:indexPath];
    cell.textLabel.text = self.textList[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:11];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.textList.count;
}



@end

//
//  WatchLiveLotteryTableViewCell.m
//  VHallSDKDemo
//
//  Created by Ming on 16/10/14.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveLotteryTableViewCell.h"

@implementation WatchLiveLotteryTableViewCell
{
    __weak IBOutlet UILabel *lblShow;
}

- (id)init {
    self = [[meetingResourcesBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    lblShow.text = _model.nick_name;
}

@end

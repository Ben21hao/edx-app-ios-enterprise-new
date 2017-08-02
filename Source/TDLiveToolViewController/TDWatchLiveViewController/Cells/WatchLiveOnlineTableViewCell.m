//
//  WatchLiveOnlineTableViewCell.m
//  VHallSDKDemo
//
//  Created by Ming on 16/8/25.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveOnlineTableViewCell.h"
#import "edX-Swift.h"

@implementation WatchLiveOnlineTableViewCell
{
    __weak IBOutlet UILabel *lblShow;
    __weak IBOutlet UILabel *lblState;
    
    NSString* userName;
    NSString* room;
    NSString* event;
    NSString* time;
    NSString* role;
    NSString* concurrent_user;
    NSString* attend_count;
}

- (id)init {
    self = [[meetingResourcesBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    if (self) {
    }
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    userName        = @"";
    room            = @"";
    event           = @"";
    time            = @"";
    role            = @"";
    concurrent_user = @"";
    attend_count    = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    userName = _model.user_name;
    room = _model.room;
    time = _model.time;
    concurrent_user = _model.concurrent_user;
    attend_count = _model.attend_count;
    
    if([_model.event isEqualToString:@"online"]) {
        event = NSLocalizedString(@"ENTER_TEXT", nil);
    }else if([_model.event isEqualToString:@"offline"]){
        event = NSLocalizedString(@"LEAVE_TEXT", nil);
    }
    
    if([_model.role isEqualToString:@"host"]) {
        role = NSLocalizedString(@"HOST_TEXT", nil);
    }else if([_model.role isEqualToString:@"guest"]) {
        role = NSLocalizedString(@"GUEST_TEXT", nil);
    }else if([_model.role isEqualToString:@"assistant"]) {
        role = NSLocalizedString(@"ASSISTANT_TEXT", nil);
    }else if([_model.role isEqualToString:@"user"]) {
        role = NSLocalizedString(@"VIEWER_TEXT", nil);
    }

    lblShow.text = [NSString stringWithFormat:@"%@[%@] %@%@%@", userName, role, event, NSLocalizedString(@"ROOM_TEXT", nil),room];
    lblState.text = [Strings onlineCountTextWithCount:concurrent_user number:attend_count time:time];
}

@end

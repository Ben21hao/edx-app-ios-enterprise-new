//
//  WatchLiveQATableViewCell.m
//  VHallSDKDemo
//
//  Created by Ming on 16/8/25.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveQATableViewCell.h"
#import "UIImageView+WebCache.h"
#import "VHallApi.h"

@implementation WatchLiveQATableViewCell {
  
    __weak IBOutlet UIButton *lblType;
    __weak IBOutlet UILabel *lblNickName;
    __weak IBOutlet UILabel *lblTime;
    __weak IBOutlet UILabel *lblContent;
    __weak IBOutlet UIImageView *headImage;
//    __weak IBOutlet UILabel *lblQuestionID;
//    __weak IBOutlet UILabel *lblJoinID;
//    __weak IBOutlet UILabel *lblRole;
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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    lblNickName.text   = [NSString stringWithFormat:@"%@:", _model.nick_name];
    lblTime.text       = _model.created_at;
    lblContent.text    = [NSString stringWithFormat:@"%@\n\n\n", _model.content];
    
   // lblJoinID.text     = [NSString stringWithFormat:@"参会 ID:%@",_model.join_id];
    if ([_model.type isEqualToString:@"question"])
    {
     //   lblRole.text = @"[--]";
//        lblQuestionID.text = [NSString stringWithFormat:@"问题 ID:%@", _model.question_id];
        [lblType setTitle:NSLocalizedString(@"ASK_TEXT", nil) forState:UIControlStateNormal];
        lblType.layer.borderColor=[UIColor redColor].CGColor;
        [lblType setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
         [headImage sd_setImageWithURL:[NSURL URLWithString:[VHallApi currentUserHeadUrl]] placeholderImage:[UIImage imageNamed:@"UIModel.bundle/head50"]];
    }
    else if ([_model.type isEqualToString:@"answer"])
    {
        [lblType setTitle:NSLocalizedString(@"ANSWER_TEXT", nil) forState:UIControlStateNormal];
        lblType.layer.borderColor=[UIColor blueColor].CGColor;
        [lblType setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        VHallAnswerModel* answer = (VHallAnswerModel *)_model;
        NSString* role = @"";
        if([answer.role_name isEqualToString:@"host"]) {
            role = NSLocalizedString(@"HOST_TEXT", nil);
        }else if([answer.role_name isEqualToString:@"guest"]) {
            role = NSLocalizedString(@"GUEST_TEXT", nil);
        }else if([answer.role_name isEqualToString:@"assistant"]) {
            role = NSLocalizedString(@"ASSISTANT_TEXT", nil);
        }else if([answer.role_name isEqualToString:@"user"]) {
            role = NSLocalizedString(@"VIEWER_TEXT", nil);
        }
      [headImage sd_setImageWithURL:[NSURL URLWithString:answer.avatar] placeholderImage:[UIImage imageNamed:@"UIModel.bundle/head50"]];
      //  lblRole.text = [NSString stringWithFormat:@"[%@]", role];
     //   lblQuestionID.text = [NSString stringWithFormat:@"问题 ID:%@  回答 ID:%@ 【%@】", _model.question_id, answer.answer_id,answer.is_open?@"公开":@"私密"];
    }
    
    [self layoutIfNeeded];
}

@end

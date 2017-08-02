//
//  WatchLiveChatTableViewCell.m
//  VHallSDKDemo
//
//  Created by Ming on 16/8/25.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveChatTableViewCell.h"
#import "MLEmojiLabel.h"
#import "UIImageView+WebCache.h"

@implementation WatchLiveChatTableViewCell {
    
    __weak IBOutlet UIImageView *pic;
    __weak IBOutlet UILabel *lblNickName;
    __weak IBOutlet UILabel *lblTime;
    __weak IBOutlet UILabel *lblContext;
    
    MLEmojiLabel *_textLabel;
}

- (id)init {
    self = [[meetingResourcesBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self layoutIfNeeded];
    
    if(!_textLabel) {
        _textLabel = [MLEmojiLabel new];
        _textLabel.numberOfLines = 0;
        
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _textLabel.isNeedAtAndPoundSign = YES;
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        _textLabel.customEmojiPlistName = @"faceExpression.plist";
        _textLabel.customEmojiBundleName = @"UIModel.bundle";
        _textLabel.userInteractionEnabled = NO;
        _textLabel.disableThreeCommon = YES;
//        _textLabel.frame = lblContext.frame;
        [self.contentView addSubview:_textLabel];
        
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(lblTime.mas_left);
            make.top.mas_equalTo(lblTime.mas_bottom).offset(8);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-8);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-5);
        }];
        
        lblContext.hidden = YES;
    }
}

- (void)layoutSubviews {
    
    [pic sd_setImageWithURL:[NSURL URLWithString:_model.avatar] placeholderImage:[UIImage imageNamed:@"UIModel.bundle/head50"]];
    
    lblNickName.text = _model.user_name;
    lblTime.text = _model.time;
    //内容
    [_textLabel setText:_model.text];
    [_textLabel sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

//
//  WatchLiveChatCell.m
//  edX
//
//  Created by Ben on 2017/7/13.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "WatchLiveChatCell.h"
#import "MLEmojiLabel.h"
#import "UIImageView+WebCache.h"

@interface WatchLiveChatCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIImageView *headImageView;
@property (nonatomic,strong) UILabel *lblNickName;
@property (nonatomic,strong) UILabel *lblTime;
@property (nonatomic,strong) MLEmojiLabel *contentLabel;


@end

@implementation WatchLiveChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)setModel:(VHallChatModel *)model {
    _model = model;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"UIModel.bundle/head50"]];
    
    self.lblNickName.text = model.user_name;
    self.lblTime.text = model.time;
    
    [self.contentLabel setText:model.text];
    [self.contentLabel sizeToFit];
}

#pragma mark - UI
- (void)configView {
    
    self.bgView = [[UIView alloc] init];
    [self.contentView addSubview:self.bgView];
    
    self.headImageView = [[UIImageView alloc] init];
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = 20.0;
    self.headImageView.contentMode = UIViewContentModeScaleToFill;
    [self.bgView addSubview:self.headImageView];
    
    self.lblNickName = [self setLabelStyle:colorHexStr10 font:16];
    [self.bgView addSubview:self.lblNickName];
    
    self.lblTime = [self setLabelStyle:colorHexStr9 font:10];
    [self.bgView addSubview:self.lblTime];
    
    self.contentLabel = [MLEmojiLabel new];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.backgroundColor = [UIColor clearColor];
    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.contentLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.contentLabel.userInteractionEnabled = NO;
    
//    self.contentLabel.isNeedAtAndPoundSign = YES;//是否需要话题和@功能，默认为不需要
    self.contentLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"; //自定义表情正则
    self.contentLabel.customEmojiPlistName = @"faceExpression.plist";//xxxxx.plist 格式
    self.contentLabel.customEmojiBundleName = @"UIModel.bundle"; //自定义表情图片所存储的bundleName xxxx.bundle格式
    self.contentLabel.disableThreeCommon = YES;
    
    [self.bgView addSubview:self.contentLabel];
}

- (void)setViewConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(8);
        make.top.mas_equalTo(self.contentView.mas_top).offset(8);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.lblNickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImageView.mas_right).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.top.mas_equalTo(self.bgView).offset(0);
        make.height.mas_equalTo(28);
    }];
    
    [self.lblTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImageView.mas_right).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.top.mas_equalTo(self.lblNickName.mas_bottom).offset(0);
        make.height.mas_equalTo(18);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImageView.mas_right).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.top.mas_equalTo(self.lblTime.mas_bottom).offset(0);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-5);
    }];
}

- (UILabel *)setLabelStyle:(NSString *)colorStr font:(NSInteger)font {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"OpenSans" size:font];
    label.textColor = [UIColor colorWithHexString:colorStr];
    return label;
}

@end
//
//  TDPublishTimeCell.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDPublishTimeCell.h"
#import <UIImageView+WebCache.h>

#import "NSString+OEXFormatting.h"

@interface TDPublishTimeCell ()

@property (nonatomic,strong) UILabel *line;

@end

@implementation TDPublishTimeCell

- (void)setQuetionModel:(TDQuetionDetailModel *)quetionModel {
    _quetionModel = quetionModel;
    
    self.nameLabel.text = self.quetionModel.create_user_info.create_show_username;
    self.timeLabel.text = self.quetionModel.create_user_info.create_time;
    [self.headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ELITEU_URL,self.quetionModel.create_user_info.create_pic]] placeholderImage:[UIImage imageNamed:@"default_big"]];
}

- (void)setReplyModel:(TDQuetionReplyInfoModel *)replyModel {
    _replyModel = replyModel;
    
    NSString *str = [self.replyModel.continue_to_ask boolValue] ? [TDLocalizeSelect(@"CONSULTATION_FURTHER_QUESTION", nil) oex_formatWithParameters:@{@"name" : self.replyModel.reply_show_name}] : [TDLocalizeSelect(@"CONSULTATION_REPLIED", nil) oex_formatWithParameters:@{@"name" : self.replyModel.reply_show_name}];
    
    self.nameLabel.text = str;
    self.timeLabel.text = self.replyModel.reply_at;
    [self.headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ELITEU_URL,self.replyModel.reply_by_pic]] placeholderImage:[UIImage imageNamed:@"default_big"]];
    
}

- (void)configView {
    
    self.headerImage = [[TDRoundHeadImageView alloc] initWithSize:CGSizeMake(30, 30) borderColor:colorHexStr5];
    [self.bgView addSubview:self.headerImage];
    
    self.nameLabel = [self setLabelStyle:14 color:colorHexStr9];
    [self.bgView addSubview:self.nameLabel];
    
    self.timeLabel = [self setLabelStyle:14 color:colorHexStr8];
    [self.bgView addSubview:self.timeLabel];
    
    self.line = [[UILabel alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    [self.bgView addSubview:self.line];
    
    self.headerImage.image = [UIImage imageNamed:@"default_big"];
}

- (void)setViewConstraint {
    
    [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImage.mas_right).offset(5);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.bgView);
        make.height.mas_equalTo(0.5);
    }];
}

@end

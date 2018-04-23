//
//  TDQuentionMessageCell.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDQuentionMessageCell.h"
#import "TDRoundHeadImageView.h"

#import <UIImageView+WebCache.h>
#import "NSString+OEXFormatting.h"

@implementation TDQuentionMessageCell

- (void)setModel:(TDMyQuetionModel *)model {
    _model = model;
    
    [self setViewConstraint:model];
}

- (void)configView {
    
    self.headerImage = [[TDRoundHeadImageView alloc] initWithSize:CGSizeMake(22, 22) borderColor:colorHexStr5];
    [self.bgView addSubview:self.headerImage];
    
    self.nameLabel = [self setLabelStyle:10 color:colorHexStr9];
    [self.bgView addSubview:self.nameLabel];
    
    self.postTimeLabel = [self setLabelStyle:10 color:colorHexStr8];
    [self.bgView addSubview:self.postTimeLabel];
    
    self.quetionLabel = [self setLabelStyle:14 color:colorHexStr10];
    [self.bgView addSubview:self.quetionLabel];
    
    self.line = [[UILabel alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    [self.bgView addSubview:self.line];
    
    self.statusLabel = [self setLabelStyle:12 color:colorHexStr2];
    [self.bgView addSubview:self.statusLabel];
    
    self.timeLabel = [self setLabelStyle:10 color:colorHexStr8];
    [self.bgView addSubview:self.timeLabel];
    
    self.headerView = [[UIView alloc] init];
    [self.bgView addSubview:self.headerView];
    
    
    self.headerImage.image = [UIImage imageNamed:@"default_big"];
}

- (void)setViewConstraint:(TDMyQuetionModel *)model {
    
    if ([model.is_company_reveiver boolValue]) {
        
        [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bgView.mas_left).offset(13);
            make.top.mas_equalTo(self.bgView.mas_top).offset(8);
            make.size.mas_equalTo(CGSizeMake(22, 22));
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.headerImage.mas_right).offset(5);
            make.centerY.mas_equalTo(self.headerImage.mas_centerY);
        }];
        
        [self.postTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
            make.centerY.mas_equalTo(self.headerImage.mas_centerY);
        }];
        
        self.nameLabel.text = model.create_user_info.create_show_username;
        self.postTimeLabel.text = model.create_user_info.create_time;
        [self.headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ELITEU_URL,model.create_user_info.create_pic]] placeholderImage:[UIImage imageNamed:@"default_big"]];
    }

    [self.quetionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.height.mas_equalTo(48);
        if ([model.is_company_reveiver boolValue]) {
            make.top.mas_equalTo(self.headerImage.mas_bottom);
        } else {
            make.top.mas_equalTo(self.bgView.mas_top);
        }
        
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.quetionLabel.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.top.mas_equalTo(self.line.mas_bottom);
        make.bottom.mas_equalTo(self.bgView);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.statusLabel.mas_right).offset(8);
        make.top.mas_equalTo(self.line.mas_bottom);
        make.bottom.mas_equalTo(self.bgView);
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.top.mas_equalTo(self.line.mas_bottom);
        make.bottom.mas_equalTo(self.bgView);
        make.width.mas_equalTo(158);
    }];
    
    
    //数据
    self.quetionLabel.text = model.title;
    
    if ([model.reply_info.is_not_readed_length intValue] <= 0) {
        if ([model.reply_info.all_reply_length intValue] <= 0) {
            [self setConsultMessage:TDLocalizeSelect(@"NO_REPLY_TEXT", nil) wihtColorStr:colorHexStr2];
            return;
            
        } else {
            [self setConsultMessage:[TDLocalizeSelect(@"MESSAGE_COUNT_TEXT", nil) oex_formatWithParameters:@{@"count": model.reply_info.all_reply_length}] wihtColorStr:colorHexStr8];
        }
        
    } else {
        [self setConsultMessage:[TDLocalizeSelect(@"UNREAD_MESSAGE_COUNT_TEXT", nil) oex_formatWithParameters:@{@"count": model.reply_info.is_not_readed_length}] wihtColorStr:colorHexStr2];
    }
    
    if (model.reply_info.reply_user_pic.count > 0) {
        [self setReplyImageView:model.reply_info.reply_user_pic];
    }
    
    self.timeLabel.text = model.reply_info.reply_last_time;
}

- (void)setConsultMessage:(NSString *)statusStr wihtColorStr:(NSString *)colorStr {
    
    self.statusLabel.text = statusStr;
    self.statusLabel.textColor = [UIColor colorWithHexString:colorStr];
}

- (void)setReplyImageView:(NSArray *)imageArray {
    
    for (int i = 0; i < imageArray.count; i ++) {
        TDRoundHeadImageView *headerImage = [[TDRoundHeadImageView alloc] initWithSize:CGSizeMake(16, 16) borderColor:colorHexStr5];
        [headerImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ELITEU_URL,imageArray[i]]] placeholderImage:[UIImage imageNamed:@"@imageArray"]];
        [self.headerView addSubview:headerImage];
        
        [headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.headerView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(16, 16));
            make.right.mas_equalTo(self.headerView.mas_right).offset(- (16 + 6) * i);
        }];
    }
}

- (void)setViewConstraint {
    
}

@end

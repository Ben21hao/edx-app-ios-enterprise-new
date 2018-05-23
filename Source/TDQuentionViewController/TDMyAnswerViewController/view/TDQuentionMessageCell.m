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

@interface TDQuentionMessageCell ()

@property (nonatomic,strong) TDBaseToolModel *toolModel;

@end

@implementation TDQuentionMessageCell

- (void)setModel:(TDMyAnswerModel *)model {
    _model = model;
    
    self.nameLabel.text = model.created_by;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",ELITEU_URL,model.created_by_pic];
    [self.headerImage sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"default_big"]];
    
    self.postTimeLabel.text = [self.toolModel changeStypeForTime:model.created_at];
    
    switch ([model.content_type intValue]) {
        case 1:
            self.quetionLabel.text = model.content;
            break;
        case 2:
            self.quetionLabel.text = TDLocalizeSelect(@"AUDIO_CONTENT", nil);
            break;
        case 3:
            self.quetionLabel.text = TDLocalizeSelect(@"PHOTO_CONTENT", nil);
            break;
        case 4:
            self.quetionLabel.text = TDLocalizeSelect(@"VIDEO_CONTENT", nil);
            break;
            
        default:
            break;
    }
    
    switch ([model.status.consult_status intValue]) {
        case 1: //待回复 -- ① 还没有人领取的问题② 别人放弃回答的问题
//            break;
        case 2: //待回复 -- 我点击了“马上回答”
            self.statusLabel.text = TDLocalizeSelect(@"UNANSWERED_TEXT", nil);
            self.statusLabel.textColor = [UIColor colorWithHexString:colorHexStr1];
            break;
        case 3://待回复(追问) -- 已经回答过，用户追问之后，领取人放弃回答。
//            break;
        case 4://待回复(追问) -- 我已回答，用户发起追问
            self.statusLabel.text = TDLocalizeSelect(@"FOLLOW_UP_TEXT", nil);
            self.statusLabel.textColor = [UIColor colorWithHexString:colorHexStr1];
            break;
        case 5: //xxx 正在回复 -- 已经有别人点击了“马上回答”
//            break;
        case 6://xxx 正在回复 -- 问题已经被回答，用户发起追问
        self.statusLabel.text = [TDLocalizeSelect(@"ANSWERING_TEXT", nil) oex_formatWithParameters:@{@"name":model.status.claim_by}];
            break;
        case 7: //已回复 -- 我已经回复了问题或者追问
            self.statusLabel.text = TDLocalizeSelect(@"ANSWERED_TEXT", nil);
            [self showReplyTime:model.status.time];
            break;
        case 8: //xxx 已回复--- 别人已经回复了问题或者追问
            self.statusLabel.text = [TDLocalizeSelect(@"ANSWERED_BY", nil) oex_formatWithParameters:@{@"name":model.status.claim_by}];
            [self showReplyTime:model.status.time];
            break;
        case 9: //已解决 -- 用户点击“已解决”，确认解决问题
            self.statusLabel.text = TDLocalizeSelect(@"CONSULTATION_RESOLVED", nil);
            [self showReplyTime:model.updated_at];
            break;
        case 10://xxx 已解决 -- 用户点击“已解决”，确认解决问题
            self.statusLabel.text = [TDLocalizeSelect(@"SOLEVED_BY", nil) oex_formatWithParameters:@{@"name":model.status.claim_by}];
            [self showReplyTime:model.updated_at];
            break;
        case 11: //用户放弃提问--问题未被回答，但是用户点击了“已解决”
            self.statusLabel.text = TDLocalizeSelect(@"CONSULTATION_RESOLVED", nil);//用户放弃提问
            [self showReplyTime:model.updated_at];
            break;
        default:
            break;
    }
}

- (void)showReplyTime:(NSString *)timeStr {
    
    self.timeLabel.hidden = NO;
    self.timeLabel.text = [self.toolModel changeStypeForTime:timeStr];
}

#pragma mark - UI
- (void)configView {
    
    self.toolModel = [[TDBaseToolModel alloc] init];
    
    self.headerImage = [[TDRoundHeadImageView alloc] initWithSize:CGSizeMake(38, 38) borderColor:colorHexStr5];
    [self.bgView addSubview:self.headerImage];
    
    self.nameLabel = [self setLabelStyle:12 color:colorHexStr8];
    [self.bgView addSubview:self.nameLabel];
    
    self.postTimeLabel = [self setLabelStyle:12 color:colorHexStr8];
    [self.bgView addSubview:self.postTimeLabel];
    
    self.quetionLabel = [self setLabelStyle:14 color:@"#000000"];
    [self.bgView addSubview:self.quetionLabel];
    
    self.line = [[UILabel alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self.bgView addSubview:self.line];
    
    self.statusLabel = [self setLabelStyle:12 color:colorHexStr9];
    [self.bgView addSubview:self.statusLabel];
    
    self.timeLabel = [self setLabelStyle:10 color:colorHexStr9];
    [self.bgView addSubview:self.timeLabel];
    
    self.timeLabel.hidden = YES;
}


- (void)setViewConstraint {
    
    [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.top.mas_equalTo(self.bgView.mas_top).offset(13);
        make.size.mas_equalTo(CGSizeMake(38, 38));
    }];
    
    [self.postTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.width.mas_equalTo(98);
        make.bottom.mas_equalTo(self.headerImage.mas_centerY).offset(-5);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImage.mas_right).offset(8);
        make.right.mas_equalTo(self.postTimeLabel.mas_left).offset(-8);
        make.bottom.mas_equalTo(self.headerImage.mas_centerY).offset(-3);
    }];
    
    [self.quetionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImage.mas_right).offset(8);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.top.mas_equalTo(self.headerImage.mas_centerY);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.headerImage.mas_bottom).offset(13);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.top.mas_equalTo(self.line.mas_bottom);
        make.bottom.mas_equalTo(self.bgView);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.centerY.mas_equalTo(self.statusLabel.mas_centerY);
    }];
}



@end

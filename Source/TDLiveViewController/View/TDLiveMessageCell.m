//
//  TDLiveMessageCell.m
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDLiveMessageCell.h"
#import <UIImageView+WebCache.h>
#import "edX-Swift.h"

@interface TDLiveMessageCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIView *messageView;
@property (nonatomic,strong) UIImageView *courseImage;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *teacherLabel;
@property (nonatomic,strong) UILabel *introduceLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *durationLabel;

@property (nonatomic,strong) TDBaseToolModel *toolModel;

@end

@implementation TDLiveMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.toolModel = [[TDBaseToolModel alloc] init];
        [self configView];
        [self setViewConstraint];
    }
    return self ;
}

- (void)setWhereFrom:(NSInteger)whereFrom {
    _whereFrom = whereFrom;
    self.durationLabel.hidden = whereFrom == 0;
}

- (void)setModel:(TDLiveModel *)model {
    _model = model;
    
    [self setDataForView:model];
}

- (void)setDataForView:(TDLiveModel *)model {
    
    self.titleLabel.text = model.livename;
    self.teacherLabel.text = [NSString stringWithFormat:@"%@%@",TDLocalizeSelect(@"LECTURER_TEXT", nil),model.anchor];
    if (model.live_introduction.length > 0) {
        self.introduceLabel.text = [NSString stringWithFormat:@"%@%@",TDLocalizeSelect(@"DISCRITE_TEXT", nil),model.live_introduction];
    }
    
    int count = [model.time intValue];
    
    int hour = count / (60 * 60);
    int muniteNum = count % (60 * 60);
    int munite = muniteNum / 60;
    int second = count % 60;
    
    NSString *hourStr = @"00";
    if (hour > 0) {
        hourStr = hour < 10 ? [NSString stringWithFormat:@"0%d",hour]: [NSString stringWithFormat:@"%d",hour];
    }
    NSString *muniteStr = @"00";
    if (munite > 0) {
        muniteStr = munite< 10 ? [NSString stringWithFormat:@"0%d",munite]: [NSString stringWithFormat:@"%d",munite];
    }
    
    NSString *secondStr = @"00";
    if (second > 0) {
        secondStr = second < 10 ? [NSString stringWithFormat:@"0%d",second] :[NSString stringWithFormat:@"%d",second];
    }
    
    self.durationLabel.text = [NSString stringWithFormat:@"%@%@",TDLocalizeSelect(@"DUIRATION_TEXT", nil),[TDLocalizeSelect(@"SECOND_COUNT_NUM", nil) oex_formatWithParameters:@{@"hour" : hourStr, @"min" : muniteStr, @"second" : secondStr}]];
    
    //TODO: 对时间进行处理
    //2017-07-06T15:00:00Z
    NSString *timeStr = [self.toolModel changeStypeForTime:model.live_start_at];
    self.timeLabel.text = [NSString stringWithFormat:@"%@%@",TDLocalizeSelect(@"START_TIME_TEXT", nil),timeStr];
    
    //处理图片链接中的中文和空格
    NSString *imageStr = [self.toolModel dealwithImageStr:[NSString stringWithFormat:@"%@%@",ELITEU_URL,model.cover_url]];
    [self.courseImage sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"Group_Live"]];
}

#pragma mark - UI
- (void)configView {
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr13];
    [self.contentView addSubview:self.bgView];
    
    self.titleLabel = [self setLabelStyle:colorHexStr10 font:16];
    [self.bgView addSubview:self.titleLabel];
    
    self.messageView = [[UIView alloc] init];
    self.messageView.backgroundColor = [UIColor colorWithHexString:@"#eef8fd"];
    [self.bgView addSubview:self.messageView];
    
    self.courseImage = [[UIImageView alloc] init];
    self.courseImage.layer.masksToBounds = YES;
    self.courseImage.layer.cornerRadius = 4.0;
    self.courseImage.image = [UIImage imageNamed:@"Group_Live"];
    [self.messageView addSubview:self.courseImage];
    
    self.teacherLabel = [self setLabelStyle:colorHexStr9 font:14];
    [self.messageView addSubview:self.teacherLabel];
    
    self.introduceLabel = [self setLabelStyle:colorHexStr8 font:14];
    [self.messageView addSubview:self.introduceLabel];
    
    self.timeLabel = [self setLabelStyle:colorHexStr9 font:TDWidth == 320 ? 12 : 14];
    [self.bgView addSubview:self.timeLabel];
    
    self.durationLabel = [self setLabelStyle:colorHexStr9 font:TDWidth == 320 ? 12 : 14];
    self.durationLabel.textAlignment = NSTextAlignmentRight;
    [self.bgView addSubview:self.durationLabel];
}

- (void)setViewConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(8);
        make.top.mas_equalTo(self.bgView.mas_top).offset(8);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-3);
        make.height.mas_equalTo(22);
    }];
    
    [self.messageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
        make.height.mas_equalTo(TDWidth * 0.33 + 24);
    }];
    
    [self.courseImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.messageView.mas_left).offset(13);
        make.centerY.mas_equalTo(self.messageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(TDWidth * 0.33, TDWidth * 0.33));
    }];
    
    [self.teacherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.courseImage.mas_right).offset(18);
        make.top.mas_equalTo(self.courseImage.mas_top);
        make.height.mas_equalTo(22);
    }];
    
    [self.introduceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.courseImage.mas_right).offset(18);
        make.top.mas_equalTo(self.teacherLabel.mas_bottom).offset(0);
        make.right.mas_equalTo(self.messageView.mas_right).offset(-8);
        make.bottom.mas_equalTo(self.messageView.mas_bottom).offset(-3);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.top.mas_equalTo(self.messageView.mas_bottom).offset(6);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-6);
    }];
    
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.top.mas_equalTo(self.messageView.mas_bottom).offset(6);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-6);
//        make.width.mas_equalTo((TDWidth - 28) / 2);
        make.left.mas_equalTo(self.timeLabel.mas_right).offset(3);
    }];
}

- (UILabel *)setLabelStyle:(NSString *)colorStr font:(NSInteger)font {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"OpenSans" size:font];
    label.textColor = [UIColor colorWithHexString:colorStr];
    label.numberOfLines = 0;
    return label;
}

@end


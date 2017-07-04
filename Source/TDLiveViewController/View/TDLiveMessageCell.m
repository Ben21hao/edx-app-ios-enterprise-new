//
//  TDLiveMessageCell.m
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDLiveMessageCell.h"
#import <UIImageView+WebCache.h>

@interface TDLiveMessageCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIView *messageView;
@property (nonatomic,strong) UIImageView *courseImage;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *teacherLabel;
@property (nonatomic,strong) UILabel *introduceLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *durationLabel;

@end

@implementation TDLiveMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self ;
}

- (void)setWhereFrom:(NSInteger)whereFrom {
    _whereFrom = whereFrom;
    self.durationLabel.hidden = self.whereFrom == 0;
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
    
    self.timeLabel = [self setLabelStyle:colorHexStr9 font:14];
    [self.bgView addSubview:self.timeLabel];
    
    self.durationLabel = [self setLabelStyle:colorHexStr9 font:14];
    self.durationLabel.textAlignment = NSTextAlignmentRight;
    [self.bgView addSubview:self.durationLabel];
    
    self.titleLabel.text = @"大数据时代下的信息技术";
    self.teacherLabel.text = [NSString stringWithFormat:@"%@哈哈哈老师",NSLocalizedString(@"LECTURER_TEXT", nil)];
    self.timeLabel.text = [NSString stringWithFormat:@"%@2017-07-03 18:18",NSLocalizedString(@"START_TIME_TEXT", nil)];
    self.durationLabel.text = [NSString stringWithFormat:@"%@02:30:55",NSLocalizedString(@"DUIRATION_TEXT", nil)];
    self.introduceLabel.text = [NSString stringWithFormat:@"%@啊哈哈哈哈哈哈哈哈卡上的咖啡好伐啦好地方拉法基哈伦裤放假阿斯顿啊哈哈哈哈哈哈哈哈卡上的咖啡好伐啦好地方拉法基哈伦裤放假阿斯顿啊哈哈哈哈哈哈哈哈卡上的咖啡好伐啦好地方拉法基哈伦裤放假阿",NSLocalizedString(@"DISCRITE_TEXT", nil)];
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(8);
        make.top.mas_equalTo(self.bgView.mas_top).offset(8);
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
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.top.mas_equalTo(self.messageView.mas_bottom).offset(6);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-6);
        make.width.mas_equalTo(103);
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


//
//  TDNewWaitfoPayCell.m
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDNewWaitfoPayCell.h"
#import <UIImageView+WebCache.h>

@interface TDNewWaitfoPayCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIImageView *courseImage;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *userNameLabel;
@property (nonatomic,strong) UILabel *moneyLabel;
@property (nonatomic,strong) UILabel *originalLabel;

@end

@implementation TDNewWaitfoPayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self config];
        [self setConstraint];
    }
    return self;
}

- (void)config {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    self.courseImage = [[UIImageView alloc] init];
    self.courseImage.image = [UIImage imageNamed:@"course_backGroud"];
    self.courseImage.layer.masksToBounds = YES;
    self.courseImage.layer.cornerRadius = 4.0;
    [self.bgView addSubview:self.courseImage];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.bgView addSubview:self.titleLabel];
    
    self.userNameLabel = [[UILabel alloc] init];
    self.userNameLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.userNameLabel.font = [UIFont systemFontOfSize:12];
    [self.bgView addSubview:self.userNameLabel];
    
    self.moneyLabel = [[UILabel alloc] init];
    self.moneyLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.moneyLabel.font = [UIFont systemFontOfSize:16];
    [self.bgView addSubview:self.moneyLabel];
    
    self.originalLabel = [[UILabel alloc] init];
    self.originalLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    self.originalLabel.font = [UIFont systemFontOfSize:12];
    [self.bgView addSubview:self.originalLabel];
    
    TDBaseToolModel *baseTool = [[TDBaseToolModel alloc] init];
    self.moneyLabel.attributedText = [baseTool setString:@"￥0.00" withFont:16  type:1];
    self.originalLabel.attributedText = [baseTool setString:@"￥0.00" withFont:12  type:2];
    
}

- (void)setConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.courseImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.centerY.mas_equalTo(self.bgView);
        make.size.mas_equalTo(CGSizeMake(140, 78));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.courseImage.mas_right).offset(8);
        make.top.mas_equalTo(self.courseImage.mas_top).offset(3);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
    }];
    
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.courseImage.mas_right).offset(8);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(3);
    }];
    
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.courseImage.mas_right).offset(8);
        make.bottom.mas_equalTo(self.courseImage.mas_bottom).offset(-3);
    }];
    
    [self.originalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.moneyLabel.mas_right).offset(3);
        make.centerY.mas_equalTo(self.moneyLabel);
    }];
    
}

#pragma mark - 数据
- (void)setModel:(TDWaitfoPayOrderModel *)model {
    _model = model;
    [self showData];
}

- (void)showData {
    
    NSString *string1 = [NSString stringWithFormat:@"%@%@",ELITEU_URL,self.model.image];
    NSString* string2 = [string1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.courseImage sd_setImageWithURL:[NSURL URLWithString:string2] placeholderImage:[UIImage imageNamed:@"course_backGroud"]];
    
    TDBaseToolModel *baseTool = [[TDBaseToolModel alloc] init];
    
    self.titleLabel.text = self.model.display_name;
    self.userNameLabel.text = self.model.teacher_name;
    self.moneyLabel.attributedText = [baseTool setString:[NSString stringWithFormat:@"￥%.2f",[self.model.min_price floatValue]] withFont:16  type:1];
    self.originalLabel.attributedText = [baseTool setString:[NSString stringWithFormat:@"￥%.2f",[self.model.price floatValue]] withFont:12 type:2];
}

@end



//
//  TDQuetionUserCell.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDQuetionUserCell.h"
#import "TDRoundHeadImageView.h"

@interface TDQuetionUserCell ()

@property (nonatomic,strong) TDRoundHeadImageView *headerImage;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *timeLabel;

@end

@implementation TDQuetionUserCell

- (void)configView {
    
    self.headerImage = [[TDRoundHeadImageView alloc] initWithSize:CGSizeMake(22, 22) borderColor:colorHexStr5];
    [self.bgView addSubview:self.headerImage];
    
    self.nameLabel = [self setLabelStyle:10 color:colorHexStr9];
    [self.bgView addSubview:self.nameLabel];
    
    self.timeLabel = [self setLabelStyle:10 color:colorHexStr8];
    [self.bgView addSubview:self.timeLabel];
    
    self.headerImage.image = [UIImage imageNamed:@"default_big"];
    self.nameLabel.text = @"张小娴";
    self.timeLabel.text = @"2017-05-19 12:34";
}

- (void)setViewConstraint {
    
    [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.bottom.mas_equalTo(self.bgView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImage.mas_right).offset(5);
        make.centerY.mas_equalTo(self.headerImage.mas_centerY);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.centerY.mas_equalTo(self.headerImage.mas_centerY);
    }];
}

@end

//
//  TDPayTypeView.m
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDPayTypeView.h"

@interface TDPayTypeView ()

@property (nonatomic,strong) UIView *bgView;

@end

@implementation TDPayTypeView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - UI
- (void)configView {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    self.headerImage = [[UIImageView alloc] init];
    self.headerImage.image = [UIImage imageNamed:@"zhifu"];
    self.headerImage.layer.masksToBounds = YES;
    self.headerImage.layer.cornerRadius = 4.0;
    [self.bgView addSubview:self.headerImage];
    
    self.typeLabel = [[UILabel alloc] init];
    self.typeLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.typeLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.bgView addSubview:self.typeLabel];
    
    self.selectButton = [[UIButton alloc] init];
    [self.selectButton setImage:[UIImage imageNamed:@"selectedNo"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
    [self.bgView addSubview:self.selectButton];
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.left.mas_equalTo(self.bgView.mas_left).offset(18);
    }];
    
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.left.mas_equalTo(self.headerImage.mas_right).offset(18);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.size.mas_equalTo(CGSizeMake(19, 19));
    }];
}

@end

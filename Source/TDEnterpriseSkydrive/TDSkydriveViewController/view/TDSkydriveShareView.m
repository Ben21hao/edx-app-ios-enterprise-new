//
//  TDSkydriveShareView.m
//  edX
//
//  Created by Elite Edu on 2018/6/7.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveShareView.h"

@interface TDSkydriveShareView ()

@end

@implementation TDSkydriveShareView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)configView {
    
    self.bgButton = [[UIButton alloc] init];
    [self addSubview:self.bgButton];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    [self addSubview:self.titleLabel];
    
    self.selectButton = [[UIButton alloc] init];
    [self.selectButton setImage:[UIImage imageNamed:@"sky_share_no_select"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"sky_share_select"] forState:UIControlStateSelected];
    [self addSubview:self.selectButton];
}

- (void)setViewConstraint {
    
    [self.bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self);
        make.right.mas_equalTo(self.mas_right).offset(-48);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.left.mas_equalTo(self.mas_left).offset(28);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(self.mas_right).offset(-13);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
}

@end

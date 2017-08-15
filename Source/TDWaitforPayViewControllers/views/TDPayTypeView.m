//
//  TDPayTypeView.m
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDPayTypeView.h"

@interface TDPayTypeView ()

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
    self.bgButton = [[UIButton alloc] init];
    self.bgButton.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgButton];
    
    self.headerImage = [[UIImageView alloc] init];
    self.headerImage.image = [UIImage imageNamed:@"zhifu"];
    self.headerImage.layer.masksToBounds = YES;
    self.headerImage.layer.cornerRadius = 4.0;
    [self.bgButton addSubview:self.headerImage];
    
    self.typeLabel = [[UILabel alloc] init];
    self.typeLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.typeLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.bgButton addSubview:self.typeLabel];
    
    self.selectButton = [[UIButton alloc] init];
    self.selectButton.userInteractionEnabled = NO;
    [self.selectButton setImage:[UIImage imageNamed:@"selectedNo"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
    [self.bgButton addSubview:self.selectButton];
}

- (void)setViewConstraint {
    [self.bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgButton);
        make.left.mas_equalTo(self.bgButton.mas_left).offset(18);
    }];
    
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgButton);
        make.left.mas_equalTo(self.headerImage.mas_right).offset(18);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgButton);
        make.right.mas_equalTo(self.bgButton.mas_right).offset(-18);
        make.size.mas_equalTo(CGSizeMake(19, 19));
    }];
}

@end

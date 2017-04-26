//
//  TDPayMoneyView.m
//  edX
//
//  Created by Elite Edu on 17/2/14.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDPayMoneyView.h"

@interface TDPayMoneyView ()

@end

@implementation TDPayMoneyView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setViewConstraint];
    }
    return self;
}

- (void)setViewConstraint {
    self.payButton = [[UIButton alloc] init];
    self.payButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.payButton.titleLabel.numberOfLines = 0;
    self.payButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.payButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.payButton setTitle:NSLocalizedString(@"PAY_TITLE", nil) forState:UIControlStateNormal];
    [self addSubview:self.payButton];
    
    [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(0);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(88, 44));
    }];
    
    self.moneyLabel = [[UILabel alloc] init];
    self.moneyLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self addSubview:self.moneyLabel];
    
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(self.payButton.mas_left).offset(-8);
    }];
}

@end

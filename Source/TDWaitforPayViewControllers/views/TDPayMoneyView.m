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
    self.createOrderButton = [[UIButton alloc] init];
    self.createOrderButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.createOrderButton.titleLabel.numberOfLines = 0;
    self.createOrderButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.createOrderButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.createOrderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createOrderButton setTitle:NSLocalizedString(@"PAY_TITLE", nil) forState:UIControlStateNormal];
    [self addSubview:self.createOrderButton];
    
    self.moneyLabel = [[UILabel alloc] init];
    self.moneyLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self addSubview:self.moneyLabel];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.activityView];
    
    [self.createOrderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(0);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(88, 44));
    }];
    
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(self.createOrderButton.mas_left).offset(-8);
    }];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.createOrderButton.mas_centerY);
        make.right.mas_equalTo(self.createOrderButton.mas_right).offset(-5);
    }];
}

@end

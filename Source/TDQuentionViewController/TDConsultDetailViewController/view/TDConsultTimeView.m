//
//  TDConsultTimeView.m
//  edX
//
//  Created by Elite Edu on 2018/5/2.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDConsultTimeView.h"

@implementation TDConsultTimeView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)configView {
    
    self.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.timeLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.timeLabel];
    
    self.leftLine = [[UILabel alloc] init];
    self.leftLine.backgroundColor = [UIColor colorWithHexString:colorHexStr7];
    [self addSubview:self.leftLine];
    
    self.rightLine = [[UILabel alloc] init];
    self.rightLine.backgroundColor = [UIColor colorWithHexString:colorHexStr7];
    [self addSubview:self.rightLine];
    
    self.timeLabel.text = @"2017-05-19  12:34";
}

- (void)setViewConstraint {
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(128, 26));
    }];
    
    [self.leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(20);
        make.right.mas_equalTo(self.timeLabel.mas_left).offset(0);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(1);
    }];
    
    [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-20);
        make.left.mas_equalTo(self.timeLabel.mas_right).offset(0);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(1);
    }];
}

@end

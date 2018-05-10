//
//  TDConsultStatusCell.m
//  edX
//
//  Created by Elite Edu on 2018/4/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDConsultStatusCell.h"

@interface TDConsultStatusCell ()

@property (nonatomic,strong) UILabel *leftLine;
@property (nonatomic,strong) UILabel *rightLine;

@end

@implementation TDConsultStatusCell

- (void)configView {
    
    self.bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    self.statusLabel = [self setLabelStyle:12 color:colorHexStr9];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:self.statusLabel];
    
    self.secondLabel = [self setLabelStyle:10 color:colorHexStr8];
    self.secondLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:self.secondLabel];
    
    self.leftLine = [[UILabel alloc] init];
    self.leftLine.backgroundColor = [UIColor colorWithHexString:colorHexStr7];
    [self.bgView addSubview:self.leftLine];
    
    self.rightLine = [[UILabel alloc] init];
    self.rightLine.backgroundColor = [UIColor colorWithHexString:colorHexStr7];
    [self.bgView addSubview:self.rightLine];
}

- (void)setViewConstraint {
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY).offset(-8);
        make.centerX.mas_equalTo(self.bgView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(128, 26));
    }];
    
    [self.secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.statusLabel.mas_centerX);
        make.top.mas_equalTo(self.statusLabel.mas_bottom).offset(2);
    }];
    
    [self.leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(20);
        make.right.mas_equalTo(self.statusLabel.mas_left).offset(0);
        make.centerY.mas_equalTo(self.bgView.mas_centerY).offset(-8);
        make.height.mas_equalTo(1);
    }];
    
    [self.rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-20);
        make.left.mas_equalTo(self.statusLabel.mas_right).offset(0);
        make.centerY.mas_equalTo(self.bgView.mas_centerY).offset(-8);
        make.height.mas_equalTo(1);
    }];
}

@end

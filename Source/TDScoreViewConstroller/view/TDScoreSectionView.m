//
//  TDScoreSectionView.m
//  edX
//
//  Created by Elite Edu on 2018/5/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDScoreSectionView.h"

@implementation TDScoreSectionView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)configView {
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    self.leftImageView = [[UIImageView alloc] init];
    self.leftImageView.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    [self addSubview:self.leftImageView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15];
    [self addSubview:self.titleLabel];
}

- (void)setViewConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView);
        make.centerY.mas_equalTo(self.bgView.mas_centerY).offset(5);
        make.size.mas_equalTo(CGSizeMake(4, 12));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(18);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.centerY.mas_equalTo(self.leftImageView.mas_centerY);
    }];
}

@end

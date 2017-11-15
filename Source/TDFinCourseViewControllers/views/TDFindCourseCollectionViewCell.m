//
//  TDFindCourseCollectionViewCell.m
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDFindCourseCollectionViewCell.h"

@implementation TDFindCourseCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setViewConstraint];
    }
    return self;
}

- (void)setViewConstraint {
    
    self.bgView = [[UIView alloc] init];
    [self addSubview:self.bgView];
    
    self.courseImage = [[UIImageView alloc] init];
    self.courseImage.layer.masksToBounds = YES;
    self.courseImage.layer.cornerRadius = 4.0;
    [self.bgView addSubview:self.courseImage];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    [self.bgView addSubview:self.titleLabel];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    float height = (TDWidth - 24) / 2 * 9 / 16;
    [self.courseImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.bgView);
        make.height.mas_equalTo(height);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(3);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-3);
        make.top.mas_equalTo(self.courseImage.mas_bottom).offset(8);
    }];
    
    self.courseImage.image = [UIImage imageNamed:@"course_backGroud"];
}

@end


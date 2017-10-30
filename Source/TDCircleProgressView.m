//
//  TDCircleProgressView.m
//  edX
//
//  Created by Elite Edu on 2017/10/27.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDCircleProgressView.h"
#import "TDCircleDrawView.h"

@interface TDCircleProgressView ()

@property (nonatomic,strong) UIImageView *circleImage;
@property (nonatomic,strong) UIImageView *downLoadImage;
@property (nonatomic,strong) TDCircleDrawView *circleView;

@end

@implementation TDCircleProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setViewConstraint];
    }
    return self;
}

- (void)setViewConstraint {
    self.backgroundColor = [UIColor clearColor];
    
    self.circleImage = [[UIImageView alloc] init];
    self.circleImage.image = [UIImage imageNamed:@"down_circel_image"];
    self.circleImage.tintColor = [UIColor colorWithHexString:colorHexStr8];
    [self addSubview:self.circleImage];
    
    [self.circleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    self.downLoadImage = [[UIImageView alloc] init];
    self.downLoadImage.image = [UIImage imageNamed:@"downing_imgae"];
    [self addSubview:self.downLoadImage];
    
    [self.downLoadImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.circleImage);
    }];
    
    self.circleView = [[TDCircleDrawView alloc] init];
    self.circleView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.circleView];
    
    [self.circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.circleImage);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
}

- (void)setProgress:(double)progress {
    _progress = progress;
    
    self.circleView.progress = progress;
    [self.circleView setNeedsDisplay];
}


@end



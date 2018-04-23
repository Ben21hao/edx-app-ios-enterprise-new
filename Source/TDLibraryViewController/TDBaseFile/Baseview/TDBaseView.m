//
//  TDBaseView.m
//  edX
//
//  Created by Elite Edu on 16/12/5.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "TDBaseView.h"

@implementation TDBaseView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configeView];
        [self setViewConstraint];
    }
    return self;
}

- (void)configeView {
    
}
- (void)setViewConstraint {
    
}

#pragma mark - "————  标题  ————"
- (instancetype)initWithTitle:(NSString *)title {
    
    self = [super init];
    if (self) {
        
        UIView *line1 = [[UIView alloc] init];
        line1.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
        [self addSubview:line1];
        
        UIView *line2 = [[UIView alloc] init];
        line2.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
        [self addSubview:line2];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
        titleLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = title;
        [self addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(28);
        }];
        
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(titleLabel.mas_centerY);
            make.left.mas_equalTo(self.mas_left).offset(18);
            make.right.mas_equalTo(titleLabel.mas_left).offset(-18);
            make.height.mas_equalTo(1);
        }];
        
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(titleLabel.mas_centerY);
            make.right.mas_equalTo(self.mas_right).offset(-18);
            make.left.mas_equalTo(titleLabel.mas_right).offset(18);
            make.height.mas_equalTo(1);
        }];
    }
    return self;
}

#pragma mark - 请求数据转圈页面
- (instancetype)initWithLoadingFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *loadIngView = [[UIView alloc] init];
        loadIngView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        [self addSubview:loadIngView];
        [loadIngView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(self);
        }];
        
        UILabel *loadLabel = [[UILabel alloc] init];
        loadLabel.textColor = [UIColor colorWithHexString:colorHexStr1];
        loadLabel.font = [UIFont fontWithName:@"FontAwesome" size:25];
        [loadLabel setText: @"\U0000f110"];//\u{f110}
        [loadIngView addSubview:loadLabel];
        
        [loadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(loadIngView);
            make.centerY.mas_equalTo(loadIngView).offset(-28);
        }];
        
        CAKeyframeAnimation *animate = [[CAKeyframeAnimation alloc] init];
        animate.keyPath = @"transform.rotation";
        
        NSMutableArray *timeArr = [[NSMutableArray alloc] init];
        NSMutableArray *directArr = [[NSMutableArray alloc] init];
        for (double i = 0; i < 8; i ++) {
            double time = i / 8.0;
            NSNumber *num = [NSNumber numberWithDouble:time];
            [timeArr addObject:num];
            
            double direct = time * 2.0 * M_PI;
            NSNumber *dNum = [NSNumber numberWithDouble:direct];
            [directArr addObject:dNum];
        }
        animate.keyTimes = timeArr;
        animate.values = directArr;
        
        animate.repeatCount = 188;
        animate.duration = 0.8;
        animate.additive = YES;
        animate.calculationMode = kCAAnimationDiscrete;
        animate.beginTime = [self.layer convertTime:0 toLayer:self.layer];
        [loadLabel.layer addAnimation:animate forKey:nil];
        
        [self bringSubviewToFront:loadIngView];
    }
    return self;
}

#pragma mark - 无数据页面
- (instancetype)initWithNullDataTitle:(NSString *)title withFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        UIView *nullView = [[UIView alloc] init];
        nullView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        [self addSubview:nullView];
        
        UILabel *nullLabel = [[UILabel alloc] init];
        nullLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
        nullLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
        nullLabel.textAlignment = NSTextAlignmentCenter;
        nullLabel.text = title;
        [nullView addSubview:nullLabel];
        
        [nullView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(self);
        }];
        
        [nullLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(nullView.mas_centerX);
            make.centerY.mas_equalTo(nullView.mas_centerY).offset(-8);
        }];
    }
    return self;
}

#pragma mark - 请求超时页面
- (instancetype)initWithRequestErrorTitle:(NSString *)title withFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        [self addSubview:view];
        
        UILabel *imageLabel = [[UILabel alloc] init];
        imageLabel.font = [UIFont fontWithName:@"FontAwesome" size:30];
        imageLabel.text = @"\U0000f06a";
        [view addSubview:imageLabel];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
        titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
        titleLabel.text = title;
        [view addSubview:titleLabel];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(self);
        }];
        
        [imageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.centerY.mas_equalTo(self.mas_centerY).offset(30);
        }];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self);
            make.top.mas_equalTo(imageLabel.mas_bottom).offset(8);
        }];
    }
    return self;
}


- (UILabel *)setLabelStyleFont:(NSInteger)font color:(NSString *)colorStr {
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"OpenSans" size:font];
    label.textColor = [UIColor colorWithHexString:colorStr];
    return label;
}


@end

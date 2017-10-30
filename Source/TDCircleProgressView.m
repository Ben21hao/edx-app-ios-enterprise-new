//
//  TDCircleProgressView.m
//  edX
//
//  Created by Elite Edu on 2017/10/27.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDCircleProgressView.h"

@interface TDCircleProgressView ()

@property (nonatomic,strong) UIImageView *circleImage;
@property (nonatomic,strong) UIImageView *downLoadImage;

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
    [self addSubview:self.circleImage];
    
    [self.circleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    self.downLoadImage = [[UIImageView alloc] init];
    self.downLoadImage.image = [UIImage imageNamed:@"downing_imgae"];
    [self addSubview:self.downLoadImage];
    
    [self.downLoadImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.circleImage);
    }];
    
    self.persentLabel = [[UILabel alloc] init];
    self.persentLabel.textAlignment = NSTextAlignmentCenter;
    self.persentLabel.font = [UIFont fontWithName:@"OpenSans" size:8];
    [self addSubview:self.persentLabel];
    
    [self.persentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.mas_equalTo(self.circleImage.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    self.circleImage.alpha = 0.5;
}

- (void)drawRect:(CGRect)rect {
    
//    self.persentLabel.text = [NSString stringWithFormat:@"%.0lf%%",self.progress];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext(); //获取上下文
    
    CGContextSetLineWidth(ctx, 1.5); //设置线条宽细
//    CGContextSetRGBStrokeColor(ctx, 0, 0.0, 0.0, 1.0); //设置颜色
    [[UIColor colorWithHexString:colorHexStr1] setStroke]; //设置描边颜色 - 两种方式都可以
    
    CGPoint center = CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2, self.bounds.origin.y + self.bounds.size.height / 2); //设置圆心位置
    CGFloat radius = 10; //半径
    CGFloat startA = - M_PI_2; //圆起点位置
    CGFloat endA = - M_PI_2 + M_PI * 2 * (self.progress / 100); //圆终点位置
    
    //用贝塞尔曲线
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    
    CGContextAddPath(ctx, path.CGPath);  //把路径 path 添加到上下文
    CGContextStrokePath(ctx);  //渲染
}

@end



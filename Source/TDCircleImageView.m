//
//  TDCircleImageView.m
//  edX
//
//  Created by Elite Edu on 2017/10/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDCircleImageView.h"

@implementation TDCircleImageView

- (void)drawRect:(CGRect)rect {
    
    CGContextRef ctx = UIGraphicsGetCurrentContext(); //获取上下文
    
    CGContextSetLineWidth(ctx, 1); //设置线条宽细
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

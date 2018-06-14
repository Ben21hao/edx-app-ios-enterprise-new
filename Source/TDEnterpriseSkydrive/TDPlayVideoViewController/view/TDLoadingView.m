//
//  TDLoadingView.m
//  EdxProject
//
//  Created by Elite Edu on 2018/4/11.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDLoadingView.h"

@interface TDLoadingView () <CAAnimationDelegate>

@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,assign) BOOL isFinish;

@end

@implementation TDLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.index = 0;
        self.duration = 2;
        [self setLoadingViewConstraint];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIBezierPath *path = [self cycleBezierPathIndex:self.index];
    self.shapeLayer.path = path.CGPath;
}

- (void)setLoadingViewConstraint {
    
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.lineWidth = 2.0; //线宽
    self.shapeLayer.fillColor = [UIColor clearColor].CGColor; //填充色
    self.shapeLayer.strokeColor = [UIColor colorWithHexString:colorHexStr1].CGColor;//描边
    self.shapeLayer.lineCap = kCALineCapRound;//端点类型
    [self.layer addSublayer:self.shapeLayer];
 
    [self loadingAnimation];
}

- (UIBezierPath *)cycleBezierPathIndex:(NSInteger)index { //贝塞尔曲线画路径
    
    CGFloat radius = self.bounds.size.width * 0.5;
    CGFloat angle = (M_PI * 2)/3;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:index * angle endAngle:index * angle + angle * 4 clockwise:YES];
    return path;
}

- (void)loadingAnimation {
    
    CABasicAnimation *startAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    startAnimation.fromValue = @0.0f;
    startAnimation.toValue = @1.0f;
    startAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    startAnimation.duration = self.duration;
    
    CABasicAnimation *endAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    endAnimation.fromValue = @0.0f;
    endAnimation.toValue = @1.0f;
    endAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    endAnimation.duration = self.duration * 0.5;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.delegate = self;
    group.duration = self.duration;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards; //结束后保持最后的状态
    group.animations = @[startAnimation,endAnimation];
    
    [self.shapeLayer addAnimation:group forKey:@"strokeEndAnimation"];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag { //动画停止
    if (self.isHidden) {
        self.isFinish = YES;
        return;
    }
    
    self.index ++;
    self.shapeLayer.path = [self cycleBezierPathIndex:self.index % 3].CGPath;
    [self loadingAnimation];
}

#pragma makr - 开始动画
- (void)startLoadingAnimation {
    
    if (self.shapeLayer.animationKeys.count > 0) {
        return;
    }
    self.hidden = NO;
    if (self.isFinish) {
        [self loadingAnimation];
    }
}
#pragma makr - 结束动画
- (void)endLoadingAnimation {
    
    self.hidden = YES;
    self.index = 0;
    [self.shapeLayer removeAllAnimations];
}

- (void)setStrokeColor:(UIColor *)strokeColor { //颜色
    _strokeColor = strokeColor;
    
    self.shapeLayer.strokeColor = strokeColor.CGColor;
}


@end

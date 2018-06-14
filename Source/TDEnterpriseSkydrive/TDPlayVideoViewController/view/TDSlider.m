//
//  TDSlider.m
//  EdxProject
//
//  Created by Elite Edu on 2018/4/11.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDSlider.h"

#define SLIDER_X_BOUNDS 30
#define SLIDER_Y_BOUNDS 40

@interface TDSlider ()

@property (nonatomic,assign) CGRect lasetBounds;

@end

@implementation TDSlider

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.maximumTrackTintColor = [UIColor clearColor]; //为了显示右边底部的progress的进度
        self.minimumTrackTintColor = [UIColor colorWithHexString:colorHexStr1];
        [self setThumbImage:[UIImage imageNamed:@"selider_track_image"] forState:UIControlStateNormal];
        [self setThumbImage:[UIImage imageNamed:@"selider_track_image"] forState:UIControlStateSelected];
    }
    return self;
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    [super trackRectForBounds:bounds];
    return CGRectMake(bounds.origin.x, bounds.origin.y, CGRectGetWidth(bounds), 2);
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    
    rect.origin.x -= 6;
    rect.size.width += 12;
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    
    self.lasetBounds = result; //记下最终的frame
    
    return result;
}

//响应者链条
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {//事件在view的哪个位置，判断点击事件是否能交给self处理
    
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView != self) {
        if ((point.y >= -15) && (point.y < point.y + SLIDER_Y_BOUNDS) && (point.x >= 0 && point.x < CGRectGetWidth(self.bounds))) {
            hitView = self;
        }
    }
    return hitView;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event { //事件是否在当前view中
    
    BOOL inside = [super pointInside:point withEvent:event];
    if (!inside) {
        if ((point.x >= (self.lasetBounds.origin.x - SLIDER_X_BOUNDS)) && (point.x <= (self.lasetBounds.origin.x + self.lasetBounds.size.width + SLIDER_X_BOUNDS)) && (point.y < (self.lasetBounds.origin.y + SLIDER_Y_BOUNDS))) {
            
            inside = YES;
        }
    }
    return inside;
}

@end



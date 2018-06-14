//
//  TDLoadingView.h
//  EdxProject
//
//  Created by Elite Edu on 2018/4/11.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDLoadingView : UIView

@property (nonatomic,assign) NSTimeInterval duration;
@property (nonatomic,strong) UIColor *strokeColor;

- (void)startLoadingAnimation; //开始动画
- (void)endLoadingAnimation; //结束动画

@end

//
//  JHCouponsAlertView.m
//  edX
//
//  Created by Elite Edu on 16/10/17.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "JHCouponsAlertView.h"
#import "UIColor+extend.h"
#import "UIColor+OEXHex.h"
#import "UIColor+JHHexColor.h"
#import "JHTextField.h"

@implementation JHCouponsAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert;
        
        //背景遮盖
        UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        backView.backgroundColor = [UIColor blackColor];
        backView.alpha = 0.5;
        [self addSubview:backView];
        
        //弹窗背景图片
        CGFloat Width = 280;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        imageView.frame = CGRectMake(0, 0, Width, 205);
        imageView.center = CGPointMake(backView.center.x,backView.center.y);
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.userInteractionEnabled = YES;
        imageView.layer.cornerRadius = 5;
        imageView.backgroundColor = [UIColor whiteColor];
        self.imageView = imageView;
        [self addSubview:imageView];
        
        //弹窗标题
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, Width, 40)];
        label.text = NSLocalizedString(@"ENTER_COINS_AMOUNT", nil);
        label.textColor = [UIColor colorWithHexString:colorHexStr9];
        label.textAlignment = NSTextAlignmentCenter;
        [imageView addSubview:label];
        
        //添加分割线
        UIView *sepV = [[UIView alloc] initWithFrame:CGRectMake(10, 49, 260, 0.5)];
        sepV.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
        [imageView addSubview:sepV];
        
        //添加提示信息
        _textF1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 53, 260, 30)];
        _textF1.numberOfLines = 0;
        _textF1.textAlignment = NSTextAlignmentCenter;
        _textF1.font = [UIFont systemFontOfSize:13];
        self.textF1.textColor = [UIColor colorWithHexString:colorHexStr9];
        [imageView addSubview:_textF1];
        
        //添加输入框2
        JHTextField *textF2 = [[JHTextField alloc] initWithFrame:CGRectMake(15, 83, 250, 40)];
        [textF2 setBorderStyle:UITextBorderStyleRoundedRect];
        textF2.borderStyle = UITextBorderStyleNone;
        textF2.clearButtonMode = UITextFieldViewModeAlways;
        textF2.keyboardType = UIKeyboardTypeEmailAddress;
        textF2.background = [UIImage imageNamed:@"bt_grey_default.png"];
        textF2.placeholder = NSLocalizedString(@"COINS_AMOUNT", nil);
        self.textF2 = textF2;
        [imageView addSubview:textF2];
        //
        UILabel *textF3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 123, 260, 30)];
        textF3.text = NSLocalizedString(@"RMB_TO_COINS", nil);
        textF3.textColor = [UIColor  colorWithHexString:colorHexStr9];
        textF3.textAlignment = NSTextAlignmentCenter;
        textF3.font = [UIFont systemFontOfSize:13];
        [imageView addSubview:textF3];
        //底部分割线1
        UIView *bottomV1 = [[UIView alloc] initWithFrame:CGRectMake(0, 155, 280, 0.5)];
        bottomV1.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
        [imageView addSubview:bottomV1];
        
        //底部分割线2
        UIView *bottomV2 = [[UIView alloc] initWithFrame:CGRectMake(140, 155, 0.5, 50)];
        bottomV2.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
        [imageView addSubview:bottomV2];
        
        //添加取消和确定按钮
        UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 155, Width * 0.5, 50)];
        [cancleBtn setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
        [cancleBtn setTitleColor:[UIColor colorWithHexString:colorHexStr9] forState:UIControlStateNormal];
        cancleBtn.tag = 0;
        [cancleBtn addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:cancleBtn];
        
        UIButton *quedingBtn = [[UIButton alloc] initWithFrame:CGRectMake(Width * 0.5, 155, Width * 0.5, 50)];
        [quedingBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
        [quedingBtn setTitleColor:[UIColor colorWithHexString:colorHexStr1] forState:UIControlStateNormal];
        quedingBtn.tag = 1;
        [quedingBtn addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:quedingBtn];
        //通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}
- (void)show
{
    [self makeKeyAndVisible];
}
#pragma mark -- 弹出键盘屏幕上移
//键盘收起
- (void)keyboardWillHide:(NSNotification *)noti {
    CGRect Frame = [UIScreen mainScreen].bounds;
    CGRect rect = Frame;
    rect.origin.y = 0;
    self.frame = rect;
}
//视图上移
- (void)keyboardWillShow:(NSNotification *)noti {
    CGRect Frame = [UIScreen mainScreen].bounds;
    // 拿到正在编辑中的textfield
    [self getIsEditingView:self];
    // textfield的位置
    CGFloat viewY = [self screenViewYValue:self.editingTextField];
    // 键盘的Y值
    NSDictionary *userInfo = [noti userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardEndY = value.CGRectValue.origin.y;
    // 动画
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:duration.doubleValue animations:^{
        if (viewY+50 > keyboardEndY) {
            CGRect rect = Frame;
            rect.origin.y += keyboardEndY - (viewY+60);
            self.frame = rect;
        }
    }];
}
//计算textfield的位置
- (CGFloat)screenViewYValue:(UIView *)textfield {
    CGFloat y = 40;
    for (UIView *view = textfield; view; view = view.superview) {
        y += view.frame.origin.y;
        if ([view isKindOfClass:[UIScrollView class]]) {
            // 如果父视图是UIScrollView则要去掉内容滚动的距离
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}
//取得正在编辑的textfield
- (void)getIsEditingView:(UIView *)rootView {
    for (UIView *subView in rootView.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            if (((UITextField *)subView).isEditing) {
                self.editingTextField = subView;
                return;
            }
        }
        [self getIsEditingView:subView];
    }
}
//移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)dismiss {
    [self resignKeyWindow];
    [self removeFromSuperview];
}

- (void)btnOnClick:(UIButton *)btn {
    if (_delegate && [_delegate respondsToSelector:@selector(alertView:didSelectOptionButtonWithTag1:)]) {
        [_delegate alertView:self didSelectOptionButtonWithTag1:btn.tag];
    }
}



@end

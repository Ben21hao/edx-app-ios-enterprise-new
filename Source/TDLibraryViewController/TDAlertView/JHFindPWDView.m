//
//  JHFindPWDView.m
//  edX
//
//  Created by Elite Edu on 16/8/12.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "JHFindPWDView.h"
#import "UIColor+extend.h"
#import "UIColor+OEXHex.h"
#import "UIColor+JHHexColor.h"
#import "JHTextField.h"

@implementation JHFindPWDView

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
        CGFloat bgViewWidth = 280;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        imageView.frame = CGRectMake(0, 0, bgViewWidth, 220);
        imageView.center = CGPointMake(backView.center.x,backView.center.y);
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.userInteractionEnabled = YES;
        imageView.layer.cornerRadius = 5;
        imageView.backgroundColor = [UIColor whiteColor];
        self.imageView = imageView;
        [self addSubview:imageView];
        
        //弹窗标题
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 280, 40)];
        label.text = NSLocalizedString(@"RESET_PASSWORD", nil);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithHexString:colorHexStr10];
        [imageView addSubview:label];
        
        //添加分割线
        UIView *sepV = [[UIView alloc] initWithFrame:CGRectMake(20, 51, 240, 0.5)];
        sepV.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
        [imageView addSubview:sepV];
        
        //添加提示信息
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 55, 250, 60)];
        messageLabel.text = NSLocalizedString(@"PLEASE_ENTER_YOUR_PHONE_OR_EMAIL_TO_RESET_PASSWORD", nil);
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont systemFontOfSize:12];
        messageLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
        [imageView addSubview:messageLabel];
        
        //添加输入框
        JHTextField *textF2 = [[JHTextField alloc] initWithFrame:CGRectMake(15, 115, 250, 40)];
        [textF2 setBorderStyle:UITextBorderStyleRoundedRect];
        textF2.borderStyle = UITextBorderStyleNone;
        textF2.keyboardType = UIKeyboardTypeEmailAddress;
        textF2.background = [UIImage imageNamed:@"bt_grey_default.png"];
        textF2.textColor = [UIColor colorWithHexString:colorHexStr9];
        
        //占位文本属性
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[NSFontAttributeName] = [UIFont systemFontOfSize:14];
        textF2.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PLEASE_ENTER_YOUR_PHONE_OR_EMAIL", nil) attributes:attributes];
        self.textF2 = textF2;
        [imageView addSubview:textF2];
        
        //底部分割线1
        UIView *bottomV1 = [[UIView alloc] initWithFrame:CGRectMake(0, 168, 280, 0.5)];
        bottomV1.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
        [imageView addSubview:bottomV1];
        
        //底部分割线2
        UIView *bottomV2 = [[UIView alloc] initWithFrame:CGRectMake(140, 168, 0.5, 50)];
        bottomV2.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
        [imageView addSubview:bottomV2];
        
        //添加取消
        UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 170, bgViewWidth * 0.5, 50)];
        [cancleBtn setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
        [cancleBtn setTitleColor:[UIColor colorWithHexString:colorHexStr9] forState:UIControlStateNormal];
        cancleBtn.tag = 0;
        [cancleBtn addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:cancleBtn];
        
        //确定按钮
        UIButton *quedingBtn = [[UIButton alloc] initWithFrame:CGRectMake(bgViewWidth * 0.5, 170, bgViewWidth * 0.5, 50)];
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

- (void)show {
    [self makeKeyAndVisible];
}

#pragma mark -- 弹出键盘屏幕上移
- (void)keyboardWillHide:(NSNotification *)noti {//键盘收起
    CGRect Frame = [UIScreen mainScreen].bounds;
    CGRect rect = Frame;
    rect.origin.y = 0;
    self.frame = rect;
}

- (void)keyboardWillShow:(NSNotification *)noti {//视图上移
    CGRect Frame = [UIScreen mainScreen].bounds;
    
    [self getIsEditingView:self];// 拿到正在编辑中的textfield
    
    CGFloat viewY = [self screenViewYValue:self.editingTextField];// textfield的位置
    NSDictionary *userInfo = [noti userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyboardEndY = value.CGRectValue.origin.y; // 键盘的Y值
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];// 动画
    [UIView animateWithDuration:duration.doubleValue animations:^{
        if (viewY+50 > keyboardEndY) {
            CGRect rect = Frame;
            rect.origin.y += keyboardEndY - (viewY+60);
            self.frame = rect;
        }
    }];
}

- (CGFloat)screenViewYValue:(UIView *)textfield {//计算textfield的位置
    CGFloat y = 40;
    for (UIView *view = textfield; view; view = view.superview) {
        y += view.frame.origin.y;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView* scrollView = (UIScrollView*)view;
            y -= scrollView.contentOffset.y;// 如果父视图是UIScrollView则要去掉内容滚动的距离
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
    
    [self.textF2 resignFirstResponder];
    [self resignKeyWindow];
    [self removeFromSuperview];
}

- (void)btnOnClick:(UIButton *)btn{
    
    if (_delegate && [_delegate respondsToSelector:@selector(alertView:didSelectOptionButtonWithTag1:)]) {
        [_delegate alertView:self didSelectOptionButtonWithTag1:btn.tag];
    }
}


@end

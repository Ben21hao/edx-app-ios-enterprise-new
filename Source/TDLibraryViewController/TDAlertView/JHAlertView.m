//
//  JHAlertView.m
//  login
//
//  Created by Elite Edu on 16/8/8.
//  Copyright © 2016年 Elite Edu. All rights reserved.
//

#import "JHAlertView.h"
#import "UIColor+extend.h"
#import "UIColor+OEXHex.h"
#import "UIColor+JHHexColor.h"
#import "JHTextField.h"
#import "OEXLoginViewController.h"

@interface JHAlertView ()
@property(nonatomic,strong) OEXLoginViewController *loginVC;
@property(nonatomic,weak) UILabel *eyeLabel;

@end

@implementation JHAlertView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert;
        
        //背景遮盖
        UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        backView.backgroundColor = [UIColor blackColor];
        backView.alpha = 0.5;
        [self addSubview:backView];
        
        //弹窗背景图片
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        imageView.frame = CGRectMake(0, 0, 280, 200);
        imageView.center = CGPointMake(self.center.x, self.center.y);
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.userInteractionEnabled = YES;
        imageView.layer.cornerRadius = 5;
        imageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:imageView];
        
        //弹窗标题
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 280, 40)];
        label.text = NSLocalizedString(@"RESET_PASSWORD", nil);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithHexString:colorHexStr10];
        [imageView addSubview:label];
        
        //添加分割线
        UIView *sepV = [[UIView alloc] initWithFrame:CGRectMake(10, 51, 260, 0.5)];
        sepV.backgroundColor = [UIColor colorWithHexString:colorHexStr7];
        [imageView addSubview:sepV];
        
        //添加输入框1
        JHTextField *textF1 = [[JHTextField alloc] initWithFrame:CGRectMake(10, 60, 180, 40)];
        [textF1 setBorderStyle:UITextBorderStyleRoundedRect];
        textF1.borderStyle = UITextBorderStyleNone;
        textF1.background = [UIImage imageNamed:@"bt_grey_default.png"];
        textF1.textAlignment = NSTextAlignmentLeft;
        textF1.textColor = [UIColor colorWithHexString:colorHexStr9];
        
        //      设置属性
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[NSFontAttributeName] = [UIFont systemFontOfSize:13];
        textF1.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PLEASE_ENTER_VERI", nil) attributes:attributes];
        textF1.keyboardType = UIKeyboardTypeNumberPad;
        self.textF1 = textF1;
        [imageView addSubview:textF1];
        
        //添加倒计时文本 && 发送验证码按钮
        UIButton *timeL = [[UIButton alloc] initWithFrame:CGRectMake(195, 60, 75, 40)];
        timeL.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
        timeL.titleLabel.font = [UIFont systemFontOfSize:14];
        [timeL setTitle:[NSString stringWithFormat:@"%@",NSLocalizedString(@"GET_VERIFICATION", nil)] forState:UIControlStateNormal];
        timeL.tintColor = [UIColor blackColor];
        timeL.layer.cornerRadius = 3;
        timeL.userInteractionEnabled = NO;
        self.timeL = timeL;
        timeL.tag = 3;
        [timeL addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview: timeL];
        
        //添加输入框2
        JHTextField *textF2 = [[JHTextField alloc] initWithFrame:CGRectMake(10, 105, 260, 40)];
        [textF2 setBorderStyle:UITextBorderStyleRoundedRect];
        textF2.borderStyle = UITextBorderStyleNone;
        textF2.background = [UIImage imageNamed:@"bt_grey_default.png"];
        textF2.textAlignment = NSTextAlignmentLeft;
        textF2.keyboardType = UIKeyboardTypeASCIICapable;
        textF2.secureTextEntry = YES;
        textF2.textColor = [UIColor colorWithHexString:colorHexStr9];
        
        //      S设置属性
        textF2.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PLEASE_ENTER_PASSWORD", nil) attributes:attributes];
        self.textF2 = textF2;
        [imageView addSubview:textF2];
        
        //添加小眼睛按钮
        UIButton *eyeBtn = [[UIButton alloc] initWithFrame:CGRectMake(225, 110, 30, 30)];
        [imageView addSubview:eyeBtn];
        [eyeBtn addTarget:self action:@selector(changeEye) forControlEvents:UIControlEventTouchUpInside];
        //文本
        UILabel *eyeLabel = [[UILabel alloc] initWithFrame:eyeBtn.frame];
        [eyeLabel setFont:[UIFont fontWithName:@"FontAwesome" size:20]];
        eyeLabel.text = @"\U0000f070";
        eyeLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
        self.eyeLabel = eyeLabel;
        [imageView addSubview:eyeLabel];
        
        //添加取消和确定按钮
        UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 152, 139, 48)];
        [cancleBtn setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
        [cancleBtn setTitleColor:[UIColor colorWithHexString:colorHexStr9] forState:UIControlStateNormal];
        cancleBtn.tag = 0;
        cancleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [cancleBtn addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:cancleBtn];
        
        UIButton *quedingBtn = [[UIButton alloc] initWithFrame:CGRectMake(141, 152, 139, 48)];
        [quedingBtn setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
        [quedingBtn setTitleColor:[UIColor colorWithHexString:colorHexStr1] forState:UIControlStateNormal];
        quedingBtn.tag = 1;
        quedingBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [quedingBtn addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:quedingBtn];
        
        //底部分割线1
        UIView *bottomV1 = [[UIView alloc] initWithFrame:CGRectMake(0, 153, 280, 0.5)];
        bottomV1.backgroundColor = [UIColor colorWithHexString:colorHexStr7];
        [imageView addSubview:bottomV1];
        
        //底部分割线2
        UIView *bottomV2 = [[UIView alloc] initWithFrame:CGRectMake(140, 153, 0.5, 50)];
        bottomV2.backgroundColor = [UIColor colorWithHexString:colorHexStr7];
        [imageView addSubview:bottomV2];
        
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
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];// 动画
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
//    CGFloat y = 0;
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
    [[[UIApplication sharedApplication]keyWindow ]endEditing:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(alertView:didSelectOptionButtonWithTag:)]) {
        [_delegate alertView:self didSelectOptionButtonWithTag:btn.tag];
    }
}
- (void)changeEye{
    self.textF2.secureTextEntry = !self.textF2.secureTextEntry;
    if (self.textF2.secureTextEntry == YES) {
        [self.eyeLabel setText:@"\U0000f070"];
    }
    if (self.textF2.secureTextEntry == NO) {
        [self.eyeLabel setText:@"\U0000f06e"];
    }
}
@end

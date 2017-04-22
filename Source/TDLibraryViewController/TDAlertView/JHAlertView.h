//
//  JHAlertView.h
//  login
//
//  Created by Elite Edu on 16/8/8.
//  Copyright © 2016年 Elite Edu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JHAlertView;
@protocol JHAlertViewDelegate <NSObject>

- (void)alertView:(JHAlertView *)alertView didSelectOptionButtonWithTag:(NSInteger)tag;

@end

@interface JHAlertView : UIWindow
@property (nonatomic, weak) id<JHAlertViewDelegate> delegate;
- (void)show;
- (void)dismiss;

@property(nonatomic,strong)UIButton *timeL;//倒计时文本
@property(nonatomic,strong)UITextField *textF1;//验证码输入框
@property(nonatomic,strong)UITextField *textF2;//新密码输入框
//@property(nonatomic,assign)CGRect Frame;  //Frame
@property (weak, nonatomic) IBOutlet UIView *editingTextField;//正在编辑的文本
@property(nonatomic,strong)UIImageView *imageView;//背景遮盖
//- (void)timeLChange;//倒计时方法

@end

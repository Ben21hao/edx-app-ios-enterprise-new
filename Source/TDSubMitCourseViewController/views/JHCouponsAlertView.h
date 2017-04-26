//
//  JHCouponsAlertView.h
//  edX
//
//  Created by Elite Edu on 16/10/17.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>


//代理
@class JHCouponsAlertView;
@protocol JHCouponsAlertViewDelegate <NSObject>

- (void)alertView:(JHCouponsAlertView *)alertView didSelectOptionButtonWithTag1:(NSInteger)btnTag;

@end

@interface JHCouponsAlertView : UIWindow

@property (nonatomic, weak) id<JHCouponsAlertViewDelegate> delegate;

- (void)show;
- (void)dismiss;
//正在编辑的文本
@property (weak, nonatomic) IBOutlet UIView *editingTextField;
//手机号码或邮箱输入框
@property (nonatomic,strong) UITextField *textF2;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *textF1;


@end

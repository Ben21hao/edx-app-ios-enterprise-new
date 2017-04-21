//
//  WYAlertView.h
//  WYAlertView
//
//  Created by wy on 16/5/11.
//  Copyright © 2016年 wy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHTextField.h"
@class WYAlertView;

@protocol WYAlertViewDelegate <NSObject>

- (void)beginDownLoad;

@end

@class WYAlertView ;

@interface WYAlertView : UIView
/*
 title:提示标题
 content:内容
 leftTitle:左边按钮名称
 rigthTitle:右边按钮名称
 hasText:是否需要TextField
 headImgString:头部图片的名称，有名称时，显示头部
 */

//- (id)initWithTitle:(NSString *)title
//        contentText:(NSString *)content
//    leftButtonTitle:(NSString *)leftTitle
//   rightButtonTitle:(NSString *)rigthTitle
//     withIconString:(NSString *)iconString
//           withText:(BOOL)hasText
//     withHeaderView:(NSString*)headImgString;
@property (strong, nonatomic) UIColor *leftColor;//取消按钮颜色，
@property (strong, nonatomic) UIColor *rightColor;//确定按钮颜色，
@property (strong, nonatomic) UIColor *contentColor;//内容颜色
@property (strong, nonatomic) UIColor *titleColor;//标题内容颜色
@property (assign, nonatomic) BOOL isRightExist;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *message;
- (void)show;

@property (nonatomic, strong) JHTextField *text;
@property (nonatomic, copy) dispatch_block_t leftBlock;
@property (nonatomic, copy) dispatch_block_t rightBlock;
//右边按钮
@property (nonatomic, strong) UIButton *rightbtn;
@property (nonatomic, strong) UIButton *leftbtn;
//点击左右按钮都会触发该消失的block
@property (nonatomic, copy) dispatch_block_t dismissBlock;

//代理
@property(weak,nonatomic)id<WYAlertViewDelegate> delegate;



+(WYAlertView*)showmessage:(NSString *)message subtitle:(NSString *)subtitle cancelbutton:(NSString *)cancle;
//纯文字
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)leftTitle rightButtonTitle:(NSString *)rigthTitle;
//带有输入框
- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)leftTitle rightButtonTitle:(NSString *)rigthTitle beTextField:(BOOL)isTextField;
//带有分享图片
- (id)initIconAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)leftTitle rightButtonTitle:(NSString *)rigthTitle imageName:(NSString *)imageName;
//带有头部背景图片
- (id)initHeaderImageAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)leftTitle rightButtonTitle:(NSString *)rigthTitle imageName:(NSString *)imageName;
//带有输入框与分享图片
- (id)initIconTextAlertWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)leftTitle rightButtonTitle:(NSString *)rigthTitle imageName:(NSString *)imageName beTextField:(BOOL)isTextField;
@end

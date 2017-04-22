//
//  JHFindPWDView.h
//  edX
//
//  Created by Elite Edu on 16/8/12.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

//代理
@class JHFindPWDView;
@protocol JHFindPWDViewDelegate <NSObject>

- (void)alertView:(JHFindPWDView *)alertView didSelectOptionButtonWithTag1:(NSInteger)tag1;

@end

@interface JHFindPWDView : UIWindow

@property (nonatomic, weak) id<JHFindPWDViewDelegate> delegate;

- (void)show;
- (void)dismiss;

@property (weak, nonatomic) IBOutlet UIView *editingTextField;//正在编辑的文本
@property(nonatomic,strong)UITextField *textF2;//手机号码或邮箱输入框
@property(nonatomic,strong)UIImageView *imageView;

@end

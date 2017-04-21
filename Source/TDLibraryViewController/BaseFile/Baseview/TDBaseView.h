//
//  TDBaseView.h
//  edX
//
//  Created by Elite Edu on 16/12/5.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDBaseView : UIView

/*
 类似这样的一个页面；
 ————  标题  ————
 */
- (instancetype)initWithTitle:(NSString *)title;

/*
 请求数据转圈页面
 */
- (instancetype)initWithLoadingFrame:(CGRect)frame;

/*
 无数据页面
 */
- (instancetype)initWithNullDataTitle:(NSString *)title withFrame:(CGRect)frame;

/*
 请求超时页面
 */
- (instancetype)initWithRequestErrorTitle:(NSString *)title withFrame:(CGRect)frame;

@end

//
//  TDOrderTeacherSuccessViewController.h
//  edX
//
//  Created by Elite Edu on 17/3/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDOrderTeacherSuccessViewController : UIViewController

@property (nonatomic,assign) NSInteger whereFrom;//1 我的课程，2 发现课程
@property (nonatomic,strong) NSString *username;//用户名
@property (nonatomic,assign) BOOL isSuccess;//是否成功
@property (nonatomic,strong) NSString *timeStr;//预约时间
@property (nonatomic,strong) NSString *iconStr;//预付宝典
@property (nonatomic,strong) NSString *quetionStr;//预约问题
@property (nonatomic,assign) NSInteger failType;//失败原因

@end

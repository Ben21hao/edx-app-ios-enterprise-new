//
//  TDTalkOrderViewController.h
//  edX
//
//  Created by Elite Edu on 17/3/9.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseViewController.h"

@interface TDTalkOrderViewController : TDBaseViewController

@property (nonatomic,strong) NSString *username;//学生用户名
@property (nonatomic,strong) NSString *courseId;//课程id
@property (nonatomic,strong) NSString *assistantName;//助教username
@property (nonatomic,copy) void(^appointmentSuccessHandle)();

@property (nonatomic,assign) BOOL is_eliteu_course;//是否是付费课程

@end

//
//  TDTeacherTimesViewController.h
//  edX
//
//  Created by Elite Edu on 17/3/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseViewController.h"

@interface TDTeacherTimesViewController : TDBaseViewController

@property (nonatomic,assign) NSInteger whereFrom;//1 我的课程，2 发现课程
@property (nonatomic,strong) NSString *username;//学生name
@property (nonatomic,strong) NSString *assistantName;//助教name
@property (nonatomic,strong) NSString *courseId;//课程id

@end

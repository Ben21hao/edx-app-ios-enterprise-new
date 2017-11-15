//
//  TDCourseListViewController.h
//  edX
//
//  Created by Elite Edu on 2017/11/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDCourseTagModel.h"

@interface TDCourseListViewController : TDBaseViewController

@property (nonatomic,assign) NSInteger whereFrom; //0 内部课程，1 英荔课程，2 对应tag的课程

@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *company_id;

@property (nonatomic,strong) TDCourseTagModel *tagModel; //选择的tag


@end

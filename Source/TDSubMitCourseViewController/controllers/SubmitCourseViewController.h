//
//  SubmitCourseViewController.h
//  edX
//
//  Created by Elite Edu on 16/10/9.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseViewController.h"

@interface SubmitCourseViewController : TDBaseViewController

@property (nonatomic,strong) NSMutableArray *array0;

@property (nonatomic,assign) float totalM; //应该付款金额
@property (nonatomic,copy) NSString *username;
@property (nonatomic,strong) NSString *course_ids;//课程id
@property (nonatomic,strong) NSString *activity_id;//活动名称
@property (nonatomic,strong) NSString *giftCoin; //赠送宝典数目

@property (nonatomic,assign) BOOL hideShowPurchase;//是否隐藏内购

@end

//
//  TDOrderAssistantViewController.h
//  edX
//
//  Created by Elite Edu on 17/2/27.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDOrderAssistantViewController : TDBaseViewController

@property (nonatomic,assign) NSInteger whereFrom; //1 我的课程；2 发现课程
@property (nonatomic,strong) NSString *courseId;//课程id
@property (nonatomic,strong) NSString *myName;//学生用户名
@property (nonatomic,strong) NSString *effectIcon;//可用宝典
@property (nonatomic,strong) NSString *company_id;

@end

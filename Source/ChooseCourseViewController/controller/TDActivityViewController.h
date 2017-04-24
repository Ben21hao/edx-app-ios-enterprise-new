//
//  TDActivityViewController.h
//  edX
//
//  Created by Elite Edu on 16/12/10.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseViewController.h"
#import "ActivityListItem.h"

@interface TDActivityViewController : TDBaseViewController

@property (nonatomic,strong) NSArray *dataArray;//活动数组
@property (nonatomic,strong) NSArray *courseArray;//选中课程数组
@property (nonatomic,strong) NSString *activityStr;//已选活动名字
@property (nonatomic,strong) NSString *totalMoney;//总支付价格

@property (nonatomic,copy) void(^selectActivityHandle)(ActivityListItem *model);

@end

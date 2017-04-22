//
//  TDOrderAssitantCell.h
//  edX
//
//  Created by Elite Edu on 17/2/27.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDTeacherModel.h"

@interface TDOrderAssitantCell : UITableViewCell

@property (nonatomic,strong) TDTeacherModel *model;

@property (nonatomic,copy) void(^orderButtonHandle)();//预约
@property (nonatomic,copy) void(^talkButtonHandle)();//即时服务
@property (nonatomic,copy) void(^headerHandle)();//头像

@end

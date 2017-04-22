//
//  UserCouponTableViewCell.h
//  edX
//
//  Created by Elite Edu on 16/8/29.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserCouponItem;

@interface UserCouponTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *firstL;
@property (weak, nonatomic) IBOutlet UILabel *secondL;
@property (weak, nonatomic) IBOutlet UILabel *thirdL;
@property (weak, nonatomic) IBOutlet UILabel *fourthL;

@property (weak, nonatomic) IBOutlet UIView *topV;
@property (weak, nonatomic) IBOutlet UIView *bottomV;
@property (weak, nonatomic) IBOutlet UIView *waterV; //蒙板
@property (weak, nonatomic) IBOutlet UILabel *usedL; //是否使用标志
@property (weak, nonatomic) IBOutlet UILabel *outTime;

@property (weak, nonatomic) IBOutlet UIButton *detailButton;

@property (weak, nonatomic) IBOutlet UIView *detailView;//备注
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (nonatomic,strong) UserCouponItem *UserCouponItem;

@property (nonatomic,copy) void(^showDetailHandle)(BOOL isSelected);

@end

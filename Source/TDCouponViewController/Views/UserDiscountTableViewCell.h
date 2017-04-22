//
//  UserDiscountTableViewCell.h
//  edX
//
//  Created by Elite Edu on 16/8/29.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UserCouponItem;
@interface UserDiscountTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *firstL;
@property (weak, nonatomic) IBOutlet UILabel *secondL;
@property (weak, nonatomic) IBOutlet UILabel *thirdL;
@property (weak, nonatomic) IBOutlet UILabel *fourthL;

@property (nonatomic,strong) UserCouponItem *UserCouponItem;

@end

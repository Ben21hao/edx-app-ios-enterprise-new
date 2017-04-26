//
//  CouponsViewController.h
//  edX
//
//  Created by Elite Edu on 16/10/14.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseViewController.h"
#import "CouponsNameItem.h"

@interface CouponsViewController : TDBaseViewController

@property (nonatomic,copy) void(^selectCouponHandle)(CouponsNameItem *model);

@property (nonatomic,strong) NSString *username;
@property (nonatomic,assign) float apply_amount;
@property (nonatomic,strong) NSString *courseIds;
@property (nonatomic,strong) NSString *couponName;
@property (nonatomic,strong) NSString *selectCouponId;

@end

//
//  SuccessRechargeViewController.h
//  edX
//
//  Created by Elite Edu on 16/9/21.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseViewController.h"

@interface SuccessRechargeViewController : TDBaseViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
//充值金额
@property (weak, nonatomic) IBOutlet UILabel *rechargeTitle;
@property (weak, nonatomic) IBOutlet UILabel *rechargeL;
//充值宝典
@property (weak, nonatomic) IBOutlet UILabel *coinsTitle;
@property (weak, nonatomic) IBOutlet UILabel *rechargeCanonsL;
//剩余宝典
@property (weak, nonatomic) IBOutlet UILabel *totaltitle;
@property (weak, nonatomic) IBOutlet UILabel *totalCanonsL;

@property (nonatomic,strong) NSString *firstL;
@property (nonatomic,strong) NSString *secondL;
@property (nonatomic,strong) NSString *total;
@property (nonatomic,strong) NSString *orderId;

@end

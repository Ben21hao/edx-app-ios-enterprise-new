//
//  SuccessRechargeModel.h
//  edX
//
//  Created by Elite Edu on 16/11/28.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuccessRechargeModel : NSObject

@property (nonatomic,strong) NSString *amount;//充值金额
@property (nonatomic,strong) NSString *coin_record_id;//订单号
@property (nonatomic,strong) NSString *give_coin;//赠送宝典
@property (nonatomic,strong) NSString *remain_coin;//用户总剩余宝典
@property (nonatomic,strong) NSString *suggest_coin;//本次充值宝典
@property (nonatomic,strong) NSString *total_coin;//本次充值总宝典

@end

//
//  CouponsNameItem.h
//  edX
//
//  Created by Elite Edu on 16/10/14.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CouponsNameItem : NSObject

@property (nonatomic,copy) NSString *coupon_name;//名字
@property (nonatomic,copy) NSString *cutdown_price;//减的价格
@property (nonatomic,strong) NSString *coupon_type;//优惠券类型
@property (nonatomic,strong) NSString *discount_rate;//折扣率
@property (nonatomic,strong) NSString *coupon_issue_id;//优惠券id
@property (nonatomic,strong) NSString *act_min_price;//满足金额
@property (nonatomic,strong) NSString *remark;//优惠券详情

@property (nonatomic,strong) NSString *all_price;//原始价格（使用企业优惠券后返回）
@property (nonatomic,strong) NSString *max_coupon_price;//享受企业优惠券课程金额（使用企业优惠券后返回)

@end

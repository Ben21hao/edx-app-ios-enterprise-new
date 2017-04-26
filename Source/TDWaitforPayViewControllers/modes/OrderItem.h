//
//  OrderItem.h
//  edX
//
//  Created by Elite Edu on 16/10/17.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

//@class SubOrderItem;
@interface OrderItem : NSObject

@property (nonatomic,strong) NSString *real_amount;//订单实付金额
@property (nonatomic,strong) NSString *activate_name;//活动名称
@property (nonatomic,strong) NSString *activate_price;//活动价格
@property (nonatomic,strong) NSString *cost_coin;//使用宝典
@property (nonatomic,strong) NSString *coupon_amount;//优惠券金额
@property (nonatomic,strong) NSString *created_at;//订单创建时间
@property (nonatomic,strong) NSString *is_invoice;//是否已开发票
@property (nonatomic,strong) NSString *order_id;//订单ID
@property (nonatomic,strong) NSArray *order_items;//订单明细
@property (nonatomic,strong) NSString *give_coin;//购买课程赠送宝典
@property (nonatomic,strong) NSString *begin_at;//购买课程赠送宝典开始时间
@property (nonatomic,strong) NSString *end_at;//购买课程赠送宝典结束时间

@end

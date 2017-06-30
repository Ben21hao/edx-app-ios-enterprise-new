//
//  TDWaitforPayModel.h
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDWaitfoPayOrderModel : NSObject

@property (nonatomic,strong) NSString *course_id; //课程id
@property (nonatomic,strong) NSString *display_name; //课程名称
@property (nonatomic,strong) NSString *image; //课程图片
@property (nonatomic,strong) NSString *price; //课程原价
@property (nonatomic,strong) NSString *min_price; //课程优惠后金额
@property (nonatomic,strong) NSString *teacher_name; //教授名称

@end

@interface TDWaitforPayModel : NSObject

@property (nonatomic,strong) NSString *order_id; //订单id
@property (nonatomic,strong) NSString *created_at; //订单创建时间
@property (nonatomic,strong) NSString *status; //订单状态

@property (nonatomic,strong) NSString *activate_name; //活动名称
@property (nonatomic,strong) NSString *activate_price; //活动价格
@property (nonatomic,strong) NSString *cost_coin;  //使用宝典
@property (nonatomic,strong) NSString *real_amount; //订单实付金额
@property (nonatomic,strong) NSString *coupon_amount; //优惠券金额
@property (nonatomic,strong) NSString *give_coin; //购买课程赠送金额
@property (nonatomic,strong) NSString *begin_at; //购买课程赠送宝典开始时间
@property (nonatomic,strong) NSString *end_at; //购买课程赠送宝典结束时间
@property (nonatomic,strong) NSString *is_invoice; //是否已开发票

@property (nonatomic,strong) NSArray <TDWaitfoPayOrderModel *> *order_items; //订单明细

@end

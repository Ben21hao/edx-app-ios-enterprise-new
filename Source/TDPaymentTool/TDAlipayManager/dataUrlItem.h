//
//  dataUrlItem.h
//  edX
//
//  Created by Elite Edu on 16/9/12.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface dataUrlItem : NSObject
//购买课程订单号
@property(nonatomic,strong)NSString *order_id;
//商品详情
@property(nonatomic,strong)NSString *body;
//卖家支付宝账号
@property(nonatomic,strong)NSString *seller_email;
//卖家支付宝ID
@property(nonatomic,strong)NSString *seller_id;
//接口名称
@property(nonatomic,strong)NSString *service;
//商户网站唯一订单号
@property(nonatomic,strong)NSString *out_trade_no;
//服务器异步通知页面路径
@property(nonatomic,strong)NSString *notify_url;
//合作者身份ID
@property(nonatomic,strong)NSString *partner;
//签名
@property(nonatomic,strong)NSString *sign;
//同步支付成功后跳转地址
@property(nonatomic,strong)NSString *return_url;
//商品名称
@property(nonatomic,strong)NSString *subject;
//金额
@property(nonatomic,strong)NSString *total_fee;
@end

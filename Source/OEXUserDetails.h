//
//  OEXUserDetails.h
//  edXVideoLocker
//
//  Created by Rahul Varma on 05/06/14.
//  Copyright (c) 2014-2016 edX. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@interface OEXUserDetails : NSObject <NSCopying>

- (id)initWithUserDictionary:(NSDictionary*)userDetails;

- (id)initWithUserDetailsData:(NSData*)data;
- (NSData *)userDetailsData;

@property (nonatomic, copy, nullable) NSNumber *userId; //用户编号
@property (nonatomic, copy, nullable) NSString *username; //登录的名称 - 唯一标示
@property (nonatomic, copy, nullable) NSString *email; //邮箱
@property (nonatomic, copy, nullable) NSString *mobile; //手机号
@property (nonatomic, copy, nullable) NSString *name; //用户名
@property (nonatomic, copy, nullable) NSString *nick_name; //昵称

@property (nonatomic, copy, nullable) NSString *course_enrollments;
@property (nonatomic, copy, nullable) NSString *url;

@property (nonatomic, copy, nullable) NSString *company_id;//公司id
@property (nonatomic, copy, nullable) NSString *logo;//公司logo
@property (nonatomic, copy, nullable) NSString *remain_amount;//公司剩余金额
@property (nonatomic, copy, nullable) NSString *total_amount;//公司总金额
@property (nonatomic, copy, nullable) NSString *remain_coin;//公司剩余宝典
@property (nonatomic, copy, nullable) NSString *total_coin;//公司总宝典
@property (nonatomic, copy, nullable) NSString *is_active;//有效性，默认为true
@property (nonatomic, copy, nullable) NSString *full_name;//公司全名
@property (nonatomic, copy, nullable) NSString *short_name;//公司简称
@property (nonatomic, copy, nullable) NSString *english_name;//公司英文名字
@property (nonatomic, copy, nullable) NSString *introduction;//公司介绍
@property (nonatomic, copy, nullable) NSString *domain_name;//域名
@property (nonatomic, copy, nullable) NSString *language;//语言习惯


/*
 还没处理的公司信息：
 @property (nonatomic,strong) NSString *app_logo;//公司app logo url
 @property (nonatomic,strong) NSString *location;//地址
 @property (nonatomic,strong) NSString *area_code;//区，县代码
 @property (nonatomic,strong) NSString *city_code;//城市代码
 @property (nonatomic,strong) NSString *province_code;//省份代码
 @property (nonatomic,strong) NSString *contact;//联系人
 @property (nonatomic,strong) NSString *contact_number;//联系人电话号码
 @property (nonatomic,strong) NSString *created_at;//数据表创建时间
 @property (nonatomic,strong) NSString *scale;//公司规模代码
 */

@end

NS_ASSUME_NONNULL_END

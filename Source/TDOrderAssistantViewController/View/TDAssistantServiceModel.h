//
//  TDAssistantServiceModel.h
//  edX
//
//  Created by Elite Edu on 17/3/7.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDMp4Model : NSObject

@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSString *url;

@end

@interface TDAssistantCommentModel : NSObject

@property (nonatomic,strong) NSString *content;//评论内容
@property (nonatomic,strong) NSString *score;//分数
@property (nonatomic,strong) NSString *is_allow_share;//是否分享
@property (nonatomic,strong) NSArray *tags;//评论标签 -- id 标签ID; name 标签名称

@end

@interface TDAvatarModel : NSObject

@property (nonatomic,strong) NSString *medium;
@property (nonatomic,strong) NSString *small;
@property (nonatomic,strong) NSString *large;
@property (nonatomic,strong) NSString *full;

@end

@interface TDAssistantServiceModel : NSObject

@property (nonatomic,strong) NSString *id;//服务单号
@property (nonatomic,strong) NSString *status;//预订状态 -- 1：已预约;2：已完成;-1：已取消
@property (nonatomic,strong) NSString *course_display_name;//课程名称
@property (nonatomic,strong) NSString *order_type;//服务类型 1 预约服务； 2 即时服务
@property (nonatomic,strong) NSString *service_type;//

@property (nonatomic,strong) NSString *service_begin_at;//服务开始时间
@property (nonatomic,strong) NSString *service_end_at;//服务结束时间
@property (nonatomic,strong) NSString *now_time;   //当前时间
@property (nonatomic,strong) NSString *service_date;//服务日期
@property (nonatomic,strong) NSString *service_time;//服务日期时间
@property (nonatomic,strong) NSString *question;//咨询问题
@property (nonatomic,strong) NSString *cost_coin;//花费宝典

@property (nonatomic,strong) NSString *order_minute;//预约分钟数
@property (nonatomic,strong) NSString *coin_pre_minute;//Xx宝典/分钟

@property (nonatomic,strong) NSString *assistant_name;//助教名称
@property (nonatomic,strong) TDAvatarModel *avatar_url;//头像

/*已服务*/
@property (nonatomic,strong) NSString *order_time_grap;//预约时间
@property (nonatomic,strong) NSString *real_cost_coin;//实际花费
@property (nonatomic,strong) NSString *is_comment;//是否评论
@property (nonatomic,strong) TDMp4Model *mp4_url;//视频回放url
@property (nonatomic,strong) TDAssistantCommentModel *comment_infomation;//评论信息

@end

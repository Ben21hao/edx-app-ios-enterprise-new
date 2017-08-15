//
//  TDLiveModel.h
//  edX
//
//  Created by Ben on 2017/7/5.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDLiveModel : NSObject

@property (nonatomic,strong) NSString *livename;  //讲座名称
@property (nonatomic,strong) NSString *anchor; //主持人用户名
@property (nonatomic,strong) NSString *live_introduction;  //直播简介
@property (nonatomic,strong) NSString *live_start_at; //讲座开始时间
@property (nonatomic,strong) NSString *now_time;//当前时间
@property (nonatomic,strong) NSString *time; //时长
@property (nonatomic,strong) NSString *vhall_webinar_id;  //微吼活动ID
@property (nonatomic,strong) NSString *vhall_user_id; //用户微吼用户ID
@property (nonatomic,strong) NSString *third_user_id;//第3方用户ID
@property (nonatomic,strong) NSDictionary *enroll; //关联课程
@property (nonatomic,strong) NSString *cover_url; //图片 ??

@end

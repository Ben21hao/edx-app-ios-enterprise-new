//
//  TDTeacherModel.h
//  edX
//
//  Created by Elite Edu on 17/2/28.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDTeacherModel : NSObject

@property (nonatomic,strong) NSString *name;//助教全名
@property (nonatomic,strong) NSString *username;//助教username
@property (nonatomic,strong) NSString *assistant_id; //助教用户id
@property (nonatomic,strong) NSString *id;//助教编号
@property (nonatomic,strong) NSString *introduction;//助教个人介绍
@property (nonatomic,strong) NSString *slogan;//助教宣传语
@property (nonatomic,strong) NSString *awards;//助教获奖情况
@property (nonatomic,strong) NSString *course_room_key;//助教实时课室密钥
@property (nonatomic,strong) NSString *hobbies;//助教兴趣爱好
@property (nonatomic,strong) NSString *is_active;//助教有效性，默认为true
@property (nonatomic,strong) NSString *realtime_status;//助教实时状态，总共有离线(0)，空闲(1)，忙碌(2)3种状态
@property (nonatomic,strong) NSString *service_times;//助教服务学生次数
@property (nonatomic,strong) NSString *skills;//专业技能
@property (nonatomic,strong) NSString *level_of_education;//助教学历
@property (nonatomic,strong) NSString *education_experience;//助教教育背景
@property (nonatomic,strong) NSString *train_experience;//助教培训经历
@property (nonatomic,strong) NSString *work_experience;//助教工作经历
@property (nonatomic,strong) NSDictionary *avatar_url;//助教头像，包含四种尺寸 full/large/medium/small


@end

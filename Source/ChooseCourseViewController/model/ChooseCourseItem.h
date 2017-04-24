//
//  ChooseCourseItem.h
//  edX
//
//  Created by Elite Edu on 16/10/8.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChooseCourseItem : NSObject


@property (nonatomic,strong) NSString *course_pic;//course_pic 课程图片
@property (nonatomic,strong) NSString *min_price;//优惠价
@property (nonatomic,strong) NSString *suggest_price;//原价
@property (nonatomic,strong) NSString *course_display_name;//课程名称
@property (nonatomic,strong) NSString *professor_name;//教授名字
@property (nonatomic,strong) NSString *professor_id;//教授id
@property (nonatomic,strong) NSString *degrees;//学位
@property (nonatomic,strong) NSString *course_id;//课程id
@property (nonatomic,strong) NSString *video_id;//视频ID
@property (nonatomic,assign) BOOL is_buy;//是否购买过课程
@property (nonatomic,strong) NSString *editingState;
@property (nonatomic,assign) BOOL isSelected;//是否选中
@property (nonatomic,assign) BOOL isCompanyCoupon;//使用企业优惠券
@property (nonatomic,strong) NSString *give_coin;//赠送宝典
@property (nonatomic,strong) NSString *begin_at;//购买课程赠送宝典开始时间
@property (nonatomic,strong) NSString *end_at; //购买课程赠送宝典结束时间

@end

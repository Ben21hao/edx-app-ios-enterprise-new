//
//  TDQuetionDetailModel.h
//  edX
//
//  Created by Elite Edu on 2018/1/19.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDReplyVoiceModel : NSObject

@property (nonatomic,strong) NSString *voice_duration;
@property (nonatomic,strong) NSString *voice_url;

@end

@interface TDReplyContentModel : NSObject //回复内容

@property (nonatomic,strong) NSArray *reply_pic_url; //图片数组
@property (nonatomic,strong) NSString *reply_text; //回复内容
@property (nonatomic,strong) TDReplyVoiceModel *reply_voice; //回复语音

@end

@interface TDQuetionReplyInfoModel : NSObject //回复

@property (nonatomic,strong) NSString *is_readed;
@property (nonatomic,strong) NSString *continue_to_ask; //是否是自己的继续问
@property (nonatomic,strong) NSString *reply_at;
@property (nonatomic,strong) NSString *reply_user_name; //用户username
@property (nonatomic,strong) NSString *reply_show_name; //用来显示的名字
@property (nonatomic,strong) NSString *reply_by_pic;       //回复用户的头像
@property (nonatomic,strong) TDReplyContentModel *reply_context; //回复内容

@property (nonatomic,assign) BOOL isPlaying;//正在播放语音

@end

@interface TDQutionUserInfoModel : NSObject //咨询人的信息

@property (nonatomic,strong) NSString *create_user_username; //username
@property (nonatomic,strong) NSString *create_show_username;//用来显示
@property (nonatomic,strong) NSString *create_pic;
@property (nonatomic,strong) NSString *create_time;

@end

@interface TDQuetionVoiceModel : NSObject

@property (nonatomic,strong) NSString *voice_duration;
@property (nonatomic,strong) NSString *voice_url;

@end

@interface TDQutionContextModel : NSObject //咨询内容

@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) TDQuetionVoiceModel *voice;
@property (nonatomic,strong) NSArray *pic_url; //图片数组

@end

@interface TDQuetionDetailModel : NSObject

@property (nonatomic,strong) NSString *consult_id;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) TDQutionContextModel *context; //咨询内容
@property (nonatomic,strong) TDQutionUserInfoModel *create_user_info;//提交咨询用户详情
@property (nonatomic,strong) NSArray *reply_info; //回复数组

@property (nonatomic,assign) BOOL isPlaying;//正在播放语音

@end

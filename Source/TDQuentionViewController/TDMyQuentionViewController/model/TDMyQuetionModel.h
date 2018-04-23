//
//  TDMyQuetionModel.h
//  edX
//
//  Created by Elite Edu on 2018/1/17.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDReplyInfo : NSObject //几条未读消息、时间、头像数组

@property (nonatomic,strong) NSString *all_reply_length;//总条数
@property (nonatomic,strong) NSString *is_not_readed_length; //多少条未读回复
@property (nonatomic,strong) NSString *reply_last_time;
@property (nonatomic,strong) NSArray *reply_user_pic;

@end

@interface TDUserInfo : NSObject //发布人

@property (nonatomic,strong) NSString *create_pic;
@property (nonatomic,strong) NSString *create_time;
@property (nonatomic,strong) NSString *create_user_username;
@property (nonatomic,strong) NSString *create_show_username; //用来显示的名字


@end


@interface TDMyQuetionModel : NSObject

@property (nonatomic,strong) NSString *consult_id; //咨询id
@property (nonatomic,strong) NSString *title; //标题
@property (nonatomic,strong) NSString *is_company_reveiver; //是否为咨询者
@property (nonatomic,strong) TDUserInfo *create_user_info; //发咨询的人信息
@property (nonatomic,strong) TDReplyInfo *reply_info;

@end

//
//  TDMyAnswerModel.h
//  edX
//
//  Created by Elite Edu on 2018/4/28.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDMyAnswerStatus : NSObject

@property (nonatomic,strong) NSString *claim_by;//回复人名字
@property (nonatomic,strong) NSString *consult_status;//1,2:待回复;3,4:待回复(追问);5,6:xxx 正在回复;7:已回复;8:xxx 已回复;9:已解决;10:xxx 已解决;11:用户放弃提问
@property (nonatomic,strong) NSString *claim_by_pic; //头像
@property (nonatomic,strong) NSString *time; //回复时间

@end

@interface TDMyAnswerModel : NSObject

@property (nonatomic,strong) NSString *consult_id;
@property (nonatomic,strong) NSString *created_by_pic;//头像
@property (nonatomic,strong) NSString *created_by; //创建人
@property (nonatomic,strong) NSString *created_at; //创建时间
@property (nonatomic,strong) NSString *content_type;//1:内容，2:语音,3:图片,4:视频
@property (nonatomic,strong) NSString *content; //内容

@property (nonatomic,strong) TDMyAnswerStatus *status;

@end

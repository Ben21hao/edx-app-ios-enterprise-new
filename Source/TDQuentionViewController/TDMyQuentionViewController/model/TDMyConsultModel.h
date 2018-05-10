//
//  TDMyConsultModel.h
//  edX
//
//  Created by Elite Edu on 2018/4/27.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TDConsultStatus : NSObject

@property (nonatomic,strong) NSString *consult_status; //1 等待回复; 2 x条未读信息; 3 正在追问，等待回复;4 已回复; 5 已解决
@property (nonatomic,strong) NSString *num_of_unread;//未读消息条数

@end


@interface TDMyConsultModel : NSObject

@property (nonatomic,strong) NSString *consult_id;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *created_at;
@property (nonatomic,strong) NSString *content_type;//1:内容，2:语音,3:图片,4:视频

@property (nonatomic,strong) TDConsultStatus *status;

@end

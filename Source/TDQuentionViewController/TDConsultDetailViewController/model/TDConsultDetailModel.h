//
//  TDConsultDetailModel.h
//  edX
//
//  Created by Elite Edu on 2018/4/27.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDConsultDetailModel : NSObject

@property (nonatomic,strong) NSString *id;//这条消息的id
@property (nonatomic,strong) NSString *user_id;//用户id
@property (nonatomic,strong) NSString *username;//用户名
@property (nonatomic,strong) NSString *userprofile_image;//用户图像

@property (nonatomic,strong) NSString *content; //内容： 文字显示文字，其他的是一个链接
@property (nonatomic,strong) NSString *content_type; //咨询记录类型; 1:文字; 2:语音; 3:图片; 4:视频
@property (nonatomic,strong) NSString *content_duration;//时间长度 - 视频、语音才用到

@property (nonatomic,strong) NSString *created_at;//咨询创建时间
@property (nonatomic,strong) NSString *is_show_time; //是否显示时间

@property (nonatomic,strong) UIImage *videoImage; //视频缩略图
@property (nonatomic,assign) BOOL isSending; //是否是正在发送的消息

@end

@interface TDConsultContetModel : NSObject

@property (nonatomic,strong) NSString *consult_id; //这条咨询的id
@property (nonatomic,strong) NSString *id;//这条消息的id
@property (nonatomic,strong) NSString *created_at;//咨询创建时间
@property (nonatomic,strong) NSString *is_company_reveicer; //是否是公司联系人
@property (nonatomic,strong) NSString *consult_status;//1:待回复; 2:已经回复; 3:追问，待回复; 4:领取任务; 5:企业联系人放弃回答; 6:已经解决; 7:用户未得到回复，用户放弃咨询
@property (nonatomic,strong) NSString *name; //领取人和解决人名字

@property (nonatomic,strong) NSString *content_duration;

@property (nonatomic,strong) NSString *last_update_time;//用户点击已解决的时间

@property (nonatomic,strong) NSString *is_slove; //是否已解决
@property (nonatomic,strong) NSString *is_claim_by_other; //是否被其他人领取

@property (nonatomic,strong) NSArray <TDConsultDetailModel *>*consult_details;//咨询详情

@end

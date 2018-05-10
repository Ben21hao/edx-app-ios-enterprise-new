//
//  TDConsultDetailViewController.h
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDBaseViewController.h"

typedef NS_ENUM(NSInteger, TDConsultDetailFrom) {
    TDConsultDetailFromUserUnSolve,//我的咨询 - 未解决
    TDConsultDetailFromUserSolve,
    TDConsultDetailFromContactUnSolve, //我的回答 - 未解决
    TDConsultDetailFromContactSolve,
    TDConsultDetailFromNewConsult //新增
};

typedef NS_ENUM(NSInteger, TDContactConsultStatus) { //我的回答 -- 咨询状态
    TDContactConsultStatusWaitReply, //待回复
    TDContactConsultStatusReplying, //我正在回复
    TDContactConsultStatusOtherReplying, //其他人正在回复
    TDContactConsultStatusSolved, //已解决
    TDContactConsultStatusUserGiveUp, //用户放弃回答
};

@interface TDConsultDetailViewController : TDBaseViewController

@property (nonatomic,assign) TDConsultDetailFrom whereFrom;

@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *consultID;
@property (nonatomic,assign) TDContactConsultStatus consultStatus;


@end

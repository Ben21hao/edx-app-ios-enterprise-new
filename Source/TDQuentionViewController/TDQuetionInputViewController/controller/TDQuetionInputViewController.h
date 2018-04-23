//
//  TDQuetionInputViewController.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDBaseViewController.h"

typedef NS_ENUM(NSInteger, TDQuetionInputFrom) {
    TDQuetionInputFromNewQuetion, //新增咨询
    TDQuetionInputFromReply, //回复
    TDQuetionInputFromContinueQution //继续问
};

@interface TDQuetionInputViewController : TDBaseViewController

@property (nonatomic,assign) NSInteger whereFrom;
@property (nonatomic,strong) NSString *titleStr;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *consult_id;

@property (nonatomic,copy) void(^replyHandle)();

@end

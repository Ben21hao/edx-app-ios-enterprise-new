//
//  TDQuetionDetailViewController.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDBaseViewController.h"
#import "TDMyQuetionModel.h"

typedef NS_ENUM(NSInteger, TDQuetionDetailFrom) {
    TDQuetionDetailFromUnSolve,
    TDQuetionDetailFromSolved
};

@interface TDQuetionDetailViewController : TDBaseViewController

@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) TDMyQuetionModel *quetionModel; //咨询id
@property (nonatomic,assign) NSInteger whereFrom; //0 未解决 1 已解决

@end

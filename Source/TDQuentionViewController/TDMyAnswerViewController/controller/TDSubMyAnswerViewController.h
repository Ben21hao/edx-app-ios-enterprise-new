//
//  TDSubMyAnswerViewController.h
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDBaseViewController.h"

typedef NS_ENUM(NSInteger,TDSubAnswerFrom) {
    TDSubAnswerFromUnsolved,
    TDSubAnswerFromSolved
};

@interface TDSubMyAnswerViewController : TDBaseViewController

@property (nonatomic,strong) NSString *username;
@property (nonatomic,assign) TDSubAnswerFrom whereFrom;

@end

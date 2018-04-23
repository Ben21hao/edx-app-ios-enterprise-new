//
//  TDSubMyQuentionViewController.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDBaseViewController.h"

typedef NS_ENUM(NSInteger,TDSubQuetionFrom) {
    TDSubQuetionFromUnsolved,
    TDSubQuetionFromSolved
};

@interface TDSubMyQuentionViewController : TDBaseViewController

@property (nonatomic,strong) NSString *username;
@property (nonatomic,assign) NSInteger whereFrom;


@end

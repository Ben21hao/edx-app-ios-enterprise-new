//
//  TDRegisterViewController.h
//  edX
//
//  Created by Elite Edu on 16/12/30.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TDRegisterViewFrom) {
    TDRegisterViewFromRegister,
    TDRegisterViewFromForgetPassword
};

@interface TDRegisterViewController : TDBaseViewController

@property (nonatomic,assign) NSInteger whereFrom;

@end

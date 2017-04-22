//
//  TDBindEmailViewController.h
//  edX
//
//  Created by Elite Edu on 17/1/5.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseViewController.h"

@interface TDBindEmailViewController : TDBaseViewController

@property (nonatomic,strong) NSString *username;
@property (nonatomic,copy) void(^bindEmailHandle)(NSString *emailStr);

@end

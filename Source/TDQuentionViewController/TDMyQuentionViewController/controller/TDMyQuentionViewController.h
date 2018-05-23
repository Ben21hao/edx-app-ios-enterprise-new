//
//  TDMyQuentionViewController.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDBaseViewController.h"
#import "TDPageingViewController.h"

@interface TDMyQuentionViewController : TDPageingViewController

@property (nonatomic,strong) NSString *username;
@property (nonatomic,assign) NSInteger unreadNum;

@end

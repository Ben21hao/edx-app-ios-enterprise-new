//
//  TDTeacherDetailViewController.h
//  edX
//
//  Created by Elite Edu on 17/2/27.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseViewController.h"
#import "TDTeacherModel.h"

@interface TDTeacherDetailViewController : TDBaseViewController

@property (nonatomic,strong) TDTeacherModel *model;
@property (nonatomic,strong) NSString *myName;

@end

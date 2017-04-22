//
//  TDTeachOrderDetailViewController.h
//  edX
//
//  Created by Elite Edu on 17/2/14.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseViewController.h"
#import "TDAssistantServiceModel.h"

@interface TDTeachOrderDetailViewController : TDBaseViewController

@property (nonatomic,strong) TDAssistantServiceModel *model;
@property (nonatomic,strong) NSString *statusStr;

@end

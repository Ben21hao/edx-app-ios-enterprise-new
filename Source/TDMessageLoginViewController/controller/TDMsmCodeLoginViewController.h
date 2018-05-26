//
//  TDMsmCodeLoginViewController.h
//  edX
//
//  Created by Elite Edu on 2018/5/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TDMsmCodeLoginViewController;

@interface TDMsmCodeLoginViewController : TDBaseViewController

@property (nonatomic,strong) NSString *phoneStr;
@property (nonatomic,strong) NSString *messageStr;

@property (nonatomic,copy) void(^loginActionHandle)();

@end

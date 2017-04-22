//
//  TDOrderCommentViewController.h
//  edX
//
//  Created by Elite Edu on 17/3/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseViewController.h"

@interface TDOrderCommentViewController : TDBaseViewController

@property (nonatomic,strong) NSString *assistantId;//订单Id
@property (nonatomic,strong) NSArray *tagsArray;//标签
@property (nonatomic,strong) NSString *username;//用户名

@property (nonatomic,copy) void(^commentSuccessHandle)();

@end

//
//  TDWebViewController.h
//  edX
//
//  Created by Elite Edu on 17/1/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseViewController.h"

@interface TDWebViewController : TDBaseViewController

@property (nonatomic,strong) NSString *titleStr;
@property (nonatomic,strong) NSURL *url;

@end

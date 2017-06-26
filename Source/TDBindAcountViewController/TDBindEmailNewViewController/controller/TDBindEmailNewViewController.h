//
//  TDBindEmailNewViewController.h
//  edX
//
//  Created by Ben on 2017/6/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDBindEmailNewViewController : TDBaseViewController

@property (nonatomic,strong) NSString *username;
@property (nonatomic,copy) void(^bindEmailHandle)(NSString *emailStr);

@end

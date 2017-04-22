//
//  UserThirdViewController.h
//  edX
//
//  Created by Elite Edu on 16/8/27.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCouponTableViewCell.h"
#import "UserDiscountTableViewCell.h"

@interface UserThirdViewController : UIViewController

@property(nonatomic,copy) NSString *username;

- (void)getNewData;

@end

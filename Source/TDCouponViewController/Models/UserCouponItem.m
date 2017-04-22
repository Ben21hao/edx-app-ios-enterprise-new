//
//  UserCouponItem.m
//  edX
//
//  Created by Elite Edu on 16/8/29.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "UserCouponItem.h"
#import <MJExtension/MJProperty.h>

@implementation UserCouponItem

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"coupons_list":@"UserCouponTextItem"};
}
@end

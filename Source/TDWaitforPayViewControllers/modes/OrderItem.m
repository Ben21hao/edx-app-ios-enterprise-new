//
//  OrderItem.m
//  edX
//
//  Created by Elite Edu on 16/10/17.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "OrderItem.h"
#import <MJExtension/MJExtension.h>

@implementation OrderItem
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"order_items" : @"SubOrderItem"};
}

@end

//
//  PurchaseModel.m
//  edX
//
//  Created by Elite Edu on 16/11/22.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "PurchaseModel.h"

@implementation PurchaseModel

- (NSMutableDictionary *)autoParameteDictionary:(NSInteger)type {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.userName forKey:@"username"];
    [dic setValue:self.trader_num forKey:type == 1 ? @"coin_record_id" : @"order_id"];
    [dic setValue:self.total_fee forKey:@"total_fee"];
    [dic setValue:self.apple_receipt forKey:@"receipt"];
    
    return dic;
}

@end

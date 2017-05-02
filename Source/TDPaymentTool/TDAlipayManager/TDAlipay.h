//
//  TDAlipay.h
//  edX
//
//  Created by Elite Edu on 17/1/14.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <Foundation/Foundation.h> 
#import "TDAliPayModel.h"

@interface TDAlipay : NSObject

- (void)submitPostAliPay:(TDAliPayModel *)aliPayModel; 

@end

//
//  aliData.h
//  edX
//
//  Created by Elite Edu on 16/9/12.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class dataUrlItem;
@interface aliData : NSObject

@property(nonatomic,strong)NSDictionary *data;
@property(nonatomic,strong)dataUrlItem *data_url;
@property(nonatomic,strong)NSString *order_id;

@end

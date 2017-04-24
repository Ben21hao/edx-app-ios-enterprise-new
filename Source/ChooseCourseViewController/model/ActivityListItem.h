//
//  ActivityListItem.h
//  edX
//
//  Created by Elite Edu on 16/10/11.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityListItem : NSObject

@property (nonatomic,assign) NSString *activity_id;//活动id
@property (nonatomic,strong) NSString *other_info;//活动其他信息
@property (nonatomic,strong) NSString *activity_name;//活动名称
@property (nonatomic,assign) NSString *activity_type;//活动类型
@property (nonatomic,assign) BOOL canUse;

@end

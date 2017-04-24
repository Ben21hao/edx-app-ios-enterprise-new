//
//  DataItem.m
//  edX
//
//  Created by Elite Edu on 16/10/11.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "DataItem.h"
#import "MJExtension.h"

@implementation DataItem

+ (NSDictionary *)mj_objectClassInArray{
    
    return @{ @"activity_list" : @"ActivityListItem",
              @"course_list" : @"ChooseCourseItem"
              };
}

@end

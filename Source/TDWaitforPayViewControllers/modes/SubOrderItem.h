//
//  SubOrderItem.h
//  edX
//
//  Created by Elite Edu on 16/10/17.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubOrderItem : NSObject

@property(nonatomic,strong)NSString *course_id;
@property(nonatomic,strong)NSString *display_name;
@property(nonatomic,strong)NSString *image;
@property(nonatomic,strong)NSString *min_price;
@property(nonatomic,strong)NSString *price;
@property(nonatomic,strong)NSString *teacher_name;

@end

//
//  CommentTopItem.h
//  edX
//
//  Created by Elite Edu on 16/10/19.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentTopItem : NSObject

@property (nonatomic,strong) NSString *count;
@property (nonatomic,strong) NSString *tag_name;
@property (nonatomic,strong) NSString *tag_id;
@property (nonatomic,assign) BOOL isSelected;

@end

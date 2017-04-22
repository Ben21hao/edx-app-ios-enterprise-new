//
//  TDAssistantCommentTagModel.h
//  edX
//
//  Created by Elite Edu on 17/3/8.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDAssistantCommentTagModel : NSObject

@property (nonatomic,strong) NSString *tag_name;
@property (nonatomic,strong) NSString *tag_id;
@property (nonatomic,assign) BOOL isSelected;

@end

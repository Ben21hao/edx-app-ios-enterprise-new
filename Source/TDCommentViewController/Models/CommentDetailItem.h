//
//  CommentDetailItem.h
//  edX
//
//  Created by Elite Edu on 16/10/19.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentDetailItem : NSObject

@property (nonatomic,copy) NSString *content;//评论内容
@property (nonatomic,copy) NSString *score;//评价分
@property (nonatomic,copy) NSString *praise_num;//评论被点赞次数
@property (nonatomic,copy) NSString *created_at;//创建时间
@property (nonatomic,copy) NSString *comment_id;//评论id
@property (nonatomic,copy) NSString *user_id;//评论用户id
@property (nonatomic,copy) NSString *user_name;//评论用户名
@property (nonatomic,copy) NSString *avatar_url;//评论人头像
@property (nonatomic,strong) NSArray *tags;//评论所选取标签信息列表

@property (nonatomic,assign) BOOL is_praise;//是否点赞
@property (nonatomic,assign) BOOL click_Open;
@property (nonatomic,assign) BOOL showMoreButton;
@property (nonatomic,assign) float maxCommentLabelHeight;

@property (nonatomic,assign) BOOL isOpening;
@property (nonatomic, assign, readonly) BOOL shouldShowMoreButton;

@end

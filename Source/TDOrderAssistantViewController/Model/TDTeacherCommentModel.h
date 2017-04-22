//
//  TDTeacherCommentModel.h
//  edX
//
//  Created by Elite Edu on 17/2/28.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDTeacherCommentModel : NSObject

@property (nonatomic,strong) NSString *content;//评论内容
@property (nonatomic,strong) NSString *score;//评价分数
@property (nonatomic,strong) NSString *praise_num;//此条评论点赞次数
@property (nonatomic,strong) NSString *create_at;//评论创建时间
@property (nonatomic,strong) NSString *id;//评论编码id
@property (nonatomic,strong) NSString *nick_name;//评论人昵称
@property (nonatomic,strong) NSDictionary *avatar_url;//评论人头像
@property (nonatomic,strong) NSArray *comment_tags;//评论标签列表
@property (nonatomic,assign) BOOL is_praise;//当前用户是否已经点赞
@property (nonatomic,strong) NSString *is_allowed_share;//是否允许分享该评论

@property (nonatomic,assign) BOOL click_Open;
@property (nonatomic,assign) BOOL showMoreButton;
@property (nonatomic,assign) float maxCommentLabelHeight;

@property (nonatomic,assign) BOOL isOpening;
@property (nonatomic, assign, readonly) BOOL shouldShowMoreButton;

@end

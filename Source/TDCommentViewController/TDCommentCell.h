//
//  TDCommentCell.h
//  edX
//
//  Created by Elite Edu on 17/1/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentDetailItem.h"

@class CommentDetailItem;

@interface TDCommentCell : UITableViewCell

@property (nonatomic,strong) NSString *username;//用户名
@property (nonatomic,copy) void(^clickPraiseButton)(NSString *praiseNum,BOOL isPraise);//点赞
@property (nonatomic,copy) void(^moreButtonActionHandle)(BOOL isOpen,float maxCommentLabelHeight);

@property (nonatomic,strong) CommentDetailItem *detailItem;

@end

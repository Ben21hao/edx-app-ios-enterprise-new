//
//  TDOrderCommentCell.h
//  edX
//
//  Created by Elite Edu on 17/2/28.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDTeacherCommentModel.h"

@interface TDOrderCommentCell : UITableViewCell

@property (nonatomic,strong) NSString *username;//用户名
@property (nonatomic,strong) TDTeacherCommentModel *detailItem;

@property (nonatomic,copy) void(^clickPraiseButton)(NSString *praiseNum,BOOL isPraise);//点赞
@property (nonatomic,copy) void(^moreButtonActionHandle)(BOOL isOpen,float maxCommentLabelHeight);

@end

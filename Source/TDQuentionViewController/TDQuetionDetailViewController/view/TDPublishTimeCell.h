//
//  TDPublishTimeCell.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDBaseNormalCell.h"
#import "TDRoundHeadImageView.h"
#import "TDQuetionDetailModel.h"

@interface TDPublishTimeCell : TDBaseNormalCell

@property (nonatomic,strong) TDRoundHeadImageView *headerImage;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,strong) TDQuetionDetailModel *quetionModel; //咨询
@property (nonatomic,strong) TDQuetionReplyInfoModel *replyModel; //回复

@end

//
//  TDQuentionMessageCell.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDBaseNormalCell.h"
#import "TDRoundHeadImageView.h"

#import "TDMyAnswerModel.h"

@interface TDQuentionMessageCell : TDBaseNormalCell

@property (nonatomic,strong) TDMyAnswerModel *model;
@property (nonatomic,assign) NSInteger whereFrom;

@property (nonatomic,strong) TDRoundHeadImageView *headerImage;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *postTimeLabel;
@property (nonatomic,strong) UILabel *quetionLabel;

@property (nonatomic,strong) UILabel *line;
@property (nonatomic,strong) UILabel *statusLabel;
@property (nonatomic,strong) UILabel *timeLabel;


@end

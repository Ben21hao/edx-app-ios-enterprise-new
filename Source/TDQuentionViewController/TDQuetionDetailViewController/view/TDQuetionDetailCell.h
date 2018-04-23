//
//  TDQuetionDetailCell.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDBaseNormalCell.h"
#import "TDAudioPlayView.h"
#import "TDQuetionDetailModel.h"

@interface TDQuetionDetailCell : TDBaseNormalCell

@property (nonatomic,strong) UILabel *quetionTitle;
@property (nonatomic,strong) UILabel *quetionDetail;
@property (nonatomic,strong) TDAudioPlayView *audioPlayView;
@property (nonatomic,strong) UIView *photoView;

@property (nonatomic,strong) TDQuetionDetailModel *quetionModel; //咨询
@property (nonatomic,strong) TDQuetionReplyInfoModel *replyModel; //回复
@property (nonatomic,assign) NSInteger index;

@property (nonatomic,copy) void(^tapImageHandle)(NSInteger tag);
@property (nonatomic,copy) void(^tapVoiceViewHandle)(BOOL isPlay);

@end

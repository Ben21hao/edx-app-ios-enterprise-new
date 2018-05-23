//
//  TDConsultAudioCell.h
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDBaseNormalCell.h"
#import "TDConsultTimeView.h"
#import "TDAudioPlayView.h"

#import "TDConsultDetailModel.h"

@interface TDConsultAudioCell : TDBaseNormalCell

@property (nonatomic,strong) TDConsultTimeView *timeView;
@property (nonatomic,strong) TDAudioPlayView *audioPlayView;
@property (nonatomic,strong) UIButton *statusButton;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;

@property (nonatomic,strong) TDConsultDetailModel *detailModel;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,assign) NSInteger index;

@property (nonatomic,copy) void(^tapVoiceViewHandle)(BOOL isPlay);

@end

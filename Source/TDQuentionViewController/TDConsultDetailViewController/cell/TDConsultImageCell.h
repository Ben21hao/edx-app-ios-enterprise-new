//
//  TDConsultImageCell.h
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDBaseNormalCell.h"
#import "TDConsultTimeView.h"
#import "TDConsultDetailModel.h"

@interface TDConsultImageCell : TDBaseNormalCell

@property (nonatomic,strong) TDConsultTimeView *timeView;
@property (nonatomic,strong) UIButton *statusButton;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;

@property (nonatomic,strong) TDConsultDetailModel *detailModel;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,copy) void(^tapImageHandle)(NSArray *imageArray,NSInteger tag);

@end

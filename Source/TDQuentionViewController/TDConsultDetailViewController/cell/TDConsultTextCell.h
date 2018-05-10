//
//  TDConsultTextCell.h
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDBaseNormalCell.h"
#import "TDConsultTimeView.h"
#import "TDConsultDetailModel.h"

@interface TDConsultTextCell : TDBaseNormalCell

@property (nonatomic,strong) TDConsultTimeView *timeView;

@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *quetionLabel;
@property (nonatomic,strong) UIButton *statusButton;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;

@property (nonatomic,strong) TDConsultDetailModel *detailModel;

@end

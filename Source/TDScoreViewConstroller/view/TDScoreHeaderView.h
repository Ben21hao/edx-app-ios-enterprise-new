//
//  TDScoreHeaderView.h
//  edX
//
//  Created by Elite Edu on 2018/5/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDCourseScoreModel.h"

@interface TDScoreHeaderView : UIView

@property (nonatomic,strong) UILabel *statusLabel;
@property (nonatomic,strong) UILabel *scoreLabel; //课程得分百分比
@property (nonatomic,strong) UILabel *showLabel;
@property (nonatomic,strong) UIImageView *bgImageView;
@property (nonatomic,strong) UIImageView *leftImageView;
@property (nonatomic,strong) UIImageView *rightImageView;
@property (nonatomic,strong) UIImageView *passImageView;
@property (nonatomic,strong) UILabel *passLabel;
@property (nonatomic,strong) UILabel *percentLabel; //进度泡
@property (nonatomic,strong) UIProgressView *progressView;

@property (nonatomic,strong) TDCourseScoreModel *scoreModel;

@end

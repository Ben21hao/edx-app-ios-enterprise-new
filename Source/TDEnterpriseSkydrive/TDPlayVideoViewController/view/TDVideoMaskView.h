//
//  TDVideoMaskView.h
//  EdxProject
//
//  Created by Elite Edu on 2018/4/11.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TDSlider.h"
#import "TDLoadingView.h"

@interface TDVideoMaskView : UIView

@property (nonatomic,strong) UIView *topBarView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIButton *returnButton;

@property (nonatomic,strong) UIView *bottomBarView; //底部工具类
@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UIButton *fullScreenButton;

@property (nonatomic,strong) UILabel *currentTimeLabel;
@property (nonatomic,strong) UILabel *totalTimeLabel;
@property (nonatomic,strong) UILabel *captionLabel; //字幕

@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) TDSlider *slider;

@property (nonatomic,strong) TDLoadingView *loadingView; //加载
@property (nonatomic,strong) UIButton *failButton; //加载失败，重新加载

/*
 单独给出属性，为了处理文字样式
 */
@property (nonatomic,strong) NSString *captionStr; //字幕
@property (nonatomic,strong) NSString *totalTimeStr; //总时间
@property (nonatomic,strong) NSString *currentTimeStr; //播放时间

@property (nonatomic,copy) void(^tapSliderHandle)(CGFloat value);

@end

//
//  TDVideoBarView.h
//  edX
//
//  Created by Elite Edu on 17/3/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDVideoBarView : UIView

@property (nonatomic,strong) UIButton *rewindButton;//快退
@property (nonatomic,strong) UISlider *timeSlider;//时间条
@property (nonatomic,strong) UILabel *timeLabel;//时间显示
@property (nonatomic,strong) UIButton *settingButton;//字符设置
@property (nonatomic,strong) UIButton *fullScreenButton;//全屏

@end

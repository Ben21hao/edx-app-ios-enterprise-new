//
//  TDSkydriveAudioView.h
//  edX
//
//  Created by Elite Edu on 2018/6/11.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDSlider.h"

@interface TDSkydriveAudioView : UIView

@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *totalLabel;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) TDSlider *slider;
@property (nonatomic,strong) UIButton *playButton;

@end

//
//  TDSkydriveAudioView.m
//  edX
//
//  Created by Elite Edu on 2018/6/11.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveAudioView.h"

@implementation TDSkydriveAudioView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - UI
- (void)configView {
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
    
    self.playButton = [self setPlayButton];
    [self addSubview:self.playButton];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.timeLabel];
    
    self.totalLabel = [[UILabel alloc] init];
    self.totalLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.totalLabel.textAlignment = NSTextAlignmentCenter;
    self.totalLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.totalLabel];
    
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.trackTintColor = [UIColor colorWithHexString:colorHexStr9];
    self.progressView.progressTintColor = [UIColor  colorWithHexString:colorHexStr7];
    [self addSubview:self.progressView];
    
    self.slider = [[TDSlider alloc] init];
    [self addSubview:self.slider];
    
    self.slider.value = 0.0;
    self.progressView.progress = 1.0;
    self.timeLabel.text = @"00:00";
}

- (void)setViewConstraint {
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(8);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playButton.mas_right).offset(0);
        make.centerY.mas_equalTo(self.playButton.mas_centerY);
        make.width.mas_equalTo(48);
    }];
    
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-8);
        make.centerY.mas_equalTo(self.playButton.mas_centerY);
        make.width.mas_equalTo(48);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_right).offset(8);
        make.right.mas_equalTo(self.totalLabel.mas_left).offset(-8);
        make.centerY.mas_equalTo(self.playButton.mas_centerY);
        make.height.mas_equalTo(2);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.progressView);
    }];
   
}

- (UIButton *)setPlayButton {
    
    UIButton *button = [[UIButton alloc] init];
    button.showsTouchWhenHighlighted = YES;
    [button setImage:[UIImage imageNamed:@"pause_image"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"play_image"] forState:UIControlStateSelected];
    
    return button;
}


@end

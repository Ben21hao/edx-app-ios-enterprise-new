//
//  TDVideoMaskView.m
//  EdxProject
//
//  Created by Elite Edu on 2018/4/11.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDVideoMaskView.h"

@interface TDVideoMaskView ()

@end

@implementation TDVideoMaskView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configeView];
        [self setViewConstraint];
    }
    return self;
}

- (void)configeView {
    
    [self addSubview:self.loadingView];
    [self addSubview:self.failButton];
    [self addSubview:self.captionLabel];
    
    [self addSubview:self.topBarView];
    [self.topBarView addSubview:self.returnButton];
    [self.topBarView addSubview:self.titleLabel];
    
    [self addSubview:self.bottomBarView];
    [self.bottomBarView addSubview:self.playButton];
    [self.bottomBarView addSubview:self.fullScreenButton];
    [self.bottomBarView addSubview:self.progressView];
    [self.bottomBarView addSubview:self.slider];
    [self.bottomBarView addSubview:self.currentTimeLabel];
    [self.bottomBarView addSubview:self.totalTimeLabel];
    
    self.topBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    self.bottomBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    self.progressView.progress = 0.0;
    self.slider.value = 0.0;
    self.exclusiveTouch = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.slider addGestureRecognizer:tap];
}

- (void)tapGestureAction:(UITapGestureRecognizer *)gesture {
    
    CGPoint point = [gesture locationInView:self.slider];
    self.slider.value = point.x / self.slider.bounds.size.width;
    
    if (self.tapSliderHandle) {
        self.tapSliderHandle(self.slider.value);
    }
}

- (void)setViewConstraint {
    
    [self.topBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo(43);
    }];
    
    [self.returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.topBarView.mas_left).offset(0);
        make.centerY.mas_equalTo(self.topBarView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(43, 43));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topBarView.mas_centerY);
        make.centerX.mas_equalTo(self.topBarView.mas_centerX);
        make.left.mas_greaterThanOrEqualTo(self.returnButton.mas_right);
    }];
    
    [self.bottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(43);
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomBarView.mas_centerY);
        make.left.mas_equalTo(self.bottomBarView.mas_left).offset(0);
        make.size.mas_equalTo(CGSizeMake(33, 33));
    }];
    
    [self.fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomBarView.mas_centerY);
        make.right.mas_equalTo(self.bottomBarView.mas_right).offset(0);
        make.size.mas_equalTo(CGSizeMake(33, 33));
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomBarView.mas_centerY);
        make.left.mas_equalTo(self.playButton.mas_right).offset(0);
        make.width.mas_equalTo(43);
    }];
    
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomBarView.mas_centerY);
        make.right.mas_equalTo(self.fullScreenButton.mas_left).offset(0);
        make.width.mas_equalTo(43);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomBarView.mas_centerY);
        make.left.mas_equalTo(self.currentTimeLabel.mas_right).offset(8);
        make.right.mas_equalTo(self.totalTimeLabel.mas_left).offset(-8);
        make.height.mas_equalTo(2);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.progressView);
    }];

    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.failButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(118, 33));
    }];
    
    [self.captionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(8);
        make.right.mas_equalTo(self.mas_right).offset(-8);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-23);
    }];
}

#pragma mark - 懒加载
- (UIView *)topBarView {
    if (!_topBarView) {
        _topBarView = [[UIView alloc] init];
    }
    return _topBarView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)returnButton {
    if (!_returnButton) {
        _returnButton = [[UIButton alloc] init];
        [_returnButton setImage:[UIImage imageNamed:@"backImagee"] forState:UIControlStateNormal];
    }
    return _returnButton;
}

- (UIView *)bottomBarView {
    if (!_bottomBarView) {
        _bottomBarView = [[UIView alloc] init];
    }
    return _bottomBarView;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"video_Pause"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"video_Play"] forState:UIControlStateSelected];
    }
    return _playButton;
}

- (UIButton *)fullScreenButton {
    if (!_fullScreenButton) {
        _fullScreenButton = [[UIButton alloc] init];
        [_fullScreenButton setImage:[UIImage imageNamed:@"full_screen_image"] forState:UIControlStateNormal];
        [_fullScreenButton setImage:[UIImage imageNamed:@"exit_full_screen_image"] forState:UIControlStateSelected];
    }
    return _fullScreenButton;
}

- (UIButton *)failButton {
    if (!_failButton) {
        _failButton = [[UIButton alloc] init];
        _failButton.hidden = YES;
        _failButton.layer.masksToBounds = YES;
        _failButton.layer.cornerRadius = 4.0;
        _failButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _failButton.layer.borderWidth = 0.5;
        _failButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
        [_failButton setAttributedTitle:[self setTitleAttrButeText:@"加载失败，重新加载" fontSize:12] forState:UIControlStateNormal];
    }
    return _failButton;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.trackTintColor = [UIColor colorWithHexString:colorHexStr9];
        _progressView.progressTintColor = [UIColor colorWithHexString:colorHexStr7];
    }
    return _progressView;
}

- (TDSlider *)slider {
    if (!_slider) {
        _slider = [[TDSlider alloc] init];
    }
    return _slider;
}

- (TDLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[TDLoadingView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _loadingView.strokeColor = [UIColor colorWithHexString:colorHexStr1];
        [_loadingView startLoadingAnimation];
    }
    return _loadingView;
}

- (UILabel *)captionLabel {
    if (!_captionLabel) {
        _captionLabel = [[UILabel alloc] init];
        _captionLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _captionLabel;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [self setTimeLabelSyle];
    }
    return _currentTimeLabel;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [self setTimeLabelSyle];
    }
    return _totalTimeLabel;
}

- (UILabel *)setTimeLabelSyle {
    UILabel *label = [[UILabel alloc] init];
    label.adjustsFontSizeToFitWidth = YES;
    label.attributedText = [self setTitleAttrButeText:@"00:00" fontSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

#pragma mark - 设置字幕
- (void)setCaptionStr:(NSString *)captionStr {
    _captionStr = captionStr;
    
    self.captionLabel.attributedText = [self setTitleAttrButeText:captionStr fontSize:13];
}

- (void)setTotalTimeStr:(NSString *)totalTimeStr {
    _totalTimeStr = totalTimeStr;
    
    self.totalTimeLabel.attributedText = [self setTitleAttrButeText:totalTimeStr fontSize:12];
}

- (void)setCurrentTimeStr:(NSString *)currentTimeStr {
    _currentTimeStr = currentTimeStr;
    
    self.currentTimeLabel.attributedText = [self setTitleAttrButeText:currentTimeStr fontSize:12];
}

- (NSMutableAttributedString *)setTitleAttrButeText:(NSString *)text fontSize:(NSInteger)font { //黑边空心文字
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 1.0;
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowOffset = CGSizeMake(1, 1);
    
    NSDictionary *attributeDic = @{
                                   NSForegroundColorAttributeName : [UIColor whiteColor],
//                                   NSStrokeWidthAttributeName : @-3.0,
//                                   NSStrokeColorAttributeName : [UIColor blackColor],
                                   NSVerticalGlyphFormAttributeName : @(0),
                                   NSShadowAttributeName : shadow,
                                   NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:font]
                                   };
    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:text attributes:attributeDic];
    return  attributeText;
}

@end

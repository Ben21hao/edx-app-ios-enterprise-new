//
//  TDVideoBarView.m
//  edX
//
//  Created by Elite Edu on 17/3/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDVideoBarView.h"
#import "edX-Swift.h"

#define customButtonWidth 44
#define customButtonHeight 48

@interface TDVideoBarView ()

@end

@implementation TDVideoBarView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];//这样就不会影响到子控制器的透明度
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - UI
- (void)configView {
    self.rewindButton = [self setButtonConstraint:[UIImage RewindIcon]];
    [self addSubview:self.rewindButton];
    
    self.timeSlider = [[UISlider alloc] init];
    self.timeSlider.continuous = YES;
    [self.timeSlider setThumbImage:[UIImage imageNamed:@"ic_seek_thumb"] forState:UIControlStateNormal];
    [self addSubview:self.timeSlider];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.text = @"0:05 / 9:55";
    [self addSubview:self.timeLabel];
    
    self.settingButton = [self setButtonConstraint:[UIImage SettingsIcon]];
    [self addSubview:self.settingButton];
    
    self.fullScreenButton = [self setButtonConstraint:[UIImage ExpandIcon]];
    [self.fullScreenButton setImage:[UIImage ShrinkIcon] forState:UIControlStateSelected];
    [self addSubview:self.fullScreenButton];
}

- (UIButton *)setButtonConstraint:(UIImage *)image {
    UIButton *button = [[UIButton alloc] init];
    button.imageEdgeInsets = UIEdgeInsetsMake(12, 11.5, 12, 11.5);
    button.showsTouchWhenHighlighted = YES;
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor whiteColor]];
    return button;
}

- (void)setViewConstraint {
    [self.rewindButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(0);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(customButtonWidth, customButtonHeight));
    }];
    
    [self.fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(0);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(customButtonWidth, customButtonHeight));
    }];
    
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.fullScreenButton.mas_left).offset(8);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(customButtonWidth, customButtonHeight));
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.settingButton.mas_left).offset(8);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(88, customButtonHeight));
    }];
    
    [self.timeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rewindButton.mas_right).offset(0);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(self.timeLabel.mas_left).offset(0);
    }];

}

@end



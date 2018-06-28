//
//  TDSkydriveAlertView.m
//  edX
//
//  Created by Elite Edu on 2018/6/7.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveAlertView.h"
#import "TDSkydriveShareView.h"

@interface TDSkydriveAlertView ()

@property (nonatomic,strong) UIView *alertView;

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) TDSkydriveShareView *oneDayView;
@property (nonatomic,strong) TDSkydriveShareView *sevenDayView;
@property (nonatomic,strong) TDSkydriveShareView *foreverView;

@end

@implementation TDSkydriveAlertView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)selectButtonAction:(UIButton *)sender {
    [self selectButtonIndex:sender.tag];
}

- (void)selectButtonIndex:(NSInteger)index {
    
    self.oneDayView.selectButton.selected = index == 0 ? YES : NO;
    self.sevenDayView.selectButton.selected = index == 1 ? YES : NO;
    self.foreverView.selectButton.selected = index == 2 ? YES : NO;
    
    self.timeType = index;
}

#pragma mark - UI
- (void)configView {
    
    self.bgButton = [[UIButton alloc] init];
    self.bgButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self addSubview:self.bgButton];
    
    self.alertView = [[UIView alloc] init];
    self.alertView.layer.masksToBounds = YES;
    self.alertView.layer.cornerRadius = 8.0;
    self.alertView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.alertView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"#6e6e6e"];
    [self addSubview:self.titleLabel];
    
    self.oneDayView = [self skyTimeView:TDSkydriveShareTimeOneDay];
    [self.alertView addSubview:self.oneDayView];
    
    self.sevenDayView = [self skyTimeView:TDSkydriveShareTimeSevenDay];
    [self.alertView addSubview:self.sevenDayView];
    
    self.foreverView = [self skyTimeView:TDSkydriveShareTimeForever];
    [self.alertView addSubview:self.foreverView];
    
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.showsTouchWhenHighlighted = YES;
    self.cancelButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15];
    [self.cancelButton setTitleColor:[UIColor colorWithHexString:colorHexStr13] forState:UIControlStateNormal];
    [self.alertView addSubview:self.cancelButton];
    
    self.sureButton = [[UIButton alloc] init];
    self.sureButton.showsTouchWhenHighlighted = YES;
    self.sureButton.backgroundColor = [UIColor colorWithHexString:colorHexStr10];
    self.sureButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15];
    [self.sureButton setTitleColor:[UIColor colorWithHexString:colorHexStr13] forState:UIControlStateNormal];
    [self.alertView addSubview:self.sureButton];
    
    self.titleLabel.text = TDLocalizeSelect(@"SKY_AVAILABLE_PERIOD", nil);
    [self.cancelButton setTitle:TDLocalizeSelect(@"SKY_PUBLIC", nil) forState:UIControlStateNormal];
    [self.sureButton setTitle:TDLocalizeSelect(@"SKY_ENCRYPTED", nil) forState:UIControlStateNormal];
    
    self.oneDayView.titleLabel.text = TDLocalizeSelect(@"SKY_ONE_DAY", nil);
    self.sevenDayView.titleLabel.text = TDLocalizeSelect(@"SKY_SEVEN_DAY", nil);
    self.foreverView.titleLabel.text = TDLocalizeSelect(@"SKY_ALWAYS", nil);
    
    self.foreverView.selectButton.selected = YES;
    self.timeType = TDSkydriveShareTimeForever;
}

- (TDSkydriveShareView *)skyTimeView:(TDSkydriveShareTime)timeType {
    
    TDSkydriveShareView *skyShareView = [[TDSkydriveShareView alloc] init];
    skyShareView.selectButton.tag = timeType;
    skyShareView.bgButton.tag = timeType;
    [skyShareView.selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [skyShareView.bgButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return skyShareView;
}

- (void)setViewConstraint {
    
    [self.bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    
    CGFloat width = (TDWidth / 3) * 2;
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgButton.mas_centerX);
        make.centerY.mas_equalTo(self.bgButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(width, 235));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.alertView.mas_left).offset(13);
        make.top.mas_equalTo(self.alertView.mas_top).offset(8);
        make.height.mas_equalTo(29);
    }];
    
    [self.oneDayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.left.right.mas_equalTo(self.alertView);
        make.height.mas_equalTo(48);
    }];
    
    [self.sevenDayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.oneDayView.mas_bottom);
        make.left.right.mas_equalTo(self.alertView);
        make.height.mas_equalTo(48);
    }];
    
    [self.foreverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sevenDayView.mas_bottom);
        make.left.right.mas_equalTo(self.alertView);
        make.height.mas_equalTo(48);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.alertView.mas_left);
        make.bottom.mas_equalTo(self.alertView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(width/2, 39));
    }];
    
    [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.alertView.mas_right);
        make.bottom.mas_equalTo(self.alertView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(width/2, 39));
    }];
}

@end

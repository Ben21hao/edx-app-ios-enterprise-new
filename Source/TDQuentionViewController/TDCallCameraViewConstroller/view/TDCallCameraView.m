//
//  TDCallCameraView.m
//  edX
//
//  Created by Elite Edu on 2018/4/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDCallCameraView.h"

@interface TDCallCameraView ()

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) int second;

@end

@implementation TDCallCameraView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

#pragma makr - 按钮处理
- (void)showSelectButtonHandle {//拍摄完成，显示选择
    
    self.selectButton.hidden = NO;
    self.discarButton.hidden = NO;
    
    self.exchangeButton.hidden = YES;
    self.cameraImageView.hidden = YES;
    self.centerWhiteImage.hidden = YES;
    
    if ([self.timer isValid]) {
        [self invalidateTimer];
    }
    
    [self.discarButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_left).offset(TDWidth / 4);
        make.centerY.mas_equalTo(self.cameraImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(82, 82));
    }];
    
    [self.selectButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_right).offset(- TDWidth / 4);
        make.centerY.mas_equalTo(self.cameraImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(82, 82));
    }];
}

- (void)hideSelectButtonHandle { //重新拍摄
    
    self.selectButton.hidden = YES;
    self.discarButton.hidden = YES;
    
    self.cameraImageView.hidden = NO;
    self.centerWhiteImage.hidden = NO;
    self.dismissButton.hidden = NO;
    self.exchangeButton.hidden = NO;
    
    [self showMindLabel];
    
    [self.discarButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.centerX);
        make.centerY.mas_equalTo(self.cameraImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(82, 82));
    }];
    
    [self.selectButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.centerX);
        make.centerY.mas_equalTo(self.cameraImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(82, 82));
    }];
}

- (void)updateCameraButtonConstraint:(BOOL)isBig {
    
    CGFloat width = isBig ? 60 : 30;
    self.centerWhiteImage.layer.cornerRadius = width / 2;
    [self.centerWhiteImage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.cameraImageView);
        make.size.mas_equalTo(CGSizeMake(width, width));
    }];
}

- (void)showMindLabel { //显示提示
    self.mindLabel.hidden = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidenMindLabel) userInfo:nil repeats:YES];
}

- (void)hidenMindLabel { //隐藏提示
    self.second ++;
    
    if (self.second > 3) {
        [self invalidateTimer];
    }
}

- (void)invalidateTimer {
    
    [self.timer invalidate];
    self.timer = nil;
    
    self.second = 0;
    self.mindLabel.hidden = YES;
}

#pragma mark - UI
- (void)configView {
    
    [self showMindLabel];
    
    self.backgroundColor = [UIColor colorWithHexString:colorHexStr13];
    
    self.exchangeButton = [[UIButton alloc] init];
    [self.exchangeButton setImage:[UIImage imageNamed:@"change_camera"] forState:UIControlStateNormal];
    [self addSubview:self.exchangeButton];
    
    self.dismissButton = [[UIButton alloc] init];
    [self.dismissButton setImage:[UIImage imageNamed:@"dimiss_down_image"] forState:UIControlStateNormal];
    [self addSubview:self.dismissButton];
    
    self.cameraImageView = [self setButtonStyleWithImage:@"gred_circle_round" cornerRadius:41];
    [self addSubview:self.cameraImageView];
    
    self.centerWhiteImage = [[UIImageView alloc] init];
    self.centerWhiteImage.image = [UIImage imageNamed:@"white_circle_round"];
    self.centerWhiteImage.layer.masksToBounds = YES;
    self.centerWhiteImage.layer.cornerRadius = 30;
    [self addSubview:self.centerWhiteImage];
    
    self.mindLabel = [[UILabel alloc] init];
    self.mindLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.mindLabel.textColor = [UIColor whiteColor];
    self.mindLabel.text = @"轻按拍摄 按住摄像";
    [self addSubview:self.mindLabel];
    
    self.discarButton = [self setButtonStyleWithImage:@"back_cicle_round" cornerRadius:41];
    [self addSubview:self.discarButton];
    
    self.selectButton = [self setButtonStyleWithImage:@"selecte_circle_round" cornerRadius:41];
    [self addSubview:self.selectButton];
    
    self.focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.focusView.layer.borderWidth = 1.0;
    self.focusView.layer.borderColor =[UIColor greenColor].CGColor;
    self.focusView.backgroundColor = [UIColor clearColor];
    [self addSubview:_focusView];
    self.focusView.hidden = YES;
}

- (void)setViewConstraint {
    
    [self.exchangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(18);
        make.right.mas_equalTo(self).offset(-18);
        make.size.mas_equalTo(CGSizeMake(39, 39));
    }];
    
    [self.cameraImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-88);
        make.size.mas_equalTo(CGSizeMake(82, 82));
    }];
    
    [self.centerWhiteImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.cameraImageView);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_left).offset(TDWidth / 4);
        make.centerY.mas_equalTo(self.cameraImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(82, 82));
    }];
    
    [self.mindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.cameraImageView.mas_centerX);
        make.bottom.mas_equalTo(self.cameraImageView.mas_top).offset(-18);
    }];
    
    [self.discarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.centerX);
        make.centerY.mas_equalTo(self.cameraImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(82, 82));
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.centerX);
        make.centerY.mas_equalTo(self.cameraImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(82, 82));
    }];
    
    self.discarButton.hidden = YES;
    self.selectButton.hidden = YES;
}

- (UIButton *)setButtonStyleWithImage:(NSString *)imageStr cornerRadius:(CGFloat)radius {
    
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = radius;
    return button;
}

@end

//
//  TDVideoUrlPlayController.m
//  edX
//
//  Created by Elite Edu on 17/3/31.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDVideoUrlPlayController.h"
#import <MediaPlayer/MediaPlayer.h>

#import "TDCaptionView.h"

#import "OEXStyles.h"
#import "edX-Swift.h"

#define TDVideo_Height_Percentage 0.6

static const NSTimeInterval RewindTimeInterval = 30;

@interface TDVideoUrlPlayController () <UIGestureRecognizerDelegate>

@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;

@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) TDCaptionView *captionView;//字幕
@property (nonatomic,strong) UIButton *playButton;//播放
@property (nonatomic,strong) UIActivityIndicatorView *activityView;//加载

@property (nonatomic,assign) BOOL isShowControlBar;//是否显示PlayTitle
@property (nonatomic,strong) NSTimer *durationTimer;


@end

@implementation TDVideoUrlPlayController

- (MPMoviePlayerController *)moviePlayer {
    if (!_moviePlayer) {
        _moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.url]];
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFit; //固定缩放比例并且尽量全部
        _moviePlayer.controlStyle = MPMovieControlStyleNone;
    }
    return _moviePlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setViewConstaint];
    
    self.isShowControlBar = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    [self.moviePlayer play];
    [self addNofication];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.moviePlayer stop];
    [self.moviePlayer pause];
    [self stopDurationTimer];
}

- (void)setHideStatusBar:(BOOL)hideStatusBar {
    _hideStatusBar = hideStatusBar;
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
 播放时间
 */
- (void)setTimeLabelText {
    
    double currentTime = (double)self.moviePlayer.currentPlaybackTime;
    double totalTime = (double)self.moviePlayer.duration;
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    self.barView.timeSlider.value = floor(currentTime);
}

/*
 currentTime 当前时间；
 totalTime 总时间
 */
- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    
    if(isnan(minutesElapsed) || minutesElapsed <= 0) {
        minutesElapsed = 0.00;
    }
    if(isnan(secondsElapsed) || secondsElapsed <= 0) {
        secondsElapsed = 0.00;
    }
    
    NSString* timeeElapsedStr = [NSString stringWithFormat:@"%.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor((totalTime ) / 60.0);
    double secondsRemaining = fmod((totalTime ), 60.0);
    
    if(isnan(minutesRemaining)) {
        minutesRemaining = 0.00;
    }
    if(isnan(secondsRemaining)) {
        secondsRemaining = 0.00;
    }
    
    self.barView.timeLabel.text = [NSString stringWithFormat:@"%@ / %.0f:%02.0f", timeeElapsedStr, minutesRemaining, secondsRemaining];
}


#pragma mark - 按钮动作
- (void)buttonAddTarge {
    
    [self.barView.rewindButton addTarget:self action:@selector(rewindButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.barView.settingButton addTarget:self action:@selector(settingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.barView.fullScreenButton addTarget:self action:@selector(fullScreenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.barView.timeSlider addTarget:self action:@selector(durationSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)durationSliderValueChanged:(UISlider *)sender {
    
    [self.moviePlayer pause];
    [self stopDurationTimer];
    
    [self.moviePlayer setCurrentPlaybackTime:floor(sender.value)];
    
    NSTimeInterval currentTime = (double)self.moviePlayer.currentPlaybackTime;
    NSTimeInterval totalTime = (double)self.moviePlayer.duration;
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startDurationTimer];
        [self.moviePlayer play];
    });
}

- (void)playButtonAction:(UIButton *)sender {//播放
    self.playButton.selected = !self.playButton.selected;
    
    if(self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self.moviePlayer pause];
    } else {
        [self.moviePlayer play];
    }
}

- (void)rewindButtonAction:(UIButton *)sender { //后退
    
    [self.moviePlayer pause];
    [self stopDurationTimer];
    
    NSTimeInterval currentTime = 0;
    if (self.moviePlayer.currentPlaybackTime > RewindTimeInterval) {
        currentTime = self.moviePlayer.currentPlaybackTime - RewindTimeInterval;
    }
    
    [self.moviePlayer setCurrentPlaybackTime:floor(currentTime)];
    [self setTimeLabelValues:(double)currentTime totalTime:(double)self.moviePlayer.duration];
    self.barView.timeSlider.value = currentTime;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startDurationTimer];
        [self.moviePlayer play];
    });
}

- (void)settingButtonAction:(UIButton *)sender {//设置
    if (self.captionView.alpha == 0.0) {
        self.captionView.alpha = 1.0;
        self.captionView.hidden = NO;
    } else {
        self.captionView.alpha = 0.0;
        self.captionView.hidden = YES;
    }
}

- (void)fullScreenButtonAction:(UIButton *)sender {//全屏
    if (self.barView.fullScreenButton.selected == YES) {
        [self interfaceOrientation:UIInterfaceOrientationPortrait];//1
    } else {
        [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];//4
    }
}

#pragma mark - 通知
- (void)addNofication {
    
    //1 - 播放状态改变，可配合playbakcState属性获取具体状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackstateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    //2 - 媒体播放完成或用户手动退出，具体完成原因可以通过通知userInfo中的key为MPMoviePlayerPlaybackDidFinishReasonUserInfoKey的对象获取
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitFullScreenMode:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFullScreenMode:) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    //确定时长后
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDurationAvailable:) name:MPMovieDurationAvailableNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideoAction) name:@"FreeView_Show_Video_Stop" object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 横竖屏
/*点击全屏按钮*/
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        
        int val = orientation;
        [invocation setArgument:&val atIndex:2]; // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation invoke];
    }
}

#pragma mark - 播放状态改变
- (void)playbackstateDidChange:(NSNotification *)notification {
    
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
    self.playButton.hidden = NO;
    
    switch (self.moviePlayer.playbackState) {
        case MPMoviePlaybackStateInterrupted://中断
            NSLog(@"中断");
            
            [self.moviePlayer pause];
            [self playButtonState:NO];
            
            break;
        case MPMoviePlaybackStatePaused://暂停
            NSLog(@"暂停");
            
            [self playButtonState:NO];
            
            break;
        case MPMoviePlaybackStatePlaying: //播放中
            NSLog(@"播放中");
            [self startDurationTimer];
            [self playButtonState:YES];
            
            break;
        case MPMoviePlaybackStateSeekingBackward://后退
            NSLog(@"后退");
            
            [self playButtonState:NO];
            
            break;
        case MPMoviePlaybackStateSeekingForward://快进
            NSLog(@"快进");
            
            [self playButtonState:YES];
            
            break;
        case MPMoviePlaybackStateStopped://停止
            NSLog(@"停止");
            
            [self stopDurationTimer];
            [self playButtonState:NO];
            
            break;
        default:
            break;
    }
}

#pragma mark - 媒体播放完成或用户手动退出
- (void)playDidFinish:(NSNotification *)notification {
    
    [self stopDurationTimer];
    [self playButtonState:NO];
    
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if(reason == MPMovieFinishReasonPlaybackEnded) {
        NSLog(@"视频播放结束");
        [self showPlayControl];
        
    } else if(reason == MPMovieFinishReasonUserExited) {
        NSLog(@"用户结束视频");
        
        
    } else if(reason == MPMovieFinishReasonPlaybackError) {
        NSLog(@"视频播放出错");
        
        [self playButtonState:NO];
        [self.moviePlayer.view removeFromSuperview];
    }
}

/*视频*/
- (void)willResignActive:(NSNotification *)notification {
    NSLog(@"视频 +++++++ ");
}

/*视频进入满屏*/
- (void)enterFullScreenMode:(NSNotification*)notification {
    NSLog(@" --- 视频进入满屏");
    [self setNeedsStatusBarAppearanceUpdate];
}

/*视频退出满屏*/
- (void)exitFullScreenMode:(NSNotification*)notification {
    NSLog(@" --- 视频退出满屏");
    [self setNeedsStatusBarAppearanceUpdate];
}

/*确定了媒体播放时长后*/
- (void)movieDurationAvailable:(NSNotification *)notification {
    
    [self setTimeLabelText];
    
    CGFloat duration = self.moviePlayer.duration;
    self.barView.timeSlider.minimumValue = 0.f;
    self.barView.timeSlider.maximumValue = floor(duration);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.58 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hidePlayControl];
    });
}

/*计时*/
- (void)startDurationTimer {//开始
    if ([self.durationTimer isValid]) {
        [self stopDurationTimer];
    }
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setTimeLabelText) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopDurationTimer {//停止
    [self.durationTimer invalidate];
    self.durationTimer = nil;
}

/*按钮状态*/
- (void)playButtonState:(BOOL)isPlaying {
    self.playButton.selected = isPlaying;
}

/*点击视频*/
- (void)tapTopview {
    if (self.isShowControlBar) {
        [self hidePlayControl];
        
    } else {
        [self showPlayControl];
    }
}

#pragma mark - 底部控制栏的处理
/*隐藏*/
- (void)hidePlayControl {
    
    self.isShowControlBar = NO;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        self.barView.alpha = 0;
        self.playButton.alpha = 0;
        self.captionView.alpha = 0;
        
    } completion:^(BOOL finished) {
        self.barView.hidden = YES;
        self.playButton.hidden = YES;
        self.captionView.hidden = YES;
    }];
}

/*展示*/
- (void)showPlayControl {
    self.isShowControlBar = YES;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        self.barView.alpha = 1;
        self.playButton.alpha = 0.5;
        
    } completion:^(BOOL finished) {
        self.barView.hidden = NO;
        self.playButton.hidden = NO;
    }];
}

/*停止视频*/
- (void)stopVideoAction {
    [self.moviePlayer pause];
}

#pragma mark - UI
- (void)setViewConstaint {
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTopview)];
    
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.topView];
    
    [self.topView addSubview:self.moviePlayer.view];
    
    self.barView = [[TDVideoBarView alloc] init];
    self.barView.userInteractionEnabled = YES;
    [self buttonAddTarge];
    [self.topView addSubview:self.barView];
    
    self.playButton = [[UIButton alloc] init];
    self.playButton.layer.masksToBounds = YES;
    self.playButton.layer.cornerRadius = 21;
    self.playButton.backgroundColor = [UIColor blackColor];
    self.playButton.alpha = 0.5;
    self.playButton.showsTouchWhenHighlighted = YES;
    self.playButton.selected = self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying ? NO: YES;
    [self.playButton setAttributedTitle:[UIImage PlayTitle] forState:UIControlStateNormal];
    [self.playButton setAttributedTitle:[UIImage PauseTitle] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.playButton];
    
    self.captionView = [[TDCaptionView alloc] init];
    self.captionView.layer.masksToBounds = YES;
    self.captionView.layer.cornerRadius = 8.0;
    [self.topView addSubview:self.captionView];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 58, 58)];
    [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityView startAnimating];
    [self.topView addSubview:self.activityView];
    
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    [self.moviePlayer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.topView);
    }];
    
    [self.barView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.topView);
        make.height.mas_equalTo(48);
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.topView.mas_centerX);
        make.centerY.mas_equalTo(self.topView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(41, 41));
    }];
    
    [self.captionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.barView.mas_top);
        make.right.mas_equalTo(self.topView.mas_right).offset(-58);
        make.size.mas_equalTo(CGSizeMake(88, 44));
    }];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.playButton.mas_centerX);
        make.centerY.mas_equalTo(self.playButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(58, 58));
    }];
    
    self.moviePlayer.view.userInteractionEnabled = NO;
    self.topView.userInteractionEnabled = YES;
    [self.topView addGestureRecognizer:tapGesture];
    
    self.playButton.hidden = YES;
    self.captionView.hidden = YES;
    self.captionView.alpha = 0.0;
    self.captionView.titleArray = @[NSLocalizedString(@"CLOSED_CAPTIONS", nil)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

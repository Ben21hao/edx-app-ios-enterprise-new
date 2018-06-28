//
//  TDSkydriveAudioViewController.m
//  edX
//
//  Created by Elite Edu on 2018/6/6.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveAudioViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TDSlider.h"

#import "TDSkydriveAudioView.h"

@interface TDSkydriveAudioViewController ()

@property (nonatomic,strong) AVPlayer *audioPlayer;
@property (nonatomic,strong) AVPlayerItem *playerItem;

@property (nonatomic,strong) TDSkydriveAudioView *audioView;
@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,assign) CGFloat totalDuration;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,assign) BOOL isOperation;//是否有手势在操作

@property (nonatomic,assign) BOOL failPlay;//播放失败

@end

@implementation TDSkydriveAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = self.titleStr;
    
    [self setViewConstraint];
    [self addObserverForVideoPlay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initAudioPlayer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self destroyPlayer];
}

- (void)initAudioPlayer {
    
//    self.filePath = [[NSBundle mainBundle] pathForResource:@"111115" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
    
//    self.playerItem = [AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:url]];
    self.playerItem = [[AVPlayerItem alloc] initWithURL:url];
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    self.audioPlayer = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    
    [[NSNotificationCenter  defaultCenter] addObserver:self selector:@selector(audioPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    [self addPeriodicTimeObserver];
}

- (void)addPeriodicTimeObserver {
    
    WS(weakSelf);
    [self.audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1f, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        NSTimeInterval currentInterval = CMTimeGetSeconds(time);
        
        if (currentInterval && !weakSelf.isOperation) {
            weakSelf.audioView.timeLabel.text = [weakSelf timeFormatterExchange:currentInterval];
            weakSelf.audioView.slider.value = currentInterval/weakSelf.totalDuration;
            
            if (weakSelf.audioView.slider.value == 1.0) {
                [weakSelf pauseAudioPlayer];
            }
        }
    }];
}

- (NSString *)timeFormatterExchange:(int)timeSecond {
    int second = timeSecond % 60;
    int minute = (timeSecond / 60) % 60;
    NSString *timeStr = [NSString stringWithFormat:@"%.2d:%.2d",minute,second];
    return timeStr;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    AVPlayerItem *playerItem = object;
    
    if ([keyPath isEqualToString:@"status"]) {
        
        AVPlayerStatus status = [change[@"new"] intValue];
        switch (status) {
            case AVPlayerStatusUnknown: {
                NSLog(@"AVPlayerStatusUnknown。。。");
                self.failPlay = YES;
            }
                break;
                
            case AVPlayerStatusReadyToPlay: {
                NSLog(@"AVPlayerStatusReadyToPlay。。。");
                self.failPlay = NO;
                self.totalDuration = CMTimeGetSeconds(playerItem.duration);
                self.audioView.totalLabel.text = [self timeFormatterExchange:self.totalDuration];
                
                [self playButtonAction:self.audioView.playButton];
            }
                break;
                
            case AVPlayerStatusFailed: {
                NSLog(@"AVPlayerStatusFailed。。。");
                self.failPlay = YES;
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)destroyPlayer {
    
    [self pauseAudioPlayer];
    self.audioPlayer = nil;
    
    [TDNotificationCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [TDNotificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [TDNotificationCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [TDNotificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

- (void)addObserverForVideoPlay {
    
    [TDNotificationCenter addObserver:self selector:@selector(appwillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [TDNotificationCenter addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [TDNotificationCenter addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [TDNotificationCenter addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)pauseAudioPlayer { //暂停播放
    
    [self.audioPlayer pause];
    self.audioView.playButton.selected = NO;
    
    self.isPlaying = NO;
}

- (void)playAudioPlayer { //播放音频
    
    [self.audioPlayer play];
    self.audioView.playButton.selected = YES;
    
    self.isPlaying = YES;
}

#pragma mark - 播放
- (void)audioPlayEnd:(NSNotification *)notifi { //结束播放
    NSLog(@"播放结束");
    [self pauseAudioPlayer];
}

- (void)playButtonAction:(UIButton *)sender { //播放按钮
    sender.selected = !sender.selected;
    
    if (self.failPlay && sender.selected) {
        [self.view makeToast:TDLocalizeSelect(@"SKY_AUDIO_FAILE", nil) duration:1.08 position:CSToastPositionCenter];
        return;
    }
    
    if (sender.selected) {
        
        if (self.audioView.slider.value == 1.0) {
            [self.audioPlayer seekToTime:kCMTimeZero];
        }
        [self playAudioPlayer];
    }
    else {
        [self pauseAudioPlayer];
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)gesture {
    
    CGPoint point = [gesture locationInView:self.audioView.slider];
    self.audioView.slider.value = point.x / self.audioView.slider.bounds.size.width;
    
    [self sliderTouchBegan:self.audioView.slider];
    [self sliderTouchChanged:self.audioView.slider];
    [self sliderTouchEnd:self.audioView.slider];
}

#pragma mark - slider拖动(播放进度)
- (void)sliderTouchBegan:(TDSlider *)sender {//开始拖动
    NSLog(@"拖动开始");
    
    self.isOperation = YES;
    [self pauseAudioPlayer];
}
- (void)sliderTouchChanged:(TDSlider *)sender { //拖动中
    
    self.isOperation = YES;
    
    CGFloat timeInterval = sender.value * self.totalDuration;
    CMTime time = CMTimeMake(timeInterval, 1);
    [self.audioPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    self.audioView.timeLabel.text = [self timeFormatterExchange:timeInterval - 1];
    
    //    NSLog(@"拖动中 -- %.2lf，%lf",sender.value,timeInterval);
}

- (void)sliderTouchEnd:(TDSlider *)sender { //拖动结束
    NSLog(@"拖动结束 -- ");
    
    self.isOperation = NO;
    
    if (self.playerItem.isPlaybackLikelyToKeepUp) {
        [self playAudioPlayer];
    }
    else {
        [self bufferingForMoment];
    }
}

- (void)bufferingForMoment { //缓冲一下
    
    [self pauseAudioPlayer];
    [self performSelector:@selector(bufferingEnd) withObject:@"Buffering" afterDelay:5];
}

- (void)bufferingEnd {
    
    if (self.playerItem.isPlaybackLikelyToKeepUp) {
        [self playAudioPlayer];
    }
    else {
        [self bufferingForMoment];
    }
}

#pragma mark - 通知相关的Action
- (void)appwillResignActive:(NSNotification *)notification { //即将进入后台
    NSLog(@"appwillResignActive");
    
    if (self.isPlaying) {
        [self.audioPlayer pause];
        self.audioView.playButton.selected = NO;
    }
}

- (void)appDidEnterBackground:(NSNotification *)notification {//已经进入后台
    NSLog(@"appDidEnterBackground");
}

- (void)appWillEnterForeground:(NSNotification *)notification { //即将进入前台
    NSLog(@"appWillEnterForeground");
}

- (void)appBecomeActive:(NSNotification *)notification { //进入前台
    NSLog(@"appBecomeActive");
    
    if (self.isPlaying) {
        [self playAudioPlayer];
    }
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"MP3_play_image"];
    [self.view addSubview:self.imageView];
    
    self.audioView = [[TDSkydriveAudioView alloc] init];
    [self.audioView.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.audioView];
    
    CGFloat width = (TDWidth / 3) * 2;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(-58);
        make.centerX.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(width, width));
    }];
    
    [self.audioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(48);
    }];
    
    [self.audioView.slider addTarget:self action:@selector(sliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.audioView.slider addTarget:self action:@selector(sliderTouchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.audioView.slider addTarget:self action:@selector(sliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.audioView.slider addGestureRecognizer:tap];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

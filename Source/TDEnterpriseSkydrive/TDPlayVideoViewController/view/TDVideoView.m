//
//  TDVideoView.m
//  EdxProject
//
//  Created by Elite Edu on 2018/4/11.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDVideoView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "TDVideoMaskView.h"

NSString* const TDVideoViewkIndex = @"kIndex";
NSString* const TDVideoViewkStart = @"kStart";
NSString* const TDVideoViewkEnd = @"kEnd";
NSString* const TDVideoViewkText = @"kText";

#define bottomBarDispearTime 8

typedef NS_ENUM(NSInteger,TDDeviceOrientation) {
    TDDeviceOrientationPortrait, //竖屏
    TDDeviceOrientationLeft, //左横屏
    TDDeviceOrientationRight //右横屏
};

typedef NS_ENUM(NSInteger, TDPanGestureDeriction) {
    TDPanGestureDerictionHorizon,
    TDPanGestureDerictionPortrait
};

@interface TDVideoView () <UIGestureRecognizerDelegate>

@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayer *videoPlayer;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;

@property (nonatomic,strong) TDVideoMaskView *videoMaskView;
@property (nonatomic,assign) CGRect originalFrame;

@property (nonatomic,strong) UISlider *volumSlider;

@property (nonatomic,assign) CGFloat totalDuration;
@property (nonatomic,assign) CGFloat currentDuration; //当前时间

@property (nonatomic,assign) BOOL isOperation;//是否有手势在操作
@property (nonatomic,assign) BOOL isVolum;//是否是音量

@property (nonatomic,assign) TDPanGestureDeriction panDirection;//滑动方向
@property (nonatomic,assign) CGFloat forwardLength;//快进的总长度

@property (nonatomic,assign) BOOL isDispeared;//工具栏已隐藏
@property (nonatomic,assign) NSInteger dispearCount;
@property (nonatomic,strong) NSTimer *dispearTimer;//用来做底部栏的消失显示

@property (nonatomic,assign) BOOL isPlaying;//判断是否在播放

@property (nonatomic,strong) NSMutableArray *captionArray;//字幕数组
@property (nonatomic,strong) NSTimer *captionTimer;

@end

@implementation TDVideoView

- (NSMutableArray *)captionArray {
    if (!_captionArray) {
        _captionArray = [[NSMutableArray alloc] init];
    }
    return _captionArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.originalFrame = frame;
        [self setViewConstaint];
        [self addObserverForVideoPlay];
        
        self.dispearCount = 0;
        self.dispearTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(dispearTimerAction) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerLayer.frame = self.bounds;
    self.videoMaskView.frame = self.bounds;
}

#pragma mark - notification
- (void)addObserverForVideoPlay {
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];//更新用呗信息
    [TDNotificationCenter addObserver:self selector:@selector(statusBarOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    [TDNotificationCenter addObserver:self selector:@selector(appwillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [TDNotificationCenter addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [TDNotificationCenter addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [TDNotificationCenter addObserver:self selector:@selector(appBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)destroyPlayer {
    
    [self pausePlayingVideo];
    
    if ([self.dispearTimer isValid]) {
        [self.dispearTimer invalidate];
    }
    
    if ([self.captionTimer isValid]) {
        [self.captionTimer invalidate];
    }
    
    //取消延迟执行的缓冲结束代码
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(bufferingEnd) object:@"Buffering"];
    
    //移除
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.videoPlayer = nil;
    
    [self removeFromSuperview];
    self.videoMaskView = nil;

    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [TDNotificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    [TDNotificationCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [TDNotificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [TDNotificationCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [TDNotificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self remoPlayerItemObsever];
}

- (void)remoPlayerItemObsever {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

#pragma mark - 视频URL
- (void)setVideoUrl:(NSString *)videoUrl {
    _videoUrl = videoUrl;
    
    [self videoPalyerInitialization];
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    [self getSrtFileData];
}

- (void)videoPalyerInitialization { //初始化播放器
    
    if ([self.videoUrl rangeOfString:@"http"].location != NSNotFound) { //网络视频
        NSURL *url = [NSURL URLWithString:[self.videoUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        self.playerItem = [AVPlayerItem playerItemWithURL:url];
        
    } else {//本地视频
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.videoUrl]];
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    }
    
    self.videoPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
    [self addPeriodicTimeObserver]; //监听播放进度
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
    self.playerLayer.backgroundColor = [UIColor whiteColor].CGColor;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    
    if (_playerItem == playerItem) {
        return;
    }
    
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        
        [self resetVideoPlayer];
    }
    
    _playerItem = playerItem;
    
    if (playerItem) {
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)resetVideoPlayer {
    
    [self pausePlayingVideo];
    
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.videoPlayer = nil;

    self.videoMaskView.slider.value = 0.0;
    self.videoMaskView.progressView.progress = 0.0;
    self.videoMaskView.currentTimeStr = @"00:00";
    self.videoMaskView.totalTimeStr = @"00:00";
    
    [self hiddenBottomBarView:NO];
    
    self.isPlaying = NO;
    [self.videoMaskView.loadingView startLoadingAnimation];
}

#pragma mark - 监听播放进度
- (void)addPeriodicTimeObserver {
    
    WS(weakSelf);
    [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1f, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        if (weakSelf.playerItem.isPlaybackLikelyToKeepUp && weakSelf.videoMaskView.slider.value > 0) {
            [weakSelf.videoMaskView.loadingView endLoadingAnimation];
            
        } else {
            weakSelf.isPlaying = NO;
            [weakSelf.videoMaskView.loadingView startLoadingAnimation];
        }

        NSTimeInterval currentInterval = CMTimeGetSeconds(time);
        weakSelf.currentDuration = currentInterval;
        weakSelf.videoMaskView.currentTimeStr = [weakSelf timeFormatterExchange:currentInterval];
//        NSLog(@"观察 ----->> %lf",currentInterval);
        
        NSTimeInterval totalInterval = CMTimeGetSeconds(weakSelf.videoPlayer.currentItem.duration);
        
        if (currentInterval && !weakSelf.isOperation) {
            
            if (weakSelf.isOperation) return;
            
            weakSelf.videoMaskView.slider.value = currentInterval / totalInterval;
            
            if (weakSelf.videoMaskView.slider.value == 1.0f) {
                weakSelf.videoMaskView.playButton.selected = NO;
            }
        }
    }];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
//    NSLog(@"观察者---------");
    
    AVPlayerItem *playerItem = object;
    
    if ([keyPath isEqualToString:@"status"]) {//监控状态属性
        
        AVPlayerStatus status = [change[@"new"] intValue];
        switch (status) {
            case AVPlayerStatusUnknown:
                NSLog(@"AVPlayerStatusUnknown。。。");
                [self showLoadingFailButton];
                break;
                
            case AVPlayerStatusReadyToPlay: { 
                NSLog(@"AVPlayerStatusReadyToPlay。。。");
                
                self.totalDuration = CMTimeGetSeconds(playerItem.duration);
                self.videoMaskView.totalTimeStr = [self timeFormatterExchange:self.totalDuration];
                
                [self playButtonAction:self.videoMaskView.playButton];
                [self addPanGesture];
                
                self.videoMaskView.failButton.hidden = YES;
                
                if (![self.captionTimer isValid]) {
                    self.captionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(captionTimerRun) userInfo:nil repeats:YES];
                }
            }
                break;
                
            case AVPlayerStatusFailed: {
                NSLog(@"AVPlayerStatusFailed。。。");
                [self showLoadingFailButton];
            }
                break;
                
            default:
                break;
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {//监控网络加载情况属性
        
        NSArray *rangeArray = [self.videoPlayer.currentItem loadedTimeRanges];
        CMTimeRange range = [rangeArray.firstObject CMTimeRangeValue]; //本次缓存时间范围
        CGFloat start = CMTimeGetSeconds(range.start);
        CGFloat duration = CMTimeGetSeconds(range.duration);
        NSTimeInterval timeInterval = start + duration;
        
        CGFloat value = timeInterval / CMTimeGetSeconds(playerItem.duration);
        self.videoMaskView.progressView.progress = value;
        
//        NSLog(@"loadedTimeRanges。。。%f",timeInterval);
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {//监听播放的区域缓存是否为空
        if (self.playerItem.isPlaybackBufferEmpty) { //缓存为空时
            [self bufferingForMoment];
        }
    }
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {//缓存可以播放的时候调用
//        NSLog(@"缓存可以播放");
    }
}

- (NSString *)timeFormatterExchange:(int)timeSecond {
    int second = timeSecond % 60;
    int minute = (timeSecond / 60) % 60;
    NSString *timeStr = [NSString stringWithFormat:@"%.2d:%.2d",minute,second];
    return timeStr;
}

#pragma mark - 滑动手势(音量和亮度)
- (void)addPanGesture {
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandle:)];
    [pan setMaximumNumberOfTouches:1]; //一个手指
    [pan setDelaysTouchesBegan:YES];
    [pan setDelaysTouchesEnded:YES];
    [pan setCancelsTouchesInView:YES];
    pan.delegate = self;
    [self.videoMaskView addGestureRecognizer:pan];
    
    self.exclusiveTouch = YES;
}

- (void)panGestureHandle:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint point = [panGesture locationInView:self.videoMaskView]; //手指在视图上的坐标
    CGPoint veloctyPoint = [panGesture velocityInView:self]; //手指在视图上移动的速度
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            
            CGFloat x = fabs(veloctyPoint.x); //绝对值
            CGFloat y = fabs(veloctyPoint.y);
            
            if (x > y) { //水平
                [self sliderTouchBegan:self.videoMaskView.slider];
                self.panDirection = TDPanGestureDerictionHorizon;
                
                CMTime time = self.videoPlayer.currentTime;
                self.forwardLength = time.value / time.timescale;
            
                [self hiddenBottomBarView:NO];
            }
            else if (x < y) { //竖直
                self.isVolum = point.x > self.bounds.size.width * 0.5;
                self.panDirection = TDPanGestureDerictionPortrait;
            }
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            switch (self.panDirection) {
                case TDPanGestureDerictionHorizon: { //快进退
                    [self horizontalMoveHandle:veloctyPoint.x];
                }
                    break;
                case TDPanGestureDerictionPortrait: { //音量或亮度
                    [self verialMoveHandle:veloctyPoint.y];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
            switch (self.panDirection) {
                case TDPanGestureDerictionHorizon: { //快进退
                    
                    NSLog(@"拖动 --- %lf",self.forwardLength);
                    
                    self.forwardLength = 0;
                    [self sliderTouchEnd:self.videoMaskView.slider];
                    [self hiddenBottomBarView:NO];
                }
                    break;
                case TDPanGestureDerictionPortrait: { //音量或亮度
                    self.isVolum = NO;
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (void)verialMoveHandle:(CGFloat)value { //亮度或音量
    self.isVolum ? (self.volumSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

- (void)horizontalMoveHandle:(CGFloat)value { //快进退
    
    self.forwardLength += value / 200;
    
    CMTime totalTime = self.playerItem.duration;
    CGFloat moveDuration = totalTime.value / totalTime.timescale;
    
    if (self.forwardLength > moveDuration) {
        self.forwardLength = moveDuration;
    }
    
    if (self.forwardLength < 0 ) {
        self.forwardLength = 0;
    }
    
    CGFloat drageSecond = self.forwardLength; //计算拖动的秒数
    self.videoMaskView.slider.value = drageSecond / moveDuration;
    self.videoMaskView.currentTimeStr = [self timeFormatterExchange:drageSecond - 1];
    
    [self.videoPlayer seekToTime:CMTimeMake(drageSecond, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];

    
//    NSLog(@"滑动 ----- %lf -- %lf",drageSecond,CMTimeGetSeconds(CMTimeMake(drageSecond, 1)));
}

//手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {

    if ([touch.view isDescendantOfView:self.videoMaskView.bottomBarView]) {//判断手势在底部工具栏
        return NO;
    }
    
    return YES;
}

#pragma mark - 点击手势
- (void)tapGestureHandle:(UITapGestureRecognizer *)tapGesture { //点击手势
    
    self.isDispeared = !self.isDispeared;
    [self hiddenBottomBarView:self.isDispeared];
}

- (void)hiddenBottomBarView:(BOOL)isHidden {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.videoMaskView.bottomBarView.alpha = isHidden ? 0.0 : 1.0;
        
    } completion:^(BOOL finished) {
        self.dispearCount = 0;
        self.isDispeared = isHidden;
    }];
}

- (void)dispearTimerAction { //定时器
    
    if (!self.isDispeared) { //底部工具栏显示的情况
        
        self.dispearCount ++;
        if (self.dispearCount > bottomBarDispearTime) {
            
            [UIView animateWithDuration:0.5 animations:^{
                self.videoMaskView.bottomBarView.alpha = 0.0;
                
            } completion:^(BOOL finished) {
                self.dispearCount = 0;
                self.isDispeared = YES;
            }];
        }
    }
}

#pragma mark - 播放按钮
- (void)playButtonAction:(UIButton *)sender { //播放按钮
    
    if (self.videoPlayer.rate == 0.0f) { //用播放速度判断
        
        if (self.videoMaskView.slider.value == 1.0f) {
            
            CMTime currentTime = CMTimeMake(0, 1);
            WS(weakSelf);
            [self.videoPlayer seekToTime:currentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                weakSelf.videoMaskView.currentTimeStr = @"00:00";
                weakSelf.videoMaskView.slider.value = 0.0f;
                sender.selected = YES;
            }];
        }
        else {
            self.isPlaying = YES;
            [self.videoPlayer play];
            sender.selected = YES;
        }
    }
    else {
        [self.videoPlayer pause];
        sender.selected = NO;
    }
}

#pragma mark - 加载失败重新加载
- (void)failButtonAction:(UIButton *)sender {
    [self setVideoUrl:self.videoUrl];
}

- (void)showLoadingFailButton {
    self.isPlaying = NO;
    self.videoMaskView.failButton.hidden = NO;
    [self.videoMaskView.loadingView endLoadingAnimation];
}

#pragma mark - slider拖动(播放进度)
- (void)sliderTouchBegan:(TDSlider *)sender {//开始拖动
    NSLog(@"拖动开始");
    
    self.dispearCount = 0;
    self.isOperation = YES;
    [self pausePlayingVideo];
}
- (void)sliderTouchChanged:(TDSlider *)sender { //拖动中
    
    self.isOperation = YES;
    
    CGFloat timeInterval = sender.value * self.totalDuration;
    CMTime time = CMTimeMake(timeInterval, 1);
    [self.videoPlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    self.videoMaskView.currentTimeStr = [self timeFormatterExchange:timeInterval - 1];
    
//    NSLog(@"拖动中 -- %.2lf，%lf",sender.value,timeInterval);
}

- (void)sliderTouchEnd:(TDSlider *)sender { //拖动结束
    NSLog(@"拖动结束 -- ");
    
    self.isOperation = NO;
    
    if (self.playerItem.isPlaybackLikelyToKeepUp) {
        [self replayVideo];
    }
    else {
        [self bufferingForMoment];
    }
}

#pragma mark - 通知相关的Action
- (void)appwillResignActive:(NSNotification *)notification { //即将进入后台
    NSLog(@"appwillResignActive");
    
    if (self.isPlaying) {
        [self.videoPlayer pause];
        self.videoMaskView.playButton.selected = NO;
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
        [self replayVideo];
    }
}

#pragma mark - 视频播放与暂停
- (void)pausePlayingVideo { //暂停
    self.isPlaying = NO;
    [self.videoPlayer pause];
    self.videoMaskView.playButton.selected = NO;
}

- (void)replayVideo { //重新播放
    self.isPlaying = YES;
    [self.videoPlayer play];
    self.videoMaskView.playButton.selected = YES;
}

- (void)bufferingForMoment { //缓冲一下
    
    [self pausePlayingVideo];
    [self.videoMaskView.loadingView startLoadingAnimation];
    
    [self performSelector:@selector(bufferingEnd) withObject:@"Buffering" afterDelay:5];
}

- (void)bufferingEnd {
    
    if (self.playerItem.isPlaybackLikelyToKeepUp) {
        [self replayVideo];
    }
    else {
        [self bufferingForMoment];
    }
}

#pragma mark - 横竖屏
- (void)fullScreenButtonAction:(UIButton *)sender { //全屏按钮
    
    self.dispearCount = 0;
    
    if (self.videoMaskView.fullScreenButton.selected) {
        [self orientationChange:TDDeviceOrientationPortrait];
    }
    else {
        [self orientationChange:TDDeviceOrientationLeft];
    }
}

- (void)orientationChange:(TDDeviceOrientation)type {
    
    CGFloat angle = 0;
    NSInteger deviceOrientation = UIDeviceOrientationPortrait;
    CGRect rectMake = self.frame;
    
    switch (type) {
        case TDDeviceOrientationPortrait:
            angle = 0;
            deviceOrientation = UIDeviceOrientationPortrait;
            rectMake = self.originalFrame;
            break;
            
        case TDDeviceOrientationLeft:
            angle = M_PI / 2;
            deviceOrientation = UIDeviceOrientationLandscapeLeft;
            rectMake = CGRectMake(0, 0, TDWidth, TDHeight);
            break;
            
        default:
            angle = -M_PI / 2;
            deviceOrientation = UIDeviceOrientationLandscapeRight;
            rectMake = CGRectMake(0, 0, TDWidth, TDHeight);
            break;
    }
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:deviceOrientation] forKey:@"orientation"];
    [self updateConstraintsIfNeeded];
    
    [UIView  animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(angle);
        self.frame = rectMake;
    }];
    
    self.videoMaskView.fullScreenButton.selected = type == TDDeviceOrientationPortrait ? NO : YES;
    [self judgeStatusBarHidden:type == TDDeviceOrientationPortrait ? NO : YES];
}

- (void)judgeStatusBarHidden:(BOOL)hidden { //是否隐藏电池条
    
    if (self.navigationBarHandle) {
        self.navigationBarHandle(hidden);
    }
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    statusBar.hidden = hidden;
}

- (void)statusBarOrientationChange:(NSNotification *)notification { //设备旋转的通知
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft: { //左
            [self orientationChange:TDDeviceOrientationLeft];
        }
            break;
        case UIDeviceOrientationLandscapeRight: {//右
            [self orientationChange:TDDeviceOrientationRight];
        }
            break;
        case UIDeviceOrientationPortrait: { //上
            [self orientationChange:TDDeviceOrientationPortrait];
        }
            break;
        default:
            break;
    }
}


#pragma mark - 字幕
- (void)getSrtFileData { //拿到本地字幕数据
    
    NSString *localPath = [[NSBundle mainBundle] pathForResource:@"1.3.1" ofType:@"srt"];
    if([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {  // File to string 本地有文件
        
        NSString *subtitleString = [NSString stringWithContentsOfFile:localPath encoding:NSUTF8StringEncoding error:nil];
        subtitleString = [subtitleString stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
        
        [self parseClosedCaptioningString:subtitleString parsed:^(BOOL parsed, NSError *error) {
            
        }];
    }
    else { //若本地不存在，则执行下载动作
        //https://www.eliteu.cn/courses/course-v1:EliteU+63040002+A1/xblock/block-v1:EliteU+63040002+A1+type@video+block@849c5bba8f864e9c97067067990cf461/handler_noauth/transcript/download?lang=zh
        
        
    }
}

//解析字幕成字典，加入数组
- (void)parseClosedCaptioningString:(NSString *)string parsed:(void (^)(BOOL parsed, NSError *error))completion {
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    while (!scanner.isAtEnd) {
        NSString *indexString;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&indexString]; //扫到 \n 是停止
        
        NSString *startString;
        [scanner scanUpToString:@" --> " intoString:&startString]; //扫描到 --> 停止,startString为这之前的字符串
        [scanner scanString:@"-->" intoString:NULL];//
        
        NSString *endString;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&endString]; //扫到 \n 是停止，endString为这之前的字符串
        
        NSString *textString;
        [scanner scanUpToString:@"\n\n" intoString:&textString]; //扫描到 \n\n 停止
        textString = [textString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; //去除空格
        
        if ([textString rangeOfString:@" --> "].location != NSNotFound) {
            NSArray *arrParse = [textString componentsSeparatedByString:@"\n"];
            textString = arrParse.lastObject;
        }
        
        NSError *error = nil;
        NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"[<|\\{][^>|\\^}]*[>|\\}]" options:NSRegularExpressionCaseInsensitive error:&error];
        
        if (error) {
            completion(NO,error);
            return;
        }
        
        textString = [expression stringByReplacingMatchesInString:textString.length > 0 ? textString : @"" options:0 range:NSMakeRange(0, textString.length) withTemplate:@""];
        
        
        if (startString || endString) {
            
            NSTimeInterval startInterval = [self getTimeFromString:startString];
            NSTimeInterval endInterval = [self getTimeFromString:endString];
            NSDictionary *tempInterval = @{
                                           TDVideoViewkIndex : indexString,
                                           TDVideoViewkStart : @(startInterval),
                                           TDVideoViewkEnd : @(endInterval),
                                           TDVideoViewkText : textString ? textString : @""
                                           };
            NSInteger index = self.captionArray.count == [indexString integerValue] ? [indexString integerValue] : self.captionArray.count;
            [self.captionArray insertObject:tempInterval atIndex:index];
        }
    }
    
    if (completion != NULL) {
        if ([self.delegate respondsToSelector:@selector(getCaptionItemArray:)]) {
            [self.delegate getCaptionItemArray:self.captionArray];
        }
        
        completion(YES, nil);
//        NSLog(@"-----%@",self.captionArray);
    }
}

- (NSTimeInterval)getTimeFromString:(NSString*)timeString {
    
    NSScanner *scanner = [NSScanner scannerWithString:timeString];
    
    int h, m, s, c;
    [scanner scanInt:&h];
    [scanner scanString:@":" intoString:NULL];
    [scanner scanInt:&m];
    [scanner scanString:@":" intoString:NULL];
    [scanner scanInt:&s];
    [scanner scanString:@"," intoString:NULL];
    [scanner scanInt:&c];
    
    return (h * 3600) + (m * 60) + s + (c / 1000.0);
}

//字幕文本显示
- (void)captionTimerRun {
    
    if (self.videoPlayer.rate == 0.0f) {
        return;
    }
    
    @autoreleasepool {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%@ >= %K) AND (%@ <= %K)", @(self.currentDuration), TDVideoViewkStart, @(self.currentDuration), TDVideoViewkEnd];
        NSArray *predArray = [self.captionArray filteredArrayUsingPredicate:predicate];
        NSDictionary *lastFound = (NSDictionary *)predArray.lastObject;
        
//        NSLog(@"字幕文本----->> %@,%@",predArray,lastFound);
        
        if (lastFound) {
            
            if ([lastFound[TDVideoViewkText] rangeOfString:@"-->"].location != NSNotFound) {
                self.videoMaskView.captionStr = @"";
            }
            else {
                self.videoMaskView.captionStr = lastFound[TDVideoViewkText];
                
                if ([self.delegate respondsToSelector:@selector(heightLightCaptionText:)]) { //选择高亮的字幕
                    NSInteger row = [self.captionArray indexOfObject:lastFound];
                    [self.delegate heightLightCaptionText:row];
                }
            }
        }
        else {
            self.videoMaskView.captionStr = @"";
        }
    }
}

- (void)setSelectedRow:(NSInteger)selectedRow { //点击字幕行
    _selectedRow = selectedRow;
    
    NSDictionary *selectDic = self.captionArray[selectedRow];
    NSTimeInterval timeInterval = [selectDic[TDVideoViewkStart] floatValue];
    
    [self.videoPlayer pause];
    
    WS(weakSelf);
    [self.videoPlayer seekToTime:CMTimeMake(timeInterval, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
        [weakSelf.videoPlayer play];
        
        weakSelf.videoMaskView.slider.value = timeInterval/self.totalDuration;
        weakSelf.videoMaskView.currentTimeStr = [self timeFormatterExchange:timeInterval];
        
        if ([weakSelf.delegate respondsToSelector:@selector(heightLightCaptionText:)]) { //选择高亮的字幕
            [weakSelf.delegate heightLightCaptionText:selectedRow];
        }
    }];
}

#pragma mark - 播放速度
- (void)chooseVideoPlayerRate { //选择播放速度
    
    CGFloat rate = self.videoPlayer.rate;
    NSInteger row;
    if (rate == 0.5) {
        row = TDVideoViewRateSlow;
    }
    else if (rate == 1.0) {
        row = TDVideoViewRateDefault;
    }
    else if (rate == 1.5) {
        row = TDVideoViewRateFast;
    }
    else {
        row = TDVideoViewRateXFast;
    }
    
    WS(weakSelf);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"播放速度" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:row == TDVideoViewRateSlow ? @"√ 0.5x" : @"0.5x" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.videoPlayer.rate = 0.5;
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:row == TDVideoViewRateDefault ? @"√ 1.0x" : @"1.0x" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.videoPlayer.rate = 1.0;
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:row == TDVideoViewRateFast ? @"√ 1.5x" : @"1.5x" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.videoPlayer.rate = 1.5;
    }];
    
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:row == TDVideoViewRateXFast ? @"√ 2.0x" : @"2.0x" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.videoPlayer.rate = 2.0;
    }];
    
    UIAlertAction *action5 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [alertController addAction:action5];
    
    [self.videoController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UI
- (void)setViewConstaint {
    
    self.backgroundColor = [UIColor blackColor];
    [self addSubview:self.videoMaskView];
    
    [self setVolumView];
}

- (TDVideoMaskView *)videoMaskView {
    
    if (!_videoMaskView) {
        _videoMaskView = [[TDVideoMaskView alloc] initWithFrame:self.bounds];
        
        [_videoMaskView.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_videoMaskView.fullScreenButton addTarget:self action:@selector(fullScreenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_videoMaskView.failButton addTarget:self action:@selector(failButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_videoMaskView.slider addTarget:self action:@selector(sliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        [_videoMaskView.slider addTarget:self action:@selector(sliderTouchChanged:) forControlEvents:UIControlEventValueChanged];
        [_videoMaskView.slider addTarget:self action:@selector(sliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
        
        WS(weakSelf);
        _videoMaskView.tapSliderHandle = ^(CGFloat value) {

            [weakSelf sliderTouchBegan:weakSelf.videoMaskView.slider];
            [weakSelf sliderTouchChanged:weakSelf.videoMaskView.slider];
            [weakSelf sliderTouchEnd:weakSelf.videoMaskView.slider];
        };
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle:)];
        [_videoMaskView addGestureRecognizer:tapGesture];
    }
    return _videoMaskView;
}

- (void)setVolumView { //音量
    
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
//    self.volumSlider = nil;
    
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.volumSlider = (UISlider *)view;
            break;
        }
    }
}

@end

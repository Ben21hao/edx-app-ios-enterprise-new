//
//  OEXVideoPlayerInterface.m
//  edX_videoStreaming
//
//  Created by Nirbhay Agarwal on 13/05/14.
//  Copyright (c) 2014 edX, Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "OEXVideoPlayerInterface.h"

#import "edX-Swift.h"
#import "Logger+OEXObjC.h"

#import "OEXHelperVideoDownload.h"
#import "OEXInterface.h"
#import "OEXMathUtilities.h"
#import "OEXStyles.h"
#import "OEXVideoSummary.h"


@interface OEXVideoPlayerInterface ()
{
    UILabel *labelTitle;
}

@property (nonatomic,strong) OEXHelperVideoDownload *currentVideo;
@property (nonatomic,strong) OEXHelperVideoDownload *lastPlayedVideo;

@property (nonatomic,assign) CGRect defaultFrame;
@property (nonatomic,strong) NSURL *currentUrl;
@property (nonatomic,assign) BOOL isLand;
@property (nonatomic) CGFloat lastPlayedTime;

@end

@implementation OEXVideoPlayerInterface

- (void)resetPlayer {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self.moviePlayerController.controls];
    [[NSNotificationCenter defaultCenter] removeObserver:self.moviePlayerController];
    
    [self.moviePlayerController setContentURL:nil];
    self.moviePlayerController.delegate = nil;
    [self.moviePlayerController resetMoviePlayer];
    self.moviePlayerController.controls = nil;
    self.moviePlayerController = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _videoPlayerVideoView = self.view;
    self.fadeInOnLoad = YES;
    self.isLand = NO;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [self addNotification]; //通知
    
    //create a player
    self.moviePlayerController = [[CLVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.moviePlayerController.view.alpha = 0.f;
    
    //create the controls
    CLVideoPlayerControls *movieControls = [[CLVideoPlayerControls alloc] initWithMoviePlayer:self.moviePlayerController style:CLVideoPlayerControlsStyleDefault];
    [movieControls setBarColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.9]];
    [movieControls setTimeRemainingDecrements:YES];
    
    //assign controls
    [self.moviePlayerController setControls:movieControls];
    
    _shouldRotate = YES;
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error]; //应用不会随着静音键和屏幕关闭而静音
    if(!success) {
        OEXLogInfo(@"VIDEO", @"error: could not set audio session category => AVAudioSessionCategoryPlayback");
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_moviePlayerController setShouldAutoplay:NO];
    
    // There appears to be an OS bug on iOS 8
    // where if you don't call "stop" before a movie player view disappears
    // it can cause a crash
    // See http://stackoverflow.com/questions/31188035/overreleased-mpmovieplayercontroller-under-arc-in-ios-sdk-8-4-on-ipad
    if([UIDevice isOSVersionAtLeast9]) {
        [_moviePlayerController pause];
    } else {
        [_moviePlayerController stop];
    }
    _shouldRotate = NO;
    _moviePlayerController.controls.isVisibile = NO;
    self.moviePlayerController.delegate = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_moviePlayerController setShouldAutoplay:YES];
    _shouldRotate = YES;
    _moviePlayerController.controls.isVisibile = YES;
    self.moviePlayerController.delegate = self; //IMPORTANT!
}

#pragma mark - 通知
- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitFullScreenMode:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFullScreenMode:) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:_moviePlayerController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackEnded:) name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayerController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(potraitAction) name:@"VideoView_InterFace_Orientation_Potraint" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(landsAction) name:@"VideoView_InterFace_Orientation_Lands" object:nil];
}

- (void)enableFullscreenAutorotation {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)playVideoFor:(OEXHelperVideoDownload *)video {
    
    _moviePlayerController.videoTitle = video.summary.name;
    _moviePlayerController.controls.video = video;
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSString *path = [video.filePath stringByAppendingPathExtension:@"mp4"];

    NSURL *url = [NSURL URLWithString:video.summary.videoURL];
    if([filemgr fileExistsAtPath:path]) {
        url = [NSURL fileURLWithPath:path];
    }

    if(video.downloadState == OEXDownloadStateComplete && ![filemgr fileExistsAtPath:path]) {
        return;
    }

    float timeinterval = [[OEXInterface sharedInterface] lastPlayedIntervalForVideo:video];// 获取最后一次播放的时间
    [self updateLastPlayedVideoWith:video]; //
    [self playVideoFromURL:url withTitle:video.summary.name timeInterval:timeinterval];
}

- (void)updateLastPlayedVideoWith:(OEXHelperVideoDownload *)video {
    
    if(_currentVideo) {
        _lastPlayedVideo = _currentVideo;
        
    } else {
        _lastPlayedVideo = video;
    }
    _currentVideo = video;
}

- (void)playVideoFromURL:(NSURL *)URL withTitle:(NSString *)title timeInterval:(NSTimeInterval)interval; {
    
    if(!URL) {
        return;
    }
    self.view = _videoPlayerVideoView;
    [self setViewFromVideoPlayerView:_videoPlayerVideoView];
    
    self.lastPlayedTime = interval;
    
    [_moviePlayerController.view setBackgroundColor:[UIColor blackColor]];
    
    _moviePlayerController.lastPlayedTime = interval;
    _moviePlayerController.videoTitle = title;
    [_moviePlayerController setContentURL:URL];
    [_moviePlayerController prepareToPlay];
    
    [_moviePlayerController setAutoPlaying:YES];
    [_moviePlayerController play];
    
    float speed = [OEXInterface getOEXVideoSpeed:[OEXInterface getCCSelectedPlaybackSpeed]];
    
    _moviePlayerController.controls.playbackRate = speed;
    [_moviePlayerController setCurrentPlaybackRate:speed];
    
    if(!_moviePlayerController.isFullscreen) {
        [_moviePlayerController.view setFrame:_videoPlayerVideoView.bounds];
        [self.view addSubview:_moviePlayerController.view];
    }
    
    if(self.fadeInOnLoad) {
        self.moviePlayerController.view.alpha = 0.0f;
        double delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds  *NSEC_PER_SEC));
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:1.0 animations:^{
                self.moviePlayerController.view.alpha = 1.f;
            }];
        });
        
    } else {
        self.moviePlayerController.view.alpha = 1;
    }
}

- (void)setAutoPlaying:(BOOL)playing {
    [self.moviePlayerController setAutoPlaying:playing];
}

- (void)setVideoPlayerVideoView:(UIView *)videoPlayerVideoView {
    
    _videoPlayerVideoView = videoPlayerVideoView;
    [self setViewFromVideoPlayerView:_videoPlayerVideoView];
}

- (void)setViewFromVideoPlayerView:(UIView *)videoPlayerView {
    
    BOOL wasLoaded = self.isViewLoaded;
    self.view = videoPlayerView;
    
    if(!wasLoaded) {
        // Call this manually since if we set self.view ourselves it doesn't ever get called.
        // This whole thing should get factored so that we just always use our own view
        // And owners can add it where they choose and the whole thing goes through the natural
        // view controller APIs
        [self viewDidLoad];
        [self beginAppearanceTransition:true animated:true];
        [self endAppearanceTransition];
    }
    
}

#pragma mark video player delegate
- (void)movieTimedOut {
    [self.delegate movieTimedOut];
}

#pragma mark - notification methods

- (void)playbackStateChanged:(NSNotification *)notification {
    switch([_moviePlayerController playbackState]) {
        case MPMoviePlaybackStateStopped:
            OEXLogInfo(@"VIDEO", @"Stopped");
            break;
        case MPMoviePlaybackStatePlaying:
            OEXLogInfo(@"VIDEO", @"Playing");
            break;
        case MPMoviePlaybackStatePaused:
            OEXLogInfo(@"VIDEO", @"Playing");
            break;
        case MPMoviePlaybackStateInterrupted:
            OEXLogInfo(@"VIDEO", @"Interrupted");
            break;
        case MPMoviePlaybackStateSeekingForward:
            OEXLogInfo(@"VIDEO", @"Seeking Forward");
            break;
        case MPMoviePlaybackStateSeekingBackward:
            OEXLogInfo(@"VIDEO", @"Seeking Backward");
            break;
    }
}

- (void)playbackEnded:(NSNotification *)notification {
    
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if(reason == MPMovieFinishReasonPlaybackEnded) {
        //NSLog(@"Reason: movie finished playing");
        
    } else if(reason == MPMovieFinishReasonUserExited) {
        //NSLog(@"Reason: user hit done button");
        
    } else if(reason == MPMovieFinishReasonPlaybackError) {
        //NSLog(@"Reason: error --> VideoPlayerInterface.m");
        [self.moviePlayerController.view removeFromSuperview];
    }
}

- (void)willResignActive:(NSNotification *)notification {
    [self.moviePlayerController.controls hideOptionsAndValues];
}

- (void)videoPlayerShouldRotate {
    [_moviePlayerController setShouldAutoplay:YES];
    _shouldRotate = YES;
}

- (void)orientationChanged:(NSNotification *)notification {
    
    if(_shouldRotate) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(manageOrientation) object:nil];

        if(![self isVerticallyCompact]) {
            [self manageOrientation];
        } else {
            [self performSelector:@selector(manageOrientation) withObject:nil afterDelay:0.8];
        }
    }
}

- (void)manageOrientation {
    
    if(!((self.moviePlayerController.playbackState == MPMoviePlaybackStatePlaying) || self.moviePlayerController.playbackState == MPMoviePlaybackStatePaused ) && !_moviePlayerController.isFullscreen) {
        return;
    }

    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    if(deviceOrientation == UIDeviceOrientationPortrait) { // 竖屏
        if(self.moviePlayerController.fullscreen) {
            [_moviePlayerController setFullscreen:NO withOrientation:UIInterfaceOrientationPortrait];
            _moviePlayerController.controlStyle = MPMovieControlStyleNone;
            [_moviePlayerController.controls setStyle:CLVideoPlayerControlsStyleEmbedded];
        }
        
    } else if(deviceOrientation == UIDeviceOrientationLandscapeLeft || deviceOrientation == UIDeviceOrientationLandscapeRight) { //横屏
        UIInterfaceOrientation interfaceOrientation = (deviceOrientation == UIDeviceOrientationLandscapeLeft) ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationLandscapeRight;
        
        [_moviePlayerController setFullscreen:YES withOrientation:interfaceOrientation animated:YES forceRotate:YES];
        _moviePlayerController.controlStyle = MPMovieControlStyleNone;
    }
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)exitFullScreenMode:(NSNotification *)notification {
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)enterFullScreenMode:(NSNotification *)notification {
    [self setNeedsStatusBarAppearanceUpdate];
}

//影响到试听课程的横竖屏
- (void)potraitAction {
    self.isLand = NO;
}

- (void)landsAction {
    self.isLand = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _width = 700.f;
        _height = 535.f;
        
    } else {
        if (!_width)
            _width = self.view.frame.size.width;
        
        if ([self isVerticallyCompact]) {
            if (!_height)
                _height = [[UIScreen mainScreen] bounds].size.height - 84; // height of nav n toolbar
            
        } else {
            if (!_height)
                _height = 220;
        }
        
    }
    //calulate the frame on every rotation, so when we're returning from fullscreen mode we'll know where to position the movie player
    self.defaultFrame = CGRectMake(self.view.frame.size.width / 2 - _width / 2, 0, _width, _height);

    //only manage the movie player frame when it's not in fullscreen. when in fullscreen, the frame is automatically managed

    if(self.moviePlayerController.isFullscreen) {
        return;
    }

    //you MUST use [CLMoviePlayerController setFrame:] to adjust frame, NOT [CLMoviePlayerController.view setFrame:]
    [self.moviePlayerController setFrame:self.defaultFrame];
    //    self.moviePlayerController.view.layer.borderColor = [UIColor redColor].CGColor;
    //    self.moviePlayerController.view.layer.borderWidth = 2;
}

#pragma mark - CLVideoPlayerControllerDelegate

- (void)moviePlayerWillMoveFromWindow {
    //movie player must be readded to this view upon exiting fullscreen mode.

    if(![self.view.subviews containsObject:self.moviePlayerController.view]) {
        [self.view addSubview:self.moviePlayerController.view];
    }

    //you MUST use [CLMoviePlayerController setFrame:] to adjust frame, NOT [CLMoviePlayerController.view setFrame:]
    //NSLog(@"set frame from  player delegate ");
    [self.moviePlayerController setFrame:self.defaultFrame];
}

- (void)playerDidStopPlaying:(NSURL *)videoUrl atPlayBackTime:(float)currentTime {
    
    NSString *url = [videoUrl absoluteString];

    if([_lastPlayedVideo.summary.videoURL isEqualToString:url] || [_lastPlayedVideo.filePath isEqualToString:url]) {
        if(currentTime > 0) {
            NSTimeInterval totalTime = self.moviePlayerController.duration;
            
            [[OEXInterface sharedInterface] markLastPlayedInterval:currentTime forVideo:_lastPlayedVideo];
            OEXPlayedState state = OEXDoublesWithinEpsilon(totalTime, currentTime) ? OEXPlayedStateWatched : OEXPlayedStatePartiallyWatched;
            [[OEXInterface sharedInterface] markVideoState:state forVideo:_lastPlayedVideo];
        }
    } else {
        if(currentTime > 0) {
            [[OEXInterface sharedInterface] markLastPlayedInterval:currentTime forVideo:_currentVideo]; //写入视频最后播放时间
        }
    }
}

- (void) videoPlayerTapped:(UIGestureRecognizer  *) sender {
    if([self.delegate respondsToSelector:@selector(videoPlayerTapped:)]) {
        [self.delegate videoPlayerTapped:sender];
    }
}

- (void)transcriptLoaded:(NSArray  *)transcript {
    if([self.delegate respondsToSelector:@selector(transcriptLoaded:)]) {
        [self.delegate transcriptLoaded:transcript];
    }
}

- (void)didFinishVideoPlaying {
    if([self.delegate respondsToSelector:@selector(didFinishVideoPlaying)]) {
        [self.delegate didFinishVideoPlaying];
    }
}

- (BOOL)prefersStatusBarHidden {
    if (self.isLand) {
        return YES;
    }
    return [self.moviePlayerController isFullscreen];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [OEXStyles sharedStyles].standardStatusBarStyle;
}

- (BOOL)hidesNextPrev {
    return self.moviePlayerController.controls.hidesNextPrev;
}

- (void)setHidesNextPrev:(BOOL)hidesNextPrev {
    [self.moviePlayerController.controls setHidesNextPrev:hidesNextPrev];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    _moviePlayerController.delegate = nil;
}

@end

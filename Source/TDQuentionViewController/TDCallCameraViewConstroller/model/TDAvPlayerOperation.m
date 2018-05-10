//
//  TDAvPlayerOperation.m
//  edX
//
//  Created by Elite Edu on 2018/5/4.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDAvPlayerOperation.h"
#import <AVFoundation/AVFoundation.h>

@interface TDAvPlayerOperation ()

@property (strong, nonatomic) NSURL *videoFileURL;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@end

@implementation TDAvPlayerOperation

- (instancetype)initVideoFileURL:(NSURL *)videoFileURL withFrame:(CGRect)frame withView:(UIView *)view {
    
    self = [super init];
    if (self) {
        [self registerNotficationMessage];
        [self initPlayLayer:frame withView:view videoUrl:videoFileURL];
    }
    
    return self;
}

- (void)initPlayLayer:(CGRect)frame withView:(UIView *)view videoUrl:(NSURL *)videoFileURL {
    
    if (!videoFileURL) {
        return;
    }
    
    AVAsset *asset = [AVURLAsset URLAssetWithURL:videoFileURL options:nil];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [[AVPlayer alloc] init];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    [self.player seekToTime:kCMTimeZero];
    [self.player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    self.playerLayer.frame = frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [view.layer addSublayer:self.playerLayer];
}

- (void)playSight {
    
    [self.playerItem seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)pauseSight {
    
    [self.playerItem seekToTime:kCMTimeZero];
    [self.player pause];
}

- (void)releaseVideoPlayer {
    
    [self removeNotificationMessage];
    
    if (self.player) {
        [self.player pause];
        [self.player replaceCurrentItemWithPlayerItem:nil];
    }
    
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
    }
    
    self.player = nil;
    self.playerLayer = nil;
    self.playerItem = nil;
}

#pragma mark - notification message
- (void)registerNotficationMessage {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)removeNotificationMessage {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)avPlayerItemDidPlayToEnd:(NSNotification *)notification {
    
    if (notification.object != self.playerItem) {
        return;
    }
    
    [self.playerItem seekToTime:kCMTimeZero];
    [self.player play];
}


@end

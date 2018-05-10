//
//  TDPreviewVideoViewController.m
//  edX
//
//  Created by Elite Edu on 2018/5/3.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDPreviewVideoViewController.h"
#import "TDAvPlayerOperation.h"
#import "SRUtil.h"

@interface TDPreviewVideoViewController ()

@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIButton *selectButton;
@property (nonatomic,strong) UIImageView *playImageView;

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;


@end

@implementation TDPreviewVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = @"视频播放";
    [self setViewConstraint];
    if (!self.isWebVideo) {
        [self addGesture];
    }
    [self initAvPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avplayerDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self setnilForPaleyer];
}

- (void)avplayerDidEnd:(NSNotification *)notifi { //播放结束
    
    if (notifi.object != self.playerItem) {
        return;
    }
    
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)initAvPlayer { //初始化播放器
    
    if (!self.isWebVideo) {
        
        self.videoPath = [[NSBundle mainBundle] pathForResource:@"1525340380" ofType:@"mp4"];
        
//        self.videoPath = [self.videoPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {
            return;
        }
        
        
        NSURL *fileUrl = [NSURL fileURLWithPath:self.videoPath];
        
        AVAsset *asset = [AVURLAsset URLAssetWithURL:fileUrl options:nil];
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    }
    else {
        self.videoPath = @"https://bss.eliteu.cn/oss_media/e80397a8-5198-11e8-9c53-52540059267e";
        self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:self.videoPath]];
        [self setLoadDataView];
    }
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    
    self.player = [[AVPlayer alloc] init];
    [self.player seekToTime:kCMTimeZero];
    [self.player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.frame = CGRectMake(0, 0, TDWidth, TDHeight);
    [self.contentView.layer insertSublayer:self.playerLayer below:self.bottomView.layer];
}

#pragma mark - obsever
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        
        [self.loadIngView removeFromSuperview];
        
        AVPlayerItemStatus status = self.playerItem.status;
        switch (status) {
            case AVPlayerItemStatusReadyToPlay: {
                NSLog(@"AVPlayerItemStatusReadyToPlay");
                [self addGesture];
            }
                break;
            case AVPlayerItemStatusUnknown: {
                NSLog(@"AVPlayerItemStatusUnknown");
                [self setLoadingFailedView];
            }
                break;
            case AVPlayerItemStatusFailed: {
                NSLog(@"AVPlayerItemStatusFailed");
                NSLog(@"%@",self.playerItem.error);
                [self setLoadingFailedView];
            }
                break;
                
            default:
                break;
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        
    }
}

- (void)setLoadingFailedView {
    [self setNullLabelOnView:self.contentView title:@"视频加载失败"];
    self.playImageView.hidden = YES;
}

#pragma mark - 手势
- (void)addGesture {
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.contentView addGestureRecognizer:gesture];
}

- (void)tapAction:(UITapGestureRecognizer *)tapGesture {
    
    BOOL isHidden = self.navigationController.navigationBar.isHidden;

    [[UIApplication sharedApplication] setStatusBarHidden:!isHidden withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:!isHidden animated:YES];
    
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(isHidden ? 48 : 0);
    }];
    
    self.selectButton.hidden = !isHidden;
    self.playImageView.hidden = !isHidden;
    
    isHidden ? [self.player pause] : [self.player play];
}

- (void)selectButtonAction:(UIButton *)sender { //确定
    
    if (sender.selected) {
        return;
    }
    sender.selected = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"User_Had_SelectVideo" object:nil userInfo:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setnilForPaleyer { //移除
    
    //TODO: 这里会导致崩溃
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    
    if (self.player) {
        [self.player pause];
    }
    self.player = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.navigationController.navigationBar.translucent = YES;
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.contentView];
    
    self.playImageView = [[UIImageView alloc] init];
    self.playImageView.image = [UIImage imageNamed:@"video_preview_play"];
    [self.view addSubview:self.playImageView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
    }];
    
    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(66, 66));
    }];
    
    if (self.isWebVideo) {
        return;
    }
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [[UIColor colorWithHexString:colorHexStr10] colorWithAlphaComponent:0.5];
    [self.view addSubview:self.bottomView];
    
    self.selectButton = [[UIButton alloc] init];
    self.selectButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.selectButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.selectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.selectButton setTitle:TDLocalizeSelect(@"DONE", nil) forState:UIControlStateNormal];
    [self.selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.selectButton.layer.masksToBounds = YES;
    self.selectButton.layer.cornerRadius = 4.0;
    [self.bottomView addSubview:self.selectButton];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(48);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bottomView);
        make.right.mas_equalTo(self.bottomView.mas_right).offset(-18);
        make.size.mas_equalTo(CGSizeMake(68, 36));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

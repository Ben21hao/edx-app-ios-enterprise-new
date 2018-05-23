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
    
    self.titleViewLabel.text = TDLocalizeSelect(@"VIDEO_PLAY", nil);
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
    
    if (!self.isWebVideo) { //相册中的
        
        //        self.videoPath = [[NSBundle mainBundle] pathForResource:@"1525340380" ofType:@"mp4"];
        //        if (![[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {
        //            return;
        //        }
        self.videoPath = [self.videoPath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        NSURL *fileUrl = [NSURL fileURLWithPath:self.videoPath];
        AVAsset *asset = [AVURLAsset URLAssetWithURL:fileUrl options:nil];
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    }
    else {
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
    [self setNullLabelOnView:self.contentView title:TDLocalizeSelect(@"FAILED_LOAD_VIDEO", nil)];
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

- (void)setnilForPaleyer { //移除播放器
    
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

- (void)selectButtonAction:(UIButton *)sender { //确定
    
    if (sender.selected) {
        return;
    }
    
    if (self.videoTime > 60.9999) {
        
        UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:nil message:TDLocalizeSelect(@"VIDEO_SECOND_TEXT", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertControl addAction:sureAction];
        [self.navigationController presentViewController:alertControl animated:YES completion:nil];
        
        return;
    }
    
    if (![[[TDBaseToolModel alloc] init] getNetworkingState]) { //没有网络
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_NOT_AVAILABLE_MESSAGE_TROUBLE", nil) duration:0.8 position:CSToastPositionCenter];
        return;
    }
    
    sender.selected = YES;
    
    [self mergeAndExportVideoAtFileURLs:[NSURL fileURLWithPath:self.videoPath]];
}

//合成并导出视频
- (void)mergeAndExportVideoAtFileURLs:(NSURL *)fileURL {
    
    [SVProgressHUD showWithStatus:TDLocalizeSelect(@"TRANSCODEING_TEXT", nil)];
    SVProgressHUD.defaultMaskType = SVProgressHUDMaskTypeBlack;
    SVProgressHUD.defaultStyle = SVProgressHUDAnimationTypeNative;
    
    NSError *error = nil;
    
    AVAsset *asset = [AVAsset assetWithURL:fileURL];//AVAsset：素材库里的素材
    if (!asset) {
        return;
    }
    
    //素材的轨道
    AVAssetTrack *assetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];//返回一个数组AVAssetTracks资产
    
    CGAffineTransform t = assetTrack.preferredTransform;
    NSUInteger degress = 0;
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
        degress = 90; //竖直
    }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
        degress = 270;// PortraitUpsideDown
    }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
        degress = 0;// LandscapeRight
    }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
        degress = 180;// LandscapeLeft
    }
    NSLog(@"CGAffineTransform - %lf - %lf - %lf - %lf - %ld",t.a,t.b,t.c,t.d,degress);
    
    if (assetTrack.naturalSize.height > assetTrack.naturalSize.width) {
        degress = 90;
    }
    
    CGFloat rate;
    CGSize renderSize;
    if (degress == 0 || degress == 180) { //横拍的视频
        
        rate = TDWidth / MAX(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        renderSize = CGSizeMake(TDWidth, TDWidth * 0.5625);
        
    } else { //竖拍的视频
        rate = TDWidth / MIN(assetTrack.naturalSize.width, assetTrack.naturalSize.height);
        renderSize = CGSizeMake(TDWidth, TDHeight);
    }
    
    NSLog(@"renderSize--->> %lf --- %lf -- %ld",renderSize.width,renderSize.height,degress);
    NSLog(@"视频naturalSize --->>%lf -- %lf --- %lf -- %lf",assetTrack.naturalSize.width,assetTrack.naturalSize.height,TDWidth,TDHeight);
    
    CMTime totalDuration = kCMTimeZero;
    
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];//用来合成音频视频
    
    NSArray *dataSourceArray= [asset tracksWithMediaType:AVMediaTypeAudio];//获取声道，即麦克风相关信息
    //文件中的音频轨道，里面可以插入各种对应的素材
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:((dataSourceArray.count > 0) ? [dataSourceArray objectAtIndex:0]:nil) atTime:totalDuration error:nil];
    
    //工程文件中的轨道，有音频轨，里面可以插入各种对应的素材
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration) ofTrack:assetTrack atTime:totalDuration error:&error];
    
    totalDuration = CMTimeAdd(totalDuration, asset.duration);
    
    CGAffineTransform layerTransform = CGAffineTransformMake(assetTrack.preferredTransform.a, assetTrack.preferredTransform.b, assetTrack.preferredTransform.c, assetTrack.preferredTransform.d, assetTrack.preferredTransform.tx * rate, assetTrack.preferredTransform.ty * rate);
    layerTransform = CGAffineTransformConcat(layerTransform, CGAffineTransformMake(1, 0, 0, 1, 0, 0)); //向上移动取中部影相
    layerTransform = CGAffineTransformScale(layerTransform, rate, rate);//放缩，解决前后摄像结果大小不对称
    
    //视频轨道中的一个视频，可以缩放、旋转等
    AVMutableVideoCompositionLayerInstruction *layerInstrucition = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [layerInstrucition setTransform:layerTransform atTime:kCMTimeZero];
    [layerInstrucition setOpacity:0.0 atTime:totalDuration];
    
    NSMutableArray *layerInstructionArray = [NSMutableArray array];
    [layerInstructionArray addObject:layerInstrucition];//data
    
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration);
    mainInstruction.layerInstructions = layerInstructionArray;
    
    //对视频进行操作
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    mainCompositionInst.instructions = @[mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 100);
    mainCompositionInst.renderSize = renderSize;
    
    //get save path
    NSURL *mergeFileURL = [NSURL fileURLWithPath:[self pathMp4VideoFile]];
    //导出视频
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];//清晰度高
    exporter.videoComposition = mainCompositionInst;
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeMPEG4;//视频格式MP4
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        [SVProgressHUD dismiss];
        
        if ([exporter status] == AVAssetExportSessionStatusCompleted) {
            NSLog(@"----- 转码成功");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.videoPath = [[mergeFileURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"User_Had_SelectVideo" object:nil userInfo:@{@"selectVideoPath":self.videoPath, @"selectVideoTime": [NSString stringWithFormat:@"%lf",self.videoTime],@"videoThumbImage": self.thumbImage}];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                
            });
        }
        else if ([exporter status] == AVAssetExportSessionStatusWaiting) {
            NSLog(@"----- 正在转码");
            [self.view makeToast:TDLocalizeSelect(@"VIDEO_TRANSCODING", nil) duration:0.8 position:CSToastPositionCenter];
        }
        else {
            NSLog(@"-----%ld 转码失败；失败信息---- %@ ",(long)[exporter status],exporter.error);
            [self.view makeToast:TDLocalizeSelect(@"FAILED_TRANSCOD", nil) duration:0.8 position:CSToastPositionCenter];
        }
    }];
}

- (NSString *)pathMp4VideoFile {//最后合成为 mp4
    
    NSString *nowTimeStr = [NSString stringWithFormat:@"%lld",[SRUtil getNowTimeStamp]];
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4",nowTimeStr];
    NSString *path = [SRUtil getVideoCachePath:videoName];
    
    NSLog(@"mp4 存储位置拼接 -- %@",path);
    
    return path;
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
    [self.selectButton setTitle:TDLocalizeSelect(@"SEND_MESSAGE_BUTTON", nil) forState:UIControlStateNormal];
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

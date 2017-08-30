//
//  WatchPlayBackViewController.m
//  VHallSDKDemo
//
//  Created by developer_k on 16/4/12.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchPlayBackViewController.h"

#import <MediaPlayer/MPMoviePlayerController.h>
#import <AVFoundation/AVFoundation.h>

#import "VHallApi.h"
#import "VHMessageToolView.h"
#import "VHPullingRefreshTableView.h"
#import "UIView+ITTAdditions.h"
#import "AnnouncementView.h"
#import "VHDocumentView.h"
#import "WatchLiveChatCell.h"

static AnnouncementView* announcementView = nil;

@interface WatchPlayBackViewController () <VHallMoviePlayerDelegate,UITableViewDelegate,UITableViewDataSource,VHPullingRefreshTableViewDelegate,VHMessageToolBarDelegate>
{
    VHallMoviePlayer *_moviePlayer;//播放器
    VHallComment *_comment;
    int _bufferCount;
    NSMutableArray *_commentsArray;//评论
    VHPullingRefreshTableView *_tableView;
    UIButton *_toolViewBackView;//遮罩
    
    VHDocumentView *_documentView;
}

@property (weak, nonatomic) IBOutlet UILabel *bufferCountLabel; //卡顿
@property (weak, nonatomic) IBOutlet UIView *backView; //视频view
@property (weak, nonatomic) IBOutlet UIImageView *textImageView; //文档页
@property (weak, nonatomic) IBOutlet UILabel *liveTypeLabel;
@property (weak, nonatomic) IBOutlet UIView *historyCommentTableView; //评论页
@property (weak, nonatomic) IBOutlet UIButton *commentBtn; //评论
@property (weak, nonatomic) IBOutlet UIButton *docBtn; //文档
@property (weak, nonatomic) IBOutlet UIButton *detalBtn; //详情
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIView *showView;//显示数据页面
@property (strong, nonatomic) IBOutlet UIView *inputView;//输入页
@property (strong, nonatomic) IBOutlet UIButton *inputButton;//输入按钮

@property (nonatomic,assign) VHallMovieVideoPlayMode playModelTemp;
@property (nonatomic,strong) MPMoviePlayerController *hlsMoviePlayer;
@property (nonatomic,strong) UILabel *textLabel;
@property (nonatomic,strong) VHMessageToolView *messageToolView;  //输入框

@property (nonatomic,strong) UIView *detailView;
@property (nonatomic,strong) UITextView *detailTextView;

@end

@implementation WatchPlayBackViewController

- (UILabel *)textLabel {
    
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.frame = CGRectMake(0, 10, self.textImageView.width, 21);
        _textLabel.text = NSLocalizedString(@"NO_DOCUMENT", nil);
        _textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _textLabel;
}

- (id)init {
    
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:meetingResourcesBundle];
    if (self) {
    }
    return self;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
    
    _commentsArray = [NSMutableArray array];//初始化评论数组
    
    if (self.hlsMoviePlayer.view) {
        [MBProgressHUD showHUDAddedTo:self.hlsMoviePlayer.view animated:YES];
    }
    
    //todo
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    param[@"id"] =  _roomId;
    param[@"name"] = [UIDevice currentDevice].name;
    param[@"email"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //    param[@"record_id"] = DEMO_Setting.recordID;
    if (_kValue && _kValue.length) {
        param[@"pass"] = _kValue;
    }
    [_moviePlayer startPlayback:param moviePlayer:self.hlsMoviePlayer]; //播放回放
    
    //播放器
    _hlsMoviePlayer.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.backView.height); //self.view.bounds;
    [self.backView addSubview:self.hlsMoviePlayer.view];
    [self.backView sendSubviewToBack:self.hlsMoviePlayer.view];
    
    self.liveTypeLabel.text = self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice ? NSLocalizedString(@"VOICE_REPLAYING", nil) : @"";
    
    if (self.textImageView.image == nil) {
        [self.textImageView addSubview:self.textLabel];
        
    } else {
        [self.textLabel removeFromSuperview];
        self.textLabel = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //[_tableView launchRefreshing];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait) {
        _topConstraint.constant = 20;
    } else {
        _topConstraint.constant = 0;
    }
}

- (void)viewDidLayoutSubviews {
    
    _hlsMoviePlayer.view.frame = _backView.bounds;
    [self.backView addSubview:self.hlsMoviePlayer.view];
    [self.backView sendSubviewToBack:self.hlsMoviePlayer.view];
    
    if (_documentView) {
        _documentView.frame = self.textImageView.bounds;
        _documentView.width = VH_SW;
        
        if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait) {
            _documentView.height = VH_SH -_backView.height - 20 - 40;
            [_documentView layoutSubviews];
        } else {
            _documentView.height = 0;
        }
    }
}

- (void)dealloc {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];//阻止iOS设备锁屏
    [self.view removeObserver:self forKeyPath:kViewFramePath];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    VHLog(@"%@ dealloc",[[self class]description]);
}

- (void)initViews {
    
    _comment = [[VHallComment alloc] init];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; //阻止iOS设备锁屏
    
    [self registerLiveNotification];
    
    self.bufferCountLabel.text = [NSString stringWithFormat:@"%@ 0",NSLocalizedString(@"BUFFERING", nil)];
    [self.commentBtn setTitle:NSLocalizedString(@"COMMENT_TEXT", nil) forState:UIControlStateNormal];
    [self.docBtn setTitle:NSLocalizedString(@"DOCUMENT_TEXT", nil) forState:UIControlStateNormal];
    [self.detalBtn setTitle:NSLocalizedString(@"DETAILS_TEXT", nil) forState:UIControlStateNormal];
    
    _moviePlayer = [[VHallMoviePlayer alloc] initWithDelegate:self];
    
    self.hlsMoviePlayer = [[MPMoviePlayerController alloc] init];
    self.hlsMoviePlayer.controlStyle = MPMovieControlStyleDefault;
    self.hlsMoviePlayer.shouldAutoplay = YES;
    self.hlsMoviePlayer.view.backgroundColor = [UIColor blackColor];
    [self.hlsMoviePlayer prepareToPlay];
    [self.hlsMoviePlayer.view setFrame:self.view.bounds];  // player的尺寸
    
    [self addObserverTarge];
    [self addPanGestureRecognizer];
    
    _tableView = [[VHPullingRefreshTableView alloc] initWithFrame:CGRectMake(0, 0, VH_SW, _historyCommentTableView.height) pullingDelegate:self headView:YES  footView:YES];
    _tableView.backgroundColor = self.view.backgroundColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.startPos = 0;
    _tableView.tag = -1;
    _tableView.dataArr = [NSMutableArray array];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorColor = self.view.backgroundColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_tableView tableViewDidFinishedLoading];
    [_historyCommentTableView addSubview:_tableView];
    
    
    self.detailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight - TDWidth * 0.56 - 39)];
    self.detailView.backgroundColor = [UIColor colorWithHexString:colorHexStr13];
    [self.showView addSubview:self.detailView];
    
    self.detailTextView = [[UITextView alloc] init];
    self.detailTextView.editable = NO;
    self.detailTextView.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.detailTextView.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.detailTextView.backgroundColor = [UIColor colorWithHexString:colorHexStr13];
    self.detailTextView.text = [NSString stringWithFormat:@"   %@", self.detailStr];
    [self.detailView addSubview:self.detailTextView];
    
    [self.detailTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.detailView.mas_left).offset(0);
        make.top.mas_equalTo(self.detailView.mas_top).offset(8);
        make.right.mas_equalTo(self.detailView.mas_right).offset(0);
        make.bottom.mas_equalTo(self.detailView.mas_bottom).offset(-18);
    }];
    
    self.detailView.hidden = YES;
}

#pragma mark - 注册通知
- (void)addObserverTarge {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.hlsMoviePlayer];//快进快退
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:self.hlsMoviePlayer]; //变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayeExitFullScreen:) name:MPMoviePlayerDidExitFullscreenNotification object:self.hlsMoviePlayer]; //退出全屏
}

- (void)registerLiveNotification {
    
    [self.view addObserver:self forKeyPath:kViewFramePath options:NSKeyValueObservingOptionNew context:nil];
    //已经进入活跃状态的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive)name:UIApplicationDidBecomeActiveNotification object:nil];
    //监听耳机的插拔
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(outputDeviceChanged:)name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

-(void)addPanGestureRecognizer { //快进快退手势
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [self.hlsMoviePlayer.view addGestureRecognizer:panGesture];
}

#pragma mark - UIPanGestureRecognizer
-(void)handlePan:(UIPanGestureRecognizer *)pan { //音量
    
    float baseY = 200.0f;
    CGPoint translation = CGPointZero;
    static float volumeSize = 0.0f;
    CGPoint currentLocation = [pan translationInView:self.view];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        translation = [pan translationInView:self.view];
        volumeSize = [VHMoviePlayer getSysVolumeSize]; //获取系统音量
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        
        float y = currentLocation.y - translation.y;
        float changeSize = ABS(y)/baseY;
        if (y > 0){
            [VHMoviePlayer setSysVolumeSize:volumeSize - changeSize];//设置系统声音大小
            
        } else {
            [VHMoviePlayer setSysVolumeSize:volumeSize + changeSize];
        }
    }
}

#pragma mark - 返回上层界面
- (IBAction)closeBtnClick:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        
        [weakSelf destoryMoivePlayer];
        [weakSelf.hlsMoviePlayer stop];
        weakSelf.hlsMoviePlayer = nil;
    }];
}

- (void)destoryMoivePlayer {
    [_moviePlayer destroyMoivePlayer];
}

#pragma mark - 屏幕自适应
- (IBAction)allScreenBtnClick:(UIButton *)sender {
    
    NSInteger mode = self.hlsMoviePlayer.scalingMode+1;
    if(mode > 3) mode = 0;
    self.hlsMoviePlayer.scalingMode = mode;
}

#pragma mark - 横竖屏处理

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
    
    //如果是iosVersion  8.0之前，UI出现问题请在此调整
    if (IOSVersion < 8.0) {
        CGRect frame = self.view.frame;
        CGRect bounds = [[UIScreen mainScreen]bounds];
        
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait// UIInterfaceOrientationPortrait
            || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) { //UIInterfaceOrientationPortraitUpsideDown
            frame = _backView.bounds;  //竖屏
        } else {
            frame = CGRectMake(0, 0, bounds.size.height, bounds.size.width);//横屏
        }
        
        _hlsMoviePlayer.view.frame = frame;
        [self.backView addSubview:self.hlsMoviePlayer.view];
        [self.backView sendSubviewToBack:_hlsMoviePlayer.view];
    }
}

- (BOOL)shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    [self.messageToolView endEditing:YES];
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - VHMoviePlayerDelegate
- (void)playError:(LivePlayErrorType)livePlayErrorType info:(NSDictionary *)info {//播放时错误的回调
    
    [MBProgressHUD hideAllHUDsForView:self.hlsMoviePlayer.view animated:YES];
    
    void (^resetStartPlay)(NSString *msg) = ^(NSString *msg){
        dispatch_async(dispatch_get_main_queue(), ^{
//            [UIAlertView popupAlertByDelegate:nil title:msg message:nil];
            [self.view makeToast:msg duration:1.08 position:CSToastPositionCenter];
        });
    };
    
    NSString *msg = @"";
    switch (livePlayErrorType) {
        case kLivePlayParamError: {
            msg = NSLocalizedString(@"ERROR_PARAMTER", nil);
            resetStartPlay(msg);
        }
            break;
        case kLivePlayRecvError: {
            msg = NSLocalizedString(@"LIVE_LECTURE_ENDED", nil);
            resetStartPlay(msg);
        }
            break;
        case kLivePlayCDNConnectError: {
            msg = NSLocalizedString(@"UNABLE_CONNECT_SERVER", nil);
            resetStartPlay(msg);
        }
            break;
        case kLivePlayGetUrlError: {
            msg = NSLocalizedString(@"UNABLE_ACQUIRE_SERVER", nil);
            resetStartPlay(info[@"content"]);
        }
            break;
        default:
            break;
    }
}

-(void)PPTScrollNextPagechangeImagePath:(NSString *)changeImagePath {//包含文档 获取翻页图片路径
    
    if (changeImagePath.length <= 0) {
        [self.textImageView addSubview:self.textLabel];
        
    } else {
        [self.textLabel removeFromSuperview];
        self.textLabel = nil;
    }
    
    if(!_documentView) {
        _documentView = [[VHDocumentView alloc]initWithFrame:self.textImageView.bounds];
        _documentView.contentMode = UIViewContentModeScaleAspectFit;
        _documentView.backgroundColor=MakeColorRGB(0xe2e8eb);
    }
    _documentView.frame = self.textImageView.bounds;
    [self.textImageView addSubview:_documentView];
    _documentView.imagePath = changeImagePath;
}

- (void)docHandList:(NSArray *)docList whiteBoardHandList:(NSArray *)boardList { //画笔
    
    if(!_documentView) {
        _documentView = [[VHDocumentView alloc]initWithFrame:self.textImageView.bounds];
        _documentView.contentMode = UIViewContentModeScaleAspectFit;
        _documentView.backgroundColor=MakeColorRGB(0xe2e8eb);
    }
    _documentView.frame = self.textImageView.bounds;
    [self.textImageView addSubview:_documentView];
    [_documentView drawDocHandList:docList whiteBoardHandList:boardList];
}

- (void)VideoPlayMode:(VHallMovieVideoPlayMode)playMode isVrVideo:(BOOL)isVrVideo {// 获取当前视频播放模式
    
    VHLog(@"---%ld",(long)playMode);
    self.playModelTemp = playMode;
    self.liveTypeLabel.text = @"";
    _hlsMoviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    
    switch (playMode) {
        case VHallMovieVideoPlayModeNone:
        case VHallMovieVideoPlayModeMedia:
            
            break;
        case VHallMovieVideoPlayModeTextAndVoice: {
            self.liveTypeLabel.text = NSLocalizedString(@"LIVE_VOICE_ONGOING", nil);
        }
            break;
            
        case VHallMovieVideoPlayModeTextAndMedia:
            break;
        default:
            break;
    }
    
    [self alertWithMessage:playMode]; //提示视频模式
}

-(void)ActiveState:(VHallMovieActiveState)activeState {//获取视频活动状态
    VHLog(@"activeState-%ld",(long)activeState);
}

- (void)Announcement:(NSString *)content publishTime:(NSString *)time {//播主发布公告
    VHLog(@"公告:%@",content);
    
    if(!announcementView) { //横屏时frame错误
        if (_showView.width < [UIScreen mainScreen].bounds.size.height) {
            announcementView = [[AnnouncementView alloc] initWithFrame:CGRectMake(0, 0, _showView.width, 35) content:content time:nil];
        } else {
            announcementView = [[AnnouncementView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 35) content:content time:nil];
        }
        
    }
    announcementView.content = [content stringByAppendingString:time];
    [_showView addSubview:announcementView];
}

#pragma mark - ALMoviePlayerControllerDelegate
- (void)movieTimedOut {
}

- (void)moviePlayerWillMoveFromWindow {
    
    if (![self.backView.subviews containsObject:self.hlsMoviePlayer.view])
        [self.backView sendSubviewToBack:self.hlsMoviePlayer.view];
    
    //you MUST use [ALMoviePlayerController setFrame:] to adjust frame, NOT [ALMoviePlayerController.view setFrame:]
    //[self.hlsMoviePlayer setFrame:self.view.frame];
}

#pragma mark - ObserveValueForKeyPath
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if([keyPath isEqualToString:kViewFramePath]) {
        
        //        CGRect frame = [[change objectForKey:NSKeyValueChangeNewKey]CGRectValue];
        _hlsMoviePlayer.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.backView.height);
        //        [self.backView addSubview:self.hlsMoviePlayer.view];
        [self.backView sendSubviewToBack:self.hlsMoviePlayer.view];
        
    }
}

#pragma mark - notification Action
- (void)moviePlaybackStateDidChange:(NSNotification *)note {
    
    switch (self.hlsMoviePlayer.playbackState) {
        case MPMoviePlaybackStatePlaying: {
            VHLog(@"播放");
            if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice )
                self.liveTypeLabel.text = NSLocalizedString(@"VOICE_REPLAYING", nil);
        }
            break;
        case MPMoviePlaybackStateSeekingBackward:
        case MPMoviePlaybackStateSeekingForward: {
            VHLog(@"快进－－快退");
        }
            break;
        case MPMoviePlaybackStateInterrupted: {
            VHLog(@"中断了");
        }
            break;
        case MPMoviePlaybackStatePaused: {
            VHLog(@"暂停");
            if (self.hlsMoviePlayer.view) {
                [MBProgressHUD hideAllHUDsForView:self.hlsMoviePlayer.view animated:YES];
            }
            if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice )
                self.liveTypeLabel.text = NSLocalizedString(@"VOICE_REPLAY", nil);
        }
            break;
        case MPMoviePlaybackStateStopped: {
            VHLog(@"停止播放");
            if (self.hlsMoviePlayer.view) {
                [MBProgressHUD hideAllHUDsForView:self.hlsMoviePlayer.view animated:YES];
            }
            if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice )
                self.liveTypeLabel.text = NSLocalizedString(@"VOICE_REPLAY", nil);
        }
            break;
        default:
            break;
    }
}

- (void)movieLoadStateDidChange:(NSNotification *)note {
    if (self.hlsMoviePlayer.loadState == MPMovieLoadStatePlayable) {
        if (self.hlsMoviePlayer.view) {
            [MBProgressHUD showHUDAddedTo:self.hlsMoviePlayer.view animated:YES];
        }
        VHLog(@"开始加载加载");
        
    } else if(self.hlsMoviePlayer.loadState == (MPMovieLoadStatePlaythroughOK | MPMovieLoadStatePlayable)) {
        if (self.hlsMoviePlayer.view) {
            [MBProgressHUD hideAllHUDsForView:self.hlsMoviePlayer.view animated:YES];
        }
        VHLog(@"加载完成");
    }
}

- (void)moviePlayeExitFullScreen:(NSNotification *)note {
    if(announcementView && !announcementView.hidden) {
        announcementView.content = announcementView.content;
    }
}

- (void)didBecomeActive { //观看直播
    
    [self.hlsMoviePlayer prepareToPlay];
    [self.hlsMoviePlayer play];
    
    if(announcementView && !announcementView.hidden) {
        announcementView.content = announcementView.content;
    }
}

- (void)outputDeviceChanged:(NSNotification *)notification {
    NSInteger routeChangeReason = [[[notification userInfo]objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable: {
            VHLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            VHLog(@"Headphone/Line plugged in");
        }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            VHLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            VHLog(@"Headphone/Line was pulled. Stopping player....");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hlsMoviePlayer play];
            });
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange: {
            // called at start - also when other audio wants to play
            VHLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
        }
            break;
        default:
            break;
    }
}

#pragma mark - 评论
- (IBAction)detailsButtonClick:(UIButton *)sender {

    [self dealwithButtonText:0];
    
    [self getHistoryComment];
    
}

#pragma mark - 文档
- (IBAction)textButtonClick:(UIButton *)sender {

    [self dealwithButtonText:1];
}

#pragma mark - 详情
- (IBAction)detailBtnClick:(id)sender {
    
    [self dealwithButtonText:2];
}

- (void)dealwithButtonText:(NSInteger)type { //判断显示哪个界面
    
    self.historyCommentTableView.hidden = type == 0 ? NO : YES;
    self.textImageView.hidden = type == 1 ? NO : YES;
    
    [_commentBtn setTitleColor:type == 0 ? [UIColor redColor] : [UIColor blackColor] forState:UIControlStateNormal];
    [_docBtn setTitleColor:type == 1 ? [UIColor redColor] : [UIColor blackColor] forState:UIControlStateNormal];
    [_detalBtn setTitleColor:type == 2 ? [UIColor redColor] : [UIColor blackColor] forState:UIControlStateNormal];
    
    [self addDetailView: type != 2];
    
}

- (void)addDetailView:(BOOL)isHidden {

    self.detailTextView.hidden = isHidden;
    self.detailView.hidden = isHidden;
}

#pragma mark - 历史记录
- (IBAction)historyCommentButtonClick:(id)sender {
    
    _tableView.startPos = 0;
    [self pullingTableViewDidStartRefreshing:_tableView];
}

#pragma mark - 拉取前20条评论
-(void)getHistoryComment {
    [_commentsArray removeAllObjects];
    [self historyCommentButtonClick:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

#pragma mark - 点击聊天输入框蒙版
- (IBAction)sendCommentBtnClick:(id)sender {
    
    _toolViewBackView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, VH_SW, VH_SH)];
    [_toolViewBackView addTarget:self action:@selector(toolViewBackViewClick) forControlEvents:UIControlEventTouchUpInside];
    _messageToolView = [[VHMessageToolView alloc] initWithFrame:CGRectMake(0, _toolViewBackView.height - [VHMessageToolView  defaultHeight], VHScreenWidth, [VHMessageToolView defaultHeight]) type:3];
    _messageToolView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    _messageToolView.delegate = self;
    _messageToolView.hidden = NO;
    _messageToolView.maxLength = 140;
    [_toolViewBackView addSubview:_messageToolView];
    [self.view addSubview:_toolViewBackView];
    [_messageToolView beginTextViewInView];
}

-(void)toolViewBackViewClick {
    
    [_messageToolView endEditing:YES];
    [_toolViewBackView removeFromSuperview];
}

#pragma mark - messageToolViewDelegate
- (void)didSendText:(NSString *)text {
    
    __weak typeof(self) weakSelf = self;
    if(text.length > 0) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [_comment sendComment:text success:^{
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//            [UIAlertView popupAlertByDelegate:nil title:NSLocalizedString(@"SENT_SUCCESS", nil) message:nil];
            [self.view makeToast:NSLocalizedString(@"SENT_SUCCESS", nil) duration:1.08 position:CSToastPositionCenter];
            
            [weakSelf getHistoryComment];
            
        } failed:^(NSDictionary *failedData) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            NSString* code = [NSString stringWithFormat:@"%@", failedData[@"code"]];
//            [UIAlertView popupAlertByDelegate:nil title:failedData[@"content"] message:code];
            NSString *msg = [code isEqualToString:@"10407"] ? NSLocalizedString(@"NO_CHAT_RECORD", nil) : failedData[@"content"];
            [self.view makeToast:msg duration:1.08 position:CSToastPositionCenter];
        }];
    }
}

#pragma mark - alertView
- (void)alertWithMessage:(VHallMovieVideoPlayMode)state {
    
    NSString *message = nil;
    switch (state) {
        case 0:
            message = NSLocalizedString(@"NO_CONTENT", nil);
            break;
        case 1:
            message = NSLocalizedString(@"VIDEO_ONLY", nil);
            break;
        case 2:
            message = NSLocalizedString(@"DOCUMENT_AND_VOICE", nil);
            break;
        case 3:
            message = NSLocalizedString(@"DOCUMENT_AND_VIDEO", nil);
            break;
            
        default:
            break;
    }
    
    NSString *typeStr = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"LECTURE_TYPE", nil),message];
    [self.view makeToast:typeStr duration:1.08 position:CSToastPositionCenter];
    
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"SYSTEM_WARING", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
//    [alert show];
}


#pragma mark - tableView Delegate
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return _commentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    id model = [_commentsArray objectAtIndex:indexPath.row];
    
    WatchLiveChatCell *cell = [[WatchLiveChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WatchLiveChatCell"];
    cell.userInteractionEnabled = NO;
    cell.model = model;
    
    UILabel *line = [[UILabel alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    [cell addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(cell);
        make.height.mas_equalTo(0.5);
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id model = [_commentsArray objectAtIndex:indexPath.row];
    
    VHallChatModel *chatModel = model;
    
    TDBaseToolModel *toolModel = [[TDBaseToolModel alloc] init];
    CGFloat rowHeight = [toolModel heightForString:chatModel.text font:14 width:TDWidth - 75];
    
    return rowHeight + 58;
}

#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(VHPullingRefreshTableView *)tableView {
    
    [_commentsArray removeAllObjects];
    [self performSelector:@selector(loadData:) withObject:tableView];
}

- (void)pullingTableViewDidStartLoading:(VHPullingRefreshTableView *)tableView {
    [self performSelector:@selector(loadData:) withObject:tableView];
}


- (void)loadData:(VHPullingRefreshTableView *)tableView {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_comment getHistoryCommentPageCountLimit:20 offSet:_commentsArray.count success:^(NSArray *msgs) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        if (msgs.count > 0) {
            [_commentsArray addObjectsFromArray:msgs];
            [tableView tableViewDidFinishedLoading];
            tableView.reachedTheEnd = (msgs == nil || _commentsArray.count <= 5);
            [tableView reloadData];
        }
        
    } failed:^(NSDictionary *failedData) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSString *code = [NSString stringWithFormat:@"%@", failedData[@"code"]];
        
//        [UIAlertView popupAlertByDelegate:nil title:failedData[@"content"] message:code];
        NSString *msg = [code isEqualToString:@"10407"] ? NSLocalizedString(@"NO_CHAT_RECORD", nil) : failedData[@"content"];
        [self.view makeToast:msg duration:1.08 position:CSToastPositionCenter];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end



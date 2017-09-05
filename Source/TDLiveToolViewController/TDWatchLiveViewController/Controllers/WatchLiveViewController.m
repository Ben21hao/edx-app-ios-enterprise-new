//
//  WatchRTMPViewController.m
//  VHallSDKDemo
//
//  Created by developer_k on 16/4/13.
//  Copyright © 2016年 vhall. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import <MediaPlayer/MPMoviePlayerController.h>
#import "VHMessageToolView.h"
#import "VHallApi.h"
#import "VHQuestionCheckBox.h"
#import "VHDocumentView.h"
#import "AnnouncementView.h"
#import "SignView.h"
#import "TDLiveLotteryView.h"

#import "WatchLiveViewController.h"

#import "MBProgressHUD.h"
#import "BarrageRenderer.h"
#import "NSSafeObject.h"
#import "SZQuestionItem.h"
#import "VHallMsgModels.h"

#import "WatchLiveChatCell.h"
#import "TDOnlineCell.h"
#import "TDLiveSurverCell.h"
#import "TDLiveQACell.h"

# define DebugLog(fmt, ...) NSLog((@"\n[文件名:%s]\n""[函数名:%s]\n""[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);

static AnnouncementView *announcementView = nil;

@interface WatchLiveViewController () <VHallMoviePlayerDelegate, VHallChatDelegate, VHallQADelegate, VHallLotteryDelegate,VHallSignDelegate,VHallSurveyDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,VHMessageToolBarDelegate>
{
    __weak IBOutlet UIView *_showView;
    VHallMoviePlayer *_moviePlayer;//播放器
    VHallChat *_chat;          //聊天
    VHallQAndA *_QA;           //问答
    VHallLottery *_lottery;    //抽奖
    VHallSign *_sign;          //签到
    VHallSurvey *_survey;      //问卷
    BarrageRenderer *_renderer; //弹幕
    
    UIImageView *_logView; //当播放音频时显示的图片
    BOOL _isStart;
    BOOL _isMute;
    BOOL _isAllScreen;
    BOOL _isReciveHistory;
    BOOL _fullScreentBtnClick;
    BOOL _isVr;
    BOOL _isRender;
    int _bufferCount;
    
    NSMutableArray *_chatDataArray;
    NSMutableArray *_QADataArray;
    NSMutableArray *_videoPlayModel;//播放模式
    NSArray *_videoLevePicArray;   //视频质量等级图片
    UIButton *_toolViewBackView;   //遮罩
    NSMutableDictionary *announcementContentDic;   //公告内容
    VHDocumentView *_documentView;
    
}

@property (weak, nonatomic) IBOutlet UILabel *bufferCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
@property (weak, nonatomic) IBOutlet UIButton *allScreenBtn;
@property (weak, nonatomic) IBOutlet UILabel *bitRateLabel;
@property (weak, nonatomic) IBOutlet UIButton *startAndStopBtn;//播放按钮
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *textImageView;
@property (weak, nonatomic) IBOutlet UILabel *liveTypeLabel;

@property (weak, nonatomic) IBOutlet UIButton *detailBtn; //详情
@property (weak, nonatomic) IBOutlet UIButton *docBtn; //文档
@property (weak, nonatomic) IBOutlet UIButton *chatBtn; //聊天
@property (weak, nonatomic) IBOutlet UIButton *QABtn; //问答
@property (weak, nonatomic) IBOutlet UITableView *chatView; //聊天、问答界面

@property (weak, nonatomic) IBOutlet UIButton *definitionBtn0;
@property (weak, nonatomic) IBOutlet UIButton *definitionBtn1;
@property (weak, nonatomic) IBOutlet UIButton *definitionBtn2;
@property (weak, nonatomic) IBOutlet UIButton *definitionBtn3;
@property (weak, nonatomic) IBOutlet UIButton *playModeBtn0;
@property (weak, nonatomic) IBOutlet UIButton *playModeBtn1;
@property (weak, nonatomic) IBOutlet UIButton *playModeBtn2;
@property (weak, nonatomic) IBOutlet UIButton *playModeBtn3;
@property (weak, nonatomic) IBOutlet UILabel *modelLabel;

@property (weak, nonatomic) IBOutlet UIButton *GyroBtn;//陀螺仪开关

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIButton *fullscreenBtn;
@property (weak, nonatomic) IBOutlet UIButton *rendererOpenBtn;

@property (nonatomic,assign) VHallMovieVideoPlayMode playModelTemp;
@property (nonatomic,strong) UILabel *textLabel;
@property (nonatomic,strong) VHMessageToolView *messageToolView;  //输入框
@property (nonatomic,strong) NSArray *surveyResultArray;//问卷结果

@property (nonatomic,strong) UIView *detailView;
@property (nonatomic,strong) UITextView *detailTextView;
@property (nonatomic,strong) TDLiveLotteryView *liveLotteryView;

@end

@implementation WatchLiveViewController

-(UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]init];
        _textLabel.frame = CGRectMake(0, 10, self.textImageView.width, 21);
        _textLabel.text = NSLocalizedString(@"NO_DOCUMENT", nil);
        _textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _textLabel;
}

- (id)init {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:meetingResourcesBundle];
    if (self) {
        [self initDatas];
    }
    return self;
}

-(void)initDatas {
    
    _isStart = YES;
    _isMute = NO;
    _isAllScreen = NO;
    
    _chatDataArray = [NSMutableArray arrayWithCapacity:0];
    _QADataArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(announcementView && !announcementView.hidden) {
        announcementView.content = announcementView.content;
    }
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait) {
        _topConstraint.constant = 20;
        _fullscreenBtn.selected = NO;
        
    } else {
        _topConstraint.constant = 0;
        _fullscreenBtn.selected = YES;
    }
    
    DeviceOrientation orientation = kDevicePortrait;
    
    UIDeviceOrientation duration = [[UIDevice currentDevice] orientation];
    
    if (duration == UIDeviceOrientationPortrait) {
        orientation = kDevicePortrait;
        
    } else if (duration == UIDeviceOrientationLandscapeRight) {
        orientation = kDeviceLandSpaceRight;
        
    }else if (duration == UIDeviceOrientationLandscapeLeft) {
        orientation = kDeviceLandSpaceLeft;
    }
    
    if (_isVr && _GyroBtn.selected) {
        [_moviePlayer setUILayoutOrientation:orientation];
    }
    
    _fullScreentBtnClick = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _moviePlayer.moviePlayerView.frame = self.backView.bounds;
    _logView.frame = _moviePlayer.moviePlayerView.bounds;
    self.liveLotteryView.frame = _showView.bounds;
    
    if (_documentView) {
        _documentView.frame = self.textImageView.bounds;
        [_documentView layoutSubviews];
    }
}

- (void)dealloc {
    
    if (_chat) {
        _chat = nil;
    }
    
    if (_QA) {
        _QA = nil;
    }
    
    if (_lottery) {
        _lottery = nil;
    }
    
    if (self.liveLotteryView) {
        [self.liveLotteryView removeFromSuperview];
    }
    
    if (_sign) {
        _sign.delegate = nil;
    }
    
    if (_survey) {
        _survey.delegate = nil;
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];//阻止iOS设备锁屏
    
    [self.view removeObserver:self forKeyPath:kViewFramePath];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    VHLog(@"%@ dealloc",[[self class]description]);
}

- (void)initViews {
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES]; //阻止iOS设备锁屏
    
    [self registerLiveNotification];
    
    self.bufferCountLabel.text = [NSString stringWithFormat:@"%@ 0",NSLocalizedString(@"BUFFERING", nil)];
    
    [self.chatBtn setTitle:NSLocalizedString(@"CHAT_TEXT", nil) forState:UIControlStateNormal];
    [self.docBtn setTitle:NSLocalizedString(@"DOCUMENT_TEXT", nil) forState:UIControlStateNormal];
    [self.QABtn setTitle:NSLocalizedString(@"QA_TEXT", nil) forState:UIControlStateNormal];
    [self.detailBtn setTitle:NSLocalizedString(@"DETAILS_TEXT", nil) forState:UIControlStateNormal];
    
    // chat & QA 在播放之前初始化并设置代理
    _chat = [[VHallChat alloc] init];
    _chat.delegate = self;
    
    _QA = [[VHallQAndA alloc] init];
    _QA.delegate = self;
    
    _lottery = [[VHallLottery alloc] init];
    _lottery.delegate = self;
    
    _sign = [[VHallSign alloc] init];
    _sign.delegate = self;
    
    _survey=[[VHallSurvey alloc] init];
    _survey.delegate= self;
    
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    _moviePlayer = [[VHallMoviePlayer alloc]initWithDelegate:self];
    _moviePlayer.movieScalingMode = kRTMPMovieScalingModeAspectFit;
    _moviePlayer.bufferTime = 6;
    _moviePlayer.reConnectTimes = 2;
    _moviePlayer.liveFormat = kLiveFormatRtmp;
    
    _moviePlayer.defaultDefinition = VHallMovieDefinitionSD; //默认播放标清
    // [_moviePlayer setRenderViewModel:kVHallRenderModelDewarpVR];
    
    _logView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UIModel.bundle/vhallLogo.tiff"]];
    _logView.backgroundColor = [UIColor whiteColor];
    _logView.contentMode = UIViewContentModeCenter;
    
    [self.backView addSubview:_moviePlayer.moviePlayerView];
    [self.backView sendSubviewToBack:_moviePlayer.moviePlayerView];
    [_moviePlayer.moviePlayerView addSubview:_logView];
    [self.view bringSubviewToFront:self.backView];
    
    _textImageView.hidden = YES;
    _logView.hidden = YES;
    _videoLevePicArray = @[@"UIModel.bundle/原画.tiff",@"UIModel.bundle/超清.tiff",@"UIModel.bundle/高清.tiff",@"UIModel.bundle/标清.tiff",@""];
    //    _videoPlayModelPicArray=@[@"UIModel.bundle/单视频",@"UIModel.bundle/单音频"];
    
    _videoPlayModel = [NSMutableArray array];
    
    if ([self.chatView  respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.chatView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [self initBarrageRenderer];
    
    self.detailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight - TDWidth * 0.56 - 39)];
    self.detailView.backgroundColor = [UIColor colorWithHexString:colorHexStr13];
    [_showView addSubview:self.detailView];
    
    self.detailTextView = [[UITextView alloc] init];
    self.detailTextView.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.detailTextView.editable = NO;
    self.detailTextView.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.detailTextView.backgroundColor = [UIColor colorWithHexString:colorHexStr13];
    self.detailTextView.text = [NSString stringWithFormat:@"   %@", self.detailStr];
    [self.detailView addSubview:self.detailTextView];
    
    [self.detailTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.detailView.mas_left).offset(8);
        make.top.mas_equalTo(self.detailView.mas_top).offset(8);
        make.right.mas_equalTo(self.detailView.mas_right).offset(-8);
        make.bottom.mas_equalTo(self.detailView.mas_bottom).offset(-18);
    }];
    
    self.detailView.hidden = YES;
    
    self.liveLotteryView = [[TDLiveLotteryView alloc] init];
    self.liveLotteryView.lottery = _lottery;
    WS(weakSelf);
    self.liveLotteryView.closeButtonHandle = ^(){
        [weakSelf.liveLotteryView removeFromSuperview];
    };
    [_showView addSubview:self.liveLotteryView];
    
    [self.liveLotteryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(_showView);
    }];
    
    self.liveLotteryView.hidden = YES;
    
}

- (void)initBarrageRenderer {
    
    _renderer = [[BarrageRenderer alloc]init];
    _renderer.canvasMargin = UIEdgeInsetsMake(20, 10,30, 10);
    [_moviePlayer.moviePlayerView addSubview:_renderer.view];
    
    // 若想为弹幕增加点击功能, 请添加此句话, 并在Descriptor中注入行为
    //    _renderer.view.userInteractionEnabled = YES;
    [_moviePlayer.moviePlayerView sendSubviewToBack:_renderer.view];
}


#pragma mark - 注册通知
- (void)registerLiveNotification {
    
    [self.view addObserver:self forKeyPath:kViewFramePath options:NSKeyValueObservingOptionNew context:nil];
    //已经进入活跃状态的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive)name:UIApplicationDidBecomeActiveNotification object:nil];
    //监听耳机的插拔
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputDeviceChanged:)name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationAction:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
}

-(void)didBecomeActive { //已经进入活跃状态的通知
    
    NSString *content = nil;
    NSString *time = nil;
    if (announcementContentDic != nil) {
        content =[announcementContentDic objectForKey:@"announceContent"];
        time =[announcementContentDic objectForKey:@"announceTime"];
    }
    
    if(announcementView != nil) {
        [announcementView setContent:[content stringByAppendingString:time]];
    }
}

- (void)outputDeviceChanged:(NSNotification*)notification { //监听耳机的插拔
    
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

- (void)orientationAction:(NSNotification *)noti {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight || orientation ==UIInterfaceOrientationLandscapeLeft) { // home键靠左右
        
        [self resignLotteryViewFirstResponder];
    }
}

- (void)resignLotteryViewFirstResponder {
    [self.liveLotteryView.tfPhone resignFirstResponder];
    [self.liveLotteryView.tfName resignFirstResponder];
}

#pragma mark - UIButton Event
- (IBAction)stopWatchBtnClick:(id)sender { //播放暂停
    
    _definitionBtn0.hidden = YES;
    
    if (_isStart) { //播放
        [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:NO];
        [MBProgressHUD showHUDAddedTo:_moviePlayer.moviePlayerView animated:YES];
        
        _bufferCount = 0;
        _bufferCountLabel.text = [NSString stringWithFormat:@"%@%d",NSLocalizedString(@"BUFFERING", nil),_bufferCount];
        
        //todo
        NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
        param[@"id"] =  _roomId; //活动id
        param[@"name"] = [UIDevice currentDevice].name;
        param[@"email"] = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        if (_kValue && _kValue.length > 0) {
            param[@"pass"] = _kValue;
        }
        [_moviePlayer startPlay:param];
        
        if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice || self.playModelTemp == VHallMovieVideoPlayModeVoice) {
            self.liveTypeLabel.text = NSLocalizedString(@"LIVE_VOICE_ONGOING", nil);
        } else {
            self.liveTypeLabel.text = @"";
        }
        
    } else { //暂停
        [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:NO];
        
        _bitRateLabel.text = @"";
        _bufferCount = 0;
        _bufferCountLabel.text = [NSString stringWithFormat:@"%@%d",NSLocalizedString(@"BUFFERING", nil),_bufferCount];
        
        _startAndStopBtn.selected = NO;
        [_moviePlayer stopPlay];
        
        if (self.playModelTemp == VHallMovieVideoPlayModeTextAndVoice || self.playModelTemp == VHallMovieVideoPlayModeVoice) {
            self.liveTypeLabel.text = NSLocalizedString(@"LIVE_VOICE_ONGOING", nil);
        }
        
        [self chatButtonClick:nil];
    }
    
    if (self.textImageView.image == nil) {
        [self.textImageView addSubview:self.textLabel];
        
    }else{
        [self.textLabel removeFromSuperview];
        self.textLabel = nil;
    }
    _isStart = !_isStart;

}

#pragma mark - 返回上层界面按钮
- (IBAction)closeBtnClick:(id)sender {
    __weak typeof(self) weakSelf = self;
    [_renderer stop];
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf destoryMoivePlayer];
    }];
}

- (void)destoryMoivePlayer {
    [_moviePlayer destroyMoivePlayer];
}

#pragma mark - 静音
- (IBAction)muteBtnClick:(UIButton *)sender {
    
    _isMute = !_isMute;
    
    [_moviePlayer setMute:_isMute];
    sender.selected = _isMute;
}

#pragma mark - RTMP屏幕自适应
- (IBAction)allScreenBtnClick:(id)sender {
    
    _isAllScreen = !_isAllScreen;
    if (_isAllScreen) {
        _moviePlayer.movieScalingMode = kRTMPMovieScalingModeAspectFill;
        
    } else {
        _moviePlayer.movieScalingMode = kRTMPMovieScalingModeAspectFit;
    }
}

#pragma mark - 发送聊天按钮
- (IBAction)sendChatBtnClick:(id)sender {
    
    _toolViewBackView=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, VH_SW, VH_SH)];
    _toolViewBackView.backgroundColor=[UIColor clearColor];
    [_toolViewBackView addTarget:self action:@selector(toolViewBackViewClick) forControlEvents:UIControlEventTouchUpInside];
    
    _messageToolView = [[VHMessageToolView alloc] initWithFrame:CGRectMake(0, _toolViewBackView.height-[VHMessageToolView  defaultHeight], VHScreenWidth, [VHMessageToolView defaultHeight]) type:3];
    _messageToolView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    _messageToolView.delegate = self;
    _messageToolView.hidden = NO;
    _messageToolView.maxLength = 140;
    
    WS(weakSelf);
    self.messageToolView.handleNoText = ^(){
        [weakSelf.view makeToast:NSLocalizedString(@"ENTER_SEND_MESSAGE", nil) duration:1.08 position:CSToastPositionCenter];
    };
    [_toolViewBackView addSubview:_messageToolView];
    [self.view addSubview:_toolViewBackView];
    
    [_messageToolView beginTextViewInView];
}

#pragma mark - 点击聊天输入框蒙版
-(void)toolViewBackViewClick {
    [_messageToolView endEditing:YES];
    [_toolViewBackView removeFromSuperview];
}

#pragma mark - Lifecycle Method
-(BOOL)shouldAutorotate {
    
    if (_fullScreentBtnClick) {
        return YES;
    } else if (_isVr) {
        return NO;
    }
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (_fullScreentBtnClick) {
        return YES;
    } else if (_isVr) {
        return NO;
    }
    return YES;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
    
    if (IOSVersion < 8.0) {
        
        CGRect frame = self.view.frame;
        CGRect bounds = [[UIScreen mainScreen]bounds];
        
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait
            || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
            frame = self.backView.bounds;//竖屏
            
        } else {
            frame = CGRectMake(0, 0, bounds.size.height, bounds.size.width);//横屏
        }
        _moviePlayer.moviePlayerView.frame = frame;
        _logView.frame = _moviePlayer.moviePlayerView.bounds;
        self.liveLotteryView.frame = _showView.bounds;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    [self.messageToolView endEditing:YES];
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    tableView.tableFooterView = [[UIView alloc] init];
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    if (self.chatBtn.selected) {
        return _chatDataArray.count;
    }
    
    if (_QABtn.selected) {
        return _QADataArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if (self.chatBtn.selected) { //选择聊天
        id model = [_chatDataArray objectAtIndex:indexPath.row];
        
        if ([model isKindOfClass:[VHallOnlineStateModel class]]) { //上下线消息
            
            TDOnlineCell *cell = [[TDOnlineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDOnlineCell"];
            cell.model = model;
            return cell;
            
        } else if([model isKindOfClass:[VHallSurveyModel class]]) { //问卷
            
            TDLiveSurverCell *cell = [[TDLiveSurverCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDLiveSurverCell"];
            cell.model = model;
            
            __weak typeof(self) weakSelf = self;
            cell.clickSurveyItem = ^(VHallSurveyModel *model) {
                [weakSelf performSelector:@selector(clickSurvey:) withObject:model];
            };
            return cell;
            
        } else { //聊天消息
            
            WatchLiveChatCell *cell = [[WatchLiveChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"WatchLiveChatCell"];
            cell.userInteractionEnabled = NO;
            cell.model = model;
            return cell;
        }
        
    } else if (_QABtn.selected) { //问答
        
        TDLiveQACell *cell = [[TDLiveQACell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDLiveQACell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = [_QADataArray objectAtIndex:indexPath.row];
        
        return cell;
        
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifiCell"];
        if (!cell) {
            cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"identifiCell"];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height = 0;
    TDBaseToolModel *toolModel = [[TDBaseToolModel alloc] init];
    
    if (self.chatBtn.selected) {
        
        id model = [_chatDataArray objectAtIndex:indexPath.row];
        
        if ([model isKindOfClass:[VHallOnlineStateModel class]]) { //上下线消息
            height = 68;
            
        } else if([model isKindOfClass:[VHallSurveyModel class]]) { //问卷
            height = 60;
            
        } else { //聊天消息
            
            VHallChatModel *chatModel = model;
            
            CGFloat rowHeight = [toolModel heightForString:chatModel.text font:14 width:TDWidth - 75];
            height = rowHeight + 55;
        }

    } else if (_QABtn.selected) {
        VHallQuestionModel *model = [_QADataArray objectAtIndex:indexPath.row];
        CGFloat rowHeight = [toolModel heightForString:model.content font:14 width:TDWidth - 66];
        height = rowHeight + 61;
    }
    return height;
}

-(void)clickSurvey:(id)mode {
    
    VHallSurveyModel *model = mode;
    __weak typeof(self) weakSelf = self;
    [self rotateScreen:NO];
    self.fullscreenBtn.enabled = NO;
    
    [_survey getSurveryContentWithSurveyId:model.surveyId webInarId:_roomId success:^(VHallSurvey *survey) {
        weakSelf.fullscreenBtn.enabled = YES;
        [weakSelf showSurveyVCWithSruveyModel:survey];
        
    } failed:^(NSDictionary *failedData) {
        weakSelf.fullscreenBtn.enabled = YES;
        
//        NSString *code = [NSString stringWithFormat:@"%@", failedData[@"code"]];
//        [UIAlertView popupAlertByDelegate:nil title:failedData[@"content"] message:code];
        
        [self.view makeToast:failedData[@"content"] duration:1.08 position:CSToastPositionCenter];
    }];
}
//调查问卷页面
-(void)showSurveyVCWithSruveyModel:(VHallSurvey*)survey {
    //    __weak typeof(self) weakSelf =self;
    NSMutableArray *titleArray = [[NSMutableArray alloc] init];
    NSMutableArray *optionArray = [[NSMutableArray alloc] init];
    NSMutableArray *typeArry  = [[NSMutableArray alloc] init];
    NSMutableArray *isMustSelectArray = [[NSMutableArray alloc] init];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_orderNum" ascending:NO];
    survey.questionArray =[survey.questionArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    for (VHallSurveyQuestion *question in survey.questionArray) {
        [titleArray addObject:question.questionTitle];
        
        if (question.quesionSelectArray != nil) {
            [optionArray addObject:question.quesionSelectArray];
            
        } else {
            [optionArray addObject:@[]];
        }
        // 选项类型 （0问答 1单选 2多选）
        if (question.type == 0) {
            [typeArry addObject:@(3)];
            
        } else if (question.type ==1) {
            [typeArry addObject:@(1)];
            
        } else if (question.type ==2) {
            [typeArry addObject:@(2)];
        }
        
        if (question.isMustSelect) {
            [isMustSelectArray addObject:@"1"];
        } else {
            [isMustSelectArray addObject:@"0"];
        }
    }
    
    SZQuestionItem *item = [[SZQuestionItem alloc] initWithTitleArray:titleArray andOptionArray:optionArray andResultArray:self.surveyResultArray andQuestonTypes:typeArry isMustSelectArray:isMustSelectArray];
    VHQuestionCheckBox *questionBox = [[VHQuestionCheckBox alloc] initWithItem:item];
    questionBox.survey = survey;
    
    [self presentViewController:questionBox animated:YES completion:^{
        
    }];
}

#pragma mark - UIPanGestureRecognizer
- (void)addPanGestureRecognizer {
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [_moviePlayer.moviePlayerView addGestureRecognizer:panGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan { //设置系统声音大小
    
    float baseY = 200.0f;
    CGPoint translation = CGPointZero;
    static float volumeSize = 0.0f;
    CGPoint currentLocation = [pan translationInView:self.view];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        translation = [pan translationInView:self.view];
        volumeSize = [VHMoviePlayer getSysVolumeSize]; //获取系统声音大小
        
    } else if(pan.state == UIGestureRecognizerStateChanged) {
        float y = currentLocation.y - translation.y;
        float changeSize = ABS(y) / baseY;
        if (y > 0){
            [VHMoviePlayer setSysVolumeSize:volumeSize - changeSize];
        } else {
            [VHMoviePlayer setSysVolumeSize:volumeSize + changeSize];
        }
    }
}

#pragma mark - VHMoviePlayerDelegate
-(void)moviePlayerWillMoveFromWindow {
}

-(void)connectSucceed:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info {//播放连接成功
    //  [_startAndStopBtn setTitle:@"停止播放" forState:UIControlStateNormal];
    _startAndStopBtn.selected = YES;
    [_definitionBtn0 setImage:[UIImage imageNamed:_videoLevePicArray[_moviePlayer.curDefinition]] forState:UIControlStateNormal];
}

-(void)bufferStart:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info { //缓冲开始回调
    _bufferCount++;
    _bufferCountLabel.text = [NSString stringWithFormat:@"%@%d",NSLocalizedString(@"BUFFERING", nil),_bufferCount];
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:NO];
    [MBProgressHUD showHUDAddedTo:_moviePlayer.moviePlayerView animated:YES];
}

-(void)bufferStop:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info {//缓冲结束回调
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:YES];
    
}

-(void)downloadSpeed:(VHMoviePlayer *)moviePlayer info:(NSDictionary *)info {//下载速率的回调
    NSString * content = info[@"content"];
    _bitRateLabel.text = [NSString stringWithFormat:@"%@ kb/s",content];
    //    VHLog(@"downloadSpeed:%@",[info description]);
}

- (void)cdnSwitch:(VHMoviePlayer*)moviePlayer info:(NSDictionary*)info {//cdn 发生切换时的回调
    
}

- (void)recStreamtype:(VHMoviePlayer*)moviePlayer info:(NSDictionary*)info { //Streamtype
    
    VHallStreamType streamType = (VHallStreamType)[info[@"content"] intValue];
    if (streamType == kVHallStreamTypeVideoAndAudio) {
        _logView.hidden = YES;
    } else if(streamType == kVHallStreamTypeOnlyAudio){
        _logView.hidden = NO;
    }
}

- (void)playError:(LivePlayErrorType)livePlayErrorType info:(NSDictionary *)info { //播放时错误的回调
    
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:YES];
    
    void (^resetStartPlay)(NSString * msg) = ^(NSString * msg){
        _isStart = YES;
        _bitRateLabel.text = @"";
        _startAndStopBtn.selected = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self detailsButtonClick: nil];
//            [UIAlertView popupAlertByDelegate:nil title:msg message:nil]; //弹框
            [self.view makeToast:msg duration:1.08 position:CSToastPositionCenter];
            
        });
    };
    
    NSString * msg = @"";
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
            [self detailsButtonClick: nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBHUDHelper showWarningWithText:info[@"content"]];
            });
        }
            break;
        default:
            break;
    }
}

#pragma mark - vhallMoviePlayerDelegate
-(void)PPTScrollNextPagechangeImagePath:(NSString *)changeImagePath { //包含文档 获取翻页图片路径
    
    //    [_pptHandView removeFromSuperview];
    //    _pptHandView = nil;
    //    self.textImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:changeImagePath]]];
    //    if (self.textImageView.image == nil) {
    //        [self.textImageView addSubview:self.textLabel];
    //    }else{
    //        [self.textLabel removeFromSuperview];
    //        self.textLabel = nil;
    //
    //    }
    
    if (changeImagePath.length <= 0) {
        [self.textImageView addSubview:self.textLabel]; //无文档
        
    } else {
        [self.textLabel removeFromSuperview];
        self.textLabel = nil;
    }
    
    if(!_documentView) {
        _documentView = [[VHDocumentView alloc] initWithFrame:self.textImageView.bounds];
        _documentView.contentMode = UIViewContentModeScaleAspectFit;
        _documentView.backgroundColor = MakeColorRGB(0xe2e8eb);
    }
    _documentView.frame = self.textImageView.bounds;
    [self.textImageView addSubview:_documentView];
    _documentView.imagePath = changeImagePath;
}

- (void)docHandList:(NSArray*)docList whiteBoardHandList:(NSArray *)boardList { //画笔
    
    if(!_documentView) {
        _documentView = [[VHDocumentView alloc]initWithFrame:self.textImageView.bounds];
        _documentView.contentMode = UIViewContentModeScaleAspectFit;
        _documentView.backgroundColor = MakeColorRGB(0xe2e8eb);
    }
    _documentView.frame = self.textImageView.bounds;
    [_documentView drawDocHandList:docList whiteBoardHandList:boardList];
}

- (void)VideoPlayMode:(VHallMovieVideoPlayMode)playMode isVrVideo:(BOOL)isVrVideo { //获取当前视频播放模式
    
    [self chatButtonClick:nil];
    _isVr = isVrVideo;
    
    if (!_isRender) {
        if (isVrVideo) {
            _GyroBtn.hidden = NO;
            _GyroBtn.selected = YES;
            [_moviePlayer setRenderViewModel:kVHallRenderModelDewarpVR];
            [_moviePlayer setUsingGyro:YES];
            
        } else {
            _GyroBtn.hidden =YES;
            _GyroBtn.selected = NO;
            [_moviePlayer setRenderViewModel:kVHallRenderModelOrigin];
            [_moviePlayer setUsingGyro:NO];
            [self addPanGestureRecognizer];
        }
        _isRender =YES;
    }
    
    VHLog(@"---%ld",(long)playMode);
    
    self.liveTypeLabel.text = @"";
    _playModelTemp = playMode;
    
    switch (playMode) {
        case VHallMovieVideoPlayModeNone:
        case VHallMovieVideoPlayModeMedia:
        case VHallMovieVideoPlayModeTextAndMedia:
            //            [_playModeBtn0 setImage:[UIImage imageNamed:_videoPlayModelPicArray[0]] forState:UIControlStateNormal];
            _playModeBtn0.selected = NO;
            _playModeBtn0.enabled=YES;
            break;
        case VHallMovieVideoPlayModeTextAndVoice:
        case VHallMovieVideoPlayModeVoice: {
            self.liveTypeLabel.text = NSLocalizedString(@"LIVE_VOICE_ONGOING", nil);
        }
            _playModeBtn0.enabled=NO;
            break;
        default:
            break;
    }
    
    [self alertWithMessage:playMode]; //提示视频模式
}

- (void)VideoPlayModeList:(NSArray *)playModeList { //获取当前视频支持的所有播放模式
    
    for (NSNumber *playMode in playModeList) {
        switch ([playMode intValue]) {
            case VHallMovieVideoPlayModeMedia:
                [_videoPlayModel addObject:@"1"];
                break;
                
            case VHallMovieVideoPlayModeTextAndVoice:
                [_videoPlayModel addObject:@"2"];
                break;
                
            case VHallMovieVideoPlayModeTextAndMedia:
                [_videoPlayModel addObject:@"3"];
                break;
                
            case VHallMovieVideoPlayModeVoice:
                [_videoPlayModel addObject:@"4"];
                break;
            default:
                break;
        }
    }
}

-(void)ActiveState:(VHallMovieActiveState)activeState { //获取视频活动状态
    VHLog(@"activeState-%ld",(long)activeState);
}

- (void)VideoDefinitionList: (NSArray *)definitionList {//该直播支持的清晰度列表
    
    VHLog(@"可用分辨率%@ 当前分辨率：%ld",definitionList,(long)_moviePlayer.curDefinition);
    _definitionBtn0.hidden = NO;
    [_definitionBtn0 setImage:[UIImage imageNamed:_videoLevePicArray[_moviePlayer.curDefinition]] forState:UIControlStateNormal];
    if (_moviePlayer.curDefinition == VHallMovieDefinitionAudio) {
        _playModelTemp=VHallMovieVideoPlayModeVoice;
        _playModeBtn0.selected = YES;
    }
}

- (void)LiveStoped { //直播结束消息
    
    VHLog(@"直播已结束");
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:YES];
    
    _isStart = NO;
    [self stopWatchBtnClick:nil];
    [self.view makeToast:NSLocalizedString(@"LIVE_ENDED", nil) duration:1.08 position:CSToastPositionCenter];
    
    if (self.liveEndHandle) {
        self.liveEndHandle();
    }
}

#pragma mark - Announcement
- (void)Announcement:(NSString *)content publishTime:(NSString *)time { //播主发布公告
    
    VHLog(@"公告:%@",content);
    if (!announcementContentDic) {
        announcementContentDic = [[NSMutableDictionary alloc] init];
    }
    [announcementContentDic setObject:content forKey:@"announceContent"];
    [announcementContentDic setObject:time forKey:@"announceTime"];
    
    if(!announcementView) { //横屏时frame错误
        if (_showView.width < [UIScreen mainScreen].bounds.size.height) {
            announcementView = [[AnnouncementView alloc]initWithFrame:CGRectMake(0, 0, _showView.width, 35) content:content time:nil];
        } else {
            announcementView = [[AnnouncementView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, 35) content:content time:nil];
        }
    }
    announcementView.content = [content stringByAppendingString:time];
    [_showView addSubview:announcementView];
    
}

#pragma mark - VHallChatDelegate
- (void)reciveOnlineMsg:(NSArray *)msgs { //获取在线消息
    
    if (msgs.count > 0) {
        [_chatDataArray addObjectsFromArray:msgs];
        if (self.chatBtn.selected) {
            [_chatView reloadData];
            [_chatView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_chatDataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

- (void)reciveChatMsg:(NSArray *)msgs {
    
    if (msgs.count > 0) {
        [_chatDataArray addObjectsFromArray:msgs];
        if (self.chatBtn.selected) {
            [_chatView reloadData];
            [_chatView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_chatDataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
        VHallChatModel *model = [msgs objectAtIndex:0];
        BarrageDescriptor * descriptor = [[BarrageDescriptor alloc]init];
        descriptor.spriteName = NSStringFromClass([BarrageWalkImageTextSprite class]);
        descriptor.params[@"text"] = model.text;
        descriptor.params[@"textColor"] = MakeColorRGB(0xffffff); //MakeColor(random()%255, random()%255, random()%255, 1);
        //@(100 * (double)random()/RAND_MAX+50) 随机速度
        descriptor.params[@"speed"] = @(100); // 固定速度
        descriptor.params[@"direction"] = @(BarrageWalkDirectionR2L);
        descriptor.params[@"side"] = @(BarrageWalkSideDefault);
        //        descriptor.params[@"clickAction"] = ^{
        //            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"弹幕被点击" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
        //            [alertView show];
        //        };
        [_renderer receive:descriptor];
    }
}

#pragma mark - VHallQAndADelegate
- (void)reciveQAMsg:(NSArray *)msgs { //接收问答消息
    
    if (msgs.count > 0) {
        VHallQAModel *qaModel = [msgs lastObject];
        
        if (qaModel.questionModel) {
            [_QADataArray addObject:qaModel.questionModel];
        }
        
        if (qaModel.answerModels && qaModel.answerModels.count > 0) {
            [_QADataArray addObjectsFromArray:qaModel.answerModels];
        }
        
        if (_QABtn.selected) {
            [_chatView reloadData];
        }
    }
}

#pragma mark - VHallLotteryDelegate
- (void)startLottery:(VHallStartLotteryModel *)msg { //开始抽奖
    
    self.liveLotteryView.lottery = _lottery;
    self.liveLotteryView.hidden = NO;
}

- (void)endLottery:(VHallEndLotteryModel *)msg { //抽奖结束
    
    self.liveLotteryView.endLotteryModel = msg;
}

#pragma mark - VHallSignDelegate
- (void)startSign { //开始签到
    
    //    NSLog(@"开始签到");
    __weak typeof(self) weakSelf = self;
    [SignView showSignBtnClickedBlock:^BOOL{
        [weakSelf SignBtnClicked];
        return NO;
    }];
}

- (void)signRemainingTime:(NSTimeInterval)remainingTime { //距签到结束剩余时间
    //    NSLog(@"距结束%d秒",(int)remainingTime);
    [SignView remainingTime:remainingTime];
}

- (void)stopSign { //签到结束
    [SignView close];
    [self showMsg:NSLocalizedString(@"SINGN_IN_ENDED", nil) afterDelay:2];
}

- (void)SignBtnClicked { //签到
    
    __weak typeof(self) weakSelf = self;
    [_sign signSuccess:^{
        [SignView close];
        [weakSelf showMsg:NSLocalizedString(@"SINGNED_IN", nil) afterDelay:2];
        
    } failed:^(NSDictionary *failedData) {
        
        [weakSelf showMsg:[NSString stringWithFormat:@"%@,%@%@",failedData[@"content"],NSLocalizedString(@"ERROR_CODE", nil),failedData[@"code"]] afterDelay:2];
        [_sign cancelSign];
        [SignView close];
    }];
}

#pragma mark - 问卷调查delegate
-(void)receiveSurveryMsgs:(NSArray *)msgs {//接收问卷消息
    
    if (msgs.count > 0) {
        [_chatDataArray addObjectsFromArray:msgs];
        
        if (self.chatBtn.selected) {
            [_chatView reloadData];
            [_chatView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_chatDataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

#pragma mark - ObserveValueForKeyPath
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if([keyPath isEqualToString:kViewFramePath]) {
        
        _moviePlayer.moviePlayerView.frame = self.backView.bounds;
        _logView.frame = _moviePlayer.moviePlayerView.bounds;
        self.liveLotteryView.frame = _showView.bounds;
        [SignView layoutView:self.view.bounds];
    }
}

#pragma mark - 详情
- (IBAction)detailsButtonClick:(UIButton *)sender {
    
    [self dealwithButtonText:3 hidChatView:YES hidTextView:YES];
    
    [self resignLotteryViewFirstResponder];
}

#pragma mark - 文档
- (IBAction)textButtonClick:(UIButton *)sender {
    
    [self dealwithButtonText:1 hidChatView:YES hidTextView:NO];
    
    [self resignLotteryViewFirstResponder];
}

#pragma mark - 聊天
- (IBAction)chatButtonClick:(UIButton *)sender {
    
    [self dealwithButtonText:0 hidChatView:NO hidTextView:YES];
    
    [_chatView reloadData];
    
    if (!_isReciveHistory) {
        [_chat getHistoryWithType:YES success:^(NSArray * msgs) {
            
            if (msgs.count > 0) {
                [_chatDataArray addObjectsFromArray:msgs];
                
                if (self.chatBtn.selected) {
                    
                    [_chatView reloadData];
                    [_chatView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_chatDataArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            }
            
        } failed:^(NSDictionary *failedData) {
            
            NSString *code = [NSString stringWithFormat:@"%@", failedData[@"code"]];
//            [UIAlertView popupAlertByDelegate:nil title:failedData[@"content"] message:code];
            
            NSString *msg = [code isEqualToString:@"10407"] ? NSLocalizedString(@"NO_CHAT_RECORD", nil) : failedData[@"content"];
            [self.view makeToast:msg duration:1.08 position:CSToastPositionCenter];
            
        }];
        _isReciveHistory = YES;
    }
    
    [self resignLotteryViewFirstResponder];
}

#pragma mark - 问答
- (IBAction)QAButtonClick:(UIButton *)sender {
    
    [self dealwithButtonText:2 hidChatView:NO hidTextView:YES];
    
    [_chatView reloadData];
    
    [self resignLotteryViewFirstResponder];
}

- (void)dealwithButtonText:(NSInteger)type hidChatView:(BOOL)hidChatView hidTextView:(BOOL)hidTextView { //判断显示哪个界面
    
    self.textImageView.hidden = hidTextView;
    self.chatView.hidden = hidChatView;
    
    self.chatBtn.selected = type == 0 ? YES : NO;
    self.docBtn.selected = type == 1 ? YES : NO;
    self.QABtn.selected = type == 2 ? YES : NO;
    self.detailBtn.selected = type == 3 ? YES : NO;
    
    [self.chatBtn setTitleColor:type == 0 ? [UIColor redColor] : [UIColor blackColor] forState:UIControlStateNormal];
    [self.docBtn setTitleColor:type == 1 ? [UIColor redColor] : [UIColor blackColor] forState:UIControlStateNormal];
    [self.QABtn setTitleColor:type == 2 ? [UIColor redColor] : [UIColor blackColor] forState:UIControlStateNormal];
    [self.detailBtn setTitleColor:type == 3 ? [UIColor redColor] : [UIColor blackColor] forState:UIControlStateNormal];
    
    [self addDetailView: type != 3];
    
}

- (void)addDetailView:(BOOL)isHidden {
    
    self.detailTextView.hidden = isHidden;
    self.detailView.hidden = isHidden;
}

#pragma mark - 弹框提示
- (void)alertWithMessage:(VHallMovieVideoPlayMode)state {
    
    NSString*message = nil;
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
    
//    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"SYSTEM_WARING", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
//    [alert show];
}


- (IBAction)definitionBtnCLicked:(UIButton *)sender {
    
    int _leve = _moviePlayer.curDefinition + 1;
    if (_leve==4) {
        _leve=0;
    }
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:NO];
    [MBProgressHUD showHUDAddedTo:_moviePlayer.moviePlayerView animated:YES];
    
    _leve =  [_moviePlayer setDefinition:_leve];
    _playModeBtn0.selected = NO;
    [_definitionBtn0 setImage:[UIImage imageNamed:_videoLevePicArray[_moviePlayer.curDefinition]] forState:UIControlStateNormal];
    
    [self resignLotteryViewFirstResponder];
}

- (IBAction)playModeBtnCLicked:(UIButton *)sender {
    
    UIButton *btn =(UIButton *)sender;
    btn.selected = !sender.selected;
    
    if (btn.selected) {
        _playModelTemp = VHallMovieVideoPlayModeVoice;
        _playModeBtn0.selected = YES;
        //        [_playModeBtn0 setImage:[UIImage imageNamed:_videoPlayModelPicArray[1]] forState:UIControlStateNormal];
    } else {
        _playModeBtn0.selected = NO;
        _playModelTemp = VHallMovieVideoPlayModeMedia;
        //        [_playModeBtn0 setImage:[UIImage imageNamed:_videoPlayModelPicArray[0]] forState:UIControlStateNormal];
    }
    
    
    [MBProgressHUD hideHUDForView:_moviePlayer.moviePlayerView animated:NO];
    [MBProgressHUD showHUDAddedTo:_moviePlayer.moviePlayerView animated:YES];
    
    _moviePlayer.playMode = _playModelTemp;
    
    if (_playModelTemp == VHallMovieVideoPlayModeVoice || _playModelTemp == VHallMovieVideoPlayModeTextAndVoice) {
        [_moviePlayer setDefinition:VHallMovieDefinitionAudio];
        _logView.hidden=NO;
        
    } else {
        [_moviePlayer setDefinition:VHallMovieDefinitionOrigin];
        _logView.hidden=YES;
    }
    
    [_definitionBtn0 setImage:[UIImage imageNamed:_videoLevePicArray[_moviePlayer.curDefinition]] forState:UIControlStateNormal];
    
    [self resignLotteryViewFirstResponder];
}

#pragma mark-  弹幕开关
- (IBAction)barrageBtnClick:(id)sender {
    //    UIButton *btn = (UIButton*)sender;
    //    btn.selected = !btn.selected;
    
    _rendererOpenBtn.selected = !_rendererOpenBtn.selected;
    if (_rendererOpenBtn.selected) {
        [_renderer start];
        
    } else {
        [_renderer stop];
    }
    
    [self resignLotteryViewFirstResponder];
}

#pragma mark - 陀螺开关
- (IBAction)startGyroClick:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.selected) {
        [_moviePlayer setUsingGyro:YES];
        
    } else {
        [_moviePlayer setUsingGyro:NO];
    }
    
    [self resignLotteryViewFirstResponder];
}

#pragma mark - messageToolViewDelegate
- (void)didSendText:(NSString *)text { //发消息
    
    if (self.chatBtn.selected == YES) { //聊天消息
        
        [_chat sendMsg:text success:^{
            
        } failed:^(NSDictionary *failedData) {
            
            NSString* code = [NSString stringWithFormat:@"%@", failedData[@"code"]];
//            [UIAlertView popupAlertByDelegate:nil title:failedData[@"content"] message:code];
            
            NSString *msg = [code isEqualToString:@"10407"] ? NSLocalizedString(@"NO_CHAT_RECORD", nil) : failedData[@"content"];
            [self.view makeToast:msg duration:1.08 position:CSToastPositionCenter];
        }];
        
        return;
    }
    
    if (_QABtn.selected == YES) { //问答消息
        
        [_QA sendMsg:text success:^{
            
        } failed:^(NSDictionary *failedData) {
            
            NSString* code = [NSString stringWithFormat:@"%@", failedData[@"code"]];
//            [UIAlertView popupAlertByDelegate:nil title:failedData[@"content"] message:code];
            
            NSString *msg = [code isEqualToString:@"10407"] ? NSLocalizedString(@"NO_CHAT_RECORD", nil) : failedData[@"content"];
            [self.view makeToast:msg duration:1.08 position:CSToastPositionCenter];
            
        }];
        
        return;
    }
}

- (IBAction)fullscreenBtnClicked:(UIButton*)sender { //全屏
    
    _fullScreentBtnClick =YES;
    if(_fullscreenBtn.isSelected) {//退出全屏
        [self rotateScreen:NO];
        
    } else {//全屏
        [self rotateScreen:YES];
    }
}

- (void)rotateScreen:(BOOL)isLandscapeRight {
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        NSNumber *num = [[NSNumber alloc] initWithInt:(isLandscapeRight ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait)];
        [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)num];
        [UIViewController attemptRotationToDeviceOrientation]; //这行代码是关键
    }
    
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: [UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = isLandscapeRight ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
    [invocation setArgument:&val atIndex:2];
    [invocation invoke];
    [[UIApplication sharedApplication] setStatusBarHidden:isLandscapeRight withAnimation:UIStatusBarAnimationSlide];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.messageToolView endEditing:YES];
    [self resignLotteryViewFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

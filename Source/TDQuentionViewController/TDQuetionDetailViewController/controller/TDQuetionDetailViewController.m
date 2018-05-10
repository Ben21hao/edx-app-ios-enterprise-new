//
//  TDQuetionDetailViewController.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDQuetionDetailViewController.h"
#import "TDQuetionDetailCell.h"
#import "TDPublishTimeCell.h"
#import "TDBaseButton.h"

#import "TDQuetionInputViewController.h"
#import "TDPreViewImageViewController.h"
#import "TDWebImagePreviewViewController.h"

#import "TDQuetionDetailModel.h"
#import "TDTapGestureRecognizer.h"

#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import <UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface TDQuetionDetailViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIButton *replyButton;
@property (nonatomic,strong) TDBaseButton *solveButton;
@property (nonatomic,strong) UILabel *nullLabel;

@property (nonatomic,strong) NSMutableArray *replyArray;
@property (nonatomic,strong) TDQuetionDetailModel *detailModel;
@property (nonatomic,strong) TDBaseToolModel *baseTool;

@property (nonatomic,assign) BOOL showSolveButton;

@property (nonatomic,strong) AVPlayer *avPlayer;

@end

@implementation TDQuetionDetailViewController

- (AVPlayer *)avPlayer {
    if (!_avPlayer) {
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:@""]];
        _avPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    }
    return _avPlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = TDLocalizeSelect(@"CONSULTAION_DETAIL", nil);

    self.baseTool = [[TDBaseToolModel alloc] init];
    
    [self setViewContraint];
    
    [self setLoadDataView];
    [self getQuetionDetailData:0];
}

- (void)headerRefreshData { //上拉刷新
    
    [self.avPlayer pause];
    
    [self getQuetionDetailData:0];
}

- (void)reloadReplyData { //刷新回复数据
    
    [self.avPlayer pause];
    [self getQuetionDetailData:1];
}

- (void)getQuetionDetailData:(NSInteger)type { //数据
    
    if (![self.baseTool networkingState]) {//网络监测
        [self.tableView.mj_header endRefreshing];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.username forKey:@"username"];
    [params setValue:self.quetionModel.consult_id forKey:@"consult_id"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/get_consultmessage_content/",ELITEU_URL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"咨询详情 ---->>> %@",responseObject);
        
        [self.loadIngView removeFromSuperview];
        [self.tableView.mj_header endRefreshing];
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        int code = [responseDic[@"code"] intValue];
        if (code == 200) {
            
            NSDictionary *dataDic = responseDic[@"data"];
            self.detailModel = [TDQuetionDetailModel mj_objectWithKeyValues:dataDic];
            
            if (self.detailModel) {
                
                if (self.detailModel.reply_info.count > 0) {
                    NSMutableArray *replyArray = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary *replyDic in self.detailModel.reply_info) {
                        TDQuetionReplyInfoModel *replyModel = [TDQuetionReplyInfoModel mj_objectWithKeyValues:replyDic];
                        if (replyModel) {
                          [replyArray addObject:replyModel];
                        }
                    }
                    self.detailModel.reply_info = replyArray;
                }
                
                [self hideNullLabel];
                [self.tableView reloadData];
            }
        }
        else if (code == 311) { //学员未关联组织
            [self.view makeToast:TDLocalizeSelect(@"STUDENT_NO_LINKE_ORGANIZATION", nil) duration:0.8 position:CSToastPositionCenter];
        } else if (code == 312) { //学员不存在
            [self.view makeToast:TDLocalizeSelect(@"NOT_FOUND_STUDENT", nil) duration:0.8 position:CSToastPositionCenter];
        } else if (code == 312) { //咨询不存在
            [self.view makeToast:TDLocalizeSelect(@"NO_FOUND_CONSULTATION", nil) duration:0.8 position:CSToastPositionCenter];
        } else {
            [self.view makeToast:TDLocalizeSelect(@"NO_SUPPORT_WECHAT", nil) duration:0.8 position:CSToastPositionCenter];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"咨详情 ---->>> %@",error);
        [self.loadIngView removeFromSuperview];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
    }];
}

- (void)hideNullLabel { //是否隐藏没有评论
    
    BOOL isHide = self.detailModel.reply_info.count != 0;
    self.nullLabel.hidden = isHide;
    if (isHide) {
        self.nullLabel.frame = CGRectMake(0, 0, TDWidth, 0);
        
    } else {
        CGFloat imageHeight = (TDWidth - 26 - 4 * 10) / 4 + 18;
        CGFloat textHeight = [self.baseTool heightForString:self.detailModel.context.text font:14 width:TDWidth - 26] + 48;
        CGFloat otherHeight = TDHeight - BAR_ALL_HEIHT - 48 -39 -43 - imageHeight - textHeight;
        
        self.nullLabel.frame = CGRectMake(0, 0, TDWidth, otherHeight);
    }
    
}

- (void)signQuetionHadSolved { //已解决

    if (![self.baseTool networkingState]) {//网络监测
        [self.tableView.mj_header endRefreshing];
        return;
    }
    
    [self.solveButton.activityView startAnimating];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.quetionModel.consult_id forKey:@"consult_id"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/submit_solve/",ELITEU_URL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"已解决 ---->>> %@",responseObject);
        
        [self.solveButton.activityView stopAnimating];
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"quetion_sure_solved_notification" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            [self.view makeToast:TDLocalizeSelect(@"NO_SUPPORT_WECHAT", nil) duration:0.8 position:CSToastPositionCenter];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"已解决 ---->>> %@",error);
        [self.solveButton.activityView stopAnimating];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
    }];
}

- (void)replyButtonAction:(UIButton *)sender { //我要回复
    
    TDQuetionInputViewController *inputVc = [[TDQuetionInputViewController alloc] init];
    inputVc.whereFrom = self.showSolveButton ? TDQuetionInputFromContinueQution : TDQuetionInputFromReply;
    inputVc.titleStr = self.quetionModel.title;
    inputVc.username = self.username;
    inputVc.consult_id = self.quetionModel.consult_id;
    WS(weakSelf);
    inputVc.replyHandle = ^() {
        [weakSelf headerRefreshData];
    };
    [self.navigationController pushViewController:inputVc animated:YES];
}

- (void)solveButtonAction:(UIButton *)sender { //已解决
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:TDLocalizeSelect(@"RESOLVED_CONSULT_CAN_NOT_QUETIONS", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    WS(weakSelf);
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf signQuetionHadSolved];
    }];
    
    [alertVC addAction:sureAction];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

- (void)gotoWebViewPreview:(NSInteger)section index:(NSInteger)index { //图片浏览
    
    TDWebImagePreviewViewController *previewVc = [[TDWebImagePreviewViewController alloc] init];
    previewVc.modalPresentationStyle = UIModalPresentationFullScreen;
    previewVc.index = index;
    if (section == 0) {
        previewVc.picUrlArray = self.detailModel.context.pic_url;
    } else {
        TDQuetionReplyInfoModel *infoModel = self.detailModel.reply_info[section - 1];
        previewVc.picUrlArray = infoModel.reply_context.reply_pic_url;
    }
    [self presentViewController:previewVc animated:YES completion:nil];
}

#pragma mark - 播放语音
- (void)playVoiceAction:(NSInteger)section play:(BOOL)isplay {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if (isplay == NO) { //停止
        
        if (section == 0) {
            self.detailModel.isPlaying = NO;
            
        } else {
            TDQuetionReplyInfoModel *model = self.detailModel.reply_info[section - 1];
            model.isPlaying = NO;
        }
        
        [self.avPlayer pause];
        
//        [self removePlayStatus];
        
    } else { //播放
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"user_tap_other_voiceView" object:nil userInfo:@{@"row_user_tap": [NSString stringWithFormat:@"%ld",(long)section]}];
        
        if (section == 0) {
            [self playQuetionVoice];
            
        } else {
            [self playReplyVoice:section - 1];
        }
    }
}

- (void)playQuetionVoice { //播放咨询的
    
    self.detailModel.isPlaying = YES;
    
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:self.detailModel.context.voice.voice_url]];
    [self.avPlayer replaceCurrentItemWithPlayerItem:playerItem];
    
    [self addNSNotificationForPlayMusicFinish:playerItem];
    
    [self.avPlayer play];
    
}

- (void)playReplyVoice:(NSInteger)index { //播放回复的
    
    TDQuetionReplyInfoModel *model = self.detailModel.reply_info[index];
    model.isPlaying = YES;
    
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:model.reply_context.reply_voice.voice_url]];
    [self.avPlayer replaceCurrentItemWithPlayerItem:playerItem];
    
    [self addNSNotificationForPlayMusicFinish:playerItem];
    
    [self.avPlayer play];

}

- (void)addNSNotificationForPlayMusicFinish:(AVPlayerItem *)playerItem { //加入通知
    
    //播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    
//    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)playFinished:(NSNotification *)notifi {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"音频播放结束----------------");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"voice_play_endTime_notificatiion" object:nil];
    
}

//- (void)removePlayStatus { //移除监听播放器状态
//    NSLog(@"移除播放状态监听----------------");
//    [self.avPlayer.currentItem removeObserver:self forKeyPath:@"status"];
//}

//观察者回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        
        switch (self.avPlayer.status) {
            case AVPlayerStatusUnknown: {
                NSLog(@"未知转态");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"voice_play_endTime_notificatiion" object:nil];
                [self.view makeToast:@"音频加载失败" duration:0.8 position:CSToastPositionCenter];
            }
                break;
            case AVPlayerStatusReadyToPlay: { //准备播放
                NSLog(@"准备播放");
            }
                break;
            case AVPlayerStatusFailed: {
                NSLog(@"加载失败");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"voice_play_endTime_notificatiion" object:nil];
                [self.view makeToast:@"音频加载失败" duration:0.8 position:CSToastPositionCenter];
            }
                break;
                
            default:
                break;
        }
        
    }
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.detailModel.reply_info.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        TDQuetionDetailCell *cell = [[TDQuetionDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDQuetionDetailCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.quetionTitle.text = self.detailModel.title;
        cell.quetionDetail.text = self.detailModel.context.text;
        
        cell.index = indexPath.section;
        
        if (indexPath.section == 0) {
            cell.quetionModel = self.detailModel;

        } else {
            if (self.detailModel.reply_info.count > 0) {
                cell.replyModel = self.detailModel.reply_info[indexPath.section - 1];
            }
        }
        
        WS(weakSelf);
        cell.tapImageHandle = ^(NSInteger tag){//图片预览
            [weakSelf gotoWebViewPreview:indexPath.section index:tag];
        };
        
        cell.tapVoiceViewHandle = ^(BOOL isPlay){ //语音
            [weakSelf playVoiceAction:indexPath.section play:isPlay];
        };
        
        return cell;
    
    } else {
        TDPublishTimeCell *cell = [[TDPublishTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDPublishTimeCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
        if (indexPath.section == 0) {
            cell.quetionModel = self.detailModel;
            
        } else {
            cell.replyModel = self.detailModel.reply_info[indexPath.section - 1];
        }

        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, 12)];
    view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        CGFloat imageHeight = (TDWidth - 26 - 4 * 10) / 4 + 28;
        
        if (indexPath.section == 0) {
            
            CGFloat textHeight = [self.baseTool heightForString:self.detailModel.context.text font:14 width:TDWidth - 26];
            CGFloat realHeight = self.detailModel.context.text.length == 0 ? 0 : (textHeight > 43 ? textHeight : 43);//文本高
            BOOL hasVoice = self.detailModel.context.voice.voice_url.length > 0;
            BOOL hasImage = self.detailModel.context.pic_url.count > 0;
            
            return realHeight + 58 + (hasVoice ? 46 : 0) + (hasImage ? imageHeight : 0);
            
        } else {
            
            TDQuetionReplyInfoModel *replyModel = self.detailModel.reply_info[indexPath.section - 1];
            
            CGFloat textHeight = [self.baseTool heightForString:replyModel.reply_context.reply_text font:14 width:TDWidth - 26] + 10;
            CGFloat realHeight = replyModel.reply_context.reply_text.length == 0 ? 0 : (textHeight > 43 ? textHeight : 43);
            
            BOOL hasVoice = replyModel.reply_context.reply_voice.voice_url.length > 0;
            BOOL hasImage = replyModel.reply_context.reply_pic_url.count > 0;
            
            return realHeight + (hasVoice ? 46 : 0) + (hasImage ? imageHeight : 0);
        }
    }
    return 43;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - UI
- (void)setViewContraint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(self.whereFrom == TDQuetionDetailFromSolved ? 0 : -49);
    }];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshData)];
    header.lastUpdatedTimeLabel.hidden = YES; //隐藏时间
    [header setTitle:TDLocalizeSelect(@"DROP_REFRESH_TEXT", nil) forState:MJRefreshStateIdle];
    [header setTitle:TDLocalizeSelect(@"RELEASE_REFRESH_TEXT", nil) forState:MJRefreshStatePulling];
    [header setTitle:TDLocalizeSelect(@"REFRESHING_TEXT", nil) forState:MJRefreshStateRefreshing];
    self.tableView.mj_header = header;
    
    self.nullLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, TDWidth, 0)];
    self.nullLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.nullLabel.textAlignment = NSTextAlignmentCenter;
    self.nullLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    self.tableView.tableFooterView = self.nullLabel;
    
    self.nullLabel.hidden = YES;
    self.nullLabel.text = TDLocalizeSelect(@"NO_REPLY_TEXT", nil);
    
    if (self.whereFrom == TDQuetionDetailFromSolved) {
        return;
    }
    
    self.showSolveButton = [self.quetionModel.is_company_reveiver boolValue] == NO || [self.username isEqualToString:self.quetionModel.create_user_info.create_user_username];
    
    UILabel *line = [[UILabel alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    [self.view addSubview:line];
    
    self.replyButton = [[UIButton alloc] init];
    self.replyButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.replyButton.backgroundColor = [UIColor colorWithHexString:colorHexStr13];
    [self.replyButton setTitleColor:[UIColor colorWithHexString:colorHexStr10] forState:UIControlStateNormal];
    [self.replyButton setTitle:self.showSolveButton ?  TDLocalizeSelect(@"FURTHER_INQUIRY_BUTTON_TITLE", nil) : TDLocalizeSelect(@"REPLY_BUTTON_TITLE", nil) forState:UIControlStateNormal];
    [self.replyButton addTarget:self action:@selector(replyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.replyButton];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-48);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.replyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(48);
        make.width.mas_equalTo(self.showSolveButton ? TDWidth / 2 : TDWidth);
    }];
    
    
    if (self.showSolveButton) {
        
        self.solveButton = [[TDBaseButton alloc] init];
        self.solveButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
        self.solveButton.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        [self.solveButton setTitleColor:[UIColor colorWithHexString:colorHexStr10] forState:UIControlStateNormal];
        [self.solveButton setTitle:TDLocalizeSelect(@"RESOLVED_BUTTON_TITLE", nil) forState:UIControlStateNormal];
        [self.solveButton addTarget:self action:@selector(solveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.solveButton];
        
        [self.solveButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.mas_equalTo(self.view);
            make.height.mas_equalTo(48);
            make.width.mas_equalTo(TDWidth / 2);
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end

//
//  TDConsultDetailViewController.m
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDConsultDetailViewController.h"
#import "TDConsultRemidView.h"
#import "TDConsultInputView.h"
#import "TDRecordView.h"

#import "TDConsultTextCell.h"
#import "TDConsultAudioCell.h"
#import "TDConsultImageCell.h"
#import "TDConsultVideoCell.h"
#import "TDConsultStatusCell.h"

#import "TDImageGroupViewController.h"
#import "TDCallCameraViewConstroller.h"
#import "TDNavigationViewController.h"
#import "TDWebImagePreviewViewController.h"
#import "TDPreviewVideoViewController.h"

#import "TDConsultDetailModel.h"
#import "TDPermissionModel.h"

#import "NSString+OEXFormatting.h"
#import <MJExtension/MJExtension.h>

#import <AVFoundation/AVFoundation.h>
#import "lame.h"

#import "OSSConstants.h"
#import "OssService.h"
#import "TDSelectImageModel.h"

#define IMAGE_WIDTH_CELL (TDWidth - 95) / 4
#define Limite_Record_Time 30

@interface TDConsultDetailViewController () <UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate,TDOssPutFileDelegate>

@property (nonatomic,strong) TDBaseToolModel *toolModel;
@property (nonatomic,strong) TDPermissionModel *permissionModel;

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDConsultRemidView *remindView;
@property (nonatomic,strong) TDConsultInputView *inputView;
@property (nonatomic,strong) UIButton *answerButton;
@property (nonatomic,strong) UILabel *nullLabel;

@property (nonatomic,strong) TDConsultContetModel *contentModel;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) CGFloat bottomHeight;
@property (nonatomic,assign) CGFloat inputViewHeight;

@property (nonatomic,strong) TDRecordView *recordView;
@property (nonatomic,strong) AVAudioRecorder *audioRecorder; //录音
@property (nonatomic,strong) AVAudioSession *audioSession;
@property (nonatomic,strong) NSString *recordUrl;//存储路径
@property (nonatomic,strong) NSString *mp3FilePath;//mp3路径
@property (nonatomic,strong) NSString *recordKeyStr; //录音的唯一标识

@property (nonatomic,strong) NSTimer *recordTimer;
@property (nonatomic,strong) NSTimer *recordCountTimer;
@property (nonatomic,assign) int recordTimeNum;
@property (nonatomic,assign) int mp3TimeNum;
@property (nonatomic,assign) BOOL isSwipe;
@property (nonatomic,assign) BOOL isOverTime;

@property (nonatomic,strong) AVPlayer *avPlayer; //语音播放

@property (nonatomic,strong) OssService *service;
@property (nonatomic,strong) NSMutableArray *contentArray; //阿里返回的fid
@property (nonatomic,assign) NSInteger putOssNum;//
@property (nonatomic,strong) NSArray *imageArray;//本地图片的
@property (nonatomic,strong) NSString *videoPath; //正在发送的语音，视频的路径
@property (nonatomic,assign) int videoTime;//视频时长

@property (nonatomic,strong) TDConsultDetailModel *sendingModel;//正在发送的消息model
@property (nonatomic,assign) BOOL hadShowAlert;//已经显示重新发送
@property (nonatomic,assign) BOOL isConsultSending;
@property (nonatomic,strong) NSMutableArray *consultImageArray;
@property (nonatomic,strong) NSString *lastId;

@end

@implementation TDConsultDetailViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (NSMutableArray *)contentArray {
    if (!_contentArray) {
        _contentArray = [[NSMutableArray alloc] init];
    }
    return _contentArray;
}

- (NSMutableArray *)consultImageArray {
    if (!_consultImageArray) {
        _consultImageArray = [[NSMutableArray alloc] init];
    }
    return _consultImageArray;
}

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
    
    self.toolModel = [[TDBaseToolModel alloc] init];
    self.permissionModel = [[TDPermissionModel alloc] init];
    self.sendingModel = [[TDConsultDetailModel alloc] init];
    self.isConsultSending = NO;
    
    self.inputViewHeight = 48;
    self.bottomHeight = 0;
    [self setViewConstraint];
    
    self.mp3TimeNum = 0;
    self.recordKeyStr = @"selfRecord";
    [self initAvAudio];
    
    [self addNotificationObaser];
    
    if (self.whereFrom != TDConsultDetailFromNewConsult) {
        [self getHistoryConsultData];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    [self stopPalyingAudio];
}

#pragma mark - 数据
- (void)getHistoryConsultData { //咨询详情
    
    if (![self.toolModel networkingState]) { return; }
    
    [self setLoadDataView];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.username forKey:@"username"];
    [dict setValue:self.consultID forKey:@"consult_id"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/get_consultmessage_content/",ELITEU_URL];
    
    [manager GET:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.loadIngView removeFromSuperview];
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            
            self.contentModel = [TDConsultContetModel mj_objectWithKeyValues:responseDic[@"data"]];
            if (self.contentModel) {
                
                if (self.contentModel.consult_details.count > 0) {
//                    self.dataArray = [TDConsultDetailModel mj_objectArrayWithKeyValuesArray:self.contentModel.consult_details];
                    
                    for (int i = 0; i < self.contentModel.consult_details.count; i ++) {
                        TDConsultDetailModel *model = [TDConsultDetailModel mj_objectWithKeyValues:self.contentModel.consult_details[i]];
                        if (model) {
                            [self.dataArray addObject:model];
                            if ([model.content_type intValue] == 3) { //图片类型
                                NSArray *array = [model.content componentsSeparatedByString:@","];
                                [self.consultImageArray addObjectsFromArray:array];
                            }
                            
                            if ([model.is_reply boolValue] == NO) {
                                self.lastId = model.id;
                            }
                        }
                    }
                }
                [self.tableView reloadData];
            }
            
            if (self.reloadUserConsultStatus && self.hasNoRead) {
                self.hasNoRead = NO;
                self.reloadUserConsultStatus(@"4");
            }
            [self dealWithConsultButtonStatus]; //按钮状态处理
            
        }
        else if ([code intValue] == 313) { //313 咨询不存在
            [self showNullLabel:TDLocalizeSelect(@"NO_FOUND_CONSULTATION", nil)];
        }
        else if ([code intValue] == 311) { //311 学员未关联企业
            [self showNullLabel:TDLocalizeSelect(@"NO_LINKE_ENTERPRISE", nil)];
        }
        else if ([code intValue] == 312) { //312 学员不存在
            [self showNullLabel:TDLocalizeSelect(@"NOT_FOUND_STUDENT", nil)];
        }
        else if ([code intValue] == 313) { //314 用户没有权限查看
            [self showNullLabel:TDLocalizeSelect(@"NO_ACCESS_VIEW", nil)];
        }
        else if ([code intValue] == 403) { //403 用户非企业咨询联系人
            [self showNullLabel:TDLocalizeSelect(@"NO_CONSULTANT_ORGANIZATION", nil)];
        }
        else { //500 查询失败;
          [self showNullLabel:TDLocalizeSelect(@"QUERY_FAILED", nil)];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.loadIngView removeFromSuperview];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"咨询详情 -- %ld",(long)error.code);
    }];
}

- (void)postNewConsultMessage:(NSInteger)type { //新增咨询: 1:文字； 2:语音; 3:图片; 4:视频

    if (![self.toolModel getNetworkingState]) {
        [self showSendFailedAlertView:type isOssFailed:NO];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.username forKey:@"username"];
    
    [dict setValue:type == 1 ? self.sendingModel.content : [self.contentArray componentsJoinedByString:@","] forKey:@"content"];
    
    [dict setValue:@(type) forKey:@"content_type"];//类型
    if (type == 2) {
        [dict setValue:@(self.mp3TimeNum) forKey:@"content_duration"];//语音时长
    }
    else if (type == 4) {
        [dict setValue:@(self.videoTime) forKey:@"content_duration"];//视频时长
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/add_consult_message/",ELITEU_URL];
    
    [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            self.rightButton.hidden = NO;
            [self removeSendingLastObject:NO];
            
            NSDictionary *dataDic = responseDic[@"data"];
            self.consultID = [NSString stringWithFormat:@"%@",dataDic[@"consult_id"]];
            
            TDConsultDetailModel *model = [TDConsultDetailModel mj_objectWithKeyValues:dataDic];
            if (model) {
                model.isSending = NO;
                model.is_show_time = @"1";
                model.username = self.username;
                model.videoImage = self.sendingModel.videoImage;
                [self.dataArray addObject:model];
                
                if ([model.content_type intValue] == 3) {
                    NSArray *array = [model.content componentsSeparatedByString:@","];
                    [self.consultImageArray addObjectsFromArray:array];
                }
                
                self.whereFrom = TDConsultDetailFromUserUnSolve;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"new_quetion_handin_notification" object:nil];
            }
            [self reloadTableviewData];
        }
        else {//311 学员未关联企业；312 学员不存在；319 文字内容超过300字，发送失败；320 类型错误，请重新发送；500 创建咨询失败；
            [self showSendFailedAlertView:type isOssFailed:NO];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self showSendFailedAlertView:type isOssFailed:NO];
        NSLog(@"新增咨询 -- %ld",(long)error.code);
    }];
}

- (void)appendConsultMessage:(NSInteger)type { //追问: 1:文字； 2:语音; 3:图片; 4:视频
    
    if (![self.toolModel getNetworkingState]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showSendFailedAlertView:type isOssFailed:NO];
        });
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.username forKey:@"username"];
    [dict setValue:self.consultID forKey:@"consult_id"];//咨询的 ID
    
    [dict setValue:type == 1 ? self.sendingModel.content : [self.contentArray componentsJoinedByString:@","] forKey:@"content"];
    
    [dict setValue:@(type) forKey:@"content_type"]; //类型
    if (type == 2) {
        [dict setValue:@(self.mp3TimeNum) forKey:@"content_duration"];//语音时长
    }
    else if (type == 4) {
        [dict setValue:@(self.videoTime) forKey:@"content_duration"];//视频时长
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/superadd_consult_message/",ELITEU_URL];
    
    [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            
            [self removeSendingLastObject:NO];
            
            NSDictionary *dataDic = responseDic[@"data"];
            
            NSArray *unreadList = dataDic[@"this_session_unread_reply_list"];
            if (unreadList.count > 0) {
                for (NSDictionary *unreadDic in unreadList) {
                    
                    TDConsultDetailModel *unreadModel = [TDConsultDetailModel mj_objectWithKeyValues:unreadDic];
                    if (unreadModel) {
                        unreadModel.created_at = unreadDic[@"reply_at"];
                        unreadModel.username = unreadDic[@"reply_by"];
                        unreadModel.userprofile_image = unreadDic[@"reply_by_img"];
                        [self.dataArray addObject:unreadModel];
                        
                        if ([unreadModel.content_type intValue] == 3) {
                            NSArray *array = [unreadModel.content componentsSeparatedByString:@","];
                            [self.consultImageArray addObjectsFromArray:array];
                        }
                    }
                }
            }
            
            TDConsultDetailModel *model = [TDConsultDetailModel mj_objectWithKeyValues:dataDic];
            if (model) {
                model.isSending = NO;
                model.username = self.username;
                model.videoImage = self.sendingModel.videoImage;
                [self.dataArray addObject:model];
                
                if ([model.content_type intValue] == 3) {
                    NSArray *array = [model.content componentsSeparatedByString:@","];
                    [self.consultImageArray addObjectsFromArray:array];
                }
            }
            [self reloadTableviewData];
            
            if (self.reloadUserConsultStatus) {
                self.reloadUserConsultStatus(@"3");
            }
        }
        else {
            [self showSendFailedAlertView:type isOssFailed:NO];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self showSendFailedAlertView:type isOssFailed:NO];
//        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"追问 -- %ld",(long)error.code);
    }];
}

- (void)replyUserConsult:(NSInteger)type {//回复咨询: 1:文字； 2:语音; 3:图片; 4:视频
    
    if (![self.toolModel getNetworkingState]) {
        [self showSendFailedAlertView:type isOssFailed:NO];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.username forKey:@"username"];
    [dict setValue:self.consultID forKey:@"feedback_id"];//咨询的 ID

    [dict setValue:type == 1 ? self.sendingModel.content : [self.contentArray componentsJoinedByString:@","] forKey:@"filename"]; //阿里云返回的文件 key
    
    [dict setValue:@(type) forKey:@"mimeType"];
    if (type == 2) {
        [dict setValue:@(self.mp3TimeNum) forKey:@"content_duration"];//语音时长
    }
    else if (type == 4) {
        [dict setValue:@(self.videoTime) forKey:@"content_duration"];//视频时长
    }
    
    if (self.lastId.length > 0) {
        [dict setValue:self.lastId forKey:@"last_id"];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/consults/",ELITEU_URL];
    
    [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            self.rightButton.hidden = YES;
            
            [self removeSendingLastObject:NO];
            
            NSDictionary *dataDic = responseDic[@"data"];
            
            NSArray *unreadList = dataDic[@"return_list"];
            if (unreadList.count > 0) {
                for (NSDictionary *unreadDic in unreadList) {
                    
                    TDConsultDetailModel *unreadModel = [TDConsultDetailModel mj_objectWithKeyValues:unreadDic];
                    if (unreadModel) {
                        unreadModel.created_at = unreadDic[@"created_at"];
                        unreadModel.username = unreadDic[@"created_by"];
                        unreadModel.userprofile_image = unreadDic[@"created_by_img"];
                        [self.dataArray addObject:unreadModel];
                        
                        if ([unreadModel.content_type intValue] == 3) {//图片
                            NSArray *array = [unreadModel.content componentsSeparatedByString:@","];
                            [self.consultImageArray addObjectsFromArray:array];
                        }
                        
                        if ([unreadModel.is_reply boolValue] == NO) {
                            self.lastId = unreadModel.id;
                        }
                    }
                }
            }
            
            TDConsultDetailModel *model = [TDConsultDetailModel mj_objectWithKeyValues:dataDic];
            if (model) {
                model.user_id = self.userId;
                model.isSending = NO;
                model.username = self.username;
                model.videoImage = self.sendingModel.videoImage;
                [self.dataArray addObject:model];
                
                if ([model.content_type intValue] == 3) {
                    NSArray *array = [model.content componentsSeparatedByString:@","];
                    [self.consultImageArray addObjectsFromArray:array];
                }
            }
            
            [self reloadTableviewData];
            
            if (self.reloadUserConsultStatus) {
                self.reloadUserConsultStatus(@"7");
            }
        }
        else {
            [self showSendFailedAlertView:type isOssFailed:NO];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self showSendFailedAlertView:type isOssFailed:NO];
//        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"回复失败 -- %ld",(long)error.code);
    }];
}

- (void)consultStatusChange:(NSInteger)type { //更改咨询状态 -- 4 领取任务;5 放弃回答;6 已解决
    
    if (![self.toolModel networkingState]) { return; }
    
    [self showLoadingStatus:@"正在提交..."];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.username forKey:@"username"];
    [dict setValue:@(type) forKey:@"status"];
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/consults/%@/status/",ELITEU_URL,self.consultID];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager PATCH:url parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [SVProgressHUD dismiss];
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            self.contentModel = [[TDConsultContetModel alloc] init];
            self.contentModel.last_update_time = responseDic[@"data"][@"last_update_time"];
            [self dealWithConsultStatus:type];
        }
        else {
            [self.view makeToast:@"咨询状态改变失败" duration:0.8 position:CSToastPositionCenter];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"咨询状态更改 -- %ld",(long)error.code);
    }];
}

- (void)dealWithConsultStatus:(NSInteger)type { //4 领取任务;5 放弃回答;6 已解决

    self.bottomHeight = 0;
    
    if (type == 4) {
        self.rightButton.hidden = NO;
        self.answerButton.hidden = YES;
        self.inputView.hidden = NO;
        
        self.inputViewHeight = 48;
        
        if (self.reloadUserConsultStatus) {
            self.reloadUserConsultStatus(@"2");
        }
    }
    else if (type == 5) {
        
        self.rightButton.hidden = YES;
        self.answerButton.hidden = NO;
        self.inputView.hidden = YES;
        
        self.inputViewHeight = 48;
        
        if (self.reloadUserConsultStatus) {
            self.reloadUserConsultStatus(@"1");
        }
    }
    else {
        self.rightButton.hidden = YES;
        self.answerButton.hidden = YES;
        self.inputView.hidden = YES;
        self.remindView.hidden = YES;
        
        self.inputViewHeight = 0;
        
        [self showRemindView:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"quetion_sure_solved_notification" object:nil];
        
        self.whereFrom = TDConsultDetailFromUserSolve;
        self.contentModel.is_slove = @"1";
        [self.tableView reloadData];
    }
    
    [self updateInputViewConstraint];
}

- (void)dealWithConsultButtonStatus { //按钮状态处理
    
    int status = [self.contentModel.consult_status intValue];
    
    if ([self.contentModel.is_slove boolValue]) { //已解决
        
        self.rightButton.hidden = YES;
        [self showRemindView:NO];
        [self showInputView:NO showAnswerButton:NO];
    }
    else { //未解决
        if (self.whereFrom == TDConsultDetailFromUserUnSolve) { //咨询人
            
            if (status == 1 || status == 2 || status == 3 || status == 4 || status == 5) {
                self.rightButton.hidden = NO;
            }
            else {
                self.rightButton.hidden = YES;
            }
            
            [self showRemindView:YES];
            [self showInputView:YES showAnswerButton:NO];
        }
        else { //公司联系人
            
            [self showRemindView:NO];
            
            if ([self.contentModel.is_claim_by_other boolValue]) { //被他人领取
                self.rightButton.hidden = YES;
                [self showInputView:NO showAnswerButton:NO];
                
            } else { //没有被他人领取
                if (status == 3 || status == 4) {
                    self.rightButton.hidden = NO;
                }
                else {
                    self.rightButton.hidden = YES;
                }
                
                if (status == 1 || status == 5) {
                    [self showInputView:NO showAnswerButton:YES];
                }
                else {
                    [self showInputView:YES showAnswerButton:NO];
                }
            }
        }
    }
    
}

- (void)showInputView:(BOOL)showInput showAnswerButton:(BOOL)showAnswer {
    
    self.answerButton.hidden = !showAnswer;
    self.inputView.hidden = !showInput;
    [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.view);
        make.height.mas_equalTo(showInput || showAnswer ? 48 : 0);
    }];
}

- (void)showRemindView:(BOOL)isShow {
    
    self.remindView.hidden = !isShow;
    [self.remindView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(isShow ? 58 : 0);
    }];
}

- (void)showLoadingStatus:(NSString *)titleStr { //加载
    
    [SVProgressHUD showWithStatus:titleStr];
    SVProgressHUD.defaultMaskType = SVProgressHUDMaskTypeBlack;
    SVProgressHUD.defaultStyle = SVProgressHUDAnimationTypeNative;
}

- (void)localConsultSendFailed:(BOOL)failed type:(NSInteger)type { //发送失败消息
    
    self.sendingModel.sendFailed = failed;
    self.sendingModel.isSending = !failed;
    self.sendingModel.content_type = [NSString stringWithFormat:@"%ld",(long)type];

    [self.tableView reloadData];
}

- (void)addSendingConsultMessage:(NSInteger)type { //构建发送中的消息；1:文字； 2:语音; 3:图片; 4:视频
    
    if (self.isConsultSending) {
        return;
    }
    self.isConsultSending = YES;
    
    self.sendingModel.is_show_time = @"0";
    self.sendingModel.isSending = YES;
    self.sendingModel.content_type = [NSString stringWithFormat:@"%ld",(long)type];
    
    switch (type) {
        case 1:
            self.sendingModel.content = self.inputView.inputTextView.text;
            break;
        case 2:
            self.sendingModel.content_duration = [NSString stringWithFormat:@"%d",self.mp3TimeNum];
            break;
        case 3:
            self.sendingModel.imageArray = self.imageArray;
            break;
        case 4:
            self.sendingModel.content_duration = [NSString stringWithFormat:@"%d",self.videoTime];
            break;
            
        default:
            break;
    }
    
    [self.dataArray addObject:self.sendingModel];
    [self reloadTableviewData];
}

- (void)reloadTableviewData { //主线程刷新数据
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    });
}

- (void)showNullLabel:(NSString *)titleStr { //没有数据
    self.nullLabel.hidden = self.dataArray.count > 0;
    self.nullLabel.text = titleStr;
}

- (void)removeSendingLastObject:(BOOL)isReloadTable {
    
    self.isConsultSending = NO;
    self.sendingModel.isSending = NO;
    [self.dataArray removeLastObject];//先移除正在发送中的消息
    
    if (isReloadTable) {
        [self.tableView reloadData];
    }
}

#pragma mark - tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.contentModel.is_slove boolValue] == YES) {
        return self.dataArray.count + 1;
    }
    else {
        if ([self.contentModel.is_claim_by_other boolValue] == YES) {
            if (self.whereFrom == TDConsultDetailFromUserUnSolve) {
                return self.dataArray.count;
            }
            else {
                return self.dataArray.count + 1;
            }
        }
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.dataArray.count) {
        TDConsultDetailModel *detailModel = self.dataArray[indexPath.row];
        
        WS(weakSelf);
        switch ([detailModel.content_type intValue]) {//1:文字; 2:语音; 3:图片; 4:视频
            case 1: {
                TDConsultTextCell *cell = [[TDConsultTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDConsultTextCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.statusButton.tag = indexPath.row;
                cell.userId = self.userId;
                cell.detailModel = detailModel;
                
                return cell;
            }
                break;
                
            case 2: {
                TDConsultAudioCell *cell = [[TDConsultAudioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDConsultAudioCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.statusButton.tag = indexPath.row;
                cell.userId = self.userId;
                cell.detailModel = detailModel;
                
                cell.index = indexPath.row;
                cell.tapVoiceViewHandle = ^(BOOL isPlay){ //语音
                    [weakSelf playVoiceAction:detailModel index:indexPath.row play:isPlay];
                };
                
                return cell;
            }
                break;
                
            case 3: {
                TDConsultImageCell *cell = [[TDConsultImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDConsultImageCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.statusButton.tag = indexPath.row;
                cell.userId = self.userId;
                cell.detailModel = detailModel;
                
                cell.tapImageHandle = ^(NSArray *imageArray,NSInteger tag) {
                    [weakSelf gotoWebViewPreview:imageArray index:tag];
                };
                
                return cell;
            }
                break;
                
            default: {
                TDConsultVideoCell *cell = [[TDConsultVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDConsultVideoCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.userId = self.userId;
                cell.detailModel = detailModel;
                cell.statusButton.tag = indexPath.row;
                cell.videoButton.tag = indexPath.row;
                [cell.videoButton addTarget:self action:@selector(videoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
            }
                break;
        }
    }
    else {
        
        TDConsultStatusCell *cell = [[TDConsultStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDConsultStatusCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        if ([self.contentModel.is_slove boolValue] == YES) { //已解决
            if (self.whereFrom == TDConsultDetailFromUserSolve) { //我的咨询已解决
                cell.statusLabel.text = TDLocalizeSelect(@"SOLVED_CONSULTS", nil);
            } else {
                cell.statusLabel.text = [self.contentModel.consult_status intValue] == 7 ? TDLocalizeSelect(@"USER_CANCELED", nil) : TDLocalizeSelect(@"SOLVED_CONSULTS", nil);
            }
            cell.secondLabel.text = self.contentModel.last_update_time;
        }
        else {//未解决
            if ([self.contentModel.is_claim_by_other boolValue] == YES) {
                
                cell.statusLabel.text = TDLocalizeSelect(@"ANSWERING_CONSULTS", nil);
                cell.secondLabel.text = self.contentModel.name;
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.dataArray.count) {
        TDConsultDetailModel *detailModel = self.dataArray[indexPath.row];
        BOOL isShow = [detailModel.is_show_time boolValue];
        
        switch ([detailModel.content_type intValue]) {
            case 1: {
                CGFloat distance = isShow ? 75 : 20;
                CGFloat height = [self.toolModel heightForString:detailModel.content font:14 width:TDWidth - 92] + distance;
                if (height > distance + 13) {
                    return height;
                }
                return height > distance + 13 ? distance : distance + 13;
            }
                break;
                
            case 2: {
                return isShow ? 118 : 63;
            }
                break;
                
            case 3: {
                CGFloat distance = isShow ? 86 : 31;
                return distance + IMAGE_WIDTH_CELL;
            }
                break;
                
            default: {
                CGFloat distance = isShow ? 86 : 31;
                return distance + IMAGE_WIDTH_CELL;
            }
                break;
        }
    }
    else {
        return 68;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.inputView.inputTextView endEditing:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.inputView.inputTextView endEditing:YES];
}

#pragma mark - 预览
- (void)gotoWebViewPreview:(NSArray *)imageArray index:(NSInteger)index { //图片浏览
    
    NSString *clickObject = imageArray[index];
    NSInteger clickIndex = [self.consultImageArray indexOfObject:clickObject];
    
    TDWebImagePreviewViewController *previewVc = [[TDWebImagePreviewViewController alloc] init];
    previewVc.modalPresentationStyle = UIModalPresentationFullScreen;
    previewVc.index = clickIndex;
    previewVc.picUrlArray = self.consultImageArray;
    [self presentViewController:previewVc animated:YES completion:nil];
}

- (void)videoButtonAction:(UIButton *)sender { //视频预览
    
    TDConsultDetailModel *detailModel = self.dataArray[sender.tag];
    
    if (detailModel.isSending) {
        return;
    }
    
    TDPreviewVideoViewController *previewVideoVC = [[TDPreviewVideoViewController alloc] init];
    previewVideoVC.videoPath = [NSString stringWithFormat:@"%@",detailModel.content];
    previewVideoVC.isWebVideo = YES;
    [self.navigationController pushViewController:previewVideoVC animated:YES];
}

#pragma mark - 键盘
- (void)addNotificationObaser {
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allowPHPhotoLibrary:) name:@"TD_User_Allow_PHPhotoLibrary" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allowAVCaptureDevice:) name:@"TD_User_Allow_AVCaptureDevice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageSelectNoti:) name:@"User_Had_SelectImage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoSelectNoti:) name:@"User_Had_SelectVideo" object:nil];
}

- (void)removeNotificationObser {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TD_User_Allow_PHPhotoLibrary" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TD_User_Allow_AVCaptureDevice" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"User_Had_SelectImage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"User_Had_SelectVideo" object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {//当键盘出现或改变时调用
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    self.bottomHeight = keyboardRect.size.height;
    
    [self updateInputViewConstraint];
}

- (void)keyboardWillHide:(NSNotification *)notification {//当键退出时调用
    self.bottomHeight = 0;
    [self updateInputViewConstraint];
}

#pragma mark - 发送语音，图片，视频
- (void)imageSelectNoti:(NSNotification *)notification { //发送图片
    
    NSDictionary *dic = notification.userInfo;
    self.imageArray = dic[@"selectImageArray"];
    
    [self addSendingConsultMessage:3];
    
    [self sendImageToOss];
}

- (void)sendImageToOss {
    
    [self contentArrayInitial:self.imageArray.count > 1];
    self.service.type = TDOssFileTypeImage;
    
    if (self.imageArray.count > 0) {
        for (int i = 0; i < self.imageArray.count; i++) {
            TDSelectImageModel *model = self.imageArray[i];
            NSString *path = [self.service saveImage:model.image withName:[NSString stringWithFormat:@"image%d",i]]; //保存图片到本地
            NSString *objectKey = [self.service dealDateFormatter:self.username type:@".png"];
            [self.service asyncPutImage:objectKey localFilePath:path inturn:i+1 total:self.imageArray.count]; //将图片推上阿里oss
        }
    }
}

- (void)videoSelectNoti:(NSNotification *)notification { //发送视频
    
    NSDictionary *dic = notification.userInfo;
    self.videoPath = dic[@"selectVideoPath"];
    self.videoTime = [dic[@"selectVideoTime"] intValue];
    UIImage *videoImage = dic[@"videoThumbImage"];
    
    [self addSendingConsultMessage:4];
    self.sendingModel.videoImage = videoImage;
  
    [self sendVideoToOss];
}

- (void)sendVideoToOss {
    
    [self contentArrayInitial:NO];
    self.service.type = TDOssFileTypeVideo;
    
    NSString *objectKey = [self.service dealDateFormatter:self.username type:@".mp4"];
    [self.service asyncPutImage:objectKey localFilePath:self.videoPath inturn:1 total:1]; //将图片推上阿里oss
}

- (void)sendAudioToOss { //发送语音
    
    [self addSendingConsultMessage:2];
    
    [self contentArrayInitial:NO];
    self.service.type = TDOssFileTypeAudio;
    
    NSString *objectKey = [self.service dealDateFormatter:self.username type:@".mp3"];
    [self.service asyncPutImage:objectKey localFilePath:self.recordUrl inturn:1 total:1]; //将图片推上阿里oss
}

#pragma mark - OSS 初始化
- (void)ossServiceInitial {
    if (self.service) {
        self.service = nil;
    }
    
    self.service = [[OssService alloc] initWithViewController:self];
    self.service.delegate = self;
}

- (void)contentArrayInitial:(BOOL)moreThanOne {
    
    [self.contentArray removeAllObjects];
    self.putOssNum = 0;
    
    if (moreThanOne) {
        self.contentArray = [NSMutableArray arrayWithArray:self.imageArray];
    }
}

#pragma mark - TDOssPutFileDelegate
- (void)putFileToOssSucessDomain:(NSString *)domain fid:(NSString *)fid type:(TDOssFileType)type inturn:(NSInteger)turn total:(NSInteger)total {
    
    self.putOssNum ++;
    
    if (total > 1) {
        [self.contentArray replaceObjectAtIndex:turn - 1 withObject:fid];
        
    } else {
        [self.contentArray addObject:fid];
    }
    NSLog(@"成功 --- %@ - %ld",self.contentArray,turn);
    
    if (self.putOssNum != total) { return; } //返回的数量和总数一样
    
    if (self.whereFrom == TDConsultDetailFromContactUnSolve) { //回复
        [self replyUserConsult:type];
    }
    else if (self.whereFrom == TDConsultDetailFromNewConsult) { //新建
        [self postNewConsultMessage:type];
    }
    else {//追问
        [self appendConsultMessage:type];
    }
}

- (void)putFileToOssFailed:(NSString *)reason type:(TDOssFileType)type {
    
    [self showSendFailedAlertView:type isOssFailed:YES];
    NSLog(@"失败 ----->> %@ - %ld",reason, type);
}

- (void)showSendFailedAlertView:(NSInteger)type isOssFailed:(BOOL)ossFailed {
    
    self.isConsultSending = NO;
    [self localConsultSendFailed:YES type:type];
    
    if (self.hadShowAlert) { //已经有弹框，就不再弹框
        return;
    }
    [self resendConsultFailedMessageSend:type isOssFailed:ossFailed];
}

#pragma mark - textView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) { //发送消息
        NSLog(@"------>> 发送消息");
        
        if (textView.text.length == 0) {
            [self.view makeToast:TDLocalizeSelect(@"ENTER_CONSULT_TEXT", nil) duration:0.8 position:CSToastPositionTop];
            
        }
        else if (textView.text.length > 500) {
           [self.view makeToast:TDLocalizeSelect(@"CONCULST_MORE_TEXT", nil) duration:0.8 position:CSToastPositionTop];
            
        }
        else {
            
            if (![self.toolModel networkingState]) {
                return NO;
            }
            
            [self addSendingConsultMessage:1]; //构建发送中消息
            
            if (self.whereFrom == TDConsultDetailFromContactUnSolve) { //回复
                [self replyUserConsult:1];
            }
            else {
                self.consultID.length == 0 ? [self postNewConsultMessage:1] : [self appendConsultMessage:1];
            }
            textView.text = @"";
            self.inputViewHeight = 48;
            [self updateInputViewConstraint];
        }
        
        return NO;
    }
    else {
        if (textView.text.length > 500) {//限制500字
            textView.text = [textView.text substringToIndex:500];
            return NO;
        }
        
        //输入框高度
        CGFloat textHeight = [self.toolModel heightForString:self.inputView.inputTextView.text font:14 width:TDWidth - 122];
        if (textHeight < 30) {
            self.inputViewHeight = 48;
        }
        else if (textHeight > 105) {
            self.inputViewHeight = 123;
        }
        else {
            self.inputViewHeight = textHeight + 18;
        }
        [self updateInputViewConstraint];
    }
    
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.isConsultSending) {
        return NO;
    }
    else {
        [self ossServiceInitial];//先获取token
        return YES;
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.inputView.placeLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.inputView.placeLabel.hidden = NO;
    }
}

- (void)updateInputViewConstraint { //输入框高度的处理
    [self.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(self.inputViewHeight);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-self.bottomHeight);
    }];
}

#pragma mark - action
- (void)cancelButtonAction:(UIButton *)sender { //取消提示
    [self.inputView resignFirstResponder];
    
    [self showRemindView:NO];
}

- (void)answerButtonAction:(UIButton *)sender { //回答问题
    [self.inputView.inputTextView resignFirstResponder];
    
    [self consultStatusChange:4];
}

- (void)inputTypeButtonAction:(UIButton *)sender { //输入类型
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        self.inputViewHeight = 48;
        [self.inputView.inputTextView resignFirstResponder]; //收起键盘
    }
    else {
        CGFloat textHeight = [self.toolModel heightForString:self.inputView.inputTextView.text font:14 width:TDWidth - 122];
        if (textHeight < 30) {
            self.inputViewHeight = 48;
        }
        else if (textHeight > 70) {
            self.inputViewHeight = 88;
        }
        else {
            self.inputViewHeight = textHeight + 18;
        }
        [self.inputView.inputTextView becomeFirstResponder];
    }
    
    self.inputView.inputTextView.hidden = sender.selected;
    self.inputView.recordButton.hidden = !sender.selected;
}

- (void)imageButtonAction:(UIButton *)sender { //拍摄和图片
    [self.inputView.inputTextView resignFirstResponder];
    
    if (self.isConsultSending) {
        return;
    }
    
    if (![self.toolModel networkingState]) {
        return;
    }
    
    [self ossServiceInitial];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    WS(weakSelf);
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"TAKE_PHOTO", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf gotoCallCameraVc];
    }];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"ALBUM_TITLE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf gotoSelectImageAction];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:photoAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)rightButtonAciton:(UIButton *)sender { //已解决或者放弃
    [self.inputView.inputTextView resignFirstResponder];
    
    if (self.isConsultSending) {
        return;
    }
    
    NSString *messageStr = self.whereFrom == TDConsultDetailFromUserUnSolve ? TDLocalizeSelect(@"REMIND_CONSULTTATION_SOLVED", nil) : TDLocalizeSelect(@"WANT_GIVE_UP", nil); 
    NSString *cancelStr = self.whereFrom == TDConsultDetailFromUserUnSolve ? TDLocalizeSelect(@"CANCEL", nil) : TDLocalizeSelect(@"NO", nil);
    NSString *sureStr = self.whereFrom == TDConsultDetailFromUserUnSolve ? TDLocalizeSelect(@"OK", nil) : TDLocalizeSelect(@"YES", nil);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    
    WS(weakSelf);
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf consultStatusChange:weakSelf.whereFrom == TDConsultDetailFromUserUnSolve ? 6 : 5];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)leftButtonAction:(UIButton *)sender {
    if (self.isConsultSending) { //正在发送
        [self leaveWhenConsultMessageSend];
    }
    else {
        [self userClickBack];
    }
}

- (void)userClickBack {
    [self removeNotificationObser];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leaveWhenConsultMessageSend { //正在发送消息，确定离开
    [self.inputView resignFirstResponder];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:TDLocalizeSelect(@"SENDING_LEAVING_TEXT", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    WS(weakSelf);
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.service normalRequestCancel];
        [weakSelf userClickBack];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)resendConsultFailedMessageSend:(TDOssFileType)type isOssFailed:(BOOL)ossFailed { //发送失败，请重新发送。
    [self.inputView resignFirstResponder];
    
    [self ossServiceInitial];//重新获取阿里云SDK的token
    
    self.hadShowAlert = YES;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:TDLocalizeSelect(@"REREND_MIND_TEXT", nil) preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"RESEND_BUTTON_TEXT", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        weakSelf.isConsultSending = YES;
        weakSelf.hadShowAlert = NO;
        [weakSelf localConsultSendFailed:NO type:type];
        
        if (ossFailed) { //oss上传失败
            
            if (type == TDOssFileTypeAudio) { //语音
                [weakSelf sendAudioToOss];
            }
            else if (type == TDOssFileTypeImage) { //图片
                [weakSelf sendImageToOss];
            }
            else {//视频
                [weakSelf sendVideoToOss];
            }
            
        } else { //访问接口失败
            if (weakSelf.whereFrom == TDConsultDetailFromContactUnSolve) { //回复
                [weakSelf replyUserConsult:type];
            }
            else if (self.whereFrom == TDConsultDetailFromNewConsult) { //新建
                [weakSelf postNewConsultMessage:type];
            }
            else {//追问
                [weakSelf appendConsultMessage:type];
            }
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"DELETE", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        weakSelf.hadShowAlert = NO;
        [weakSelf localConsultSendFailed:NO type:type];
        [weakSelf removeSendingLastObject:YES];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 选择图片
- (void)gotoSelectImageAction {
    
    if (![self.permissionModel requestPhotoLibraryPermissionInController:self]) {
        return;
    }
    
    TDImageGroupViewController *imageGroupVc = [[TDImageGroupViewController alloc] init];
    
    TDNavigationViewController *naviController = [[TDNavigationViewController alloc] initWithRootViewController:imageGroupVc];
    [self presentViewController:naviController animated:YES completion:nil];
}

- (void)allowPHPhotoLibrary:(NSNotification *)notifi { //允许访问相册通知
    [self gotoSelectImageAction];
}

#pragma mark - 拍摄
- (void)gotoCallCameraVc { //拍摄
    
    if (![self.permissionModel requestAVMediaTypePermissionInController:self type:0]) {
        return;
    }
    
    if (![self.permissionModel requestAVMediaTypePermissionInController:self type:1]) {
        return;
    }
    
    TDCallCameraViewConstroller *cameraVc = [[TDCallCameraViewConstroller alloc] init];
    [self presentViewController:cameraVc animated:YES completion:nil];
}

- (void)allowAVCaptureDevice:(NSNotification *)notifi {//允许访问相机通知
    [self gotoCallCameraVc];
}

#pragma mark - 录音
- (void)initAvAudio { //初始化

    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    //设置录音格式 AVFormatIDKey==kAudioFormatLinearPCM 全称脉冲编码调制，是一种模拟信号的数字化的方法。
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
    [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];//录音通道数  1 或 2 ，要转换成mp3格式必须为双通道
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];//线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInteger:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];//录音的质量

    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];//存储录音文件
    self.recordUrl = [NSString stringWithFormat:@"%@/%@.lpcm",strUrl,self.recordKeyStr];

    NSError *error;//初始化录音控制器
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:self.recordUrl] settings:recordSetting error:&error];
    self.audioRecorder.meteringEnabled = YES;//开启音量检测
    self.audioRecorder.delegate = self;
    self.audioSession = [AVAudioSession sharedInstance];//得到AVAudioSession单例对象
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];//设置类别,表示该应用同时支持播放和录音

    self.recordTimeNum = 0;
    self.isOverTime = NO;

    [self deleteFile];
}

- (void)startRecord { //开始录音

    //设置类别,表示该应用同时支持播放和录音
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    [self deleteFile];

    if (![self.audioRecorder isRecording]) {

        [self.audioSession setActive:YES error:nil]; //启动音频会话管理,此时会阻断后台音乐的播放.

        [self.audioRecorder prepareToRecord];
        [self.audioRecorder peakPowerForChannel:0.0];
        [self.audioRecorder record];
    }
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    self.recordCountTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordCountAction) userInfo:nil repeats:YES];
}

- (void)cancelRecord { //取消录音

    [self inalidateTimer];

    [self.audioRecorder deleteRecording]; //删除录音文件
    [self stopRecord];
}

- (void)inalidateTimer { //取消
    [self.recordTimer invalidate];
    [self.recordCountTimer invalidate];
    
    self.recordTimeNum = 0;
    
    self.recordView.imageView.hidden = NO;
    self.recordView.countDownLabel.hidden = YES;
}

- (void)stopRecord { //录音停止
    [self.audioRecorder stop];
    [self.audioSession setActive:NO error:nil]; //一定要在录音停止以后再关闭音频会话管理（否则会报错），此时会延续后台音乐播放
}

- (void)recordFinish { //结束录音

    [self inalidateTimer];

    self.mp3TimeNum = self.audioRecorder.currentTime > Limite_Record_Time ? Limite_Record_Time : ceil(self.audioRecorder.currentTime);
    NSLog(@"录音时间 --->> %d",self.mp3TimeNum);

    if (self.mp3TimeNum > 2) { //如果录制时间<2不发送
        [NSThread detachNewThreadSelector:@selector(transformVAFToMP3) toTarget:self withObject:nil];

    } else {
        [self.audioRecorder deleteRecording];
        [self.view makeToast:TDLocalizeSelect(@"ENCH_RECOR_LESS_TWO_SECOND", nil) duration:0.8 position:CSToastPositionCenter];
    }
    [self updateRecordButton:TDLocalizeSelect(@"HOLD_TO_RECORD", nil) imageStr:@"record_not_image" enable:YES];

    [self stopRecord];
}

- (void)deleteRecordAuadio { //删除录音文件
    [self.audioRecorder deleteRecording];
}

- (void)deleteFile { //删除已保存的语音
    
    [self deleteRecordAuadio];
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileUrl = [NSString stringWithFormat:@"%@/%@.mp3",strUrl,self.recordKeyStr];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileUrl error:nil];
    
    self.recordUrl = [NSString stringWithFormat:@"%@/%@.lpcm",strUrl,self.recordKeyStr];
}

- (void)detectionVoice { //音量大小
    
    if (self.isSwipe) {
        return;
    }
    
    [self.audioRecorder updateMeters]; //刷新音量数据
    
    //    [self.audioRecorder averagePowerForChannel:0]; //获取音量的平均值
    //    [self.audioRecorder peakPowerForChannel:0]; //音量的最大值
    
    double lowPassResults = pow(10, ([self.audioRecorder peakPowerForChannel:0] * 0.05));
    //    NSLog(@"音量最大值----->>>%lf",lowPassResults);
    if (lowPassResults < 0) {
        self.recordView.imageView.image = [UIImage imageNamed:@"record_voice_zero"];
    } else if (0 < lowPassResults && lowPassResults <= 0.25) {
        self.recordView.imageView.image = [UIImage imageNamed:@"record_voice_one"];
    } else if (0.25 < lowPassResults && lowPassResults <= 0.5) {
        self.recordView.imageView.image = [UIImage imageNamed:@"record_voice_two"];
    } else if (0.5 < lowPassResults && lowPassResults <= 0.75) {
        self.recordView.imageView.image = [UIImage imageNamed:@"record_voice_three"];
    } else {
        self.recordView.imageView.image = [UIImage imageNamed:@"record_voice_fourth"];
    }
}

- (void)recordCountAction { //时间

    //    ceil(self.audioRecorder.currentTime)
        self.recordTimeNum ++;//self.audioRecorder.currentTime
    //    NSLog(@"%ld -- 录音时间%lf",self.recordTimeNum,self.audioRecorder.currentTime);

    NSLog(@"%f -- 录音时间%lf",ceil(self.audioRecorder.currentTime),self.audioRecorder.currentTime);

    if (self.audioRecorder.currentTime >= Limite_Record_Time - 10) {
        self.recordView.imageView.hidden = YES;
        self.recordView.countDownLabel.hidden = NO;
        self.recordView.countDownLabel.text = [NSString stringWithFormat:@"%d",Limite_Record_Time - self.recordTimeNum];
    }
    
    if (ceil(self.audioRecorder.currentTime) >= Limite_Record_Time) {

        self.isOverTime = YES;
        self.recordView.hidden = YES;
        [self recordFinish];
        [self.view makeToast:TDLocalizeSelect(@"EACH_RECORD_MORE_SECOND", nil) duration:0.8 position:CSToastPositionCenter];
    }
}

- (void)transformVAFToMP3 { //将录音文件转为 MP3 文件

    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.mp3FilePath = [NSString stringWithFormat:@"%@/%@.mp3",strUrl,self.recordKeyStr];

    @try {
        int read, write;

        FILE *pcm = fopen([self.recordUrl cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([self.mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置

        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];

        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);

        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);

            fwrite(mp3_buffer, write, 1, mp3);

        } while (read != 0);

        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSLog(@"MP3生成成功: %@",self.mp3FilePath);
        
        self.recordUrl = self.mp3FilePath;
        [self sendAudioToOss];
        
        //MP3时间
        //        AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.mp3FilePath] options:nil];
        //        CMTime audioDuration = audioAsset.duration;
        //        float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
        //
        //        NSLog(@"mp3的时间 -- %lf",audioDurationSeconds);
        //
        //        //MP3大小
        //        NSInteger fileSize =  [self getFileSize:self.mp3FilePath];
        //        NSLog(@"mp3大小 ------- %@", [NSString stringWithFormat:@"%ld kb", fileSize/1024]);
    }
}

- (NSInteger)getFileSize:(NSString *)path { //计算文件大小

    NSFileManager *filemanager = [[NSFileManager alloc] init];
    if([filemanager fileExistsAtPath:path]){

        NSDictionary *attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;

        if ( (theFileSize = [attributes objectForKey:NSFileSize]) ) {
            return  [theFileSize intValue];
        } else {
            return -1;
        }

    } else {
        return -1;
    }
}
#pragma mark - 长按录音
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    return UIRectEdgeNone;
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (self.isConsultSending) {
        return;
    }
    if (![self.permissionModel requestAVMediaTypePermissionInController:self type:1]) {
        return;
    }
    
    CGPoint point = [gestureRecognizer locationInView:self.inputView.recordButton];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按开始");
        
        [self ossServiceInitial];//先获取token
        
        self.recordView.hidden = NO;
        [self startRecord];
        [self updateRecordButton:TDLocalizeSelect(@"RELEASE_TO_SAVE", nil) imageStr:@"record_black_image" enable:YES];
        
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"长按结束");
        
        if (self.isOverTime) {
            self.isOverTime = NO;
            return;
        }
        
        self.recordView.hidden = YES;
        
        if (point.y > -35) { //在范围内
            [self recordFinish];
            
        } else {//出了范围，取消
            [self updateRecordButton:TDLocalizeSelect(@"HOLD_TO_RECORD", nil) imageStr:@"record_not_image" enable:YES];
            [self updateRecordView:NO];
            [self cancelRecord];
        }
        
    } else if(gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        NSLog(@"长按中");
        
        if (self.isOverTime) {
            return;
        }
        
        [self updateRecordButton:TDLocalizeSelect(@"RELEASE_TO_SAVE", nil) imageStr:@"record_black_image" enable:YES];
        if (point.y > -35) {
            [self updateRecordView:NO];
            
        } else {
            [self updateRecordView:YES];
        }
    }
    
    //    NSLog(@"y轴移动-------->>> %lf",point.y);
}

- (void)updateRecordView:(BOOL)isSwipe {

    self.isSwipe = isSwipe;

    self.recordView.remindLabel.text = isSwipe == NO ? TDLocalizeSelect(@"SCROLL_UP_TO_CANCEL", nil) : TDLocalizeSelect(@"RELEASE_FINGER_TO_CANCEL", nil);
    self.recordView.imageView.image = [UIImage imageNamed:isSwipe == NO ? @"record_voice_zero" : @"record_revoke_image"];
    self.recordView.remindLabel.backgroundColor = isSwipe == NO ? [UIColor clearColor] : [UIColor colorWithHexString:colorHexStr5];
    self.recordView.remindLabel.textColor = isSwipe == NO ? [UIColor whiteColor] : [UIColor redColor];
}

//更新按钮状态
- (void)updateRecordButton:(NSString *)titleStr imageStr:(NSString *)imageStr enable:(BOOL)enable {
    
    [self.inputView.recordButton setTitle:titleStr forState:UIControlStateNormal];
    [self.inputView.recordButton setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
//    self.inputView.recordButton.userInteractionEnabled = enable;
}

#pragma mark - 播放语音
- (void)playVoiceAction:(TDConsultDetailModel *)detailModel index:(NSInteger)index play:(BOOL)isplay {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if (isplay == NO) { //停止
        
        detailModel.isPlaying = NO;
        [self.avPlayer pause];
        
    } else { //播放
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"user_tap_other_voiceView" object:nil userInfo:@{@"row_user_tap": [NSString stringWithFormat:@"%ld",(long)index]}];
        
        [self playConsultDetailVoice:detailModel];
    }
}

- (void)playConsultDetailVoice:(TDConsultDetailModel *)detailModel {
    
    detailModel.isPlaying = YES;
    
    //网络url
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:detailModel.content]];
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
                [self.view makeToast:TDLocalizeSelect(@"FAILED_LOAD_AUDIO", nil) duration:0.8 position:CSToastPositionCenter];
            }
                break;
            case AVPlayerStatusReadyToPlay: { //准备播放
                NSLog(@"准备播放");
            }
                break;
            case AVPlayerStatusFailed: {
                NSLog(@"加载失败");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"voice_play_endTime_notificatiion" object:nil];
                [self.view makeToast:TDLocalizeSelect(@"FAILED_LOAD_AUDIO", nil) duration:0.8 position:CSToastPositionCenter];
            }
                break;
                
            default:
                break;
        }
        
    }
}

- (void)deleteVoiceFile { //删除保存在本地的录音文件，防止占用手机存储空间
    
    if (self.avPlayer) {
        [self.avPlayer pause];
    }
    [self.audioRecorder deleteRecording];
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileUrl = [NSString stringWithFormat:@"%@/%@.mp3",strUrl,self.recordKeyStr];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileUrl error:nil];
}

- (void)stopPalyingAudio {
    if (self.avPlayer) {
        [self.avPlayer pause];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"user_leave_voiceView" object:nil];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    self.remindView = [[TDConsultRemidView alloc] init];
    [self.remindView.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.remindView];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self.view addSubview:self.tableView];
    
    self.inputView = [[TDConsultInputView alloc] init];
    self.inputView.inputTextView.delegate = self;
    [self.inputView.inputTypeButton addTarget:self action:@selector(inputTypeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputView.imageButton addTarget:self action:@selector(imageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.inputView];
    
    self.answerButton = [[UIButton alloc] init];
    self.answerButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.answerButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.answerButton setTitle:TDLocalizeSelect(@"ANSER_BUTTON_TEXT", nil) forState:UIControlStateNormal];
    [self.answerButton setTitleColor:[UIColor colorWithHexString:colorHexStr13] forState:UIControlStateNormal];
    [self.answerButton addTarget:self action:@selector(answerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.answerButton.layer.masksToBounds = YES;
    self.answerButton.layer.cornerRadius = 4.0;
    [self.view addSubview:self.answerButton];
    
    NSString *rightStr = TDLocalizeSelect(@"RESOLVED_BUTTON_TITLE", nil);
    if (self.whereFrom == TDConsultDetailFromContactUnSolve) {
        rightStr = TDLocalizeSelect(@"GIVE_UP_NAVI", nil);
    }
    [self.rightButton setTitle:rightStr forState:UIControlStateNormal];
    
    self.answerButton.hidden = YES;
    
    CGFloat remindHeight = 58;
    CGFloat inputHeight = 48;
    
    switch (self.whereFrom) {
        case TDConsultDetailFromUserUnSolve:
            self.rightButton.hidden = NO;
            break;
            
        case TDConsultDetailFromUserSolve: {
            self.remindView.hidden = YES;
            remindHeight = 0;
            
            self.inputView.hidden = YES;
            inputHeight = 0;
        }
            break;
            
        case TDConsultDetailFromContactUnSolve: { //我的回答 -- 未解决
            self.remindView.hidden = YES;
            remindHeight = 0;
            
            switch (self.consultStatus) {
                case TDContactConsultStatusWaitReply: {
                    self.answerButton.hidden = NO;
                    self.inputView.hidden = YES;
                }
                    break;
                    
                case TDContactConsultStatusReplying:
//                    self.rightButton.hidden = NO;
                    break;
                    
                default: { //其他人在回答
                    self.inputView.hidden = YES;
                    inputHeight = 0;
                }
                    break;
            }
        }
            break;
            
        case TDConsultDetailFromContactSolve: {
            self.remindView.hidden = YES;
            remindHeight = 0;
            
            self.inputView.hidden = YES;
            inputHeight = 0;
        }
            break;
            
        default: {//新增咨询
            
        }
            break;
    }

    [self.remindView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(remindHeight);
    }];
    
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.view);
        make.height.mas_equalTo(inputHeight);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.remindView.mas_bottom);
        make.bottom.mas_equalTo(self.inputView.mas_top);
    }];
    
    [self.answerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(18);
        make.right.mas_equalTo(self.view.mas_right).offset(-18);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-8);
        make.height.mas_equalTo(33);
    }];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.3;
    [self.inputView.recordButton addGestureRecognizer:longPress];
    
    self.recordView = [[TDRecordView alloc] init];
    self.recordView.frame = CGRectMake(0, 0, TDWidth, TDHeight - BAR_ALL_HEIHT - 48);
    [self.view addSubview:self.recordView];
    
    self.recordView.hidden = YES;
    
    self.nullLabel = [[UILabel alloc] init];
    self.nullLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.nullLabel.textAlignment = NSTextAlignmentCenter;
    self.nullLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    [self.tableView addSubview:self.nullLabel];
    
    [self.nullLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.tableView);
    }];
    
    self.nullLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

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

#define IMAGE_WIDTH_CELL (TDWidth - 95) / 4
#define Limite_Record_Time 15

@interface TDConsultDetailViewController () <UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (nonatomic,strong) TDBaseToolModel *toolModel;
@property (nonatomic,strong) TDPermissionModel *permissionModel;

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDConsultRemidView *remindView;
@property (nonatomic,strong) TDConsultInputView *inputView;
@property (nonatomic,strong) UIButton *answerButton;

@property (nonatomic,strong) TDConsultContetModel *contentModel;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) CGFloat bottomHeight;
@property (nonatomic,assign) CGFloat inputViewHeight;

@property (nonatomic,strong) TDRecordView *recordView;
@property (nonatomic,strong) AVAudioRecorder *audioRecorder; //录音
@property (nonatomic,strong) AVAudioSession *audioSession;
@property (nonatomic,strong) NSString *recordUrl;//存储路径
@property (nonatomic,strong) NSString *mp3FilePath;//mp3路径

@property (nonatomic,strong) NSTimer *recordTimer;
@property (nonatomic,strong) NSTimer *recordCountTimer;
@property (nonatomic,assign) NSInteger recordTimeNum;
@property (nonatomic,assign) int mp3TimeNum;
@property (nonatomic,assign) BOOL isSwipe;

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,strong) NSTimer *playTimer;
@property (nonatomic,assign) NSInteger playImageNum;
@property (nonatomic,assign) BOOL isOverTime;

@property (nonatomic,strong) NSString *recordKeyStr; //录音的唯一标识

@end

@implementation TDConsultDetailViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = @"咨询详情";
    
    self.toolModel = [[TDBaseToolModel alloc] init];
    self.permissionModel = [[TDPermissionModel alloc] init];
    
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [self removeNotificationObser];
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
                    self.dataArray = [TDConsultDetailModel mj_objectArrayWithKeyValuesArray:self.contentModel.consult_details];
//                    NSArray *detailArray = [TDConsultDetailModel mj_objectArrayWithKeyValuesArray:self.contentModel.consult_details];
//                    if (detailArray.count > 0) {
//                        self.contentModel.consult_details = detailArray;
//                    }
                }
                [self.tableView reloadData];
                
                if ([self.contentModel.consult_status intValue] == 2) {
                    self.rightButton.hidden = YES;
                }
                else {
                    if (self.whereFrom == TDConsultDetailFromContactUnSolve && self.consultStatus == TDContactConsultStatusReplying) {
                        self.rightButton.hidden = NO;
                    }
                }
            }
        }
        else if ([code intValue] == 313) {//咨询不存在
            
        }
        else {
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.loadIngView removeFromSuperview];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"咨询详情 -- %ld",(long)error.code);
    }];
}

- (void)postNewConsultMessage:(NSInteger)type { //新增咨询: 1:文字； 2:语音; 3:图片; 4:视频

    if (![self.toolModel networkingState]) { return; }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.username forKey:@"username"];

    NSString *content = [self dealwithPostMessageType:type];
    [dict setValue:content forKey:@"content"];
    
    [dict setValue:@(type) forKey:@"content_type"];//类型
    if (type == 2 || type == 4) {
        [dict setValue:@(88) forKey:@"content_duration"];//语音，视频的时长
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/add_consult_message/",ELITEU_URL];
    
    [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            self.rightButton.hidden = NO;
            
            NSDictionary *dataDic = responseDic[@"data"];
            self.consultID = [NSString stringWithFormat:@"%@",dataDic[@"consult_id"]];
            
            TDConsultDetailModel *model = [TDConsultDetailModel mj_objectWithKeyValues:dataDic];
            if (model) {
                model.isSending = NO;
                model.is_show_time = @"1";
                model.username = self.username;
                [self.dataArray addObject:model];
                
                self.whereFrom = TDConsultDetailFromUserUnSolve;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"new_quetion_handin_notification" object:nil];
            }
            [self.tableView reloadData];
        }
        else {
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"新增咨询 -- %ld",(long)error.code);
    }];
}

- (void)appendConsultMessage:(NSInteger)type { //追问: 1:文字； 2:语音; 3:图片; 4:视频
    
    if (![self.toolModel networkingState]) { return; }
    
    [self addSendingConsultMessage];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.username forKey:@"username"];
    [dict setValue:self.consultID forKey:@"consult_id"];//咨询的 ID
    
    NSString *content = [self dealwithPostMessageType:type];
    [dict setValue:content forKey:@"content"];
    
    [dict setValue:@(type) forKey:@"content_type"]; //类型
    if (type == 2 || type == 4) {
        [dict setValue:@(88) forKey:@"content_duration"]; //语音，视频的时长
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/superadd_consult_message/",ELITEU_URL];
    
    [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            [self.dataArray removeLastObject];
            
            NSDictionary *dataDic = responseDic[@"data"];
            TDConsultDetailModel *model = [TDConsultDetailModel mj_objectWithKeyValues:dataDic];
            if (model) {
                model.isSending = NO;
                model.username = self.username;
                [self.dataArray addObject:model];
            }
            [self.tableView reloadData];
        }
        else {
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"新增咨询 -- %ld",(long)error.code);
    }];
}

- (void)replyUserConsult:(NSInteger)type {//回复咨询: 1:文字； 2:语音; 3:图片; 4:视频
    
    if (![self.toolModel networkingState]) { return; }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.username forKey:@"username"];
    [dict setValue:self.consultID forKey:@"feedback_id"];//咨询的 ID
    
    [dict setValue:self.inputView.inputTextView.text forKey:@"filename"]; //阿里云返回的文件 key
    
    [dict setValue:@(type) forKey:@"mimeType"];
    if (type == 2 || type == 4) {
        [dict setValue:@(88) forKey:@"content_duration"];
    }
    
    TDConsultDetailModel *model = self.dataArray.lastObject;
    [dict setValue:model.id forKey:@"last_id"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/consults/",ELITEU_URL];
    
    [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            self.rightButton.hidden = YES;
            
            NSDictionary *dataDic = responseDic[@"data"];
            TDConsultDetailModel *model = [TDConsultDetailModel mj_objectWithKeyValues:dataDic];
            if (model) {
                model.isSending = NO;
                model.username = self.username;
                [self.dataArray addObject:model];
            }
            
            [self.tableView reloadData];
        }
        else {
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
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

- (NSString *)dealwithPostMessageType:(NSInteger)type { //1:文字； 2:语音; 3:图片; 4:视频
    switch (type) {
        case 1:
            return self.inputView.inputTextView.text;
            break;
        case 2:
            return @"语音";
            break;
        case 3:
            return @"/oss_media/080beb52-519b-11e8-9c53-52540059267e,/oss_media/6fd419e0-5109-11e8-9c53-52540059267e,/oss_media/322f1aaa-4f6e-11e8-9c53-52540059267e";
            break;
        default:
            return @"/oss_media/oss_media/e80397a8-5198-11e8-9c53-52540059267e";
            break;
    }
}

- (void)dealWithConsultStatus:(NSInteger)type { //4 领取任务;5 放弃回答;6 已解决
    
    if (type == 6) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"quetion_sure_solved_notification" object:nil];
    }

    self.bottomHeight = 0;
    
    if (type == 4) {
        self.rightButton.hidden = NO;
        self.answerButton.hidden = YES;
        self.inputView.hidden = NO;
        
        self.inputViewHeight = 48;
    }
    else if (type == 5) {
        
        self.rightButton.hidden = YES;
        self.answerButton.hidden = NO;
        self.inputView.hidden = YES;
        
        self.inputViewHeight = 48;
    }
    else {
        self.rightButton.hidden = YES;
        self.answerButton.hidden = YES;
        self.inputView.hidden = YES;
        self.remindView.hidden = YES;
        
        self.inputViewHeight = 0;
        
        [self.remindView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(self.view);
            make.height.mas_equalTo(0);
        }];
        
        self.whereFrom = TDConsultDetailFromUserSolve;
        self.contentModel.is_slove = @"1";
        [self.tableView reloadData];
    }
    
    [self updateInputViewConstraint];
}

- (void)showLoadingStatus:(NSString *)titleStr {
    
    [SVProgressHUD showWithStatus:titleStr];
    SVProgressHUD.defaultMaskType = SVProgressHUDMaskTypeBlack;
    SVProgressHUD.defaultStyle = SVProgressHUDAnimationTypeNative;
}

- (void)addSendingConsultMessage {
    
    TDConsultDetailModel *model = [[TDConsultDetailModel alloc] init];
    model.username = self.username;
    model.content = self.inputView.inputTextView.text;
    model.is_show_time = @"0";
    model.isSending = YES;
    model.content_type = @"1";
    
    [self.dataArray addObject:model];
    [self.tableView reloadData];
}

#pragma mark - tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.contentModel.is_slove boolValue] == YES || [self.contentModel.is_claim_by_other boolValue] == YES) {
        return self.dataArray.count + 1;
    }
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < self.dataArray.count) {
        TDConsultDetailModel *detailModel = self.dataArray[indexPath.row];
        
        switch ([detailModel.content_type intValue]) {//1:文字; 2:语音; 3:图片; 4:视频
            case 1: {
                TDConsultTextCell *cell = [[TDConsultTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDConsultTextCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.statusButton.tag = indexPath.row;
                cell.detailModel = detailModel;
                [cell.statusButton addTarget:self action:@selector(statusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
            }
                break;
                
            case 2: {
                TDConsultAudioCell *cell = [[TDConsultAudioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDConsultAudioCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.statusButton.tag = indexPath.row;
                cell.detailModel = detailModel;
                [cell.statusButton addTarget:self action:@selector(statusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
            }
                break;
                
            case 3: {
                TDConsultImageCell *cell = [[TDConsultImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDConsultImageCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.statusButton.tag = indexPath.row;
                cell.detailModel = detailModel;
                [cell.statusButton addTarget:self action:@selector(statusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                WS(weakSelf);
                cell.tapImageHandle = ^(NSArray *imageArray,NSInteger tag) {
                    [weakSelf gotoWebViewPreview:imageArray index:tag];
                };
                
                return cell;
            }
                break;
                
            default: {
                TDConsultVideoCell *cell = [[TDConsultVideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDConsultVideoCell"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.detailModel = detailModel;
                
                cell.statusButton.tag = indexPath.row;
                cell.videoButton.tag = indexPath.row;
                [cell.videoButton addTarget:self action:@selector(videoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [cell.statusButton addTarget:self action:@selector(statusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
            }
                break;
        }
    }
    else {
        
        TDConsultStatusCell *cell = [[TDConsultStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDConsultStatusCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        switch (self.whereFrom) {
            case TDConsultDetailFromUserSolve:
                cell.statusLabel.text = @"问题已解决";
                cell.secondLabel.text = self.contentModel.last_update_time;
                break;
                
            case TDConsultDetailFromContactUnSolve:
                if (self.consultStatus == TDContactConsultStatusOtherReplying) {
                    cell.statusLabel.text = @"正在回复";
                    cell.secondLabel.text = self.contentModel.name;
                }
                else {
                    cell.statusLabel.text = @"问题已解决";
                    cell.secondLabel.text = self.contentModel.last_update_time;
                }
                break;
                
            case TDConsultDetailFromContactSolve:
                cell.statusLabel.text = self.consultStatus == TDContactConsultStatusUserGiveUp ? @"用户放弃提问" : @"问题已解决";
                cell.secondLabel.text = self.contentModel.last_update_time;
                break;
                
            default:
                break;
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

- (void)gotoWebViewPreview:(NSArray *)imageArray index:(NSInteger)index { //图片浏览
    
    TDWebImagePreviewViewController *previewVc = [[TDWebImagePreviewViewController alloc] init];
    previewVc.modalPresentationStyle = UIModalPresentationFullScreen;
    previewVc.index = index;
    previewVc.picUrlArray = imageArray;
    [self presentViewController:previewVc animated:YES completion:nil];
}

- (void)videoButtonAction:(UIButton *)sender { //视频预览
    
    TDConsultDetailModel *detailModel = self.dataArray[sender.tag];
    
    TDPreviewVideoViewController *previewVideoVC = [[TDPreviewVideoViewController alloc] init];
    previewVideoVC.videoPath = [NSString stringWithFormat:@"%@",detailModel.content];
    previewVideoVC.isWebVideo = YES;
    [self.navigationController pushViewController:previewVideoVC animated:YES];
}

- (void)statusButtonAction:(UIButton *)sender { //重发
    
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

- (void)imageSelectNoti:(NSNotification *)notification { //发送图片
//    NSDictionary *dic = notification.userInfo;
//    NSArray *infoArray = dic[@"selectImageArray"];
//    if (infoArray.count > 0) {
//        for (TDSelectImageModel *model in infoArray) {
//            if (![self.imageArray containsObject:model]) {
//                [self.imageArray addObject:model];
//            }
//        }
//    }
    if (self.whereFrom == TDConsultDetailFromContactUnSolve) { //回复
        [self replyUserConsult:3];
    }
    else if (self.whereFrom == TDConsultDetailFromNewConsult) { //新建
        [self postNewConsultMessage:3];
    }
    else {//追问
        [self appendConsultMessage:3];
    }
}

- (void)videoSelectNoti:(NSNotification *)notification {
    
    if (self.whereFrom == TDConsultDetailFromContactUnSolve) { //回复
        [self replyUserConsult:4];
    }
    else if (self.whereFrom == TDConsultDetailFromNewConsult) { //新建
        [self postNewConsultMessage:4];
    }
    else {//追问
        [self appendConsultMessage:4];
    }
}

#pragma mark - textView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) { //发送消息
        NSLog(@"------>> 发送消息");
        
        if (self.whereFrom == TDConsultDetailFromContactUnSolve) { //回复
            [self replyUserConsult:1];
        }
        else {
           self.consultID.length == 0 ? [self postNewConsultMessage:1] : [self appendConsultMessage:1];
        }
        textView.text = @"";
        self.inputViewHeight = 48;
        [self updateInputViewConstraint];
        
        return NO;
    }
    else {
        if (textView.text.length > 100) { return NO; }
        
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
        [self updateInputViewConstraint];
    }
    
    return YES;
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
    
    [self.remindView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(0);
    }];
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

- (void)imageButtonAction:(UIButton *)sender { //拍摄图片
    
    [self.inputView resignFirstResponder];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    WS(weakSelf);
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    
    NSString *messageStr = self.whereFrom == TDConsultDetailFromUserUnSolve ? @"已解决的问题将无法继续咨询" : @"确定放弃回答此问题？"; //@"已解决的问题将无法继续咨询"
    NSString *cancelStr = self.whereFrom == TDConsultDetailFromUserUnSolve ? TDLocalizeSelect(@"CANCEL", nil) : @"否";
    NSString *sureStr = self.whereFrom == TDConsultDetailFromUserUnSolve ? TDLocalizeSelect(@"OK", nil) : @"是";
    
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

- (void)leaveWhenConsultMessageSend { //正在发送消息，确定离开
    
    [self.inputView resignFirstResponder];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"正在发送消息，确定离开？发送将被中断。" preferredStyle:UIAlertControllerStyleAlert];
    
    WS(weakSelf);
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    
}

- (void)consultMessageSendFailed { //发送失败，请重新发送。
    
    [self.inputView resignFirstResponder];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"发送失败，请重新发送。" preferredStyle:UIAlertControllerStyleAlert];
//    WS(weakSelf);
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"重发" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
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

- (void)allowPHPhotoLibrary:(NSNotification *)notifi {
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

- (void)allowAVCaptureDevice:(NSNotification *)notifi {
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

- (void)deleteFile { //删除已保存的语音
    
    [self deleteRecordAuadio];
    
    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileUrl = [NSString stringWithFormat:@"%@/%@.mp3",strUrl,self.recordKeyStr];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileUrl error:nil];
    
    self.recordUrl = [NSString stringWithFormat:@"%@/%@.lpcm",strUrl,self.recordKeyStr];
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (![self.permissionModel requestAVMediaTypePermissionInController:self type:1]) {
        return;
    }
    
    CGPoint point = [gestureRecognizer locationInView:self.inputView.recordButton];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按开始");
        
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
        
        if (point.y > -35) {
            [self recordFinish];
            
        } else {
//            self.inputView.audioPlayView.hidden = YES;
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
        [self updateAvButtonConstraint];
        [self updateRecordButton:TDLocalizeSelect(@"MAX_ONE_RECORD", nil) imageStr:@"record_not_image" enable:NO];

    } else {
        [self.audioRecorder deleteRecording];
        [self updateRecordButton:TDLocalizeSelect(@"HOLD_TO_RECORD", nil) imageStr:@"record_not_image" enable:YES];
        [self.view makeToast:TDLocalizeSelect(@"ENCH_RECOR_LESS_TWO_SECOND", nil) duration:0.8 position:CSToastPositionCenter];
    }

    [self stopRecord];
}

- (void)deleteRecordAuadio { //删除录音文件

    if (self.audioPlayer.playing) {
        [self.audioPlayer stop];
        [self stopPlayMp3Constraint];
    }

    [self.audioRecorder deleteRecording];
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
        self.recordView.countDownLabel.text = [NSString stringWithFormat:@"%ld",Limite_Record_Time - self.recordTimeNum];
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

- (void)updateAvButtonConstraint { //更新语音的布局

//    self.inputView.audioPlayView.hidden = NO;

//    self.inputView.audioPlayView.timeLabel.text = [NSString stringWithFormat:@"%d“",self.mp3TimeNum];
//    float width = (TDWidth - 88) * (self.mp3TimeNum / Limite_Record_Time);
//
//    [self.inputView.audioPlayView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.view.mas_left).offset(13);
//        make.bottom.mas_equalTo(self.inputView.imageView.mas_top).offset(-18);
//        make.height.mas_equalTo(30);
//        make.width.mas_equalTo(width > 88 ? width : 88);
//    }];
}

#pragma mark - 播放录音
- (void)playAvAudio { //点击时候播放与暂停

    if (self.audioPlayer.playing) {
        [self.audioPlayer stop];
        [self stopPlayMp3Constraint];
        return;
    }


    [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self.audioSession setActive:YES error:nil];

    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:self.recordUrl] error:nil];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];

    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playTimerAction) userInfo:nil repeats:YES];

    //    NSLog(@"播放时间 ---->> %f",audioPlayer);
}

- (void)playTimerAction {

    self.playImageNum ++;
//    switch (self.playImageNum % 3) {
//        case 0:
//            self.inputView.audioPlayView.imageView.image = [UIImage imageNamed:@"player_three_image"];
//            break;
//        case 1:
//            self.inputView.audioPlayView.imageView.image = [UIImage imageNamed:@"player_one_image"];
//            break;
//        default:
//            self.inputView.audioPlayView.imageView.image = [UIImage imageNamed:@"player_two_image"];
//            break;
//    }
}

// AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag { //播放结束

    [self stopPlayMp3Constraint];
}

- (void)stopPlayMp3Constraint {
//    self.inputView.audioPlayView.imageView.image = [UIImage imageNamed:@"player_black_image"];
    [self.playTimer invalidate];
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
    [self.answerButton setTitle:@"回答问题" forState:UIControlStateNormal];
    [self.answerButton setTitleColor:[UIColor colorWithHexString:colorHexStr13] forState:UIControlStateNormal];
    [self.answerButton addTarget:self action:@selector(answerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.answerButton.layer.masksToBounds = YES;
    self.answerButton.layer.cornerRadius = 4.0;
    [self.view addSubview:self.answerButton];
    
    NSString *rightStr = @"已解决";
    if (self.whereFrom == TDConsultDetailFromContactUnSolve) {
        rightStr = @"放弃";
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

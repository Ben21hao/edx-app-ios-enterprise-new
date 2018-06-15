//
//  TDSkydriveFileViewController.m
//  edX
//
//  Created by Elite Edu on 2018/6/6.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveFileViewController.h"
#import "TDLocalFileWebViewController.h"
#import "TDSkydriveVideoViewController.h"
#import "TDSkydriveAudioViewController.h"
#import "TDSkydrveLoacalViewController.h"
#import "TDSkydriveNoSupportViewController.h"

#import "TDNodataView.h"
#import "TDSkydriveAlertView.h"
#import "TDSkydriveFolderCell.h"
#import "TDSkydriveFileCell.h"

#import "TDSkydrveFileModel.h"

#import "OEXAuthentication.h"
#import "edX-Swift.h"

#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>

@interface TDSkydriveFileViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDNodataView *noDataView;
@property (nonatomic,strong) TDSkydriveAlertView *alertView;

@property (nonatomic,strong) TDBaseToolModel *toolModel;

@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation TDSkydriveFileViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = self.folderName;
    self.rightButton.hidden = NO;
    [self.rightButton setImage:[UIImage imageNamed:@"file_download_image"] forState:UIControlStateNormal];
    
    self.toolModel = [[TDBaseToolModel alloc] init];
    
    [self setViewConstraint];
    [self setLoadDataView];
    [self requestData];
}

- (void)rightButtonAciton:(UIButton *)sender {
    [self gotoLocalVc];
}

#pragma mark - data
- (void)requestData {
    
    if (![self.toolModel networkingState]) {
        [self endRequestHandle];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager shareManager];
    NSString *authenStr = [OEXAuthentication authHeaderForApiAccess];
    [manager.requestSerializer setValue:authenStr forHTTPHeaderField:@"Authorization"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/v0/netdisk/cloud_file/",ELITEU_URL];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.username forKey:@"username"];
    [params setValue:self.folderID forKey:@"parent_id"];
    
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self endRequestHandle];
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        NSLog(@"------>> %@",responseDic);
        
        id code = responseDic[@"code"];
        if ([code intValue] == 200) {
            
            self.noDataView.hidden = YES;
            if (self.dataArray.count > 0) { //只有下拉加载，访问成功后，删除原有数据
                [self.dataArray removeAllObjects];
            }
            
            NSArray *dataArray = responseDic[@"data"];
            if (dataArray.count > 0) {
                
                for (int i = 0; i < dataArray.count; i ++) {
                    TDSkydrveFileModel *model = [TDSkydrveFileModel mj_objectWithKeyValues:dataArray[i]];
                    if (model) {
                        [self.dataArray addObject:model];
                    }
                }
            }
            else {
                [self nodataViewReason:@"该网盘暂无文件"];
            }
            [self.tableView reloadData];
        }
        else if ([code intValue] == 203) {//没有用户
            [self accountInvalidUser];
        }
        else {
            [self nodataViewReason:@"请求失败，下拉重新加载"];
        }

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self endRequestHandle];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"网盘文件夹错误----->> %@",error);
    }];
}

- (void)endRequestHandle {
    [self.loadIngView removeFromSuperview];
    [self.tableView.mj_header endRefreshing];
}

- (void)nodataViewReason:(NSString *)reasonStr {
    self.noDataView.hidden = NO;
    self.noDataView.messageLabel.text = reasonStr;
}

- (void)accountInvalidUser {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TDLocalizeSelect(@"SYSTEM_WARING", nil) message:@"账号异常，请联系管理员" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[OEXRouter sharedRouter] logoutAction];
    }];
    
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TDSkydrveFileModel *model = self.dataArray[indexPath.row];
    
    if ([model.type intValue] == 0) { //文件夹
        TDSkydriveFolderCell *cell = [[TDSkydriveFolderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SkydriveFolderCell"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.fileModel = model;
        
        return cell;
    }
    else {
        
        TDSkydriveFileCell *cell = [[TDSkydriveFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SkydriveFileCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.downloadButton.tag = indexPath.row;
        cell.shareButton.tag = indexPath.row;
        
        [cell.downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.fileModel = model;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TDSkydrveFileModel *model = self.dataArray[indexPath.row];
    if ([model.type intValue] == 0) {
        [self gotoFileVc]; //下一级目录
    }
    else {
        [self gotoNoSupportVc];
    }
}

#pragma mark - Action
- (void)downloadButtonAction:(UIButton *)sender { //下载按钮
    
}

- (void)shareButtonAction:(UIButton *)sender { //分享按钮
    [self showAlertVeiw];
}

#pragma mark - 分享弹框
- (void)showAlertVeiw {
    
    self.alertView = [[TDSkydriveAlertView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight)];
    [self.alertView.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView.sureButton addTarget:self action:@selector(sureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.alertView];
}

- (void)cancelButtonAction:(UIButton *)sender { //公开
    [self createShereUrlType:1 index:sender.tag];
}

- (void)sureButtonAction:(UIButton *)sender { //加密
    [self createShereUrlType:0 index:sender.tag];
}

- (void)createShereUrlType:(int)type index:(NSInteger)index { //创建分享链接
    
    [self.alertView removeFromSuperview];
    
    TDBaseToolModel *toolModel = [[TDBaseToolModel alloc] init];
    if (![toolModel networkingState]) {
        [self.alertView removeFromSuperview];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"创建中"];
    SVProgressHUD.defaultMaskType = SVProgressHUDMaskTypeBlack;
    SVProgressHUD.defaultStyle = SVProgressHUDAnimationTypeNative;
    
    NSString *expireStr = @"0";
    if (self.alertView.timeType == TDSkydriveShareTimeOneDay) {
        expireStr = @"1";
    }
    else if (self.alertView.timeType == TDSkydriveShareTimeSevenDay) {
        expireStr = @"7";
    }
    
    TDSkydrveFileModel *model = self.dataArray[index];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:expireStr forKey:@"expire_at"];//分享文件的时长。有7，1，0
    [params setValue:model.id forKey:@"cloud_file"];//分享文件的id
    [params setValue:[NSString stringWithFormat:@"%d",type] forKey:@"type"];//0 加密，1 公开
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager shareManager];
    NSString *authValue = [NSString stringWithFormat:@"%@", [OEXAuthentication authHeaderForApiAccess]];
    [manager.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];//安全验证
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/v0/netdisk/sharefile/",ELITEU_URL];
    
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [SVProgressHUD dismiss];
        
        NSDictionary *responDic = (NSDictionary *)responseObject;
        NSLog(@"----->> %@",responDic);
        
        id code = responDic[@"code"];
        if ([code intValue] == 200) {
            NSString *shareUrl = responDic[@"share_url"];
            NSString *password = responDic[@"password"];
            [self copyShareLink:shareUrl password:password];
        }
        else {
            [self.view makeToast:@"链接创建失败" duration:1.08 position:CSToastPositionCenter];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"分享链接创建失败----->> %@",error);
    }];
}

- (void)copyShareLink:(NSString *)linkStr password:(NSString *)passwordStr { //赋值分享链接
    
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    if (passwordStr.length > 0) {
        pasteBoard.string = [NSString stringWithFormat:@"链接：%@\n密码：%@",linkStr,passwordStr];
    }
    else {
        pasteBoard.string = [NSString stringWithFormat:@"链接：%@",linkStr];
    }
    
    [self.view makeToast:@"外链地址已经复制到剪切板中！" duration:1.08 position:CSToastPositionCenter];
}

#pragma makr - 文件浏览/播放
- (void)gotoVideoPlayVC { //视频播放
    TDSkydriveVideoViewController *videoVc = [[TDSkydriveVideoViewController alloc] init];
    //    TDVideoViewController *videoVc = [[TDVideoViewController alloc] init];
    [self.navigationController pushViewController:videoVc animated:YES];
}

- (void)gotoAudioPlayVC {//音频播放
    TDSkydriveAudioViewController *audioPlayVC = [[TDSkydriveAudioViewController alloc] init];
    [self.navigationController pushViewController:audioPlayVC animated:YES];
}

- (void)gotoPreviewFile:(NSString *)filePath type:(NSString *)type { //文档浏览
    
    if (filePath.length == 0) {
        NSLog(@"----- 空路径 ---");
        return;
    }
    
    TDLocalFileWebViewController *webVc = [[TDLocalFileWebViewController alloc] init];
    webVc.titleStr = @"文档浏览";
    webVc.url = [NSURL fileURLWithPath:filePath];
    webVc.typeStr = type;
    [self.navigationController pushViewController:webVc animated:YES];
}

- (void)gotoLocalVc { //文件管理
    
    TDSkydrveLoacalViewController *localVc = [[TDSkydrveLoacalViewController alloc] init];
    [self.navigationController pushViewController:localVc animated:YES];
}

- (void)gotoFileVc { //下一级目录
    
    TDSkydriveFileViewController *fileVc = [[TDSkydriveFileViewController alloc] init];
    fileVc.username = self.username;
    fileVc.folderName = self.folderName;
    fileVc.folderID = self.folderID;
    [self.navigationController pushViewController:fileVc animated:YES];
}

- (void)gotoNoSupportVc { //不支持预览
    
    TDSkydriveNoSupportViewController *noSupportVc = [[TDSkydriveNoSupportViewController alloc] init];
    noSupportVc.titleStr = @"不支持预览";
    [self.navigationController pushViewController:noSupportVc animated:YES];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor colorWithHexString:colorHexStr6];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    self.noDataView = [[TDNodataView alloc] init];
    self.noDataView.imageView.image = [UIImage imageNamed:@"file_null_image"];
    self.noDataView.messageLabel.text = @"该文件夹暂无文件";
    [self.tableView addSubview:self.noDataView];
    
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tableView);
        make.top.mas_equalTo(self.tableView.mas_top).offset(0);
        make.size.mas_equalTo(CGSizeMake(TDWidth, TDHeight - BAR_ALL_HEIHT));
    }];
    
    self.noDataView.hidden = YES;
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestData)];
    header.lastUpdatedTimeLabel.hidden = YES; //隐藏时间
    [header setTitle:TDLocalizeSelect(@"DROP_REFRESH_TEXT", nil) forState:MJRefreshStateIdle];
    [header setTitle:TDLocalizeSelect(@"RELEASE_REFRESH_TEXT", nil) forState:MJRefreshStatePulling];
    [header setTitle:TDLocalizeSelect(@"REFRESHING_TEXT", nil) forState:MJRefreshStateRefreshing];
    self.tableView.mj_header = header;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end



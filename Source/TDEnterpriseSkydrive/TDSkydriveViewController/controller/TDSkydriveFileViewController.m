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
#import "TDSkydriveImageViewController.h"

#import "TDNodataView.h"
#import "TDSkydriveAlertView.h"
#import "TDSkydriveFolderCell.h"
#import "TDSkydriveFileCell.h"

#import "TDSkydrveFileModel.h"
#import "TDSkydrveFileModel.h"

#import "TDDownloadOperation.h"
#import "OEXAuthentication.h"
#import "edX-Swift.h"

#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>

@interface TDSkydriveFileViewController () <UITableViewDelegate,UITableViewDataSource,TDDownloadOperationDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDNodataView *noDataView;
@property (nonatomic,strong) TDSkydriveAlertView *alertView;

@property (nonatomic,strong) TDBaseToolModel *toolModel;

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *sqliteArray; //数据库的数据

@property (nonatomic,strong) TDDownloadOperation *downloadOperation;

@end

@implementation TDSkydriveFileViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (NSMutableArray *)sqliteArray {
    if (!_sqliteArray) {
        _sqliteArray = [[NSMutableArray alloc] init];
    }
    return _sqliteArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = self.folderName;
    self.rightButton.hidden = NO;
    [self.rightButton setImage:[UIImage imageNamed:@"file_download_image"] forState:UIControlStateNormal];
    
    self.toolModel = [[TDBaseToolModel alloc] init];
    
    [self setViewConstraint];
    
    self.downloadOperation = [TDDownloadOperation shareOperation];
    [self.downloadOperation backgroundURLSession];
    [self.downloadOperation sqliteOperationInit:self.username];
    self.downloadOperation.delegate = self;
    [self getFileData];
    
    [self setLoadDataView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFileData) name:@"skydrive_delete_finish" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFileData) name:@"noSupport_skydrive_delete_finish" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.downloadOperation.delegate = self;
}

- (void)dealloc {
    NSLog(@" ---->>> ");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"skydrive_delete_finish" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"skydrivnoSupport_skydrive_delete_finishe_delete_finish" object:nil];
}

- (void)rightButtonAciton:(UIButton *)sender {
    [self gotoLocalVc];
}

- (void)getFileData { //查询本地数据 -> 再请求服务器数据
    
    NSMutableArray *localArray = [self.downloadOperation getLocalDownloadFileData];//查询本地数据库的数据
    if (self.sqliteArray) {
        [self.sqliteArray removeAllObjects];
    }
    [self.sqliteArray addObjectsFromArray:localArray];
    
    [self requestData];//请求服务器的数据
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
        NSLog(@"-------------------->>>");
        
        id code = responseDic[@"code"];
        if ([code intValue] == 20000) {
            
            self.noDataView.hidden = YES;
            if (self.dataArray.count > 0) { //只有下拉加载，访问成功后，删除原有数据
                [self.dataArray removeAllObjects];
            }
            
            NSArray *dataArray = responseDic[@"data"];
            if (dataArray.count > 0) {
                
                for (int i = 0; i < dataArray.count; i ++) {
                    TDSkydrveFileModel *model = [TDSkydrveFileModel mj_objectWithKeyValues:dataArray[i]];
                    
                    if (model) {
                        model = [self synFileMessage:model];
                        [self.dataArray addObject:model];
                    }
                }
            }
            else {
                [self nodataViewReason:@"该网盘暂无文件"];
            }
            [self.tableView reloadData];
        }
        else if ([code intValue] == 30103) {//没有用户
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

#pragma amrk - 用户不存在
- (void)accountInvalidUser {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TDLocalizeSelect(@"SYSTEM_WARING", nil) message:@"账号异常，请联系管理员" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[OEXRouter sharedRouter] logoutAction];
    }];
    
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 下载
- (void)downloadButtonAction:(UIButton *)sender { //下载按钮
    
    TDSkydrveFileModel *model = self.dataArray[sender.tag];
    switch (model.status) {
        case 0: {
            if ([self judgeHasDownloadingTask]) {//有下载中： 未下载 -> 等待下载
                [self.downloadOperation fileChageToWaitToDownload:model firstAdd:YES];
            }
            else { //无下载中：未下载 -> 下载
                [self currentModelDownloadOperation:model];
                [self.downloadOperation beginDownloadFileModel:model firstAdd:YES]; //下载，第一次加入
            }
        }
            break;
        case 1:{//下载中 -> 暂停
            [self currentModelDownloadOperation:model];
            [self.downloadOperation pauseDownload:model]; //暂停(暂停完成后，判断是否有等待，有则下一个)
            NSLog(@"暂停 -->> %@",model.name);
        }
            break;
        case 2: { //等待下载 -> 暂停
            [self.downloadOperation waitChageToPause:model];
        }
            break;
        case 3: {
            if ([self judgeHasDownloadingTask]) {//有下载中： 暂停 -> 等待下载，下一个
                [self.downloadOperation fileChageToWaitToDownload:model firstAdd:NO];
            }
            else { //无下载中：暂停 -> 下载
                [self currentModelDownloadOperation:model];
                [self.downloadOperation beginDownloadFileModel:model firstAdd:NO];//下载
            }
        }
            break;
        case 4: {//失败
            if ([self judgeHasDownloadingTask]) {//有下载中： 失败 -> 等待下载
                [self.downloadOperation fileChageToWaitToDownload:model firstAdd:NO];
            }
            else { //无下载中：失败 -> 下载
                [self currentModelDownloadOperation:model];
                [self.downloadOperation beginDownloadFileModel:model firstAdd:NO]; //下载
            }
        }
            break;
        case 5: {//已经成功了，不可点
        }
            break;
        default:
            break;
    }
//    NSLog(@"点击下载：状态 ----->> %ld",(long)model.status);
}

- (void)currentModelDownloadOperation:(TDSkydrveFileModel *)currentModel { //当前下载文件
    self.downloadOperation.currentModel = currentModel;
    self.downloadOperation.filePath = [self getPreviewFilePathForId:currentModel];
}

#pragma mark - 判断是否
- (BOOL)judgeHasDownloadingTask { //是否有下载中
    
    NSMutableArray *localArray = [self.downloadOperation getLocalDownloadFileData];
    for (int i = 0; i < localArray.count; i ++) {
        TDSkydrveFileModel *model = localArray[i];
        
        if (model.status == 1) { //有文件在下载
            return YES;
        }
    }
    return NO; //无正在下载的文件
}

- (TDSkydrveFileModel *)judgHasWaitToDownloadTask:(NSMutableArray *)localArray { //是否有正在等待
    
    for (int i = 0; i < localArray.count; i ++) {
        TDSkydrveFileModel *model = localArray[i];
        
        if (model.status == 2) { //有文件在等待下载
            return model;
        }
    }
    return nil; //无正在等待下载的文件
}

- (TDSkydrveFileModel *)synFileMessage:(TDSkydrveFileModel *)fileModel { //同步本地数据
    
    for (int i = 0; i < self.sqliteArray.count; i ++) {
        
        TDSkydrveFileModel *model = self.sqliteArray[i];
        if (model.status == 1) {//正在下载
            [self currentModelDownloadOperation:model];
        }
        
        if ([fileModel.id isEqualToString:model.id]) {
            fileModel.progress = model.progress;
            fileModel.status = model.status;
            fileModel.download_size = model.download_size;
            fileModel.resumeData = model.resumeData;
            
//            NSLog(@"同步model --->> %@  %@ -- %ld",model.id ,model.file_size,(long)model.status);
            return model;
        }
    }
    return fileModel;
}

#pragma mark - TDDownloadOperationDelegate
- (void)nextFileShouldBeginDownload { //有等待：下一个任务开始下载

//    TDSkydrveFileModel *nextModel = [self judgHasWaitToDownloadTask:self.dataArray];
//    if (nextModel) {//有等待下载： 下一个
//        [self currentModelDownloadOperation:nextModel];
//        [self.downloadOperation nextFileBeginDownload:nextModel];
//    }
//    
//    
//    [self.downloadOperation getLocalDownloadFileSortDataBlock:^(NSMutableArray *downloadArray, NSMutableArray *finishArray) {
//        NSLog(@"是否有等待--->>> %@ -->> %@",downloadArray,finishArray);
//    }];
    
    WS(weakSelf);
    [self.downloadOperation getLocalDownloadFileSortDataBlock:^(NSMutableArray *downloadArray, NSMutableArray *finishArray) {
        
        NSLog(@"下一个 ----->> 有等待 -->> %@",downloadArray);
        
        TDSkydrveFileModel *nextModel = [weakSelf judgHasWaitToDownloadTask:downloadArray];
        if (nextModel) {//有等待下载： 下一个
            [weakSelf currentModelDownloadOperation:nextModel];
            [weakSelf.downloadOperation nextFileBeginDownload:nextModel];
        }
    }];
}

- (void)currentFileDownloadFinish:(TDSkydrveFileModel *)currentModel { //下载完一个任务，刷新任务管理页
    
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
        cell.progressView.downloadButton.tag = indexPath.row;
        cell.shareButton.tag = indexPath.row;
        
        [cell.progressView.downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.fileModel = model;
//        NSLog(@"cell的model --->> %@ -- %ld",model.name,(long)model.status);
        
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
        [self gotoFileFolder:model]; //下一级目录
        
    }
    else {
        if (model.status == 5) { //只有下载完才能看
            NSInteger format = [model.file_type_format integerValue];
            switch (format) { //文件分类: 0 文件夹 ，1 图片，3 文档，2 音频，4 视频， 5 压缩包，6 其他
                case 1:
                    [self gotoPreviewImage:model];
                    break;
                case 2:
                    [self gotoAudioPlayVC:model];
                    break;
                case 3:
                    [self gotoPreviewDocument:model]; //文档
                    break;
                case 4:
                    [self gotoVideoPlayVC:model];
                    break;
                case 5:
                    [self gotoNoSupportVc:model];
                    break;
                default: //不支持的文件类型
                    [self gotoNoSupportVc:model];
                    break;
            }
        }
    }
}

#pragma makr - 文件浏览/播放
- (void)gotoVideoPlayVC:(TDSkydrveFileModel *)model { //视频播放
    
    NSString *filePath = [self getPreviewFilePathForId:model];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    
    //    TDVideoViewController *videoVc = [[TDVideoViewController alloc] init];
    
    TDSkydriveVideoViewController *videoVc = [[TDSkydriveVideoViewController alloc] init];
    videoVc.filePath = filePath;
    videoVc.titleStr = model.name;
    [self.navigationController pushViewController:videoVc animated:YES];
}

- (void)gotoAudioPlayVC:(TDSkydrveFileModel *)model {//音频播放
    
    NSString *filePath = [self getPreviewFilePathForId:model];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    TDSkydriveAudioViewController *audioPlayVC = [[TDSkydriveAudioViewController alloc] init];
    audioPlayVC.filePath = filePath;
    audioPlayVC.titleStr = model.name;
    [self.navigationController pushViewController:audioPlayVC animated:YES];
}

- (void)gotoPreviewDocument:(TDSkydrveFileModel *)model { //文档浏览
    
    NSString *filePath = [self getPreviewFilePathForId:model];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    
    TDLocalFileWebViewController *webVc = [[TDLocalFileWebViewController alloc] init];
    webVc.titleStr = model.name;
    webVc.url = [NSURL fileURLWithPath:filePath];
    webVc.typeStr = model.type;
    [self.navigationController pushViewController:webVc animated:YES];
}

- (void)gotoPreviewImage:(TDSkydrveFileModel *)model { //图片预览
    
    NSString *filePath = [self getPreviewFilePathForId:model];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    
    TDSkydriveImageViewController *imageVc = [[TDSkydriveImageViewController alloc] init];
    imageVc.filePath = filePath;
    imageVc.titleStr = model.name;
    imageVc.typeStr = model.file_type;
    [self.navigationController pushViewController:imageVc animated:YES];
}

- (void)gotoNoSupportVc:(TDSkydrveFileModel *)model { //不支持预览
    
    NSString *filePath = [self getPreviewFilePathForId:model];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    
    TDSkydriveNoSupportViewController *noSupportVc = [[TDSkydriveNoSupportViewController alloc] init];
    noSupportVc.titleStr = model.id;
    noSupportVc.filePath = filePath;
    [self.navigationController pushViewController:noSupportVc animated:YES];
}

- (NSString *)getPreviewFilePathForId:(TDSkydrveFileModel *)model { //拼接路径
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *namePath = [NSString stringWithFormat:@"skydive_download_%@_%@.%@",self.username,model.id,model.file_type];
    NSString *filePath = [path stringByAppendingPathComponent:namePath];
    
//    NSLog(@"文件路径------->> %@",filePath);
    return filePath;
}

#pragma mark - 其他目录
- (void)gotoLocalVc { //文件管理
    
    TDSkydrveLoacalViewController *localVc = [[TDSkydrveLoacalViewController alloc] init];
    localVc.username = self.username;
    [self.navigationController pushViewController:localVc animated:YES];
}

- (void)gotoFileFolder:(TDSkydrveFileModel *)model { //下一级目录
    
    TDSkydriveFileViewController *fileVc = [[TDSkydriveFileViewController alloc] init];
    fileVc.username = self.username;
    fileVc.folderName = model.name;
    fileVc.folderID = model.id;
    [self.navigationController pushViewController:fileVc animated:YES];
}

#pragma mark - 分享
- (void)shareButtonAction:(UIButton *)sender { //分享按钮
    [self showAlertVeiw];
}

- (void)showAlertVeiw { //弹框
    
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
        
        id code = responDic[@"code"];
        if ([code intValue] == 20000) {
            NSDictionary *dataDic = responDic[@"data"];
            NSString *shareUrl = dataDic[@"share_url"];
            NSString *password = dataDic[@"password"];
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
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getFileData)];
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



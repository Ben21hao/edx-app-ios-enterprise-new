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

@property (nonatomic,strong) TDDownloadOperation *downloadOperation;

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
    self.titleViewLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.rightButton.hidden = NO;
    [self.rightButton setImage:[UIImage imageNamed:@"file_download_image"] forState:UIControlStateNormal];
    
    self.toolModel = [[TDBaseToolModel alloc] init];
    
    [self setViewConstraint];
    
    self.downloadOperation = [TDDownloadOperation shareOperation];
    [self.downloadOperation backgroundURLSession];
    [self.downloadOperation sqliteOperationInit:self.username];
    self.downloadOperation.delegate = self;
    self.downloadOperation.username = self.username;
    [self getFileData];
    
    [self setLoadDataView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFileData) name:@"skydrive_delete_finish" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFileData) name:@"noSupport_skydrive_delete_finish" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityNotReachableAction:) name:@"Network_Status_NotReachable" object:nil]; //网络不可用
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityReachableViaWWANAction:) name:@"Network_Status_ReachableViaWWAN" object:nil]; //网络切换为移动网络
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.downloadOperation.delegate = self;
}

- (void)dealloc {
    NSLog(@" 销毁---->>> ");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"skydrive_delete_finish" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"skydrivnoSupport_skydrive_delete_finishe_delete_finish" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Network_Status_NotReachable" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Network_Status_ReachableViaWWAN" object:nil];
}

- (void)rightButtonAciton:(UIButton *)sender {
    [self gotoLocalVc];
}

- (void)getFileData { //查询本地数据 -> 再请求服务器数据
    
    NSMutableArray *localArray = [self.downloadOperation getLocalDownloadFileData];//查询本地数据库的数据
    
    [self requestData:localArray];//请求服务器的数据
}

#pragma mark - data
- (void)requestData:(NSMutableArray *)localArray {
    
    if (![self.toolModel networkingState]) {
        [self endRequestHandle];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager shareManager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
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
                        model = [self synFileMessage:model localArray:localArray];
                        [self.dataArray addObject:model];
                    }
                }
            }
            else {
                [self nodataViewReason:TDLocalizeSelect(@"SKY_FOLDERS_EMPTY_TEXT", nil)];
            }
            [self.tableView reloadData];
        }
        else if ([code intValue] == 30103) {//没有用户
            [self accountInvalidUser];
        }
        else {
            [self nodataViewReason:TDLocalizeSelect(@"SKY_REQUEST_FAILED", nil)];
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
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TDLocalizeSelect(@"SYSTEM_WARING", nil) message:TDLocalizeSelect(@"SKY_ACCOUNT_ERROR", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"LOGOUT", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[OEXRouter sharedRouter] logoutAction];
    }];
    
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 下载
- (void)downloadButtonAction:(UIButton *)sender { //下载按钮
    
    TDSkydrveFileModel *model = self.dataArray[sender.tag];
    model.udpateLocal = YES;
    
    switch (model.status) {
        case 0: {
            if ([self judgeHasDownloadingTask]) {//有下载中： 未下载 -> 等待下载
                [self.downloadOperation fileChageToWaitToDownload:model firstAdd:YES];
            }
            else { //无下载中：未下载 -> 下载
                
                [self currentModelDownloadOperation:model];
                
                BOOL wifiOnly = [OEXInterface shouldDownloadOnlyOnWifi];
                if ([self.toolModel networkingStateReachableViaWWAN] && wifiOnly) { //移动网络
                    [self changeDownloadEnvirentment:model firstAdd:YES];
                }
                else {
                    [self beginDownloadFileModel:model firstAdd:YES]; //下载，第一次加入
                }
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
        case 3: { //暂停
            if ([self judgeHasDownloadingTask]) {//有下载中： 暂停 -> 等待下载，下一个
                [self.downloadOperation fileChageToWaitToDownload:model firstAdd:NO];
            }
            else { //无下载中：暂停 -> 下载
                [self currentModelDownloadOperation:model];
                
                BOOL wifiOnly = [OEXInterface shouldDownloadOnlyOnWifi];
                if ([self.toolModel networkingStateReachableViaWWAN] && wifiOnly) { //移动网络
                    [self changeDownloadEnvirentment:model firstAdd:NO];
                }
                else {
                    [self beginDownloadFileModel:model firstAdd:NO];//下载
                }
            }
        }
            break;
        case 4: {//失败
            if ([self judgeHasDownloadingTask]) {//有下载中： 失败 -> 等待下载
                [self.downloadOperation fileChageToWaitToDownload:model firstAdd:NO];
            }
            else { //无下载中：失败 -> 下载
                [self currentModelDownloadOperation:model];
                
                BOOL wifiOnly = [OEXInterface shouldDownloadOnlyOnWifi];
                if ([self.toolModel networkingStateReachableViaWWAN] && wifiOnly) { //移动网络
                    [self changeDownloadEnvirentment:model firstAdd:NO];
                }
                else {
                    [self beginDownloadFileModel:model firstAdd:NO];//下载
                }
            }
        }
            break;
        case 5: {//已经成功了，不可点
        }
            break;
        default:
            break;
    }
    NSLog(@"点击下载：状态 ----->> %ld",(long)model.status);
}

- (void)currentModelDownloadOperation:(TDSkydrveFileModel *)currentModel { //当前下载文件
    self.downloadOperation.currentModel = currentModel;
    self.downloadOperation.filePath = [self getPreviewFilePathForId:currentModel];
}

- (void)beginDownloadFileModel:(TDSkydrveFileModel *)model firstAdd:(BOOL)isFirst {
    
    if (![self.toolModel networkingState]) { //没网
        return;
    }
    
    if (![self freeDiskSpaceEnounghInBytes:model.real_file_size]) { //内存不足
        [self pauseAllDownloadFile:YES]; //所有任务暂停
        return;
    }
    
    [self currentModelDownloadOperation:model];
    [self.downloadOperation beginDownloadFileModel:model firstAdd:isFirst];//下载
}

- (void)changeDownloadEnvirentment:(TDSkydrveFileModel *)model firstAdd:(BOOL)isFirst { //4G环境下，若只允许wifi下载，提示移动网络下
    
    UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:nil message:TDLocalizeSelect(@"SKY_CELLULAR_CONNECTION_TEXT", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"SKY_PAUSE_BUTTON_TEXT", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf pauseAllDownloadFile:YES];
    }];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"SKY_CONTINUE_BUTTON_TEXT", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [OEXInterface setDownloadOnlyOnWifiPref:NO]; //切换允许移动网络下载
        [weakSelf beginDownloadFileModel:model firstAdd:isFirst];//下载
    }];
    
    [alertControler addAction:cancelAction];
    [alertControler addAction:continueAction];
    [self presentViewController:alertControler animated:YES completion:nil];
}

- (void)wifiOnlyAlertViewShow { //只有wifi下载的弹框
    
    if (![self judgeHasDownloadingTask]) { //没有下载中
        return;
    }
    
    UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:nil message:TDLocalizeSelect(@"SKY_CELLULAR_CONNECTION_TEXT", nil)  preferredStyle:UIAlertControllerStyleAlert];
    
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"SKY_PAUSE_BUTTON_TEXT", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf pauseAllDownloadFile:YES];
    }];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"SKY_CONTINUE_BUTTON_TEXT", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [OEXInterface setDownloadOnlyOnWifiPref:NO]; //切换允许移动网络下载
        [weakSelf continiuAllDownloadFile]; //继续下载
    }];
    
    [alertControler addAction:cancelAction];
    [alertControler addAction:continueAction];
    [self presentViewController:alertControler animated:YES completion:nil];
}

- (CGFloat)freeDiskSpaceEnounghInBytes:(NSString *)sizeStr { //手机存储是否足够
    
    CGFloat fileSize = [sizeStr floatValue];
    CGFloat freeSize = 0.0;// 剩余大小
    NSError *error = nil;// 是否登录
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *_free = [dictionary objectForKey:NSFileSystemFreeSize];
        freeSize = [_free unsignedLongLongValue] * 1.0;
        NSLog(@"存储空间 ----->>> 剩余：%.2lfM - 文件：%.2lfM",freeSize/1024/1024,fileSize/1024/1024);
        
        if (fileSize > freeSize - 2048) { //给2M的剩余空间
            [self.view makeToast:TDLocalizeSelect(@"SKY_INSUFFICIENT_STORAGE", nil) duration:1.08 position:CSToastPositionCenter];
            return NO;
        }
        return YES;
    }
    else {
        NSLog(@"查询内存存储控件失败: Domain = %@, Code = %ld", [error domain], (long)[error code]);
        return YES;
    }
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

- (TDSkydrveFileModel *)synFileMessage:(TDSkydrveFileModel *)fileModel localArray:(NSMutableArray *)localArray { //同步本地数据
    
    for (int i = 0; i < localArray.count; i ++) {
        
        TDSkydrveFileModel *model = localArray[i];
        if (model.status == 1) {//正在下载
            [self currentModelDownloadOperation:model];
        }
        
        if ([fileModel.id isEqualToString:model.id]) {
            fileModel.progress = model.progress;
            fileModel.status = model.status;
            fileModel.download_size = model.download_size;
            fileModel.resumeData = model.resumeData;
            
            NSLog(@"同步model --->> %@  %@ -- %ld",fileModel.name ,fileModel.is_shareable,(long)fileModel.status);
            return fileModel;
        }
    }
    return fileModel;
}

- (void)allDataChangeStatus:(TDSkydrveFileModel *)fileModel {
    
    for (int i = 0; i < self.dataArray.count; i ++) {
        
        TDSkydrveFileModel *model = self.dataArray[i];
        
        if ([fileModel.id isEqualToString:model.id]) {
            model.progress = fileModel.progress;
            model.status = fileModel.status;
            model.download_size = fileModel.download_size;
            model.resumeData = fileModel.resumeData;
        }
    }
}

#pragma mark - TDDownloadOperationDelegate
- (void)nextFileShouldBeginDownload { //有等待：下一个任务开始下载
    
    WS(weakSelf);
    [self.downloadOperation getLocalDownloadFileSortDataBlock:^(NSMutableArray *downloadArray, NSMutableArray *finishArray) {
        
        NSLog(@"下一个 ----->> 有等待 -->> %@",downloadArray);
        
        TDSkydrveFileModel *nextModel = [weakSelf judgHasWaitToDownloadTask:downloadArray];
        if (nextModel) {//有等待下载： 下一个
            nextModel.udpateLocal = YES;
            
            if (![self freeDiskSpaceEnounghInBytes:nextModel.real_file_size]) { //内存不足
                [self pauseAllDownloadFile:YES]; //所有任务暂停
            }
            else {
                [weakSelf currentModelDownloadOperation:nextModel];
                [weakSelf.downloadOperation nextFileBeginDownload:nextModel];
            }
        }
    }];
}

- (void)currentFileDownloadFinish:(TDSkydrveFileModel *)currentModel { //下载完一个任务，刷新任务管理页
    
}

#pragma mark - 网络变化
- (void)reachabilityNotReachableAction:(NSNotification *)notification {//没网
    
    NSLog(@"--->> 网络信号不好");
    
    [self.view makeToast:TDLocalizeSelect(@"SKY_BAD_NETWORK", nil) duration:1.08 position:CSToastPositionCenter];
    
    WS(weakSelf);
    [self.downloadOperation getLocalDownloadFileSortDataBlock:^(NSMutableArray *downloadArray, NSMutableArray *finishArray) {
        
        for (int i = 0; i < downloadArray.count; i ++) {
            TDSkydrveFileModel *model = downloadArray[i];
            model.udpateLocal = YES; //更新本地数据库
            
            if (model.status == 1 || model.status == 2) { // -> 暂停
                
                model.status = 3;
                [weakSelf currentModelDownloadOperation:model];
                [weakSelf.downloadOperation pauseDownload:model];

                [weakSelf.downloadOperation waitChageToPause:model];
                
                [weakSelf allDataChangeStatus:model];//同步本地数据
            }
        }
    }];
}

- (void)reachabilityReachableViaWWANAction:(NSNotification *)notification {//只允许wifi下载情况下，切换到移动网络
    
    [self pauseAllDownloadFile:NO]; //不更新
    [self wifiOnlyAlertViewShow];
}

- (void)pauseAllDownloadFile:(BOOL)udpateLocal { //暂停 - udpateLocal: 是否更新本地数据库
    
    WS(weakSelf);
    [self.downloadOperation getLocalDownloadFileSortDataBlock:^(NSMutableArray *downloadArray, NSMutableArray *finishArray) {
        
        for (int i = 0; i < downloadArray.count; i ++) {
            
            TDSkydrveFileModel *model = downloadArray[i];
            model.udpateLocal = udpateLocal; //是否更新本地数据库
            
            if (model.status == 1 || model.status == 2) { // -> 暂停
                [weakSelf currentModelDownloadOperation:model];
                [weakSelf.downloadOperation pauseDownload:model];
//            }
//            else if (model.status == 2) { //等待 -> 暂停
                [weakSelf.downloadOperation waitChageToPause:model];
            }
        }
    }];
}

- (void)continiuAllDownloadFile { //继续
 
    WS(weakSelf);
    [self.downloadOperation getLocalDownloadFileSortDataBlock:^(NSMutableArray *downloadArray, NSMutableArray *finishArray) {
        
        for (int i = 0; i < downloadArray.count; i ++) {
            TDSkydrveFileModel *model = downloadArray[i];
            model.udpateLocal = YES; //更新本地数据库
            
            if (model.status == 1) { //下载 -> 下载
                [weakSelf currentModelDownloadOperation:model];
                [weakSelf beginDownloadFileModel:model firstAdd:NO];
            }
            else if (model.status == 2) { //等待 -> 等待
                [weakSelf.downloadOperation fileChageToWaitToDownload:model firstAdd:NO];
            }
        }
    }];
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

- (void)judgeDucumentCanPreview:(TDSkydrveFileModel *)model {
    
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
    noSupportVc.username = self.username;
    noSupportVc.model = model;
    noSupportVc.filePath = filePath;
    noSupportVc.downloadOperation = self.downloadOperation;
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
    [self showAlertVeiw:sender.tag];
}

- (void)showAlertVeiw:(NSInteger)tag { //弹框
    
    self.alertView = [[TDSkydriveAlertView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight)];
    self.alertView.cancelButton.tag = tag;
    self.alertView.sureButton.tag = tag;
    
    [self.alertView.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView.sureButton addTarget:self action:@selector(sureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView.bgButton addTarget:self action:@selector(bgButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.alertView];
}

- (void)bgButtonAction:(UIButton *)sender {
    [self.alertView removeFromSuperview];
}

- (void)cancelButtonAction:(UIButton *)sender { //公开
    [self createShereUrlType:1 index:sender.tag];
}

- (void)sureButtonAction:(UIButton *)sender { //加密
    [self createShereUrlType:0 index:sender.tag];
}

- (void)createShereUrlType:(int)type index:(NSInteger)index { //创建分享链接
    
    TDBaseToolModel *toolModel = [[TDBaseToolModel alloc] init];
    if (![toolModel networkingState]) {
        [self.alertView removeFromSuperview];
        return;
    }
    
    [SVProgressHUD showWithStatus:TDLocalizeSelect(@"SKY_CREAT_WAIT", nil)];
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
    [params setValue:model.id forKey:@"cloud_file"];//分享文件的id
    [params setValue:expireStr forKey:@"expire_at"];//分享文件的时长。有7，1，0
    [params setValue:[NSString stringWithFormat:@"%d",type] forKey:@"type"];//0 加密，1 公开
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager shareManager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSString *authValue = [NSString stringWithFormat:@"%@", [OEXAuthentication authHeaderForApiAccess]];
    [manager.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];//安全验证
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/v0/netdisk/sharefile/",ELITEU_URL];
    
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [SVProgressHUD dismiss];
        [self.alertView removeFromSuperview];
        
        NSDictionary *responDic = (NSDictionary *)responseObject;
        
        id code = responDic[@"code"];
        if ([code intValue] == 20000) {
            NSDictionary *dataDic = responDic[@"data"];
            NSString *shareUrl = dataDic[@"share_url"];
            NSString *password = dataDic[@"password"];
            [self copyShareLink:shareUrl password:password];
        }
        else {
            [self.view makeToast:TDLocalizeSelect(@"SKY_FAIL_CREATE", nil) duration:1.08 position:CSToastPositionCenter];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self.alertView removeFromSuperview];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"分享链接创建失败----->> %@",error);
    }];
}

- (void)copyShareLink:(NSString *)linkStr password:(NSString *)passwordStr { //赋值分享链接
    
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    if (passwordStr.length > 0) {
        pasteBoard.string = [TDLocalizeSelect(@"SKY_LINK_PASSWORD", nil) oex_formatWithParameters:@{@"link":linkStr,@"password":passwordStr}];
    }
    else {
        pasteBoard.string = [TDLocalizeSelect(@"SKY_LINK", nil) oex_formatWithParameters:@{@"link":linkStr}];
    }
    
    [self.view makeToast:TDLocalizeSelect(@"SKY_URL_COPIED", nil) duration:1.08 position:CSToastPositionCenter];
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
    self.noDataView.messageLabel.text = TDLocalizeSelect(@"SKY_FOLDERS_EMPTY_TEXT", nil);
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



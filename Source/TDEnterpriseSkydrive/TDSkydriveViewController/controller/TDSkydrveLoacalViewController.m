//
//  TDSkydrveLoacalViewController.m
//  edX
//
//  Created by Elite Edu on 2018/6/11.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydrveLoacalViewController.h"
#import "TDLocalFileWebViewController.h"
#import "TDSkydriveVideoViewController.h"
#import "TDSkydriveAudioViewController.h"
#import "TDSkydriveNoSupportViewController.h"
#import "TDSkydriveImageViewController.h"

#import "TDSkydriveLocalView.h"

#import "TDSkydrveFileModel.h"

#import "TDDownloadOperation.h"
#import "edX-Swift.h"

@interface TDSkydrveLoacalViewController () <TDSkydriveSelectDelegate,TDDownloadOperationDelegate>

@property (nonatomic,strong) TDSkydriveLocalView *localView;

@property (nonatomic,strong) NSMutableArray *downloadingArray;
@property (nonatomic,strong) NSMutableArray *finishArray;
@property (nonatomic,strong) NSMutableArray *selectArray;

@property (nonatomic,strong) TDDownloadOperation *downloadOperation;

@property (nonatomic,strong) TDBaseToolModel *toolModel;

@end

@implementation TDSkydrveLoacalViewController

- (NSMutableArray *)downloadingArray {
    if (!_downloadingArray) {
        _downloadingArray = [[NSMutableArray alloc] init];
    }
    return _downloadingArray;
}

- (NSMutableArray *)finishArray {
    if (!_finishArray) {
        _finishArray = [[NSMutableArray alloc] init];
    }
    return _finishArray;
}

- (NSMutableArray *)selectArray {
    if (!_selectArray) {
        _selectArray = [[NSMutableArray alloc] init];
    }
    return _selectArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = TDLocalizeSelect(@"SKY_MANAGE_FILES_TEXT", nil);
    [self.rightButton setImage:[UIImage imageNamed:@"select_white_circle"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"select_blue_white_circle"] forState:UIControlStateSelected];
    [self setViewConstraint];
    
    self.toolModel = [[TDBaseToolModel alloc] init];
    
    self.downloadOperation = [TDDownloadOperation shareOperation];
    [self.downloadOperation backgroundURLSession];
    [self.downloadOperation sqliteOperationInit:self.username];
    self.downloadOperation.delegate = self;
    
    [self getLocalData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLocalData) name:@"noSupport_skydrive_delete_finish" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityNotReachableAction:) name:@"Network_Status_NotReachable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityReachableViaWWANAction:) name:@"Network_Status_ReachableViaWWAN" object:nil];
}

- (void)dealloc {
    NSLog(@" ---->>> ");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noSupport_skydrive_delete_finish" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Network_Status_NotReachable" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Network_Status_ReachableViaWWAN" object:nil];
}

- (void)getLocalData { //获取数据
    
    WS(weakSelf);
    [self.downloadOperation getLocalDownloadFileSortDataBlock:^(NSMutableArray *downloadArray, NSMutableArray *finishArray) {//查询本地数据库的数据
        weakSelf.downloadingArray = downloadArray;
        weakSelf.finishArray = finishArray;
        [weakSelf.localView reloadTableViewForDownload:self.downloadingArray finish:self.finishArray];
    }];
}

#pragma mark - TDDownloadOperationDelegate
- (void)currentFileDownloadFinish:(TDSkydrveFileModel *)currentModel { //下载完一个任务，刷新任务管理页
    
    for (int i = 0; i < self.downloadingArray.count; i ++) {
        
        TDSkydrveFileModel *model = self.downloadingArray[i];
        if ([model.id isEqualToString:currentModel.id]) {
            [self.downloadingArray removeObject:model];
        }
    }

    [self.finishArray addObject:currentModel];
    [self.localView reloadTableViewForDownload:self.downloadingArray finish:self.finishArray];
}

- (void)nextFileShouldBeginDownload { //有等待：下一个任务开始下载
    
    TDSkydrveFileModel *nextModel = [self judgHasWaitToDownloadTask];
    if (nextModel) {//有等待下载： 下一个
        nextModel.udpateLocal = YES;
        
        if (![self freeDiskSpaceEnounghInBytes:nextModel.real_file_size]) { //内存不足
            [self pauseAllDownloadFile:YES]; //所有任务暂停
        }
        else {
            [self currentModelDownloadOperation:nextModel];
            [self.downloadOperation nextFileBeginDownload:nextModel];
        }
        
        NSLog(@"下一个 -->> %@",nextModel.name);
    }
}

#pragma mark - 判断是否
- (BOOL)judgeHasDownloadingTask { //是否有下载中
    
    for (int i = 0; i < self.downloadingArray.count; i ++) {
        TDSkydrveFileModel *model = self.downloadingArray[i];
        
        if (model.status == 1) { //有文件在下载
            return YES;
        }
    }
    return NO; //无正在下载的文件
}

- (TDSkydrveFileModel *)judgHasWaitToDownloadTask { //是否有正在等待
    
    for (int i = 0; i < self.downloadingArray.count; i ++) {
        TDSkydrveFileModel *model = self.downloadingArray[i];
        
        if (model.status == 2) { //有文件在等待下载
            return model;
        }
    }
    return nil; //无正在等待下载的文件
}

#pragma mark - 全选
- (void)rightButtonAciton:(UIButton *)sender { //全选
    
    sender.selected = !sender.selected;
    self.localView.isAllSelect = sender.selected;
    
    [self.selectArray removeAllObjects];
    
    if (sender.selected) {
        [self.selectArray addObjectsFromArray:self.downloadingArray];
        [self.selectArray addObjectsFromArray:self.finishArray];
    }
}

#pragma mark - 底部按钮
- (void)editeButtonAction:(UIButton *)sender { //编辑
    self.rightButton.hidden = NO;
    [self.localView userEditingFile:YES];
    
    [self pauseAllDownloadFile:NO]; //不更新本地数据库
}

- (void)cancelButtonAction:(UIButton *)sender {//取消
    [self.selectArray removeAllObjects];
    [self finishEditeHandle];
}

- (void)deleteButtonAction:(UIButton *)sender {//删除
    if (self.selectArray.count == 0) {
        [self.view makeToast:@"请选择需要删除的文件" duration:1.08 position:CSToastPositionCenter];
        return;
    }
    [self deleteFileAlertView];
}

- (void)deleteFileAlertView {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认删除" message:@"是否删除当前所选文件？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    WS(weakSelf);
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf deleteSelectData];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)finishEditeHandle { //结束编辑
    
    self.rightButton.hidden = YES;
    self.rightButton.selected = NO;
    [self.localView userEditingFile:NO];
    
    [self continiuAllDownloadFile];//编辑结束后，恢复下载
}

- (void)deleteSelectData {//执行删除本地数据的操作
    
    if (self.selectArray.count == 0) {
        return;
    }
    
    NSLog(@"删除选中 -- %@",self.selectArray);
    
    WS(weakSelf);
    [self.downloadOperation deleteSelectLocalFile:self.selectArray handler:^(TDSkydrveFileModel *model, BOOL isFinish) { //删除数据
        
        if ([weakSelf.downloadingArray containsObject:model]) {
            [weakSelf.downloadingArray removeObject:model];
        }
        
        if ([weakSelf.finishArray containsObject:model]) {
            [weakSelf.finishArray removeObject:model];
        }
        
        if (isFinish) {
            [weakSelf.selectArray removeAllObjects];
            [weakSelf.localView reloadTableViewForDownload:self.downloadingArray finish:self.finishArray];
            
            [weakSelf.localView makeToast:@"已成功删除所选文件" duration:1.08 position:CSToastPositionCenter];
            
            [weakSelf finishEditeHandle];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"skydrive_delete_finish" object:nil];
        }
    }];
}

#pragma mark - TDSkydriveSelectDelegate
- (void)userClickFileRowModel:(TDSkydrveFileModel *)model { //点击下载
    
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
        case 1:{ //下载中 -> 暂停
            [self currentModelDownloadOperation:model];
            [self.downloadOperation pauseDownload:model]; //暂停(暂停完成后，判断是否有等待，有则下一个)
        }
            break;
        case 2: { //等待下载 -> 暂停
            [self.downloadOperation waitChageToPause:model];
        }
            break;
        case 3:{ //暂停
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
        case 4: {
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

- (void)userSelectFileRowAtIndexpath:(TDSkydrveFileModel *)model { //编辑选择
    
    if (model.isSelected) {
        [self.selectArray addObject:model];
    }
    else {
        [self.selectArray removeObject:model];
    }
    
    if (self.selectArray.count == self.downloadingArray.count + self.finishArray.count) {
        self.rightButton.selected = YES;
    }
    else {
        self.rightButton.selected = NO;
    }
}

- (void)userPreviewFileRowAtIndexpath:(NSIndexPath *)indexPath { //文件预览
    
    if (indexPath.section == 1) {
        TDSkydrveFileModel *model = self.finishArray[indexPath.row];
        
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
        
        NSLog(@"预览--%@ %ld - %@",model.name,(long)model.status,model.file_type_format);
    }
}

- (void)beginDownloadFileModel:(TDSkydrveFileModel *)model firstAdd:(BOOL)isFirst {
    
    if (![self.toolModel networkingState]) {
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
    
    UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:nil message:TDLocalizeSelect(@"SKY_CELLULAR_CONNECTION_TEXT", nil)  preferredStyle:UIAlertControllerStyleAlert];
    
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
        [weakSelf continiuAllDownloadFile]; //恢复下载
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
        
//        NSLog(@"存储空间 ----->>> %lf - %lf",freeSize,fileSize);
        
        if (fileSize > freeSize) {
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

#pragma mark - 网络变化
- (void)reachabilityNotReachableAction:(NSNotification *)notification {//没网
    
    NSLog(@"--->> 网络信号不好");
    
    WS(weakSelf);
    [self.downloadOperation getLocalDownloadFileSortDataBlock:^(NSMutableArray *downloadArray, NSMutableArray *finishArray) {
        
        for (int i = 0; i < downloadArray.count; i ++) {
            TDSkydrveFileModel *model = downloadArray[i];
            model.udpateLocal = YES; //更新本地数据库
            
            if (model.status == 1) { // -> 暂停
                [weakSelf currentModelDownloadOperation:model];
                [weakSelf.downloadOperation pauseDownload:model];
            }
            else if (model.status == 2) { //等待 -> 暂停
                [weakSelf.downloadOperation waitChageToPause:model];
            }
        }
        
        [weakSelf getLocalData];//再查询一次数据
    }];
}

- (void)reachabilityReachableViaWWANAction:(NSNotification *)notification {//只允许wifi下载情况下，切换到移动网络
    
    [self pauseAllDownloadFile:NO]; //不更新本地数据库
    [self wifiOnlyAlertViewShow];
}

- (void)pauseAllDownloadFile:(BOOL)updateLocal { //暂停 - updateLocal: 是否更新本地数据库
    
    WS(weakSelf);
    [self.downloadOperation getLocalDownloadFileSortDataBlock:^(NSMutableArray *downloadArray, NSMutableArray *finishArray) {
        
        for (int i = 0; i < downloadArray.count; i ++) {
            
            TDSkydrveFileModel *model = downloadArray[i];
            model.udpateLocal = updateLocal; //是否更新本地数据库
            
            if (model.status == 1 || model.status == 2) { // -> 暂停
                
                [weakSelf.downloadOperation waitChageToPause:model];
                
                [weakSelf currentModelDownloadOperation:model];
                [weakSelf.downloadOperation pauseDownload:model];
                
            }
        }
    }];
}

- (void)continiuAllDownloadFile { //继续 （恢复下载）
    
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


#pragma mark - 文件浏览/播放
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

#pragma mark - UI
- (void)setViewConstraint {
    
    self.localView = [[TDSkydriveLocalView alloc] init];
    self.localView.delegate = self;
    [self.localView.editeButton addTarget:self action:@selector(editeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.localView.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.localView.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.localView];
    
    [self.localView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

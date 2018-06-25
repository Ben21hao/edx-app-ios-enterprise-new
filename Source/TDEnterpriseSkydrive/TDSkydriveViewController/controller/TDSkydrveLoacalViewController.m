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

#import "TDSkydriveSqliteOperation.h"

@interface TDSkydrveLoacalViewController () <TDSkydriveSelectDelegate>

@property (nonatomic,strong) TDSkydriveLocalView *localView;

@property (nonatomic,strong) NSMutableArray *downloadingArray;
@property (nonatomic,strong) NSMutableArray *finishArray;
@property (nonatomic,strong) NSMutableArray *selectArray;

@property (nonatomic,strong) TDSkydriveSqliteOperation *sqliteOperation;

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
    
    self.titleViewLabel.text = @"文件管理";
    [self.rightButton setImage:[UIImage imageNamed:@"select_white_circle"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"select_blue_white_circle"] forState:UIControlStateSelected];
    [self setViewConstraint];
    
    self.sqliteOperation = [[TDSkydriveSqliteOperation alloc] init];
    [self.sqliteOperation createSqliteForUser:self.username];
    
//    [self hhhh];
    
    WS(weakSelf);
    [self.sqliteOperation querySqliteSortData:^(NSMutableArray *downloadArray, NSMutableArray *finishArray) { //查询本地数据
        weakSelf.downloadingArray = downloadArray;
        weakSelf.finishArray = finishArray;
        [weakSelf.localView reloadTableViewForDownload:downloadArray finish:finishArray];
    }];
}

- (void)hhhh {
    
    TDSkydrveFileModel *model = [[TDSkydrveFileModel alloc] init];
    model.name = @"1蓝卡队华法林惊世毒妃答复按时发大发发阿萨德法师法发大水";
    model.file_size = @"88M";
    model.type = @"1";
    model.file_type = @"jpg";
    model.resources_url = @"https://bss.eliteu.cn/oss_media/15ec0c3e-51d7-11e8-9c53-52540059267e";
    model.created_at = @"2018-88-88 99-88";
    model.download_size = @"28M";
    model.progress = 18.8;
    
    for (int i = 0; i < 9; i ++) {
        model.id = [NSString stringWithFormat:@"8_文件id_%d",i];;
        
        if (i > 5) {
            model.status = 5;
            model.file_type_format = @"5";
        }
        else {
            model.status = i;
            model.file_type_format = [NSString stringWithFormat:@"%d",i];
        }
        
        [self.sqliteOperation insertFileData:model];
    }
}

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
}

- (void)cancelButtonAction:(UIButton *)sender {//取消
    [self.selectArray removeAllObjects];
    [self finishEditeHandle];
}

- (void)deleteButtonAction:(UIButton *)sender {//删除
    [self deleteFileAlertView];
}

- (void)deleteFileAlertView {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认删除" message:@"是否删除当前所选文件？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    WS(weakSelf);
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf deleteSelectData];
        
        //移除选择
        [weakSelf finishEditeHandle];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)finishEditeHandle { //结束编辑
    self.rightButton.hidden = YES;
    self.rightButton.selected = NO;
    [self.localView userEditingFile:NO];
}

- (void)deleteSelectData {//执行删除本地数据的操作
    
    if (self.selectArray.count == 0) {
        return;
    }
    
    NSLog(@"删除选中 -- %@",self.selectArray);
    //删除数据
    WS(weakSelf);
    [self.sqliteOperation deleteFileArray:self.selectArray handler:^(TDSkydrveFileModel *model, BOOL isFinish) {
        
        if ([weakSelf.downloadingArray containsObject:model]) {
            [weakSelf.downloadingArray removeObject:model];
        }
        
        if ([weakSelf.finishArray containsObject:model]) {
            [weakSelf.finishArray removeObject:model];
        }
        
        if (isFinish) {
            [weakSelf.selectArray removeAllObjects];
            [weakSelf.localView reloadTableViewForDownload:self.downloadingArray finish:self.finishArray];
        }
    }];
}

#pragma mark - TDSkydriveSelectDelegate
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

- (void)userPreviewFileRowAtIndexpath:(NSIndexPath *)indexPath { //预览
    
    NSLog(@"预览--row %ld",indexPath.row);
    if (indexPath.section == 1) {
        
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
    
    NSLog(@"文件路径------->> %@",filePath);
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

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

#import "TDSkydriveLocalView.h"

@interface TDSkydrveLoacalViewController () <TDSkydriveSelectDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDSkydriveLocalView *localView;

@end

@implementation TDSkydrveLoacalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = @"文件管理";
    [self.rightButton setImage:[UIImage imageNamed:@"select_white_circle"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"select_blue_white_circle"] forState:UIControlStateSelected];
    [self setViewConstraint];
}

- (void)rightButtonAciton:(UIButton *)sender { //全选
    
    sender.selected = !sender.selected;
    self.localView.isAllSelect = sender.selected;
}

#pragma mark - 底部按钮
- (void)editeButtonAction:(UIButton *)sender { //编辑
    self.rightButton.hidden = NO;
    [self.localView userEditingFile:YES];
}

- (void)cancelButtonAction:(UIButton *)sender {//取消
    self.rightButton.hidden = YES;
    [self.localView userEditingFile:NO];
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
        weakSelf.rightButton.hidden = YES;
        [weakSelf.localView userEditingFile:NO];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - TDSkydriveSelectDelegate
- (void)userSelectFileRowAtIndexpath:(NSIndexPath *)indexPath { //编辑选择
    NSLog(@"选择 --section %ld --row %ld",indexPath.section,indexPath.row);
}

- (void)userPreviewFileRowAtIndexpath:(NSIndexPath *)indexPath { //预览
    
    NSLog(@"预览--row %ld",indexPath.row);
    
    if (indexPath.section == 1) {
        [self gotoNoSupportVc:@"不支持文件的预览" path:@"user/12345678.otf"];//不支持预览的文件
    }
}

#pragma mark - 文件预览/播放
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

- (void)gotoNoSupportVc:(NSString *)titleStr path:(NSString *)pathStr {
    
    TDSkydriveNoSupportViewController *noSupportVc = [[TDSkydriveNoSupportViewController alloc] init];
    noSupportVc.titleStr = titleStr;
    noSupportVc.filePath = pathStr;
    [self.navigationController pushViewController:noSupportVc animated:YES];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.localView = [[TDSkydriveLocalView alloc] init];
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

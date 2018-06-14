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
#import "OEXAuthentication.h"

#import "TDNodataView.h"
#import "TDSkydriveAlertView.h"
#import "TDSkydriveFolderCell.h"
#import "TDSkydriveFileCell.h"

@interface TDSkydriveFileViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDNodataView *noDataView;
@property (nonatomic,strong) TDSkydriveAlertView *alertView;

@end

@implementation TDSkydriveFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = self.folderName;
    self.rightButton.hidden = NO;
    [self.rightButton setImage:[UIImage imageNamed:@"file_download_image"] forState:UIControlStateNormal];
    
    [self setViewConstraint];
}

- (void)rightButtonAciton:(UIButton *)sender {
    
    [self gotoLocalVc];
}

#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        TDSkydriveFolderCell *cell = [[TDSkydriveFolderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SkydriveFolderCell"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.timeLabel.text = @"2018-01-18 18:28";
        cell.titleLabel.text = @"二级文件夹二级文件夹二级文件夹二级文件夹二级文件夹二级文件夹二级文件夹二级文件夹二级文件夹二级文件夹二级文件夹";
        
        return cell;
    }
    else {
        TDSkydriveFileCell *cell = [[TDSkydriveFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SkydriveFileCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell.downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.titleLabel.text = @"技术部pdf技术部pdf技术部pdf技术部pdf技术部pdf技术部pdf技术部pdf技术部pdf技术部pdf技术部pdf技术部.pdf";
        cell.timeLabel.text = @"2018-01-18 18:28";
        cell.sizeLabel.text = @"200MB";
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self gotoFileVc]; //下一级目录
    }
    else {
        [self systemActivity];
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
    [self createShereUrlType:1];
}

- (void)sureButtonAction:(UIButton *)sender { //加密
    [self createShereUrlType:0];
}

- (void)createShereUrlType:(int)type { //创建分享链接
    
    TDBaseToolModel *toolModel = [[TDBaseToolModel alloc] init];
    if (![toolModel networkingState]) {
        [self.alertView removeFromSuperview];
        return;
    }
    
    NSString *expireStr = @"0";
    if (self.alertView.timeType == TDSkydriveShareTimeOneDay) {
        expireStr = @"1";
    }
    else if (self.alertView.timeType == TDSkydriveShareTimeSevenDay) {
        expireStr = @"7";
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:expireStr forKey:@"expire_at"];//分享文件的时长。有7，1，0
    [params setValue:@"1" forKey:@"cloud_file"];//分享文件的id
    [params setValue:@"0" forKey:@"type"];//0 加密，1 公开
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager shareManager];
//    NSString *authValue = [NSString stringWithFormat:@"%@", [OEXAuthentication authHeaderForApiAccess]];
    NSString *authValue = @"Bearer 78d6cba9078f91bfe8ee7c3146154b475d7a6c78";
    [manager.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];//安全验证
    
    NSString *url = @"http://sodaling.ngrok.elitemc.cn:8000/api/mobile/v0/sharefile/";
    
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.alertView removeFromSuperview];
        
        NSDictionary *responDic = (NSDictionary *)responseObject;
        NSLog(@"----->> %@",responDic);
        
        [self copyShareLink:@"www.baidu.com" password:@"123456"];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.alertView removeFromSuperview];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"分享链接创建失败----->> %@",error);
    }];
}

- (void)copyShareLink:(NSString *)linkStr password:(NSString *)passwordStr { //赋值分享链接
    
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = [NSString stringWithFormat:@"链接：%@\n密码：%@",linkStr,passwordStr];
    
    [self.view makeToast:@"外链地址已经复制到剪切板中！" duration:0.8 position:CSToastPositionCenter];
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
    [self.navigationController pushViewController:fileVc animated:YES];
}

- (void)systemActivity { //系统分享
    
//    UIImage *image = [UIImage imageNamed:@"tubiao"];
    NSURL *url = [NSURL URLWithString:@"https://www.jianshu.com/p/d500fb72a079"];
    
    NSArray *itemArray = @[@"文件分享",@"文件名字",url];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:itemArray applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
    activityController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        
        if (completed) {//成功
            NSLog(@"---->> 分享成功");
        }
        else {
            NSLog(@"---->> 分享失败");
        }
    };
    [self presentViewController:activityController animated:YES completion:nil];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end

//
//  TDEnterpriseSkydriveViewController.m
//  edX
//
//  Created by Elite Edu on 2018/6/6.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDEnterpriseSkydriveViewController.h"
#import "TDSkydriveFileViewController.h"
#import "TDVideoViewController.h"
#import "TDSkydrveLoacalViewController.h"

#import "TDSkydriveFolderCell.h"
#import "TDSkydriveLocalCell.h"
#import "TDSkydriveFolderHeaderView.h"
#import "TDNodataView.h"
#import "TDBaseView.h"
#import "TDSkydrveFileModel.h"

#import "TDReachabilityManager.h"
#import "OEXAuthentication.h"
#import "edX-Swift.h"

#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>

#include <sys/param.h>
#include <sys/mount.h>

@interface TDEnterpriseSkydriveViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDNodataView *noDataView;
@property (nonatomic,strong) TDBaseView *loadingView;

@property (nonatomic,strong) NSMutableArray *dataArray;

@property (nonatomic,strong) TDBaseToolModel *toolModel;
@property (nonatomic,assign) BOOL isForgound;

@end

@implementation TDEnterpriseSkydriveViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = TDLocalizeSelect(@"ENTERPRISE_SKYDRIVE", nil);
    
    self.toolModel = [[TDBaseToolModel alloc] init];
    self.isForgound = YES;
    [self setViewConstraint];
    
    [TDReachabilityManager startReachability];//网络开始检测
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isForgound) {
        
        self.loadingView = [[TDBaseView alloc] initWithLoadingFrame:CGRectMake(0, 0, TDWidth, TDHeight - BAR_ALL_HEIHT)];
        [self.view addSubview:self.loadingView];
        
        [self requestData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.isForgound = NO;
    
}

#pragma mark - data
- (void)requestData {
    
    if (![self.toolModel networkingState]) {
        [self endRequestHandle];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager shareManager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer]; 
    NSString *authenStr = [OEXAuthentication authHeaderForApiAccess];
    [manager.requestSerializer setValue:authenStr forHTTPHeaderField:@"Authorization"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.username forKey:@"username"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/v0/netdisk/cloud_file/",ELITEU_URL];
    
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self endRequestHandle];
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        
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
                        [self.dataArray addObject:model];
                    }
                }
            }
            else {
                [self nodataViewReason:TDLocalizeSelect(@"SKY_ELITEU_ENPTY_TEXT", nil)];
            }
            [self.tableView reloadData];
        }
        else if ([code intValue] == 203) {//没有用户
            [self accountInvalidUser];
        }
        else {
            [self nodataViewReason:TDLocalizeSelect(@"SKY_REQUEST_FAILED", nil)];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self endRequestHandle];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"企业网盘首页错误----->> %@",error);
    }];
}

- (void)endRequestHandle {
    [self.loadingView removeFromSuperview];
    [self.tableView.mj_header endRefreshing];
}

- (void)nodataViewReason:(NSString *)reasonStr {
    self.noDataView.hidden = NO;
    self.noDataView.messageLabel.text = reasonStr;
}

- (void)accountInvalidUser {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TDLocalizeSelect(@"SYSTEM_WARING", nil) message:TDLocalizeSelect(@"SKY_ACCOUNT_ERROR", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"LOGOUT", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[OEXRouter sharedRouter] logoutAction];
    }];
    
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else {
        return self.dataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        TDSkydriveLocalCell *cell = [[TDSkydriveLocalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"enterpriseSkydriveCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.titleLabel.text = TDLocalizeSelect(@"SKY_MANAGE_FILES_TEXT", nil);
        
        return cell;
    }
    else {
        
        TDSkydrveFileModel *model = self.dataArray[indexPath.row];
        
        TDSkydriveFolderCell *cell = [[TDSkydriveFolderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"enterpriseSkydriveCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.fileModel = model;
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    TDSkydriveFolderHeaderView *headerView = [[TDSkydriveFolderHeaderView alloc] initWithReuseIdentifier:@"skydriveFolderHeaderView"];
    headerView.titleLabel.text = TDLocalizeSelect(@"SKY_CLOUND_FOULDERS_TEXT", nil);
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0;
    }
    
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //xls，xlsx，pdf，pptx，ppt，docx，rtf, txt
    if (indexPath.section == 0) {
        [self gotoLocalVc];
    }
    else {
        TDSkydrveFileModel *model = self.dataArray[indexPath.row];
        [self gotoFolderView:model.name folderId:model.id];
    }
}

- (void)gotoFolderView:(NSString *)folderName folderId:(NSString *)folderId {//子文件夹
    
    TDSkydriveFileViewController *skydriveFileVc = [[TDSkydriveFileViewController alloc] init];
    skydriveFileVc.username = self.username;
    skydriveFileVc.folderName = folderName;
    skydriveFileVc.folderID = folderId;
    [self.navigationController pushViewController:skydriveFileVc animated:YES];
}

- (void)gotoLocalVc { //文件管理
    
    TDSkydrveLoacalViewController *localVc = [[TDSkydrveLoacalViewController alloc] init];
    localVc.username = self.username;
    [self.navigationController pushViewController:localVc animated:YES];
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
    
    self.noDataView = [[TDNodataView alloc] init];
    self.noDataView.imageView.image = [UIImage imageNamed:@"file_null_image"];
    self.noDataView.messageLabel.text = TDLocalizeSelect(@"SKY_ELITEU_ENPTY_TEXT", nil);
    [self.tableView addSubview:self.noDataView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tableView);
        make.top.mas_equalTo(self.tableView.mas_top).offset(116);
        make.size.mas_equalTo(CGSizeMake(TDWidth, TDHeight - 116 - BAR_ALL_HEIHT));
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

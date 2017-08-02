//
//  TDLiveSubViewController.m
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDLiveSubViewController.h"
#import "WatchPlayBackViewController.h"
#import "WatchLiveViewController.h"

#import "TDLiveMessageCell.h"
#import "TDLiveBottomCell.h"

#import "TDLiveModel.h"

#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>

@interface TDLiveSubViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDBaseView *loadingView;

@property (nonatomic,strong) UILabel *nonDataLabel;

@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation TDLiveSubViewController

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.whereFrom == 0 ? NSLocalizedString(@"UPCOMING_TITLE_TEXT", nil) : NSLocalizedString(@"FINISHED_TITLE_TEXT", nil);
    
    [self setViewConstaint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.loadingView = [[TDBaseView alloc] initWithLoadingFrame:self.view.bounds];
    [self.view addSubview:self.loadingView];
    
    DEMO_Setting.activityID = @"780567811";
    
    [self getData];
}

#pragma mark - data
- (void)getData {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.username forKey:@"username"];
    [dic setValue:@(1) forKey:@"status"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/live/%@",ELITEU_URL,self.username];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.loadingView removeFromSuperview];
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        if ([code intValue] == 200) {
            
            NSArray *dataArray = responseDic[@"data"];
            if (dataArray.count > 0) {
                
                for (int i = 0; i < dataArray.count; i ++) {
                    TDLiveModel *model = [TDLiveModel mj_objectWithKeyValues:dataArray[i]];
                    if (model) {
                        [self.dataArray addObject:model];
                    }
                }
                [self.tableView reloadData];
                
            } else {
                
            }
            
        } else {
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.loadingView removeFromSuperview];
        [self.view makeToast:NSLocalizedString(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"error ---- %@",error);
    }];
    
    TDLiveModel *model = [[TDLiveModel alloc] init];
    model.live_start_at = @"2017-07-12T15:00:00Z";
    model.livename = @"测试直播";
    model.anchor = @"我我我我";
    model.live_introduction = @"测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦测试一下直播哦";
    model.time = @"100";
    [self.dataArray addObject:model];

}

#pragma mark - 进入讲座
- (void)enterButtonAction:(UIButton *)sender {
    [self loginVhLiveAccount:0];
}

- (void)gotoWatchLiveVC {//观看讲座
    
    WatchLiveViewController * watchVC  =[[WatchLiveViewController alloc]init];
    watchVC.roomId = DEMO_Setting.activityID; //活动id
    watchVC.kValue = DEMO_Setting.kValue;
    watchVC.bufferTimes = DEMO_Setting.bufferTimes;
    [self presentViewController:watchVC animated:YES completion:nil];
}

#pragma mark - 做习题
- (void)praticeButtonAction:(UIButton *)sender {
    
}

#pragma mark - 观看回放
- (void)playButtonAction:(UIButton *)sender {
    
    [self loginVhLiveAccount:1];
}

- (void)gotoWatchPlayBackVideo {//观看回放
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    WatchPlayBackViewController *watchVC  =[[WatchPlayBackViewController alloc]init];
    watchVC.roomId = DEMO_Setting.activityID; //活动id
    watchVC.kValue = DEMO_Setting.kValue;
//    watchVC.detailStr =
    [self presentViewController:watchVC animated:YES completion:nil];
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)loginVhLiveAccount:(NSInteger)type { //登录威吼
    
    DEMO_Setting.account  = @"13800138002";
    DEMO_Setting.password = @"123456";
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    __weak typeof(self) weekself = self;
    [VHallApi loginWithAccount:DEMO_Setting.account password:DEMO_Setting.password success:^{
        
        [MBProgressHUD hideAllHUDsForView:weekself.view animated:YES];
        
        type == 0 ? [weekself gotoWatchLiveVC] : [weekself gotoWatchPlayBackVideo];
        
        VHLog(@"Account: %@ userID:%@",[VHallApi currentAccount],[VHallApi currentUserID]);
        [weekself showMsg:NSLocalizedString(@"ENTER_SUCCESSFUL", nil) afterDelay:1.5];
        
    } failure:^(NSError * error) {
        VHLog(@"登录失败%@",error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:weekself.view animated:YES];
            [weekself showMsg:error.domain afterDelay:1.5];
        });
    }];
}

- (void)showMsg:(NSString*)msg afterDelay:(NSTimeInterval)delay {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = msg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:delay];
}

#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.nonDataLabel.hidden = self.dataArray.count != 0;
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TDLiveModel *model = self.dataArray[indexPath.section];
    
    if (indexPath.row == 0) {
        TDLiveMessageCell *cell = [[TDLiveMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDLiveMessageCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.whereFrom = self.whereFrom;
        cell.model = model;
        
        return cell;
        
    } else {
        TDLiveBottomCell *cell = [[TDLiveBottomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDLiveBottomCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.whereFrom = self.whereFrom;
        cell.model = model;
        
        [cell.enterButton addTarget:self action:@selector(enterButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.praticeButton addTarget:self action:@selector(praticeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return TDWidth * 0.33 + 98;
    } else {
        return 53;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

#pragma mark - UI
- (void)setViewConstaint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    self.nonDataLabel = [[UILabel alloc] init];
    self.nonDataLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.nonDataLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    self.nonDataLabel.textAlignment = NSTextAlignmentCenter;
    self.nonDataLabel.text = NSLocalizedString(@"NO_LIVE_LECTURE_TEXT", nil);
    [self.tableView addSubview:self.nonDataLabel];
    
    [self.nonDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.tableView.center);
    }];
    self.nonDataLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

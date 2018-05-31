//
//  TDSubMyQuentionViewController.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDSubMyQuentionViewController.h"
#import "TDConsultCell.h"

#import "TDMyConsultModel.h"
#import "TDConsultDetailViewController.h"

#import <MJRefresh/MJRefresh.h>
#import <MJExtension/MJExtension.h>
#import "NSString+OEXFormatting.h"

@interface TDSubMyQuentionViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UILabel *nullLabel;

@property (nonatomic,strong) NSMutableArray *quetionArray;
@property (nonatomic,assign) BOOL isForgound;
@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) TDBaseToolModel *baseTool;
@property (nonatomic,assign) NSInteger noReadNum;

@end

@implementation TDSubMyQuentionViewController


- (NSMutableArray *)quetionArray {
    if (!_quetionArray) {
        _quetionArray = [[NSMutableArray alloc] init];
    }
    return _quetionArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isForgound = YES;
    self.page = 1;
    self.baseTool = [[TDBaseToolModel alloc] init];
    
    [self setViewContraint];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quetionDataReload:) name:@"quetion_sure_solved_notification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quetionDataReload:) name:@"new_quetion_handin_notification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isForgound) {
        [self setLoadDataView];
        [self headerRefreshData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.isForgound = NO;
}

- (void)quetionDataReload:(NSNotification *)notifi { //刷新数据
    
    [self headerRefreshData];
}

- (void)headerRefreshData { //下拉刷新
    self.page = 1;
    [self getSubQuetionData];
}

- (void)footerLoadMoreData { //上拉加载
    [self getSubQuetionData];
}

- (void)getSubQuetionData { //数据
    
    if (![self.baseTool networkingState]) {//网络监测
        [self hiddenFooterView];
        [self endRefresh];
        [self showNullLabel:TDLocalizeSelect(@"QUERY_FAILED", nil)];
        return;
    }
    
    self.nullLabel.hidden = YES;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.username forKey:@"username"];
    [params setValue:@(self.whereFrom) forKey:@"is_solve"];
    
    [params setValue:@(self.page) forKey:@"pageindex"];
    [params setValue:@"8" forKey:@"pagesize"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/get_myconsultmessage/",ELITEU_URL];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager shareManager];
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self endRefresh];
        
        if (self.page == 1) {
            [self.quetionArray removeAllObjects];
            [self.tableView reloadData];
        }
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        int code = [responseDic[@"code"] intValue];
        
        if (code == 200) {
            NSArray *dataArray = responseDic[@"data"];
            
            if (dataArray.count < 8) {
                [self hiddenFooterView];
                
            } else {
                
                if (self.page == 1) {
                    [self.tableView.mj_footer resetNoMoreData];
                    self.tableView.mj_footer.hidden = NO;
                }
                self.page ++;
            }
            
            if (dataArray.count > 0) {
                for (int i = 0; i < dataArray.count; i ++) {
                    
                    NSDictionary *itemDic = dataArray[i];
                    TDMyConsultModel *model = [TDMyConsultModel mj_objectWithKeyValues:itemDic];
                    if (model) {
//                        if (self.whereFrom == TDSubQuetionFromSolved) {
//                            model.status.consult_status = @"5";
//                        }
                        [self.quetionArray addObject:model];
                    }
                }
                
            } else {
                if (self.page > 1) {
                    [self.view makeToast:TDLocalizeSelect(@"NO_MORE_DATA", nil) duration:0.8 position:CSToastPositionCenter];
                }
            }
            
            self.noReadNum = [responseDic[@"extra_data"][@"not_read_num"] integerValue];
            
            if (self.page == 1) {
                [self showNullLabel:self.whereFrom == 0 ?  TDLocalizeSelect(@"NO_UNSOLVED_CONSULTS", nil) : TDLocalizeSelect(@"NO_SOLVED_CONSULTS", nil)];
            }
            [self.tableView reloadData];
            
        } else if (code == 311) { //用户未关联企业
            [self hiddenFooterView];
            [self showNullLabel:TDLocalizeSelect(@"STUDENT_NO_LINKE_ORGANIZATION", nil)];
            
        } else if (code == 312) { //用户不存在
            [self hiddenFooterView];
            [self showNullLabel:TDLocalizeSelect(@"NO_EXIST_USER", nil)];
            
        } else if (code == 313) { //用户不属于任何公司
            [self hiddenFooterView];
            [self showNullLabel:TDLocalizeSelect(@"STUDENT_NO_LINKE_ORGANIZATION", nil)];
            
        } else { //查询失败
            [self hiddenFooterView];
            [self showNullLabel:TDLocalizeSelect(@"QUERY_FAILED", nil)];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"我的咨询 ---->>> %@",error);
        [self endRefresh];
        [self hiddenFooterView];
        [self showNullLabel:TDLocalizeSelect(@"QUERY_FAILED", nil)];
    }];
}

- (void)hiddenFooterView {
    self.tableView.mj_footer.hidden = YES;
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}

- (void)endRefresh {
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    
    [self.loadIngView removeFromSuperview];
}

- (void)showNullLabel:(NSString *)titleStr {

    self.nullLabel.hidden = self.quetionArray.count > 0;
    self.nullLabel.text = titleStr;
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.quetionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    TDMyConsultModel *model = self.quetionArray[indexPath.section];
    TDConsultCell *cell = [[TDConsultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDConsultCell"];
    
    cell.consultModel = model;
    cell.whereFrom = self.whereFrom == TDSubQuetionFromUnsolved ? 0 : 1;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 73;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    

    [self gotoDetailVc:indexPath.section];
}

- (void)gotoDetailVc:(NSInteger)section  {
    
    TDMyConsultModel *model = self.quetionArray[section];
    
    BOOL hasNoRead = NO;
    NSInteger noreadNum = [model.status.num_of_unread integerValue];
    if ([model.status.num_of_unread integerValue] > 0) {
        self.noReadNum -= noreadNum;
        
        if (self.noReadNum <= 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Consult_Data_Change" object:nil]; //刷新个人资料
        }
        hasNoRead = YES;
    }
    
    TDConsultDetailViewController *consultVc = [[TDConsultDetailViewController alloc] init];
    consultVc.whereFrom = self.whereFrom == TDSubQuetionFromUnsolved ? TDConsultDetailFromUserUnSolve : TDConsultDetailFromUserSolve;
    consultVc.consultID = model.consult_id;
    consultVc.username = self.username;
    consultVc.hasNoRead = hasNoRead;
    
    if ([model.status.consult_status intValue] == 2 || [model.status.consult_status intValue] == 4) { //2 xx条未读消息，4 已回复
        WS(weakSelf);
        consultVc.reloadUserConsultStatus = ^(NSString *consult_status){
            model.status.consult_status = consult_status;
            model.status.num_of_unread = @"0";
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        };
    }
    
    [self.navigationController pushViewController:consultVc animated:YES];
}

#pragma mark - UI
- (void)setViewContraint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshData)];
    header.lastUpdatedTimeLabel.hidden = YES; //隐藏时间
    [header setTitle:TDLocalizeSelect(@"DROP_REFRESH_TEXT", nil) forState:MJRefreshStateIdle];
    [header setTitle:TDLocalizeSelect(@"RELEASE_REFRESH_TEXT", nil) forState:MJRefreshStatePulling];
    [header setTitle:TDLocalizeSelect(@"REFRESHING_TEXT", nil) forState:MJRefreshStateRefreshing];
    self.tableView.mj_header = header;
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerLoadMoreData)];
    [footer setTitle:TDLocalizeSelect(@"LOADING_TEXT", nil) forState:MJRefreshStateRefreshing];
    [footer setTitle:TDLocalizeSelect(@"LOADED_ALL_TEXT", nil) forState:MJRefreshStateNoMoreData];
    [footer setTitle:TDLocalizeSelect(@"CLICK_PULL_LOAD_MORE", nil) forState:MJRefreshStateIdle];
    self.tableView.mj_footer = footer;
    
    self.nullLabel = [[UILabel alloc] init];
    self.nullLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.nullLabel.textAlignment = NSTextAlignmentCenter;
    self.nullLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    [self.tableView addSubview:self.nullLabel];
    
    [self.nullLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.tableView);
    }];
    
    self.nullLabel.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

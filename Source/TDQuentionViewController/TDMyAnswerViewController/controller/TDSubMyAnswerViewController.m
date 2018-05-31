//
//  TDSubMyAnswerViewController.m
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSubMyAnswerViewController.h"

#import "TDConsultDetailViewController.h"

#import "TDQuentionMessageCell.h"

#import "TDMyAnswerModel.h"

#import <MJRefresh/MJRefresh.h>
#import <MJExtension/MJExtension.h>

@interface TDSubMyAnswerViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UILabel *nullLabel;

@property (nonatomic,strong) NSMutableArray *quetionArray;
@property (nonatomic,assign) BOOL isForgound;
@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) TDBaseToolModel *baseTool;

@end

@implementation TDSubMyAnswerViewController

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
    
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/get_consultmessage/",ELITEU_URL];
    
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
                    TDMyAnswerModel *model = [TDMyAnswerModel mj_objectWithKeyValues:itemDic];
                    if (model) {
                        [self.quetionArray addObject:model];
                    }
                }
                
            } else {
                if (self.page > 1) {
                    [self.view makeToast:TDLocalizeSelect(@"NO_MORE_DATA", nil) duration:0.8 position:CSToastPositionCenter];
                }
            }
            
            if (self.page == 1) {
                [self showNullLabel:self.whereFrom == 0 ? TDLocalizeSelect(@"NO_UNSOLVED_CONSULTS", nil) : TDLocalizeSelect(@"NO_SOLVED_CONSULTS", nil)];
            }
            [self.tableView reloadData];
            
        }
        else if (code == 311) { //用户未关联企业
            [self hiddenFooterView];
            [self showNullLabel:TDLocalizeSelect(@"STUDENT_NO_LINKE_ORGANIZATION", nil)];
            
        }
        else if (code == 312) { //用户不存在
            [self hiddenFooterView];
            [self showNullLabel:TDLocalizeSelect(@"NO_EXIST_USER", nil)];
            
        }
        else if (code == 313) { //用户不属于任何公司
            
            [self hiddenFooterView];
            [self showNullLabel:TDLocalizeSelect(@"STUDENT_NO_LINKE_ORGANIZATION", nil)];
            
        }
        else if (code == 313) { //用户不属于任何公司
            
            [self hiddenFooterView];
            [self showNullLabel:TDLocalizeSelect(@"STUDENT_NO_LINKE_ORGANIZATION", nil)];
            
        }
        else {
            [self hiddenFooterView];
            [self showNullLabel:TDLocalizeSelect(@"QUERY_FAILED", nil)];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"我的回答 ---->>> %@",error);
        [self hiddenFooterView];
        [self endRefresh];
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
    
    TDMyAnswerModel *model = self.quetionArray[indexPath.section];
    TDQuentionMessageCell *cell = [[TDQuentionMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDQuentionMessageCell"];
    cell.model = model;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 98;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    [self gotoDetailVc:indexPath.section];
}

- (void)gotoDetailVc:(NSInteger)section {
    
    TDMyAnswerModel *model = self.quetionArray[section];
    
    int status = [model.status.consult_status intValue];
    TDContactConsultStatus consultStatus = TDContactConsultStatusWaitReply;
    
    if (self.whereFrom == TDSubAnswerFromUnsolved) {
        if (status == 1 || status == 3) {
            consultStatus = TDContactConsultStatusWaitReply;
        }
        else if (status == 2 || status == 4 || status == 7) {
            consultStatus = TDContactConsultStatusReplying;
        }
        else if (status == 5 || status == 6 || status == 8) {
            consultStatus = TDContactConsultStatusOtherReplying;
        }
    }
    else { //已解决
        if (status == 9 || status == 10) {
            consultStatus = TDContactConsultStatusSolved;
        } else {
            consultStatus = TDContactConsultStatusUserGiveUp;
        }
    }
    
    TDConsultDetailViewController *consultVc = [[TDConsultDetailViewController alloc] init];
    consultVc.whereFrom = self.whereFrom == TDSubAnswerFromUnsolved ? TDConsultDetailFromContactUnSolve : TDConsultDetailFromContactSolve;
    consultVc.consultStatus = consultStatus;
    consultVc.consultID = model.consult_id;
    consultVc.username = self.username;
    consultVc.userId = self.userId;
    WS(weakSelf);
    consultVc.reloadUserConsultStatus = ^(NSString *consult_status){
        model.status.consult_status = consult_status;
        [weakSelf.tableView reloadSections:[NSIndexSet  indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    };
    
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

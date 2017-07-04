//
//  TDLiveSubViewController.m
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDLiveSubViewController.h"
#import "TDLiveMessageCell.h"
#import "TDLiveBottomCell.h"

#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>

@interface TDLiveSubViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDBaseView *loadingView;

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,assign) NSInteger page;

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
    self.page = 1;
    
    [self setViewConstaint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.loadingView = [[TDBaseView alloc] initWithLoadingFrame:self.view.bounds];
    [self.view addSubview:self.loadingView];
    
    [self getData];
}

#pragma mark - data
- (void)getData {
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.username forKey:@"username"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/live/%@",ELITEU_URL,self.username];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.loadingView removeFromSuperview];
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        if ([code intValue] == 200) {
            
        } else {
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.loadingView removeFromSuperview];
        
        [self.view makeToast:NSLocalizedString(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"error--%@",error);
    }];
}

#pragma mark - button Action
- (void)enterButtonAction:(UIButton *)sender { //进入讲座
    
}

- (void)praticeButtonAction:(UIButton *)sender { //做习题
    
}

- (void)playButtonAction:(UIButton *)sender { //观看回放
    
}

#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 8;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        TDLiveMessageCell *cell = [[TDLiveMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDLiveMessageCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.whereFrom = self.whereFrom;
        
        return cell;
        
    } else {
        TDLiveBottomCell *cell = [[TDLiveBottomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDLiveBottomCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.whereFrom = self.whereFrom;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

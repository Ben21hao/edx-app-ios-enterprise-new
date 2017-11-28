//
//  TDCourseListViewController.m
//  edX
//
//  Created by Elite Edu on 2017/11/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDCourseListViewController.h"
#import "TDFindCourseView.h"
#import "OEXCourse.h"

#import "OEXRouter.h"
#import "edX-Swift.h"

@interface TDCourseListViewController ()

@property (nonatomic,strong) TDFindCourseView *findCourseView;

@property (nonatomic,assign) NSInteger page;
@property (nonatomic,strong) NSMutableArray *courseArray;

@property (nonatomic,strong) TDBaseToolModel *toolModel;
@property (nonatomic,assign) BOOL isForgound;

@end

@implementation TDCourseListViewController

- (NSMutableArray *)courseArray {
    if (!_courseArray) {
        _courseArray = [[NSMutableArray alloc] init];
    }
    return _courseArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.page = 1;
    self.isForgound = YES;
    
    if (self.whereFrom == 2) {
       self.titleViewLabel.text = self.tagModel.subject_name;
    }
    
    [self setViewConstraint];
    
    self.toolModel = [[TDBaseToolModel alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isForgound) {
        [self setLoadDataView];
        [self getCourseListData:0];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
   
    self.isForgound = NO;
}

- (void)backButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - data
- (void)getCourseListData:(NSInteger)type { //type : 0 第一页数据，1 其他页

    if (![self.toolModel networkingState]) {
        [self showOrHideNoDataLabel];
        return;
    }
    
    if (type == 0) {
        self.page = 1;
    } else {
        self.page ++;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",ELITEU_URL,TD_SORT_COURSE_URL];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.username forKey:@"username"];
    
    [dic setValue:@"8" forKey:@"pagesize"];
    [dic setValue:@(self.page) forKey:@"pageindex"];
    [dic setValue:@"1" forKey:@"mobile"];
    
    if (self.whereFrom != 1) {
        [dic setValue:self.company_id forKey:@"company_id"];
    }
    
    if (self.whereFrom == 2) {
        [dic setValue:self.tagModel.subject_id forKey:@"subject_id"]; //选择的标签
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self dealWithHeaderAndFooterView];
        
        if (self.page == 1) {
            [self.courseArray removeAllObjects];
        }
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        if ([code intValue] == 200) {
            
            NSArray *dataArray = responseDic[@"data"];
            if (dataArray.count > 0) {
                
                for (NSDictionary *dataDic in dataArray) {
                    OEXCourse *courseModel = [[OEXCourse alloc] initWithDictionary:dataDic];
                    if (courseModel != nil) {
                        [self.courseArray addObject:courseModel];
                    }
                }
                self.findCourseView.courseArray = self.courseArray;
                
            } else {
                [self dealWithPage];
            }
            
        } else if ([code intValue] == 203) {
            
        } else if ([code intValue] == 204) {
            [self dealWithPage];
            [self.findCourseView.collectionView.mj_footer endRefreshingWithNoMoreData];
            
//            [self.view makeToast:TDLocalizeSelect(@"NO_MORE_DATA", nil) duration:1.08 position:CSToastPositionCenter];
            
        } else {
            [self.view makeToast:TDLocalizeSelect(@"SERVICE_FAILED", nil) duration:1.08 position:CSToastPositionCenter];
            NSLog(@"%@-------->>> %@",code,responseDic[@"msg"]);
        }
        
        [self showOrHideNoDataLabel];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        
        [self showOrHideNoDataLabel];
        [self dealWithHeaderAndFooterView];
        
        NSLog(@"获取课程分类tag -- %ld",(long)error.code);
    }];
}

- (void)dealWithPage {
    self.page > 1 ? self.page == 1 : self.page --;
}

- (void)footerRefresh { //底部加载
    [self getCourseListData:1];
}

- (void)headerRefresh { //头部刷新
    [self getCourseListData:0];
}

- (void)showOrHideNoDataLabel {
    
    self.loadIngView.hidden = YES;
    self.findCourseView.noDataLabel.hidden = self.courseArray.count > 0;
    self.findCourseView.collectionView.mj_footer.hidden = self.courseArray.count < 8;
}

- (void)dealWithHeaderAndFooterView {
    [self.findCourseView.collectionView.mj_header endRefreshing];
    [self.findCourseView.collectionView.mj_footer endRefreshing];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    header.lastUpdatedTimeLabel.hidden = YES; //隐藏时间
    [header setTitle:TDLocalizeSelect(@"DROP_REFRESH_TEXT", nil) forState:MJRefreshStateIdle];
    [header setTitle:TDLocalizeSelect(@"RELEASE_REFRESH_TEXT", nil) forState:MJRefreshStatePulling];
    [header setTitle:TDLocalizeSelect(@"REFRESHING_TEXT", nil) forState:MJRefreshStateRefreshing];
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefresh)];
    [footer setTitle:TDLocalizeSelect(@"LOADING_TEXT", nil) forState:MJRefreshStateRefreshing];
    [footer setTitle:TDLocalizeSelect(@"LOADED_ALL_TEXT", nil) forState:MJRefreshStateNoMoreData];
    [footer setTitle:TDLocalizeSelect(@"CLICK_PULL_LOAD_MORE", nil) forState:MJRefreshStateIdle];
    
    self.findCourseView = [[TDFindCourseView alloc] init];
    self.findCourseView.collectionView.mj_footer = footer;
    self.findCourseView.collectionView.mj_header = header;
    [self.view addSubview:self.findCourseView];
    
    [self.findCourseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    WS(weakSelf);
    self.findCourseView.didSelectRow = ^(NSInteger rowIndex){
        [[OEXRouter sharedRouter] showCourseCatalogDetailCourseModel:weakSelf.courseArray[rowIndex] fromController:weakSelf]; //课程详情
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

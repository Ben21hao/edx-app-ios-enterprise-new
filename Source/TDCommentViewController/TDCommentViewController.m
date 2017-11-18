//
//  TDCommentViewController.m
//  edX
//
//  Created by Elite Edu on 17/1/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#define TopView_Width 228

#import "TDCommentViewController.h"
#import "TDBaseToolModel.h"
#import "CommentTopItem.h"
#import "CommentDetailItem.h"
#import "TDCommentCell.h"

#import <MJRefresh/MJRefresh.h>
#import <MJExtension/MJExtension.h>

@interface TDCommentViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) TDBaseToolModel *baseTool;

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *topArry;//头部标签
@property (nonatomic,strong) NSMutableArray *commentArray;//评论数组
@property (nonatomic,assign) NSInteger page;//页码
@property (nonatomic,strong) NSString *scoreStr;//评分
@property (nonatomic,strong) NSString *selectId;//选中的标签
@property (nonatomic,strong) UIButton *selectedButton;//选中的标签

@end

@implementation TDCommentViewController

- (NSMutableArray *)topArry {
    if (!_topArry) {
        _topArry = [[NSMutableArray alloc] init];
    }
    return _topArry;
}

- (NSMutableArray *)commentArray {
    if (!_commentArray) {
        _commentArray = [[NSMutableArray alloc] init];
    }
    return _commentArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    self.baseTool = [[TDBaseToolModel alloc] init];
    
    self.page = 1;
    self.selectedButton = [[UIButton alloc] init];
    
    [self setLoadDataView]; //加载页面
    
    [self requestConcurrentDataRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.titleViewLabel.text = TDLocalizeSelect(@"STUDENT_COMMENT", nil);
}

- (void)requestConcurrentDataRequest { //多并发网络请求
    
    if (![self.baseTool networkingState]) {//网络监测
        [self.loadIngView removeFromSuperview];
        return;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_async(group, queue, ^{
       [self requestTopData]; //获取头部数据
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_group_async(group, queue, ^{
       [self requestCommentData:0]; //评论数据
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_group_notify(group, queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
}

#pragma mark - 获取头部数据
- (void)requestTopData {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/v0.5/social_contact/comment_summary/%@",ELITEU_URL,self.courseID];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        if ([code intValue] == 200) {
            
            self.scoreStr = responseDic[@"data"][@"avg_score"]; //评分
            NSArray *listArray = responseDic[@"data"][@"tag_count_list"];//头部标签
            if (listArray.count > 0) {
                for (int i = 0; i < listArray.count; i ++) {
                    CommentTopItem *topItem = [CommentTopItem mj_objectWithKeyValues:listArray[i]];
                    if (topItem) {
                        [self.topArry addObject:topItem];
                    }
                }
            }
        } else {
            NSLog(@"%@",responseDic[@"msg"]);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"评论头部标签 error--%@",error);
    }];
}

#pragma mark - 下拉刷新
- (void)pullDownRefresh {
    self.page = 1;
    [self requestCommentData:1];
}

#pragma mark - 上拉加载
- (void)topPullLoading { 
    [self requestCommentData:1];
}

#pragma mark - 筛选
- (void)tagButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    self.page = 1;
    
    if (sender.selected) {
        sender.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
        self.selectedButton.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        self.selectedButton.selected = NO;
        self.selectedButton = sender;
        CommentTopItem *topItem = self.topArry[sender.tag];
        topItem.isSelected = YES;
        self.selectId = topItem.tag_id;
        
        [self requestCommentData:1];
        
    } else {
        self.selectedButton = nil;
        self.selectId = nil;
        [self pullDownRefresh];//都无选中，则显示总数据
        sender.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    }
}

#pragma mark- 获取评论数据
- (void)requestCommentData:(NSInteger)type {
    
    if (type == 1) {
        if (![self.baseTool networkingState]) {//网络监测
            [self.tableView.mj_header endRefreshing];
            return;
        }
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.courseID forKey:@"course_id"];
    [params setValue:self.userName forKey:@"username"];
    [params setValue:@"8" forKey:@"pagesize"];
    [params setValue:@(self.page) forKey:@"pageindex"];
    
    if (self.selectId.length > 0 ) {
        [params setValue:self.selectId forKey:@"tag_id"];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/v0.5/social_contact/comment_detail/%@",ELITEU_URL,self.courseID];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.loadIngView removeFromSuperview];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            
            if (self.commentArray.count > 0 && self.page == 1) {
                [self.commentArray removeAllObjects];
            }
            
            NSDictionary *dataDic = responseObject[@"data"];
            NSArray *listArray = (NSArray *)dataDic[@"comment_list"];
            
            if (listArray.count < 8) {
                [self hiddenFooterView];
                
            } else {
                if (self.page == 1) {
                    [self.tableView.mj_footer resetNoMoreData];
                    self.tableView.mj_footer.hidden = NO;
                }
            }
            
            if (listArray.count > 0) {
                for (int i = 0; i <listArray.count; i ++) {
                    CommentDetailItem *detailItem = [CommentDetailItem mj_objectWithKeyValues:listArray[i]];
                    if (detailItem) {
                        [self.commentArray addObject:detailItem];
                    }
                }
                self.page ++;
            }
            
        } else {
            [self hiddenFooterView];
            [self.view makeToast:TDLocalizeSelect(@"QUERY_FAILED", nil) duration:1.08 position:CSToastPositionCenter];
            NSLog(@"评论 --- %@",responseObject[@"msg"]);
        }
        
        if (!self.tableView) {
            if (self.topArry.count == 0 && self.commentArray.count == 0) {
                [self setNullDataView:TDLocalizeSelect(@"NO_STUDENT_COMMENT", nil)];
                return;
                
            } else {
                [self setviewConstraint];
            }
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        [self.loadIngView removeFromSuperview];
        NSLog(@"获取评论数据 error--%@",error);
    }];
}

- (void)hiddenFooterView {
    self.tableView.mj_footer.hidden = YES;
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.commentArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    CommentDetailItem *detailItem = self.commentArray[indexPath.section];
    
    TDCommentCell *cell = [[TDCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDCommentCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.username = self.userName;
    
    cell.clickPraiseButton = ^(NSString *praiseNum,BOOL isPraise){
        detailItem.praise_num = praiseNum;
        detailItem.is_praise = isPraise;
    };
    cell.moreButtonActionHandle = ^(BOOL isOpen,float maxCommentLabelHeight){
        detailItem.click_Open = isOpen;
        detailItem.maxCommentLabelHeight = maxCommentLabelHeight;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    };
    
    cell.detailItem = detailItem;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentDetailItem *detailItem = self.commentArray[indexPath.section];
    return [self heightForCell:detailItem];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (int)heightForCell:(CommentDetailItem *)detailItem {
    
    CGSize size = [detailItem.content boundingRectWithSize:CGSizeMake(TDWidth - 95, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:14]} context:nil].size;
    
    if (size.height > 76.3) { //4行文本的高
        if (!detailItem.click_Open) {
            size.height = 76.3 + 27;
        } else if (detailItem.click_Open) {
            size.height = size.height + 27;
        }
    }
    
    int height = size.height + 26 + 100;
    if (detailItem.tags.count > 0) {
        if (detailItem.content.length > 0) {
            height = size.height + ((detailItem.tags.count - 1) / 3 + 1) * 26 + 16 + 100;
        } else {
            height = size.height + ((detailItem.tags.count - 1) / 3 + 1) * 26 + 100;
        }
    }
    
    return height;
}

#pragma mark - UI
- (void)setviewConstraint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(self.view);
    }];
    
    self.tableView.tableHeaderView = [self headerView];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullDownRefresh)];
    header.lastUpdatedTimeLabel.hidden = YES; //隐藏时间
    [header setTitle:TDLocalizeSelect(@"DROP_REFRESH_TEXT", nil) forState:MJRefreshStateIdle];
    [header setTitle:TDLocalizeSelect(@"RELEASE_REFRESH_TEXT", nil) forState:MJRefreshStatePulling];
    [header setTitle:TDLocalizeSelect(@"REFRESHING_TEXT", nil) forState:MJRefreshStateRefreshing];
    self.tableView.mj_header = header;
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(topPullLoading)];
    [footer setTitle:TDLocalizeSelect(@"LOADING_TEXT", nil) forState:MJRefreshStateRefreshing];
    [footer setTitle:TDLocalizeSelect(@"LOADED_ALL_TEXT", nil) forState:MJRefreshStateNoMoreData];
    [footer setTitle:TDLocalizeSelect(@"CLICK_PULL_LOAD_MORE", nil) forState:MJRefreshStateIdle];
    self.tableView.mj_footer = footer;
}

#pragma mark - 头部视图
- (UIView *)headerView {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, (self.topArry.count / 3 + 1) * 28 + 39 + 24)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    /*
     星星
     */
    UIView *starView = [[UIView alloc] init];
    [headerView addSubview:starView];
    [starView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(headerView.mas_centerX);
        make.top.mas_equalTo(headerView.mas_top).offset(8);
        make.size.mas_equalTo(CGSizeMake(TopView_Width, 39));
    }];
    
    int width = TopView_Width / 5;
    for (int i = 0; i < 5; i ++) {
        
        UIImageView *starImage = [[UIImageView alloc] init];
        starImage.contentMode = UIViewContentModeCenter;
        
        if (i > [self.scoreStr intValue]) {
            starImage.image = [UIImage imageNamed:@"star11"];
        } else {
            starImage.image = [UIImage imageNamed:@"star1"];
        }
        [starView addSubview:starImage];
        [starImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(starView.mas_left).offset(width * i);
            make.centerY.mas_equalTo(starView);
            make.width.mas_equalTo(width);
        }];
    }
    
    UIView *tagView = [[UIView alloc] init];
    [headerView addSubview:tagView];
    
    [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerView.mas_left).offset(18);
        make.right.mas_equalTo(headerView.mas_right).offset(-18);
        make.top.mas_equalTo(starView.mas_bottom).offset(8);
        make.bottom.mas_equalTo(headerView.mas_bottom).offset(-8);
    }];
    
    /*
     标签 - 一行三个标签
     */
    int tagWidth = (TDWidth - 36) / 3;
    for (int i = 0; i < self.topArry.count; i ++) {
        int rang = i % 3;
        
        UIButton *tagButton = [[UIButton alloc] init];
        tagButton.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        [tagButton setTitleColor:[UIColor colorWithHexString:colorHexStr9] forState:UIControlStateNormal];
        [tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        tagButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
        tagButton.layer.cornerRadius = 11.0;
        tagButton.layer.borderWidth = 0.5;
        tagButton.layer.borderColor = [UIColor colorWithHexString:colorHexStr8].CGColor;
        tagButton.tag = i;
        [tagButton addTarget:self action:@selector(tagButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        CommentTopItem *item = self.topArry[i];
        [tagButton setTitle:[NSString stringWithFormat:@"%@(%@)",item.tag_name,item.count] forState:UIControlStateNormal];
        [tagView addSubview:tagButton];
        
        [tagButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(tagView.mas_left).offset(rang * (tagWidth - 3) + 4);
            make.top.mas_equalTo(tagView.mas_top).offset(i / 3 * (23 + 5));
            make.size.mas_equalTo(CGSizeMake(tagWidth - 8, 23));
        }];
    }
    
    return headerView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end

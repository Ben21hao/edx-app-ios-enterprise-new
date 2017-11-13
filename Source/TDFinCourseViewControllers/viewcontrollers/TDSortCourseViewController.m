//
//  TDSortCourseViewController.m
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDSortCourseViewController.h"
#import "TDCourseListViewController.h"
#import "TDSortCourseCell.h"
#import "TDCourseTagModel.h"

#import <MJExtension/MJExtension.h>

@interface TDSortCourseViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSString *company_count;
@property (nonatomic,strong) NSString *eliteu_count;
@property (nonatomic,strong) NSMutableArray *companyArray;
@property (nonatomic,strong) NSMutableArray *eliteArray;

@property (nonatomic,strong) TDBaseToolModel *toolModel;

@end

@implementation TDSortCourseViewController

- (NSMutableArray *)companyArray {
    if (!_companyArray) {
        _companyArray = [[NSMutableArray alloc] init];
    }
    return _companyArray;
}

- (NSMutableArray *)eliteArray {
    if (!_eliteArray) {
        _eliteArray = [[NSMutableArray alloc] init];
    }
    return _eliteArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.toolModel = [[TDBaseToolModel alloc] init];
    
    [self setViewConstraint];
    [self getAllTagData];
    
    [self setLoadDataView];
}

#pragma mark - data
- (void)getAllTagData {
    
    if (![self.toolModel networkingState]) {
        [self showOrHideNoDataLabel];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",ELITEU_URL,TD_FIND_COURSE_URL];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.company_id forKey:@"company_id"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        if ([code intValue] == 200) {
            
            NSDictionary *dataDic = responseDic[@"data"];
            self.company_count = dataDic[@"company_count"];
            self.eliteu_count = dataDic[@"eliteu_count"];
            
            NSArray *company = dataDic[@"company"];
            if (company.count > 0) {
                for (NSDictionary *tagDic in company) {
                    TDCourseTagModel *model = [TDCourseTagModel mj_objectWithKeyValues:tagDic];
                    if (model) {
                        [self.companyArray addObject:model];
                    }
                }
            }
            NSArray *eliteu = dataDic[@"eliteu"];
            if (eliteu.count > 0) {
                for (NSDictionary *tagDic in eliteu) {
                    TDCourseTagModel *model = [TDCourseTagModel mj_objectWithKeyValues:tagDic];
                    if (model) {
                        [self.eliteArray addObject:model];
                    }
                }
            }
            [self.tableView reloadData];
        } else {
            
        }
        [self showOrHideNoDataLabel];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        [self showOrHideNoDataLabel];
        NSLog(@"获取课程分类tag -- %ld",(long)error.code);
    }];
}

- (void)showOrHideNoDataLabel {
    self.loadIngView.hidden = YES;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopTitleCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TopTitleCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:13];
        cell.detailTextLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
        cell.textLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
        cell.detailTextLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
        
        cell.textLabel.text = indexPath.section == 0 ? @"内部课程" : @"英荔课程";
        NSString *countStr = indexPath.section == 0 ? self.company_count : self.eliteu_count;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"共%@门课",countStr];
        
        return cell;
        
    } else {
        
        TDSortCourseCell *cell = [[TDSortCourseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDSortCourseCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.tagArray = indexPath.section == 0 ? self.companyArray : self.eliteArray;
        
        WS(weakSelf);
        cell.selectTagButtonHandle = ^(NSString *subject_id){
            [weakSelf gotoSpecificSortVC:subject_id];
        };
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 37;
        
    } else {
        return indexPath.section == 0 ? [self getHeightForRow:self.companyArray] : [self getHeightForRow:self.eliteArray];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 13;
}

- (CGFloat)getHeightForRow:(NSArray *)tagArray {
    
    CGFloat leftWidth = 0;
    CGFloat topHeight = 0;
    
    for (int i = 0; i < tagArray.count; i ++) {
        
        CGFloat width = [self getTagStrWidh:tagArray index:i];
        if (i == 0) {
            topHeight = 13;
            leftWidth = 13;
            
        } else {
            
            CGFloat lastWidth = [self getTagStrWidh:tagArray index:i - 1];
            leftWidth = leftWidth + lastWidth + 13;
            
            if (leftWidth + width + 13 > TDWidth) {
                leftWidth = 13;
                topHeight = topHeight + 24 + 13;
            }
        }
    }
    return topHeight + 13 > 47 ? topHeight + 13 : 47;
}

- (CGFloat)getTagStrWidh:(NSArray *)tagArray index:(NSInteger)index {
    
    TDCourseTagModel *model = tagArray[index];
    NSString *titleStr = [NSString stringWithFormat:@"%@  %@",model.subject_name,model.count];
    
    CGFloat width = [self.toolModel widthForString:titleStr font:12] + 28;
    
    return width;
}

#pragma mark - action
- (void)gotoSpecificSortVC:(NSString *)subject_id {
    
    TDCourseListViewController *courseListVc = [[TDCourseListViewController alloc] init];
    courseListVc.username = self.username;
    courseListVc.company_id = self.company_id;
    courseListVc.subject_id = subject_id;
    courseListVc.whereFrom = 2;
    [self.navigationController pushViewController:courseListVc animated:YES];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end

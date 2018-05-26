//
//  TDScoreViewController.m
//  edX
//
//  Created by Elite Edu on 2018/5/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDScoreViewController.h"
#import "TDScoreHeaderView.h"
#import "TDScoreSectionView.h"
#import "TDScoreCellCell.h"
#import "TDCourseScoreModel.h"

#import <MJExtension/MJExtension.h>

@interface TDScoreViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDScoreHeaderView *headerView;

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *noExampleLabel;

@property (nonatomic,strong) TDCourseScoreModel *scoreModel;

@end

@implementation TDScoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = self.courseTitle;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self getCourseScoreData];
}

#pragma makr - data 
- (void)getCourseScoreData {
    
    TDBaseToolModel *toolModel = [[TDBaseToolModel alloc] init];
    if (![toolModel networkingState]) {
        return;
    }
    
    [self setLoadDataView];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/enterprise/v0.5/getcoursescores/",ELITEU_URL];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.username forKey:@"username"];
    [dict setValue:self.course_id forKey:@"course_id"];
    
    [manager GET:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.loadIngView removeFromSuperview];
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            NSDictionary *dataDic = responseDic[@"data"];
            self.scoreModel = [TDCourseScoreModel mj_objectWithKeyValues:dataDic]; //章
            
            if (self.scoreModel.courseware_summary.count > 0) {
                NSMutableArray *chapterArray = [[NSMutableArray alloc] init];
                for (NSDictionary *chapterDic in self.scoreModel.courseware_summary) {
                    TDChapterScoreModel *chapterModel = [TDChapterScoreModel mj_objectWithKeyValues:chapterDic];
                    if (chapterModel) {
                        
                        if (chapterModel.subsection.count > 0) {
                            NSMutableArray *unitArray = [[NSMutableArray alloc] init];
                            for (NSDictionary *unitDic in chapterModel.subsection) {
                                TDUnitScoreModel *unitModel = [TDUnitScoreModel mj_objectWithKeyValues:unitDic];
                                if (unitModel) {
                                    
                                    unitModel.isUnit = YES;
                                    [unitArray addObject:unitModel]; //节
                                    
                                    if (unitModel.problem_score_list > 0) {
                                        for (NSDictionary *sectionDic in unitModel.problem_score_list) {
                                            TDUnitScoreModel *sectionModel = [TDUnitScoreModel mj_objectWithKeyValues:sectionDic];
                                            if (sectionModel) {
                                                sectionModel.isUnit = NO;
                                                [unitArray addObject:sectionModel]; //单元
                                            }
                                        }
                                    }
                                }
                            }
                            chapterModel.subsection = unitArray;//单元数组
                        }
                        
                        [chapterArray addObject:chapterModel];
                    }
                }
                self.scoreModel.courseware_summary = chapterArray;//节数组
            }
            
//            self.scoreModel.course_problem_public = @"0";
            if ([self.scoreModel.course_problem_public boolValue] == YES) { //已发布习题
                [self setViewConstraint];
                self.headerView.scoreModel = self.scoreModel;
                [self.tableView reloadData];
                
            } else {
                [self setNoExampleData];
            }
        }
        else if ([code intValue] == 500) {
            [self setNullDataView:@"查询失败"];
        }
        else {
            [self setNullDataView:@"查询失败"];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.loadIngView removeFromSuperview];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"发送登录验证码 -- %ld",(long)error.code);
    }];
    
}

#pragma mark - tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.scoreModel.courseware_summary.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    TDChapterScoreModel *chapterModel = self.scoreModel.courseware_summary[section];
    return chapterModel.subsection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TDChapterScoreModel *chapterModel = self.scoreModel.courseware_summary[indexPath.section];
    
    TDUnitScoreModel *unitScoreModel = chapterModel.subsection[indexPath.row];
    
    if (unitScoreModel.isUnit == YES) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"courseUnitCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"courseUnitCell"];
            
            UILabel *line = [[UILabel alloc] init];
            line.backgroundColor = [UIColor colorWithHexString:colorHexStr7];
            [cell addSubview:line];
            
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(cell.mas_left).offset(18);
                make.right.mas_equalTo(cell.mas_right).offset(-18);
                make.bottom.mas_equalTo(cell.mas_bottom);
                make.height.mas_equalTo(0.5);
            }];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
        cell.textLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
        
        cell.textLabel.text = unitScoreModel.subsection_display_name;
        
        return cell;
    }
    else {
        TDScoreCellCell *cell = [[TDScoreCellCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"scoreCell"];;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.unitScoreModel = unitScoreModel;
        
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    TDChapterScoreModel *scoreModel = self.scoreModel.courseware_summary[section];
    
    TDScoreSectionView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"scoreHeaderView"];
    if (!headerView) {
        headerView = [[TDScoreSectionView alloc] initWithReuseIdentifier:@"scoreHeaderView"];
    }
    headerView.titleLabel.text = scoreModel.section_display_name;
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 48;
    }
    return 58;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 43;
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    self.headerView = [[TDScoreHeaderView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, 228)];
    self.tableView.tableHeaderView = self.headerView;
}

- (void)setNullData:(NSString *)nullStr {
    [self setNullLabelOnView:self.view title:nullStr];
}

- (void)setNoExampleData { //未发布习题
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"score_left_Image"];
    [self.view addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_centerY).offset(-28);
        make.size.mas_equalTo(CGSizeMake(72, 93));
        
    }];
    
    self.noExampleLabel = [[UILabel alloc] init];
    self.noExampleLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.noExampleLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    self.noExampleLabel.textAlignment = NSTextAlignmentCenter;
    self.noExampleLabel.text = @"尚未发布习题哦！";
    [self.view addSubview:self.noExampleLabel];
    
    [self.noExampleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(18);
        make.right.mas_equalTo(self.view.mas_right).offset(-18);
        make.top.mas_equalTo(self.imageView.mas_bottom).offset(18);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

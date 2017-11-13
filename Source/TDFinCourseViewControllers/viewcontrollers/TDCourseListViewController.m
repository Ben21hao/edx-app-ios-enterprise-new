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
       self.titleViewLabel.text = @"分类页";
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
    
    self.page = 1;
    self.isForgound = NO;
}

- (void)backButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - data
- (void)getCourseListData:(NSInteger)type {

    if (![self.toolModel networkingState]) {
        [self showOrHideNoDataLabel];
        return;
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
        [dic setValue:self.subject_id forKey:@"subject_id"]; //选择的标签
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
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
            }
            
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

#pragma mark - UI
- (void)setViewConstraint {
    
    self.findCourseView = [[TDFindCourseView alloc] init];
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

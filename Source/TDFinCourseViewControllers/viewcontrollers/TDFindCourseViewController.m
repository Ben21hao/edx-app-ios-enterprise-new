//
//  TDFindCourseViewController.m
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDFindCourseViewController.h"
#import "TDSortCourseViewController.h"
#import "TDCourseListViewController.h"

@interface TDFindCourseViewController ()

@end

@implementation TDFindCourseViewController

- (instancetype)initWithUserName:(NSString *)username companyId:(NSString *)companyId {
    self = [super init];
    if (self) {
        self.company_id = companyId;
        self.username = username;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = TDLocalizeSelect(@"FIND_COURSES", nil);
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    [self addAllChildrenVC]; //加入子控制器
    [self setSubTitleConstraint]; //子标题布局
}

- (void)addAllChildrenVC {
    for (int i = 0; i < 3; i ++) {
        switch (i) {
            case 0: {
                TDCourseListViewController *insideVC = [[TDCourseListViewController alloc] init];
                insideVC.title = TDLocalizeSelect(@"EXCLUSIVE_COURSES", nil);
                insideVC.company_id = self.company_id;
                insideVC.username = self.username;
                insideVC.whereFrom = 0;
                
                [self addChildViewController:insideVC];
                [self.childVcArray addObject:insideVC];
            }
                break;
            case 1: {
                TDCourseListViewController *eliteuVC = [[TDCourseListViewController alloc] init];
                eliteuVC.title = TDLocalizeSelect(@"ELITEU_COURSES", nil);
                eliteuVC.username = self.username;
                eliteuVC.whereFrom = 1;
                
                [self addChildViewController:eliteuVC];
                [self.childVcArray addObject:eliteuVC];
            }
                break;
                
            default: {
                TDSortCourseViewController *sortVC = [[TDSortCourseViewController alloc] init];
                sortVC.title = TDLocalizeSelect(@"CATEGORIES", nil);
                sortVC.company_id = self.company_id;
                sortVC.username = self.username;
                
                [self addChildViewController:sortVC];
                [self.childVcArray addObject:sortVC];
            }
                break;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

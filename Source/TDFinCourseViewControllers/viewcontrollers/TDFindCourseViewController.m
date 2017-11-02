//
//  TDFindCourseViewController.m
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDFindCourseViewController.h"
#import "TDInsideCourseViewController.h"
#import "TDEliteCourseViewController.h"
#import "TDSortCourseViewController.h"

@interface TDFindCourseViewController ()

@end

@implementation TDFindCourseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = TDLocalizeSelect(@"FIND_COURSES", nil);
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    [self addAllChildrenVC];
}

- (void)addAllChildrenVC {
    for (int i = 0; i < 3; i ++) {
        switch (i) {
            case 0: {
                TDInsideCourseViewController *insideVC = [[TDInsideCourseViewController alloc] init];
                insideVC.title = @"内部课程";
                [self addChildViewController:insideVC];
                [self.childVcArray addObject:insideVC];
            }
                break;
            case 1: {
                TDEliteCourseViewController *eliteuVC = [[TDEliteCourseViewController alloc] init];
                eliteuVC.title = @"英荔课程";
                [self addChildViewController:eliteuVC];
                [self.childVcArray addObject:eliteuVC];
            }
                break;
                
            default: {
                TDSortCourseViewController *sortVC = [[TDSortCourseViewController alloc] init];
                sortVC.title = @"课程分类";
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

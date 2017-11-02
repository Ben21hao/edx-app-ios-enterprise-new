//
//  TDInsideCourseViewController.m
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDInsideCourseViewController.h"
#import "TDFindCourseView.h"

@interface TDInsideCourseViewController ()

@property (nonatomic,strong) TDFindCourseView *findCourseView;

@end

@implementation TDInsideCourseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setViewConstraint];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.findCourseView = [[TDFindCourseView alloc] init];
    [self.view addSubview:self.findCourseView];
    
    [self.findCourseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

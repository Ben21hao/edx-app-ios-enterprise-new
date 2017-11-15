//
//  TDAssistantServiceViewController.m
//  edX
//
//  Created by Elite Edu on 17/2/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDAssistantServiceViewController.h"
#import "TDSubServiceViewController.h"
#import "TDBaseScrollView.h"

@interface TDAssistantServiceViewController ()

@end

@implementation TDAssistantServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = TDLocalizeSelect(@"TA_SERVICE", nil);
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self setLeftNavigationBar]; //返回按钮处理
    
    [self addAllChildrenVC]; //加入子控制器
    [self setSubTitleConstraint]; //子标题布局
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - 加入子控制器
- (void)addAllChildrenVC {
    
    for (int i = 0; i < 3 ; i ++ ) {
        TDSubServiceViewController *subViewController = [[TDSubServiceViewController alloc] init];
        subViewController.whereFrom = i;
        subViewController.username = self.username;
        subViewController.company_id = self.company_id;
        subViewController.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        [self addChildViewController:subViewController];
        
        [self.childVcArray addObject:subViewController];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end




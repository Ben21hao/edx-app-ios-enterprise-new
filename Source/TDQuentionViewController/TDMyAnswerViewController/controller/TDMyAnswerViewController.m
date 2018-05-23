//
//  TDMyAnswerViewController.m
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDMyAnswerViewController.h"
#import "TDSubMyAnswerViewController.h"
#import "TDQuetionInputViewController.h"

@interface TDMyAnswerViewController ()

@end

@implementation TDMyAnswerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = TDLocalizeSelect(@"MY_ANSWERS_NAVI", nil);
    [self setLeftNavigationBar];
    
    [self addChileVC];
    [self setSubTitleConstraint];
    
}

- (void)rightButtonAciton:(UIButton *)sender {
    
    TDQuetionInputViewController *inputVc = [[TDQuetionInputViewController alloc] init];
    inputVc.whereFrom = TDQuetionInputFromNewQuetion;
    inputVc.username = self.username;
    inputVc.titleStr = TDLocalizeSelect(@"NEW_CONSULTATION_TEXT", nil);
    [self.navigationController pushViewController:inputVc animated:YES];
}

#pragma mark - 加入子视图
- (void)addChileVC {
    
    for (int i = 0 ; i < 2; i ++) {
        
        TDSubMyAnswerViewController *subViewController = [[TDSubMyAnswerViewController alloc] init];
        subViewController.username = self.username;
        subViewController.userId = self.userId;
        subViewController.whereFrom = i == 0 ? TDSubAnswerFromUnsolved : TDSubAnswerFromSolved;
        subViewController.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        [self addChildViewController:subViewController];
        [self.childVcArray addObject:subViewController];
        
        switch (i) {
            case 0:
                subViewController.title = TDLocalizeSelect(@"CONSULTATION_UNSOLVED", nil);
                break;
            default:
                subViewController.title = TDLocalizeSelect(@"CONSULTATION_RESOLVED", nil);
                break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end

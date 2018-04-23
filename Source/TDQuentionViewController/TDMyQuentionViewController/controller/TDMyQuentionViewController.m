//
//  TDMyQuentionViewController.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDMyQuentionViewController.h"
#import "TDSubMyQuentionViewController.h"
#import "TDQuetionInputViewController.h"

@interface TDMyQuentionViewController ()

@end

@implementation TDMyQuentionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = TDLocalizeSelect(@"MY_QUETIONS", nil);
    [self setLeftNavigationBar];
    [self setRightNavigationBar];
    [self.rightButton setImage:[UIImage imageNamed:@"add_white_image"] forState:UIControlStateNormal];
    
    [self addChileVC];
    [self setSubTitleConstraint];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quetuonSureSolved:) name:@"quetion_sure_solved_notification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newQuetionHandin:) name:@"new_quetion_handin_notification" object:nil];
}

- (void)quetuonSureSolved:(NSNotification *)notifi {
    
    
    
    UIButton *seleButton = self.titleButtons[1];
    [self btnClick:seleButton];
}

- (void)newQuetionHandin:(NSNotification *)notifi {
    UIButton *seleButton = self.titleButtons[0];
    [self btnClick:seleButton];
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
        
        TDSubMyQuentionViewController *subViewController = [[TDSubMyQuentionViewController alloc] init];
        subViewController.username = self.username;
        subViewController.whereFrom = i == 0 ? TDSubQuetionFromUnsolved : TDSubQuetionFromSolved;
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

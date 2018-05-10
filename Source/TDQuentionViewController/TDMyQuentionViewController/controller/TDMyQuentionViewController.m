//
//  TDMyQuentionViewController.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDMyQuentionViewController.h"
#import "TDSubMyQuentionViewController.h"
#import "TDConsultDetailViewController.h"

#import "TDCallCameraViewConstroller.h"
#import "TDImageGroupViewController.h"

#import "TDNavigationViewController.h"

#import "TDConsultGuidView.h"

@interface TDMyQuentionViewController ()

@property (nonatomic,strong) TDConsultGuidView *guidView;

@end

@implementation TDMyQuentionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = TDLocalizeSelect(@"MY_QUETIONS", nil);
    [self setLeftNavigationBar];
    [self setRightNavigationBar];
    [self.rightButton setTitle:@"新增" forState:UIControlStateNormal];
    
    [self addChileVC];
    [self setSubTitleConstraint];
    
    [self addGuidView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quetuonSureSolved:) name:@"quetion_sure_solved_notification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newQuetionHandin:) name:@"new_quetion_handin_notification" object:nil];
}


#pragma mark - 通知
- (void)quetuonSureSolved:(NSNotification *)notifi {
    
    UIButton *seleButton = self.titleButtons[1];
    [self btnClick:seleButton];
}

- (void)newQuetionHandin:(NSNotification *)notifi {
    UIButton *seleButton = self.titleButtons[0];
    [self btnClick:seleButton];
}

#pragma mark - 按钮
- (void)rightButtonAciton:(UIButton *)sender {
    
//    TDCallCameraViewConstroller *cameraVc = [[TDCallCameraViewConstroller alloc] init];
//    [self presentViewController:cameraVc animated:YES completion:nil];

    TDConsultDetailViewController *consultVc = [[TDConsultDetailViewController alloc] init];
    consultVc.whereFrom = TDConsultDetailFromNewConsult;
    consultVc.username = self.username;
    [self.navigationController pushViewController:consultVc animated:YES];
    
//    [self gotoPhotoSelectVc];
}

- (void)gotoPhotoSelectVc { //图片选择页
    
    TDImageGroupViewController *imageGroupVc = [[TDImageGroupViewController alloc] init];
    
    TDNavigationViewController *naviController = [[TDNavigationViewController alloc] initWithRootViewController:imageGroupVc];
    [self presentViewController:naviController animated:YES completion:nil];
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

- (void)addGuidView {
    
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:@"Consult_GuidView_ShowCount"];
    if (count == 0) {
    
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"Consult_GuidView_ShowCount"];
        
        self.guidView = [[TDConsultGuidView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight)];
        [self.guidView.tapButton addTarget:self action:@selector(tapButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.guidView];
    }
}

- (void)tapButtonAction:(UIButton *)sender {
    [self.guidView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

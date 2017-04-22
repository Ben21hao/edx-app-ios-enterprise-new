//
//  TDBindSuccessViewController.m
//  edX
//
//  Created by Elite Edu on 17/1/5.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDBindSuccessViewController.h"

@interface TDBindSuccessViewController () <UIGestureRecognizerDelegate>

@property (nonatomic,strong) UILabel *topLabel;
@property (nonatomic,strong) UIButton *sureButton;

@end

@implementation TDBindSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = NSLocalizedString(@"SURE_BIND", nil);
    [self configView];
    [self setViewConstraint];
    
    self.leftButton.hidden = YES;
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [backButton setImage:[UIImage imageNamed:@"backImagee"] forState:UIControlStateNormal];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -23, 0, 23);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    [backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
}

#pragma mark - 返回
- (void)backButtonAction:(UIButton *)sender {
    [self.navigationController popToViewController:self.navigationController.childViewControllers[1] animated:YES];
}

#pragma mark - 确定
- (void)sureButtonAction:(UIButton *)sender {
    [self.navigationController popToViewController:self.navigationController.childViewControllers[1] animated:YES];
}

#pragma mark - UI
- (void)configView {
    self.topLabel = [[UILabel alloc] init];
    self.topLabel.text = NSLocalizedString(@"EMAIL_AREADY_SEND", nil);
    self.topLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.topLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    self.topLabel.numberOfLines = 0;
    [self.view addSubview:self.topLabel];
    
    self.sureButton = [[UIButton alloc] init];
    self.sureButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.sureButton.layer.cornerRadius = 4.0;
    [self.sureButton setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [self.sureButton addTarget:self action:@selector(sureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sureButton];
}

- (void)setViewConstraint {
   [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(self.view.mas_top).offset(18);
       make.left.mas_equalTo(self.view.mas_left).offset(18);
       make.right.mas_equalTo(self.view.mas_right).offset(-18);
   }];
    
    [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLabel.mas_bottom).offset(18);
        make.left.mas_equalTo(self.view.mas_left).offset(18);
        make.right.mas_equalTo(self.view.mas_right).offset(-18);
        make.height.mas_equalTo(39);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

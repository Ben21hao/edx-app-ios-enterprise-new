//
//  TDBaseViewController.m
//  edX
//
//  Created by Elite Edu on 16/12/5.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "TDBaseViewController.h"

@interface TDBaseViewController () <UIGestureRecognizerDelegate>

@end

@implementation TDBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitleLabel];
    [self setLeftNavigationBar];
    [self setRightNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

#pragma mark - 导航栏标题
- (void)setTitleLabel{
    
    self.titleViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, TDWidth - 198, 44)];
    self.titleViewLabel.textAlignment = NSTextAlignmentCenter;
    self.titleViewLabel.font = [UIFont fontWithName:@"OpenSans" size:18.0];
    self.titleViewLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = self.titleViewLabel;
}

#pragma mark - 导航栏左边按钮
- (void)setLeftNavigationBar {
    
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [self.leftButton setImage:[UIImage imageNamed:@"backImagee"] forState:UIControlStateNormal];
    self.leftButton.showsTouchWhenHighlighted = YES;
    self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -23, 0, 23);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    [self.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    
}

- (void)backButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 导航栏右边按钮
- (void)setRightNavigationBar {
    
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 68, 48)];
    [self.rightButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    self.rightButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, -16);
    self.rightButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16.0];
    self.rightButton.titleLabel.textAlignment = NSTextAlignmentRight;
    self.rightButton.showsTouchWhenHighlighted = YES;
    [self.rightButton addTarget:self action:@selector(rightButtonAciton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];

}

- (void)rightButtonAciton:(UIButton *)sender {
    if (self.rightButtonHandle) {
        self.rightButtonHandle();
    }
}

#pragma mark - 数据加载
- (void)setLoadDataView {
    
    self.loadIngView = [[UIView alloc] init];
    self.loadIngView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self.view addSubview:self.loadIngView];
    [self.loadIngView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    UILabel *loadLabel = [[UILabel alloc] init];
    loadLabel.textColor = [UIColor colorWithHexString:colorHexStr1];
    loadLabel.font = [UIFont fontWithName:@"FontAwesome" size:25];
    [loadLabel setText: @"\U0000f110"];//\u{f110}
    [self.loadIngView addSubview:loadLabel];
    
    [loadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.loadIngView);
        make.centerY.mas_equalTo(self.loadIngView).offset(-28);
    }];
    
    CAKeyframeAnimation *animate = [[CAKeyframeAnimation alloc] init];
    animate.keyPath = @"transform.rotation";
    
    NSMutableArray *timeArr = [[NSMutableArray alloc] init];
    NSMutableArray *directArr = [[NSMutableArray alloc] init];
    for (double i = 0; i < 8; i ++) {
        double time = i / 8.0;
        NSNumber *num = [NSNumber numberWithDouble:time];
        [timeArr addObject:num];
        
        double direct = time * 2.0 * M_PI;
        NSNumber *dNum = [NSNumber numberWithDouble:direct];
        [directArr addObject:dNum];
    }
    animate.keyTimes = timeArr;
    animate.values = directArr;
    
    animate.repeatCount = 88;
    animate.duration = 0.6;
    animate.additive = YES;
    animate.calculationMode = kCAAnimationDiscrete;
    animate.beginTime = [self.view.layer convertTime:0 toLayer:self.view.layer];
    [loadLabel.layer addAnimation:animate forKey:nil];
    
    [self.view bringSubviewToFront:self.loadIngView];
}

#pragma mark - 无数据处理
- (void)setNullDataView:(NSString *)title {
    self.nullView = [[UIView alloc] init];
    self.nullView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self.view addSubview:self.nullView];
    
    UILabel *nullLabel = [[UILabel alloc] init];
    nullLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    nullLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    nullLabel.textAlignment = NSTextAlignmentCenter;
    nullLabel.text = title;
    [self.nullView addSubview:nullLabel];
    
    [self.nullView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    [nullLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.nullView.mas_centerX);
        make.centerY.mas_equalTo(self.nullView.mas_centerY).offset(-8);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

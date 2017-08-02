//
//  TDWebViewController.m
//  edX
//
//  Created by Elite Edu on 17/1/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDWebViewController.h"
#import "edx-Swift.h"
#import "TDBaseToolModel.h"

@interface TDWebViewController () <WKUIDelegate,WKNavigationDelegate>

@property (nonatomic,strong) WKWebView *webview;
@property (nonatomic,strong) UIButton *agreeButton;

@end

@implementation TDWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self configView];
    [self setViewConstraint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.titleViewLabel.text = self.titleStr;
    TDBaseToolModel *baseTool = [[TDBaseToolModel alloc] init];
    if (![baseTool networkingState]) {
        return;
    }
    
    [self setLoadDataView];
    [self.webview loadRequest:[NSURLRequest requestWithURL:self.url]];
}

#pragma mark - delegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.loadIngView removeFromSuperview];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
    [[OEXFlowErrorViewController sharedInstance] showErrorWithTitle:@"加载出错"
                                                            message:[NSString stringWithFormat:@"加载%@出错",self.titleStr]
                                                   onViewController:[UIApplication sharedApplication].keyWindow.rootViewController.view
                                                         shouldHide:YES];
    [self.loadIngView removeFromSuperview];
}

#pragma mark - action
- (void)agreeButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UI
- (void)configView {
    
    self.agreeButton = [[UIButton alloc] init];
    self.agreeButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.agreeButton.layer.cornerRadius = 4.0;
    [self.agreeButton setTitle:NSLocalizedString(@"ENDORSED", nil) forState:UIControlStateNormal];
    [self.agreeButton addTarget:self action:@selector(agreeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.agreeButton];
    
    self.webview = [[WKWebView alloc] init];
    self.webview.navigationDelegate = self;
    self.webview.UIDelegate = self;
    self.webview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webview];
}

- (void)setViewConstraint {
    
    [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(18);
        make.right.mas_equalTo(self.view.mas_right).offset(-18);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-13);
        make.height.mas_equalTo(39);
    }];
    
    [self.webview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.agreeButton.mas_top).offset(-8);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end



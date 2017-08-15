//
//  TDWebUrlViewController.m
//  edX
//
//  Created by Elite Edu on 2017/8/15.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDWebUrlViewController.h"
#import "edx-Swift.h"

@interface TDWebUrlViewController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic,strong) WKWebView *webview;

@end

@implementation TDWebUrlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self configView];
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
    
    [self.view makeToast:NSLocalizedString(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
    [self.loadIngView removeFromSuperview];
}

#pragma mark - action
- (void)agreeButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UI
- (void)configView {
    
    self.webview = [[WKWebView alloc] init];
    self.webview.navigationDelegate = self;
    self.webview.UIDelegate = self;
    self.webview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webview];
    
    [self.webview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

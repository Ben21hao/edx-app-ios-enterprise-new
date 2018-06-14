//
//  TDLocalFileWebViewController.m
//  edX
//
//  Created by Elite Edu on 2018/6/6.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDLocalFileWebViewController.h"
#import <WebKit/WebKit.h>

@interface TDLocalFileWebViewController () <WKUIDelegate,WKNavigationDelegate>

@property (nonatomic,strong) WKWebView *webview;

@end

@implementation TDLocalFileWebViewController

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
    
    [self.webview loadFileURL:self.url allowingReadAccessToURL:self.url];
}

#pragma mark - delegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [self.loadIngView removeFromSuperview];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
    [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
    [self.loadIngView removeFromSuperview];
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"crash ----- %@",webView.URL.absoluteString);
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

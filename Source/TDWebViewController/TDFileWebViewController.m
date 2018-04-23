//
//  TDFileWebViewController.m
//  edX
//
//  Created by Elite Edu on 2017/12/5.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDFileWebViewController.h"
#import "edx-Swift.h"

#import "BCEDocumentReader.h"

@interface TDFileWebViewController ()<BCEDocumentReaderDelegate, WKUIDelegate, WKNavigationDelegate>

@property (nonatomic,strong) WKWebView *webview;
@property (nonatomic,strong) UIButton *downloadButton;

@property (nonatomic,strong) NSURL *url;

@property (nonatomic,strong) BCEDocumentReader *reader;

@end

@implementation TDFileWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self setViewData];
}

- (void)setViewData {
    
    TDBaseToolModel *baseTool = [[TDBaseToolModel alloc] init];
    if (![baseTool networkingState]) {
        return;
    }
    
    [self requestFileData];
    
    [self setLoadDataView];
}

- (void)requestFileData {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.couse_id forKey:@"course_id"];
    [params setValue:self.block_id forKey:@"block_id"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@/api/courses/vyingli/course_block/",ELITEU_URL];
    
    WS(weakSelf);
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"status"];
        
        if ([code intValue] == 200) {
            TDFileModel *model = [TDFileModel mj_objectWithKeyValues:responseDic];
            
            if (model) {
                weakSelf.url = [NSURL URLWithString:model.file_url];
                
                [weakSelf judgeSetViewConstranitView:model];
                [weakSelf dealWithView:[model.allow_download boolValue]];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"文档 error ------>> %@",error);
    }];
}

- (void)loadBaiduDocument:(TDFileModel *)model {
    
    NSDictionary* parameters = @{
                                 BDocPlayerSDKeyDocID: model.baidu_doc_id,
                                 BDocPlayerSDKeyToken: @"token",
                                 BDocPlayerSDKeyHost: @"BCEDOC",
                                 BDocPlayerSDKeyDocType: @"doc",
                                 BDocPlayerSDKeyTotalPageNum: @"1",
                                 BDocPlayerSDKeyDocTitle: @"文档",
                                 BDocPlayerSDKeyPageNumber : @(0)
                                 };
    
    NSError* error;
    [self.reader loadDoc:parameters error:&error];
}

- (void)docLoadingEnded:(NSError *)error {
    NSLog(@"文档加载---->>> %@",error);
    [self.loadIngView removeFromSuperview];
}

- (void)judgeSetViewConstranitView:(TDFileModel *)model {
    
    if (model.baidu_doc_id.length > 0) {
        
        self.reader = [[BCEDocumentReader alloc] init];
        self.reader.delegate = self;
        [self.view addSubview:self.reader];
        
        [self.reader mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view.mas_top).offset(0);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-43);
        }];
        
        [self loadBaiduDocument:model];

        
    } else {
        
        self.webview = [[WKWebView alloc] init];
        self.webview.navigationDelegate = self;
        self.webview.UIDelegate = self;
        self.webview.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.webview];
        
        [self.webview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-43);
        }];
        
         [self.webview loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
    
    [self addDownloadButton];
}


- (void)dealWithView:(BOOL)allow_download {

    self.downloadButton.hidden = !allow_download;
}

#pragma mark - delegate
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    [self.loadIngView removeFromSuperview];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
    [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
    [self.loadIngView removeFromSuperview];
}

#pragma mark - action
- (void)downloadButtonAction:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:self.url];
}

#pragma mark - UI
- (void)addDownloadButton {
    
    self.downloadButton = [[UIButton alloc] init];
    self.downloadButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.downloadButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.downloadButton.layer.masksToBounds = YES;
    self.downloadButton.layer.cornerRadius = 24;
    [self.downloadButton setBackgroundImage:[UIImage imageNamed:@"download_file_image"] forState:UIControlStateNormal];
    [self.downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadButton];
    
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).offset(-8);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-88);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

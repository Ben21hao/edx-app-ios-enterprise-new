//
//  TDFileDownloadViewController.m
//  edX
//
//  Created by Elite Edu on 2018/6/14.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDFileDownloadViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#define FileName @"xx_cc1.mp4"
#define FileLength @"xx_cc1.xx"

#define FILE_BACKGROUND_DOWNLOAD_SESSION_KEY @"cn.eliteu.enterprise.mobile.ios_Download_file"

@interface TDFileDownloadViewController ()  <NSURLSessionDataDelegate>

@property (nonatomic,strong) UILabel *progressLabel;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) UIButton *downLoadButton;
@property (nonatomic,strong) UIButton *removeButton;

@property (nonatomic,strong) NSOutputStream *stream;//输出流
@property (nonatomic,assign) NSInteger totalLength;// 文件总大小
@property (nonatomic,assign) NSInteger currentLength;// 已经下载大小
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSURLSessionDataTask *dataTask;

@end

@implementation TDFileDownloadViewController

-(NSURLSessionDataTask *)dataTask {
    if (!_dataTask) {
        
        self.currentLength = [self getCurrentLength];
        
        NSURL *url =[NSURL URLWithString:@"http://1228.vod.myqcloud.com/1228_838890c8c8e411e6ad39991f76a4df69.f30.mp4"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        // 将本地的data长度，塞到请求头
        NSString *rangeStr =[NSString stringWithFormat:@"bytes=%zd-",self.currentLength];
        [request setValue: rangeStr forHTTPHeaderField:@"Range"];
        _dataTask = [self.session dataTaskWithRequest:request];
    }
    return _dataTask;
}
- (NSURLSession *)session {
    
    if (!_session) {
//        NSURLSessionConfiguration *backgroundConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FILE_BACKGROUND_DOWNLOAD_SESSION_KEY]; //后台下载
//        backgroundConfiguration.allowsCellularAccess = YES; //允许用蜂窝下载
        
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = @"文件下载";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.font = [UIFont systemFontOfSize:14];
    self.progressLabel.text = @"0.0%";
    [self.view addSubview:self.progressLabel];
    
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.progressTintColor = [UIColor redColor];
    self.progressView.progress = 0.0;
    [self.view addSubview:self.progressView];
    
    self.downLoadButton = [[UIButton alloc] init];
    [self.downLoadButton setImage:[UIImage imageNamed:@"video_Pause"] forState:UIControlStateNormal];
    [self.downLoadButton setImage:[UIImage imageNamed:@"video_Play"] forState:UIControlStateSelected];
    [self.downLoadButton addTarget:self action:@selector(downLoadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downLoadButton];
    
    self.removeButton = [[UIButton alloc] init];
    [self.removeButton setImage:[UIImage imageNamed:@"video_Pause"] forState:UIControlStateNormal];
    [self.removeButton setImage:[UIImage imageNamed:@"video_Play"] forState:UIControlStateSelected];
    [self.removeButton addTarget:self action:@selector(removeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.removeButton];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(33);
        make.right.mas_equalTo(self.view.mas_right).offset(-33);
        make.top.mas_equalTo(self.view.mas_top).offset(88);
    }];
    
    [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.progressView.mas_bottom).offset(12);
        make.centerX.mas_equalTo(self.progressView.mas_centerX);
    }];
    
    [self.downLoadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.progressLabel.mas_bottom).offset(12);
        make.centerX.mas_equalTo(self.progressView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(33, 33));
    }];
    
    [self.removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.downLoadButton.mas_bottom).offset(12);
        make.centerX.mas_equalTo(self.progressView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(33, 33));
    }];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadComplish:) name:AFNetworkingTaskDidCompleteNotification object:nil];
    
    
    NSString *caches =[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:FileLength];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    if (dict) {
        self.progressView.progress = 1.0 * [self getCurrentLength]/[dict[FileLength] integerValue];
        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%",100 * self.progressView.progress];
        if (self.progressView.progress == 1) {
            self.removeButton.enabled = YES;
        }
    }
}

- (NSInteger )getCurrentLength {
    
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:FileName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *dict = [manager attributesOfItemAtPath:filePath error:nil];
    return [dict[@"NSFileSize"] integerValue];
}

- (void)saveTotal:(NSInteger)length {
    
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:FileLength];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(length) forKey:FileLength];
    [dict writeToFile:filePath atomically:YES];
}

#pragma mark - NSURLSessionDataDelegate代理方法
// 接收到服务器响应的时候调用
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    // 拿到文件总大小 获得的是当次请求的数据大小，当我们关闭程序以后重新运行，开下载请求的数据是不同的 ,所以要加上之前已经下载过的内容
    self.totalLength = response.expectedContentLength + self.currentLength;
    
    // 把文件总大小保存的沙盒 没有必要每次都存储一次,只有当第一次接收到响应，self.currentLength为零时，存储文件总大小就可以了
    if (self.currentLength == 0) {
        [self saveTotal:self.totalLength];
    }
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:FileName];
    
    // 创建输出流 如果没有文件会创建文件，YES：会往后面进行追加
    NSOutputStream *stream = [[NSOutputStream alloc] initToFileAtPath:filePath append:YES];
    [stream open];
    self.stream = stream;
    
    completionHandler(NSURLSessionResponseAllow);
}

// 接收到服务器返回数据时调用，会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    self.currentLength += data.length;
    [self.stream write:data.bytes maxLength:data.length]; // 输出流写数据
    self.progressView.progress = 1.0 * self.currentLength / self.totalLength;
    self.progressLabel.text = [NSString stringWithFormat:@"%.2ld%%",100 * self.currentLength / self.totalLength];
}

/* 在任务下载完成、下载失败或者是应用被杀掉后，重新启动应用并创建相关identifier的Session时调用
 * 当请求完成之后调用，如果请求失败error有值
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    [self.stream close];// 关闭stream
    self.stream = nil;
    self.removeButton.enabled = YES;
}

/* 应用在后台，而且后台所有下载任务完成后，
 * 在所有其他NSURLSession和NSURLSessionDownloadTask委托方法执行完后回调，
 * 可以在该方法中做下载数据管理和UI刷新
 */
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
}

#pragma mark - 下载
- (void)downLoadButtonAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    //    NSString *fileStr = @"http://120.25.226.186:32812/resources/videos/minion_02.mp4";
    ////    NSString *fileStr = @"https://www.eliteu.cn/courses/course-v1:EliteU+63040002+A1/xblock/block-v1:EliteU+63040002+A1+type@video+block@849c5bba8f864e9c97067067990cf461/handler_noauth/transcript/download?lang=zh";
    if (sender.selected) {
        [self.dataTask resume];
        
    } else {
        [self.dataTask suspend];
    }
}

- (void)removeButtonAction:(UIButton *)sender {
    
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [caches stringByAppendingPathComponent:FileName];
    
    NSURL *videoPathURL=[[NSURL alloc] initFileURLWithPath:filePath];
    
    MPMoviePlayerViewController *vc =[[MPMoviePlayerViewController alloc] initWithContentURL:videoPathURL];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

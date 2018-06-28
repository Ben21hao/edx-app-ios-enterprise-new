
//
//  TDDownloadOperation.m
//  BackgroundDownloadDemo
//
//  Created by Elite Edu on 2018/6/16.
//  Copyright © 2018年 hkhust. All rights reserved.
//

#import "TDDownloadOperation.h"
#import "NSURLSession+CorrectedResumeData.h"

#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface TDDownloadOperation () <NSURLSessionDownloadDelegate>

@property (nonatomic,strong) NSMutableDictionary *completionHandlerDictionary;
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic,strong) NSURLSession *backgroundSession;

//@property (nonatomic,strong) NSData *resumeData; //当前下载文件已下载的数据，用于续传
@property (nonatomic,assign) int64_t expectedTotalBytes; //总大小

@property (nonatomic,strong) TDSkydriveSqliteOperation *sqliteOperation;

@end

@implementation TDDownloadOperation

static TDDownloadOperation *operation = nil;
static NSURLSession *session = nil;

+ (TDDownloadOperation *)shareOperation {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operation = [[TDDownloadOperation alloc] init];
    });
    return operation;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundSession = [self backgroundURLSession];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"TDDownloadOperation --->> 销毁");
}

#pragma mark - backgroundURLSession
- (NSURLSession *)backgroundURLSession { //只有一个后台session
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"com.yourcompany.appId.BackgroundSession";
        NSURLSessionConfiguration* sessionConfig = nil;
        
//#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 80000)
        sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
//#else
//        sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
//#endif
        session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self
                                           delegateQueue:[NSOperationQueue mainQueue]];
    });
    return session;
}


#pragma mark - 对当前下载文件的操作
- (void)beginDownloadFileModel:(TDSkydrveFileModel *)model firstAdd:(BOOL)isFirst { //下载, isFirst：是否第一次加入下载
    
    self.completionHandlerDictionary = @{}.mutableCopy;
    [self.downloadTask cancelByProducingResumeData:^(NSData * resumeData) {//cancel last download task，取消上次的任务
        NSLog(@"----->> 暂停上次的任务");
    }];
    
    if (model.resumeData) { //续传
//
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10) {
//            self.downloadTask = [self.backgroundSession downloadTaskWithCorrectResumeData:model.resumeData];
//        } else {
            self.downloadTask = [self.backgroundSession downloadTaskWithResumeData:model.resumeData];
//        }
    }
    else { //第一次下载
        NSURL *downloadURL = [NSURL URLWithString:model.resources_url];
        NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
        self.downloadTask = [self.backgroundSession downloadTaskWithRequest:request];
    }
    
    [self.downloadTask resume];
    
//    NSLog(@"--->> 开始下载 %@",model.name);
    self.currentModel.status = 1;
    if (isFirst) {
        [self insertDownloadFile:model]; //加入本地数据库
    }
    else {
        if (model.udpateLocal) {
            [self updateDownloadFileStatus:model]; //更新数据库状态
        }
    }
    [self postDownloadStatusNotification:self.currentModel]; //cell状态
}

//- (void)continueDownload:(TDSkydrveFileModel *)model { //继续下载
//    
//    if (model.resumeData) {
//        if (IS_IOS10ORLATER) {
//            self.downloadTask = [self.backgroundSession downloadTaskWithCorrectResumeData:model.resumeData];
//        } else {
//            self.downloadTask = [self.backgroundSession downloadTaskWithResumeData:model.resumeData];
//        }
//        [self.downloadTask resume];
//        
//    }
//    else {
//    }
//    
//    NSLog(@"--->> 继续下载");
//    self.currentModel.status = 1;
//    [self postDownloadStatusNotification:self.currentModel];
//}

- (void)pauseDownload:(TDSkydrveFileModel *)model { //下载中 -> 暂停
    
    __weak __typeof(self) wSelf = self;
    [self.downloadTask cancelByProducingResumeData:^(NSData * resumeData) { //暂停下载
        
        __strong __typeof(wSelf) sSelf = wSelf;
        self.currentModel.resumeData = resumeData;
        
        if ([sSelf isValideResumeData:self.currentModel.resumeData]) {
            [sSelf updateDownloadFileRusumeData:self.currentModel];
        }
        NSLog(@"暂停当前任务 ----->> %@",model.resumeData);
    }];
}

- (BOOL)isValideResumeData:(NSData *)resumeData {
    if (!resumeData || resumeData.length == 0) {
        return NO;
    }
    return YES;
}

#pragma mark - 不是当前下载文件
- (void)waitChageToPause:(TDSkydrveFileModel *)model { //等待下载 -> 暂停
    
    model.status = 3;
    [self postDownloadStatusNotification:model];
    
    if (model.udpateLocal) {
        [self updateDownloadFileStatus:model]; //更新
    }
}

- (void)fileChageToWaitToDownload:(TDSkydrveFileModel *)model firstAdd:(BOOL)isFirst  { //有下载中：-> 等待 (点击 开始下载，暂停，失败)
   
    model.status = 2;
    if (isFirst) {
        [self insertDownloadFile:model];
    }
    else {
        if (model.udpateLocal) {
            [self updateDownloadFileStatus:model];
        }
    }
    [self postDownloadStatusNotification:model];
    
    NSLog(@"变等待 -->> %@",model.name);
}

- (void)nextFileBeginDownload:(TDSkydrveFileModel *)model { //有等待： 下一个 等待的任务开始下载(暂停，完成，失败 三种情况)
    [self beginDownloadFileModel:model firstAdd:NO];
}

#pragma mark - 处理kill掉程序
- (void)exitApplicationSaveResumeData { //用户退出程序

    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
    }];
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location { //下载成功
    
    NSString *locationString = [location path];
    NSLog(@"下载成功 downloadTask: %lu didFinishDownloadingToURL: %@ 本地路径: %@", (unsigned long)downloadTask.taskIdentifier, location, self.filePath);
    
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtPath:locationString toPath:self.filePath error:&error]; // 用 NSFileManager 将文件复制到应用的存储中
    
    // 通知 UI 刷新
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes { /* 从fileOffset位移处恢复下载任务 */
    
    self.expectedTotalBytes = expectedTotalBytes;
    NSLog(@"恢复下载任务：fileOffset: %lld expectedTotalBytes: %lld",fileOffset,expectedTotalBytes);
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite { //下载进度
    
//    NSLog(@"已下载 -- downloadTask:%lu percent:%.2f%% , 大小：%lld -- %lld",(unsigned long)downloadTask.taskIdentifier,(float)totalBytesWritten / totalBytesExpectedToWrite * 100,totalBytesWritten,bytesWritten);
    
    self.expectedTotalBytes = totalBytesExpectedToWrite;
    NSString *progress = [NSString stringWithFormat:@"%.2f",(float)totalBytesWritten / totalBytesExpectedToWrite];
    [self postDownlaodProgressNotification:progress]; //更新进度
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    NSLog(@"Background URL session %@ finished events.\n", session);
    
    if (session.configuration.identifier) {
        [self callCompletionHandlerForSession:session.configuration.identifier];// 调用在 -application:handleEventsForBackgroundURLSession: 中保存的 handler
    }
}

/*
 * 该方法下载成功和失败都会回调，只是失败的是error是有值的，
 * 在下载失败时，error的userinfo属性可以通过NSURLSessionDownloadTaskResumeData
 * 这个key来取到resumeData(和上面的resumeData是一样的)，再通过resumeData恢复下载
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error) {
        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) { // 看已下载的数据是否有效check if resume data are available
            
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]; //通过之前保存的resumeData，获取断点的NSURLSessionTask，调用resume恢复下载
            self.currentModel.resumeData = resumeData;
            if ([self isValideResumeData:self.currentModel.resumeData]) {
                [self updateDownloadFileRusumeData:self.currentModel];
            }
        }
        
        NSLog(@"下载error --->> %@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        if (error.code == -999) { //暂停
            
            self.currentModel.status = 3;
            if (self.currentModel.udpateLocal) {
                [self postDownloadStatusNotification:self.currentModel]; //cell的status
                [self allowUpdateLocalData];
            }
            NSLog(@"--->> 暂停下载");
        }
        else {
            self.currentModel.status = 4;
            [self postDownloadStatusNotification:self.currentModel]; //cell的status
            [self allowUpdateLocalData];
            NSLog(@"--->> 下载失败");
        }
        
    } else {
        
        [self postDownlaodProgressNotification:@"1"]; //更新progress
        self.currentModel.status = 5;
        
        [self.delegate currentFileDownloadFinish:self.currentModel]; //完成当前的下载任务
        [self postDownloadStatusNotification:self.currentModel]; //cell的status
        
        [self updateDownloadFileStatus:self.currentModel]; //更新本地状态
        if (self.currentModel.udpateLocal) {
            [self.delegate nextFileShouldBeginDownload]; //开始下一个任务
        }
        NSLog(@"--->> 下载成功");
    }
}

- (void)allowUpdateLocalData { //允许更新本地数据库
    [self updateDownloadFileStatus:self.currentModel]; //更新本地状态
    [self.delegate nextFileShouldBeginDownload]; //开始下一个任务
}

#pragma mark - 更新通知
- (void)postDownlaodProgressNotification:(NSString *)progress { //更新当前下载的进度
    
    self.currentModel.progress = [progress floatValue];
    NSString *sizeStr = [self sizeConversion];
    self.currentModel.download_size = sizeStr;
    
    int value = self.currentModel.progress * 100;
    if (value % 10 == 0) { //十分之一更新一次
        [self updateDownloadFileProgress:self.currentModel];//更新进度
        [self updateDownloadFileDownloadSize:self.currentModel];
    }
    
    NSDictionary *userInfo = @{@"progress":progress, @"download_size": sizeStr};
    NSString *name = [NSString stringWithFormat:@"%@_downloadProgressNotification",self.currentModel.id];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:userInfo];
    });
}

- (void)postDownloadStatusNotification:(TDSkydrveFileModel *)model { //对应文件：更新状态
    
    //0 未下载，1 下载中，2 等待下载，3 暂停，4 下载失败，5 下载完成
    NSDictionary *userInfo = @{@"status": [NSString stringWithFormat:@"%ld",(long)model.status]};
    NSString *name = [NSString stringWithFormat:@"%@_downloadStatusNotification",model.id];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:userInfo];
    });
}

- (NSString *)sizeConversion { //大小换算
    
    CGFloat writtenBytes = self.expectedTotalBytes * self.currentModel.progress;
    
    NSString *sizeStr = @"";
    CGFloat kb = writtenBytes/1024;
    if (kb < 1024) {
        sizeStr = [NSString stringWithFormat:@"%.0fKB",kb];
        return sizeStr;
    }
    
    CGFloat mb = kb / 1024;
    if (mb < 1024) {
        sizeStr = [NSString stringWithFormat:@"%.0fMB",mb];
        return sizeStr;
    }
    
    CGFloat gb = mb / 1024;
    sizeStr = [NSString stringWithFormat:@"%.1fGB",gb];
    
    return sizeStr;
}

#pragma mark - Save completionHandler
- (void)addCompletionHandler:(CompletionHandlerType)handler forSession:(NSString *)identifier {
    
    if ([self.completionHandlerDictionary objectForKey:identifier]) {
        NSLog(@"Error: Got multiple handlers for a single session identifier.  This should not happen.\n");
    }
    
    [self.completionHandlerDictionary setObject:handler forKey:identifier];
}

- (void)callCompletionHandlerForSession:(NSString *)identifier {
    CompletionHandlerType handler = [self.completionHandlerDictionary objectForKey:identifier];
    
    if (handler) {
        [self.completionHandlerDictionary removeObjectForKey: identifier];
        NSLog(@"Calling completion handler for session %@", identifier);
        
        handler();
    }
}

#pragma mark - 本地数据库
- (void)sqliteOperationInit:(NSString *)username {//初始化
    self.sqliteOperation = [[TDSkydriveSqliteOperation alloc] init];
    [self.sqliteOperation createSqliteForUser:username];
}

- (NSMutableArray *)getLocalDownloadFileData { //查本地数据库 - 用于初始化数据
    return [self.sqliteOperation querySqliteAllData];
}

- (void)getLocalDownloadFileSortDataBlock:(void(^)(NSMutableArray *downloadArray, NSMutableArray *finishArray))handler {
    
    [self.sqliteOperation querySqliteSortData:handler];
}

//增
- (void)insertDownloadFile:(TDSkydrveFileModel *)model { //加入
    [self.sqliteOperation insertFileData:model];
}

//改
- (void)updateDownloadFileStatus:(TDSkydrveFileModel *)model { //更新下载的状态
    [self.sqliteOperation updateFileStatus:model.status id:model.id];
}

- (void)updateDownloadFileProgress:(TDSkydrveFileModel *)model { //更新进度
    [self.sqliteOperation updateFileProgress:model.progress id:model.id];
}

- (void)updateDownloadFileRusumeData:(TDSkydrveFileModel *)model { //更新 resumeData
    [self.sqliteOperation updateFileRusumeData:model.resumeData id:model.id];
}

- (void)updateDownloadFileDownloadSize:(TDSkydrveFileModel *)model { //更新已下载大小
    [self.sqliteOperation updateFileDownloadSize:model.download_size id:model.id];
}

//删除
- (void)deleteSelectLocalFile:(NSArray *)selectArray forUser:(NSString *)username handler:(void(^)(TDSkydrveFileModel *model, BOOL isFinish))handler {
    [self.sqliteOperation deleteFileArray:selectArray forUser:username handler:handler];
}

@end



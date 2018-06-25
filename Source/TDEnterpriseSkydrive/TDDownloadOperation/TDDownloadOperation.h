//
//  TDDownloadOperation.h
//  BackgroundDownloadDemo
//
//  Created by Elite Edu on 2018/6/16.
//  Copyright © 2018年 hkhust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDSkydriveSqliteOperation.h"

@protocol TDDownloadOperationDelegate <NSObject>

- (void)nextFileShouldBeginDownload; //下一个任务

@optional
- (void)currentFileDownloadFinish:(TDSkydrveFileModel *)currentModel;//下载完一个任务，刷新任务管理页

@end

typedef void(^CompletionHandlerType)();

@interface TDDownloadOperation : NSObject

@property (nonatomic,strong) TDSkydrveFileModel *currentModel; //正在下载的文件model
@property (nonatomic,strong) NSString *filePath;

/*
 初始化
 */
+ (TDDownloadOperation *)shareOperation;
- (NSURLSession *)backgroundURLSession;//初始化后天下载

/*
 当前下载
 */
- (void)beginDownloadFileModel:(TDSkydrveFileModel *)model firstAdd:(BOOL)isFirst; //开始下载
//- (void)continueDownload:(TDSkydrveFileModel *)model; //继续下载
- (void)pauseDownload:(TDSkydrveFileModel *)model; //下载中 变 暂停下载

/*
 不是当前下载
 */
- (void)waitChageToPause:(TDSkydrveFileModel *)model; // 等待下载 -> 暂停下载
- (void)fileChageToWaitToDownload:(TDSkydrveFileModel *)model firstAdd:(BOOL)isFirst; //有下载中：-> 等待 (点击 开始下载，暂停，失败)
- (void)nextFileBeginDownload:(TDSkydrveFileModel *)model; //有等待： 下一个 等待的任务开始下载

- (void)exitApplicationSaveResumeData; //用户退出程序
- (void)addCompletionHandler:(CompletionHandlerType)handler forSession:(NSString *)identifier;// 保存 completion handler 以在处理 session 事件后更新 UI

/*
 数据库
 */

@property (nonatomic,weak) id<TDDownloadOperationDelegate> delegate;

- (void)sqliteOperationInit:(NSString *)username;//初始化

- (void)getLocalDownloadFileData:(void(^)(NSMutableArray *localArray))handler; //查询数据库所有数据 - 用于初始化数据
- (void)getLocalDownloadFileSortDataBlock:(void(^)(NSMutableArray *downloadArray, NSMutableArray *finishArray))handler;//查询

- (void)insertDownloadFile:(TDSkydrveFileModel *)model;//加入

- (void)updateDownloadFileStatus:(TDSkydrveFileModel *)model;//更新下载的状态
- (void)updateDownloadFileProgress:(TDSkydrveFileModel *)model; //更新下载进度
- (void)updateDownloadFileRusumeData:(TDSkydrveFileModel *)model; //更新 resumeData
- (void)updateDownloadFileDownloadSize:(TDSkydrveFileModel *)model; //更新已下载大小

- (void)deleteSelectLocalFile:(NSArray *)selectArray handler:(void(^)(TDSkydrveFileModel *model, BOOL isFinish))handler;//删除选中的数组
    
@end

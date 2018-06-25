//
//  TDSkydriveSqliteOperation.h
//  edX
//
//  Created by Elite Edu on 2018/6/20.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TDSkydrveFileModel.h"
#import "TDSkydrveFileModel.h"

#import "FMDatabase.h"

typedef void(^SqliteQuerySortHandler)(NSMutableArray *downloadArray, NSMutableArray *finishArray);
typedef void(^SqliteQueryHandler)(NSMutableArray *localArray);

@interface TDSkydriveSqliteOperation : NSObject

@property (nonatomic,strong) FMDatabase *dataBase;
@property (nonatomic,strong) NSString *sqlitePath;

- (void)createSqliteForUser:(NSString *)username; //创建数据库和表

- (void)insertFileData:(TDSkydrveFileModel *)model; //增

- (void)deleteFileData:(NSString *)fileId; //根据文件id来删除删
- (void)deleteFileArray:(NSArray *)selectArray handler:(void(^)(TDSkydrveFileModel *model,BOOL isFinish))handler; //批量删除

- (void)updateFileProgress:(CGFloat)progress id:(NSString *)fileId;//更新进度
- (void)updateFileStatus:(NSInteger)status id:(NSString *)fileId;//更新下载状态
-(void)updateFileRusumeData:(NSData *)resumeData id:(NSString *)fileId; //已下载数据，用于断点续传
-(void)updateFileDownloadSize:(NSString *)download_size id:(NSString *)fileId;//已下载的大小

- (void)querySqliteSortData:(SqliteQuerySortHandler)handler;//查 -分别返回未完成，已完成的文件数据
- (void)querySqlite:(SqliteQueryHandler)handler;//查所有的数据
    
- (TDSkydrveFileModel *)querySqliteFileResumeData:(TDSkydrveFileModel *)model;//查询resumedata

- (void)sqliteInit:(NSString *)username; //demo

@end

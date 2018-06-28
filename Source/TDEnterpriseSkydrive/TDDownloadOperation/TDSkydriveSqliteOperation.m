//
//  TDSkydriveSqliteOperation.m
//  edX
//
//  Created by Elite Edu on 2018/6/20.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveSqliteOperation.h"

@implementation TDSkydriveSqliteOperation

- (instancetype)init {
    
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - 创建数据库和表
- (void)createSqliteForUser:(NSString *)username { //初始化FMDatabase
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    self.sqlitePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_skydriveFile.sqlite",username]];
    self.dataBase = [FMDatabase databaseWithPath:self.sqlitePath]; //初始化对象
    
    [self createSqliteTable];
}

- (void)createSqliteTable { //创建表
    
    if ([self.dataBase open]) {
//        NSLog(@"打开数据库成功");
        
        NSString *createSql = @"CREATE TABLE IF NOT EXISTS skydrive_table (id text NOT NULL, name text NOT NULL, type text, file_type text, file_type_format text, resources_url text, created_at text, real_file_size text, file_size text, download_size text, resumeData text, progress double, status integer);";
        
        BOOL result = [self.dataBase executeUpdate:createSql];
        if (result) {
            NSLog(@"创建表成功");
        } else {
            NSLog(@"创建表失败");
        }
    }
    else {
        NSLog(@"打开数据库失败");
    }
    [self.dataBase close];
}

#pragma mark - 增
- (void)insertFileData:(TDSkydrveFileModel *)model{//增加一条数据
    
    if ([self.dataBase open]) {
//        NSLog(@"增 - 打开数据库成功");
    
        NSString *insetSql = @"INSERT INTO skydrive_table (id, name, type, file_type, file_type_format, resources_url, created_at, real_file_size, file_size, download_size, resumeData, progress, status) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";
        BOOL insert = [self.dataBase executeUpdate:insetSql, model.id, model.name, model.type, model.file_type, model.file_type_format, model.resources_url, model.created_at, model.real_file_size, model.file_size, @"0M", @"",@(model.progress),@(model.status)];
        
        if (insert) {
            NSLog(@"插入成功 %@",model.id);
        } else {
            NSLog(@"插入失败 %@",model.id);
        }
    }
    else {
        NSLog(@"增 - 打开数据库失败");
    }
    [self.dataBase close];
}

#pragma mark - 删
- (void)deleteFileData:(NSString *)fileId { //根据文件id来删除删
    
    if ([self.dataBase open]) {
    
        BOOL delete = [self.dataBase executeUpdate:@"delete from skydrive_table where id = ?", fileId];
        if (delete) {
            NSLog(@"数据库 --> 删除成功 %@", fileId);
        }
        else {
            NSLog(@"数据库 --> 删除失败 %@", fileId);
        }
    }
    [self.dataBase close];
}

- (void)deleteFileArray:(NSArray *)selectArray forUser:(NSString *)username handler:(void(^)(TDSkydrveFileModel *model, BOOL isFinish))handler { //删除选中的
    
    if ([self.dataBase open]) {
    
        for (int i = 0; i < selectArray.count; i ++) {
            
            TDSkydrveFileModel *model = selectArray[i];
            
            NSString *deleteSql = @"delete from skydrive_table where id = ?";
            BOOL delete = [self.dataBase executeUpdate:deleteSql, model.id];
            
            if (delete) {
                NSLog(@"删除成功 %@",model.id);
                
                NSString *filePath = [self getPreviewFilePathForId:model forUser:username];
                NSFileManager *manager = [NSFileManager defaultManager];
                if ([manager fileExistsAtPath:filePath]) {
                    [manager removeItemAtPath:filePath error:nil];
                    NSLog(@"----->> 移除本地文件 %@",model.name);
                }
                
                if (i == selectArray.count - 1) {
                    handler(model, YES); //最后一个
                }
                else {
                    handler(model, NO); //不是最后一个
                }
            } else {
                NSLog(@"删除失败 %@", model.id);
                
                handler(model, YES); //删除结束
            }
        }
    }
    [self.dataBase close];
}

- (NSString *)getPreviewFilePathForId:(TDSkydrveFileModel *)model forUser:(NSString *)username { //拼接路径
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *namePath = [NSString stringWithFormat:@"skydive_download_%@_%@.%@",username,model.id,model.file_type];
    NSString *filePath = [path stringByAppendingPathComponent:namePath];
    
    //    NSLog(@"文件路径------->> %@",filePath);
    return filePath;
}

#pragma mark - 改
- (void)updateFileProgress:(CGFloat)progress id:(NSString *)fileId {//更新进度
    
    if ([self.dataBase open]) {
        
        BOOL change = [self.dataBase executeUpdate:@"update skydrive_table set progress = ? where id = ?", @(progress), fileId];
        if (change) {
//            NSLog(@"progress更新成功 %@ %lf",fileId,progress);
        } else {
            NSLog(@"progress更新失败 %@ %lf",fileId,progress);
        }
    }
    [self.dataBase close];
}

-(void)updateFileStatus:(NSInteger)status id:(NSString *)fileId {//更新状态
    
    if ([self.dataBase open]) {
        
        BOOL change = [self.dataBase executeUpdate:@"update skydrive_table set status = ? where id = ?", @(status), fileId];
        
        if (change) {
            NSLog(@"status更新成功 %@ -> %ld",fileId,(long)status);
        } else {
            NSLog(@"status更新失败  %@",fileId);
        }
    }
    
    [self.dataBase close];
}

-(void)updateFileRusumeData:(NSData *)resumeData id:(NSString *)fileId {//更新 resumeData
    
    if ([self.dataBase open]) {
        
        NSString *resumeStr = [self dataToString:resumeData];
        BOOL change = [self.dataBase executeUpdate:@"update skydrive_table set resumeData = ? where id = ?", resumeStr, fileId];
        if (change) {
//            NSLog(@"resumeData更新成功 %@",resumeStr);
        } else {
            NSLog(@"resumeData更新失败 %@",resumeStr);
        }
    }
    
    [self.dataBase close];
}

-(void)updateFileDownloadSize:(NSString *)download_size id:(NSString *)fileId {
    
    if ([self.dataBase open]) {
        
        BOOL change = [self.dataBase executeUpdate:@"update skydrive_table set download_size = ? where id = ?", download_size, fileId];
        if (change) {
//            NSLog(@"download_size更新成功 %@ - %@",download_size);
        } else {
            NSLog(@"download_size更新失败 %@",download_size);
        }
    }
    
    [self.dataBase close];
}

#pragma mark - 查
- (void)querySqliteSortData:(SqliteQuerySortHandler)handler { //查整个表
    
    NSMutableArray *downloadArray = [[NSMutableArray alloc] init];
    NSMutableArray *finishArray = [[NSMutableArray alloc] init];
    
    if ([self.dataBase open]) {
//        NSLog(@"查 - 打开数据库成功");
        
        NSString *queryStr = @"select * from skydrive_table";
        FMResultSet *result = [self.dataBase executeQuery:queryStr];
        if (result) {
            
            while ([result next]) {
                TDSkydrveFileModel *model = [[TDSkydrveFileModel alloc] init];
                model.id = [result stringForColumn:@"id"];
                model.name = [result stringForColumn:@"name"];
                
                model.type = [result stringForColumn:@"type"];
                model.file_type = [result stringForColumn:@"file_type"];
                model.file_type_format = [result stringForColumn:@"file_type_format"];
                
                model.resources_url = [result stringForColumn:@"resources_url"];
                model.created_at = [result stringForColumn:@"created_at"];
                
                model.real_file_size = [result stringForColumn:@"real_file_size"];
                model.file_size = [result stringForColumn:@"file_size"];
                model.download_size = [result stringForColumn:@"download_size"];
                
                model.progress = [result doubleForColumn:@"progress"];
                if (model.progress == 1.0) {
                    model.status = 5;
                }
                else {
                    model.status = [result intForColumn:@"status"];
                }
                
                if (model.status != 5) {
                    NSString *str = [result stringForColumn:@"resumeData"];
                    if (str.length == 0) {
                        model.resumeData = nil;
                    }
                    else {
                        model.resumeData = [self strToData:str];
                    }
                }
                
                NSLog(@"数据库 --->>>%@ %@ --> %f --->>>> %ld",model.id,model.name,model.progress,(long)model.status);
                
                if (model.status == 5) {
                    [finishArray addObject:model];
                }
                else {
                    [downloadArray addObject:model];
                }
            }
            handler(downloadArray,finishArray);
        }
        
    }
    else {
        NSLog(@"查 - 打开数据库失败");
    }
    [self.dataBase close];
}

- (NSMutableArray *)querySqliteAllData { //查整个表
    
    NSMutableArray *downloadArray = [[NSMutableArray alloc] init];
    
    if ([self.dataBase open]) {
//        NSLog(@"查 - 打开数据库成功");
        
        NSString *queryStr = @"select * from skydrive_table";
        FMResultSet *result = [self.dataBase executeQuery:queryStr];
        if (result) {
            
            while ([result next]) {
                TDSkydrveFileModel *model = [[TDSkydrveFileModel alloc] init];
                model.id = [result stringForColumn:@"id"];
                model.name = [result stringForColumn:@"name"];
                
                model.type = [result stringForColumn:@"type"];
                model.file_type = [result stringForColumn:@"file_type"];
                model.file_type_format = [result stringForColumn:@"file_type_format"];
                
                model.resources_url = [result stringForColumn:@"resources_url"];
                model.created_at = [result stringForColumn:@"created_at"];
                
                model.real_file_size = [result stringForColumn:@"real_file_size"];
                model.file_size = [result stringForColumn:@"file_size"];
                model.download_size = [result stringForColumn:@"download_size"];
                
                model.progress = [result doubleForColumn:@"progress"];
                if (model.progress == 1.0) {
                    model.status = 5;
                }
                else {
                    model.status = [result intForColumn:@"status"];
                }
//                model.status = [result intForColumn:@"status"];
                
                if (model.status != 5) {
                    NSString *str = [result stringForColumn:@"resumeData"];
                    if (str.length == 0) {
                        model.resumeData = nil;
                    }
                    else {
                        model.resumeData = [self strToData:str];
                    }
                }
                
//                NSString *str = [result stringForColumn:@"resumeData"];
//                model.resumeData = [self strToData:str];
                
//                NSLog(@"查询数据库 ---> %@ -- %@", model.download_size, model.resumeData);
                [downloadArray addObject:model];
            }
        }
    }
    else {
        NSLog(@"查 - 打开数据库失败");
    }
    [self.dataBase close];
    
    return downloadArray;
}

- (TDSkydrveFileModel *)querySqliteFileResumeData:(TDSkydrveFileModel *)model { //查询resumedata
    
    if ([self.dataBase open]) {
//        NSLog(@"查 - 打开数据库成功");
        
        NSString *queryStr = @"select * from skydrive_table where id = ?";
        FMResultSet *result = [self.dataBase executeQuery:queryStr, model.id];
        if (result) {
            while ([result next]) {
                NSString *str = [result stringForColumn:@"resumeData"];
                model.resumeData = [self strToData:str];
            }
        }
    }
    else {
        NSLog(@"查 - 打开数据库失败");
    }

    [self.dataBase close];
    return model;
}

#pragma mark - data和string转换
- (NSString *)dataToString:(NSData *)data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

- (NSData *)strToData:(NSString *)str {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"本地str转resumedata: %@ -->> %@",str,data);
    return data;
}


@end

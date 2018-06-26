//
//  TDSkydrveFileModel.h
//  edX
//
//  Created by Elite Edu on 2018/6/15.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDSkydrveFileModel : NSObject

@property (nonatomic,strong) NSString *id;//文件表id
@property (nonatomic,strong) NSString *name;//文件或者文件夹名

@property (nonatomic,strong) NSString *type; //0：文件夹; 1：文件
@property (nonatomic,strong) NSString *file_type;//文件类型, png,jpeg等后缀
@property (nonatomic,strong) NSString *file_type_format;//文件分类: 0 文件夹 ，1 图片，3 文档，2 音频，4 视频， 5 压缩包，6 其他

@property (nonatomic,strong) NSString *resources_url;//文件下载地址
@property (nonatomic,strong) NSString *created_at;//创建时间

@property (nonatomic,strong) NSString *file_size;//文件大小 单位：KB，M, GB
@property (nonatomic,strong) NSString *download_size;//已下载大小
@property (nonatomic,strong) NSData *resumeData;//已下载数据,用于断点续传

@property (nonatomic,assign) CGFloat progress;//下载进度
@property (nonatomic,assign) NSInteger status; // 0 未下载，1 下载中，2 等待下载，3 暂停，4 下载失败，5 下载完成

@property (nonatomic,strong) NSString *is_shareable;//True:分享 False:不分享

@property (nonatomic,assign) BOOL isEditing;//是否正在编辑
@property (nonatomic,assign) BOOL isSelected;//是否已被选择

@property (nonatomic,assign) BOOL udpateLocal;//是否更新本地数据库

@end

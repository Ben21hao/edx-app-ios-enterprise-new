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
@property (nonatomic,strong) NSString *type;//0：文件夹; 1：文件
@property (nonatomic,strong) NSString *file_size;//文件大小 单位：KB，M, GB
@property (nonatomic,strong) NSString *file_type;//文件类型
@property (nonatomic,strong) NSString *resources_url;//文件下载地址
@property (nonatomic,strong) NSString *is_shareable;//True:分享 False:不分享
@property (nonatomic,strong) NSString *created_at;//创建时间

@end

//
//  TDSkydriveNoSupportViewController.h
//  edX
//
//  Created by Elite Edu on 2018/6/14.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDBaseViewController.h"
#import "TDDownloadOperation.h"

@interface TDSkydriveNoSupportViewController : TDBaseViewController

@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) TDSkydrveFileModel *model;
@property (nonatomic,strong) NSString *filePath;//本地文件路径

@property (nonatomic,strong) TDDownloadOperation *downloadOperation;

@end

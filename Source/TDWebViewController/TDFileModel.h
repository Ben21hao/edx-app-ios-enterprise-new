//
//  TDFileModel.h
//  edX
//
//  Created by Elite Edu on 2017/12/5.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDFileModel : NSObject

@property (nonatomic,strong) NSString *file_url; //文档url
@property (nonatomic,strong) NSString *allow_download; //是否允许下载
@property (nonatomic,strong) NSArray *file_image; //图片数组

@end

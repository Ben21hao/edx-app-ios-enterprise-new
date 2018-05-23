//
//  TDWebThumbImageModel.h
//  edX
//
//  Created by Elite Edu on 2018/5/8.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDWebThumbImageModel : NSObject

+ (UIImage *)getThumbnailImage:(NSString *)videoPath; //本地视频缩略图
+ (UIImage *)getVideoThumbnailImage:(NSString *)videoUrl isLoacal:(BOOL)isLocal; //isLocal 是否是本地视频

@end

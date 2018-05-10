//
//  TDWebThumbImageModel.h
//  edX
//
//  Created by Elite Edu on 2018/5/8.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDWebThumbImageModel : NSObject

+ (UIImage *)getThumbnailImage:(NSString *)videoPath;
+ (UIImage *)getWebUrlVideoThumbnailImage:(NSString *)videoUrl;

@end

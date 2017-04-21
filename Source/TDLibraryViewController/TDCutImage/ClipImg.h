//
//  ClipImg.h
//  edX
//
//  Created by Elite Edu on 16/9/27.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClipImg : NSObject
+ (UIImage *)imageWithBorderW:(CGFloat)borderW borderColor:(UIColor *)color image:(UIImage *)image;
+ (UIImage *)imageWithColor:(UIColor *)color;
@end

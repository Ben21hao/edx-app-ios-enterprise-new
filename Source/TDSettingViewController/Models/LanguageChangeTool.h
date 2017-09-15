//
//  LanguageChangeTool.h
//  edX
//
//  Created by Elite Edu on 2017/9/12.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LanguageChangeTool : NSObject

+ (NSBundle *)bundle;//获取当前资源文件 

+ (void)initUserLanguage;//初始化语言文件

+ (void)setUserlanguage:(NSString *)language;//设置当前语言

@end

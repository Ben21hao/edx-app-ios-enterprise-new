//
//  LanguageChangeTool.m
//  edX
//
//  Created by Elite Edu on 2017/9/12.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "LanguageChangeTool.h"

@implementation LanguageChangeTool

static NSBundle *bundle = nil;

+ ( NSBundle *)bundle{
    
    return bundle;
    
}

// userLanguage储存在NSUserDefaults中，首次加载时要检测是否存在，如果不存在的话读AppleLanguages，并赋值给userLanguage。
+ (void)initUserLanguage{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *string = [userDefault valueForKey:@"userLanguage"];
    
    //获取系统当前语言版本(中文zh-Hans-CN,英文en-CN)
    NSArray* languages = [userDefault objectForKey:@"AppleLanguages"];
    NSString *systemStr = [languages objectAtIndex:0];
    
    if(string.length == 0){
        
        string = [systemStr isEqualToString:@"en-CN"] || [systemStr isEqualToString:@"en"] ? @"en" : @"zh-Hans";

        [userDefault setValue:string forKey:@"userLanguage"];
        [userDefault synchronize];//持久化，不加的话不会保存
    }
    
    //获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:string ofType:@"lproj"];
    bundle = [NSBundle bundleWithPath:path]; //生成bundle
}

// 设置语言方法
+ (void)setUserlanguage:(NSString *)language{
    
    NSLog(@"设置语言 ---->>>> %@",language);
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj" ]; //1.第一步改变bundle的值
    bundle = [NSBundle bundleWithPath:path];
    
    [userDefault setValue:language forKey:@"userLanguage"]; //2.持久化
    [userDefault synchronize];
}


@end
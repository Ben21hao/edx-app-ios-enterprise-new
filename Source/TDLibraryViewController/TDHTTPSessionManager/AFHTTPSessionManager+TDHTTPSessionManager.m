//
//  AFHTTPSessionManager+TDHTTPSessionManager.m
//  edX
//
//  Created by Elite Edu on 2018/5/31.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "AFHTTPSessionManager+TDHTTPSessionManager.h"

static AFHTTPSessionManager *manager;

@implementation AFHTTPSessionManager (TDHTTPSessionManager)

+ (AFHTTPSessionManager *)shareManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
    });
    return manager;
}

@end

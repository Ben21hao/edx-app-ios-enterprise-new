//
//  TDReachabilityManager.m
//  edX
//
//  Created by Elite Edu on 2018/6/26.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDReachabilityManager.h"
#import "OEXInterface.h"
#import "Reachability.h"

@implementation TDReachabilityManager

+ (void)startReachability { //检测网络状态 - 状态有变化时，就会有检测
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: {//未知网络
                NSLog(@"未知网络");
            }
//                break;
            case AFNetworkReachabilityStatusNotReachable: { //无法联网
                NSLog(@"无法联网");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Network_Status_NotReachable" object:nil];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: {//手机自带网络
                
                BOOL wifiOnly = [OEXInterface shouldDownloadOnlyOnWifi];
                if (wifiOnly) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Network_Status_ReachableViaWWAN" object:nil];
                }
                NSLog(@"当前使用的是2g/3g/4g网络");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: {//WIFI
                NSLog(@"当前在WIFI网络下");
            }
        }
    }];
}


@end

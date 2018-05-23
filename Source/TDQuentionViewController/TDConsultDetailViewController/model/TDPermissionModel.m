//
//  TDPermissionModel.m
//  edX
//
//  Created by Elite Edu on 2018/5/2.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDPermissionModel.h"
#import "NSString+OEXFormatting.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation TDPermissionModel

#pragma mark - 授权
- (BOOL)requestAVMediaTypePermissionInController:(UIViewController *)vc type:(NSInteger)type { //0 相机； 1 麦克风
    
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:type == 0 ? AVMediaTypeVideo : AVMediaTypeAudio];
    switch (audioStatus) {
        case AVAuthorizationStatusNotDetermined: { //未询问过用户是否授权
            
            WS(weakSelf);
            [AVCaptureDevice requestAccessForMediaType:type == 0 ? AVMediaTypeVideo : AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {
                    NSLog(@"---允许用户使用%ld",(long)type);
                }
                if (type == 0) { //不管允许不允许，都询问麦克风的授权
                    [weakSelf requestAVMediaTypePermissionInController:vc type:1];
                }
                else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"TD_User_Allow_AVCaptureDevice" object:nil];
                }
            }];
        }
            break;
            
        case AVAuthorizationStatusRestricted: //未授权，例如家长控制
            //            break;
        case AVAuthorizationStatusDenied://未授权，用户曾选择过拒绝授权
            [self showAuthenAlertViewInController:vc type:type];
            break;
            
        case AVAuthorizationStatusAuthorized://已经授权
            return YES;
            break;
            
        default:
            break;
    }
    return NO;
}


- (BOOL)requestPhotoLibraryPermissionInController:(UIViewController *)vc { //相册权限
    
    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoStatus) {
        case PHAuthorizationStatusNotDetermined: { //第一次选择
            
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {//获取图片权限
                if (status == PHAuthorizationStatusAuthorized) { //点击允许
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"TD_User_Allow_PHPhotoLibrary" object:nil];
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted://不能完成授权，可能开启了访问限制
            //            break;
        case PHAuthorizationStatusDenied://禁止了 -- 提示跳转相册授权设置
            [self showAuthenAlertViewInController:vc type:2];
            break;
            
        case PHAuthorizationStatusAuthorized://已经通过授权
            return YES;
            break;
            
        default:
            break;
    }
    return NO;
}

#pragma mark - 设置权限
- (void)showAuthenAlertViewInController:(UIViewController *)vc type:(NSInteger)type {//0 相机； 1 麦克风；2 相册
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDic));
    NSString *appName = infoDic[@"CFBundleDisplayName"];
    
    NSString *messageStr;
    switch (type) {
        case 0:
            messageStr = [TDLocalizeSelect(@"ALLOW_USE_CAMERA_TEXT", nil) oex_formatWithParameters:@{@"name": appName}];
            break;
        case 1:
            messageStr = [TDLocalizeSelect(@"ALLOW_USE_MICROPHONE_TEXT", nil) oex_formatWithParameters:@{@"name": appName}];
            break;
        default:
            messageStr = [TDLocalizeSelect(@"ALLOW_USE_ALBUM_TEXT", nil) oex_formatWithParameters:@{@"name": appName}];
            break;
    }
    
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:TDLocalizeSelect(@"SYSTEM_WARING", nil) message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
        });
    }];
    [alertControl addAction:cancelAction];
    [alertControl addAction:sureAction];
    
    [vc presentViewController:alertControl animated:YES completion:nil];
}

@end

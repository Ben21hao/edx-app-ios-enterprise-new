//
//  TDPermissionModel.h
//  edX
//
//  Created by Elite Edu on 2018/5/2.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDPermissionModel : NSObject

- (BOOL)requestAVMediaTypePermissionInController:(UIViewController *)vc type:(NSInteger)type;
- (BOOL)requestPhotoLibraryPermissionInController:(UIViewController *)vc;

@end

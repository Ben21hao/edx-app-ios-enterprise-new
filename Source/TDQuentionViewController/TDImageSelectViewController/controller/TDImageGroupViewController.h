//
//  TDImageGroupViewController.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/12.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDBaseViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface TDImageGroupViewController : TDBaseViewController

@property (nonatomic,strong) NSArray *hadImageArray;

@property (nonatomic,copy) void(^selectHandle)(NSArray *imageArray);

@end

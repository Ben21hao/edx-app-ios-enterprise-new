//
//  TDImageSelectViewController.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/10.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDBaseViewController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TDImageSelectViewController : TDBaseViewController

@property (nonatomic, strong) PHAssetCollection *assetCollection;

@property (nonatomic,strong) NSArray *hadImageArray;

@end

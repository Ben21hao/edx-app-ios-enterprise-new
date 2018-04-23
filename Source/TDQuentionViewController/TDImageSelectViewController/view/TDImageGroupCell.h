//
//  TDImageGroupCell.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/12.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseNormalCell.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface TDImageGroupCell : TDBaseNormalCell

- (void)reloadDataWithAssetCollection:(PHAssetCollection *)assetCollection;

@end

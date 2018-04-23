//
//  TDPreviewImageCell.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/13.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDSelectImageModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface TDPreviewImageCell : UICollectionViewCell

- (void)setPreviewImageCell;

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) TDSelectImageModel *model;

@end

//
//  TDImageSelectCell.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/10.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDSelectImageModel.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface TDImageSelectCell : UICollectionViewCell

- (void)setSelectCell;

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIButton *selectButton;
@property (nonatomic,strong) UIView *shadowView;

@property (nonatomic,strong) TDSelectImageModel *model;

@end


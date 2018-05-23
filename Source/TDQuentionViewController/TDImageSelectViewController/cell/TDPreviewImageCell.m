//
//  TDPreviewImageCell.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/13.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDPreviewImageCell.h"
#import "TDImageHandle.h"

#define collectionCell_Width (TDWidth - 16)/4

@implementation TDPreviewImageCell

- (void)setModel:(TDSelectImageModel *)model {
    _model = model;
    
    [self showImageWithPHAsset:model.asset];
}

- (void)showImageWithPHAsset:(PHAsset *)asset {
    
    WS(weakSelf);
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {//视频只能拿到collectionCell_Width宽高的缩略图
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [asset thumbnail:CGSizeMake(collectionCell_Width, collectionCell_Width) resultHandler:^(UIImage *result, NSDictionary *info) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.imageView.image = result;
                    weakSelf.model.image = result;
                });
            }];
        });
    }
    else {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [asset original:^(UIImage *result, NSDictionary *info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.imageView.image = result;
                    weakSelf.model.image = result;
                });
            }];
        });
    }

}

- (void)setPreviewImageCell {
    
    if (self.imageView) {
        return;
    }
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.clipsToBounds = YES;
    self.imageView.userInteractionEnabled = YES;
    [self addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
}

@end

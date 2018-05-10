//
//  TDPreviewImageCell.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/13.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDPreviewImageCell.h"
#import "TDImageHandle.h"

@implementation TDPreviewImageCell

- (void)setModel:(TDSelectImageModel *)model {
    _model = model;
    
    [self showImageWithPHAsset:model.asset];
}

- (void)showImageWithPHAsset:(PHAsset *)asset {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        WS(weakSelf);
        [asset thumbnail:CGSizeMake(TDWidth, TDHeight) resultHandler:^(UIImage *result, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageView.image = result;
            });
        }];
    });
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

//
//  TDImageGroupCell.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/12.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDImageGroupCell.h"
#import "TDImageHandle.h"

@interface TDImageGroupCell ()

@property (nonatomic,strong) UIImageView *groupImageView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *numLabel;
@property (nonatomic,strong) UIImageView *accesImageView;

@end

@implementation TDImageGroupCell

- (void)reloadDataWithAssetCollection:(PHAssetCollection *)assetCollection {
    
    self.nameLabel.text = assetCollection.localizedTitle;
    self.numLabel.text = [NSString stringWithFormat:@"(%zd)", [assetCollection numberOfAssets]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        WS(weakSelf);
        [assetCollection posterImage:CGSizeMake(58, 58) resultHandler:^(UIImage *result, NSDictionary *info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.groupImageView.image = result;
            });
        }];
    });
    
}

- (void)configView {
    self.groupImageView = [[UIImageView alloc] init];
    self.groupImageView.clipsToBounds = YES;
    self.groupImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.bgView addSubview:self.groupImageView];
    
    self.nameLabel = [self setLabelStyle:14 color:colorHexStr10];
    [self.bgView addSubview:self.nameLabel];
    
    self.numLabel = [self setLabelStyle:12 color:colorHexStr8];
    [self.bgView addSubview:self.numLabel];
    
    self.accesImageView = [[UIImageView alloc] init];
    self.accesImageView.image = [UIImage imageNamed:@"right_gray_image"];
    [self.bgView addSubview:self.accesImageView];
    
}

- (void)setViewConstraint {
    
    [self.groupImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.top.mas_equalTo(self.bgView.mas_top).offset(5);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-5);
        make.width.mas_equalTo(58);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.groupImageView.mas_right).offset(8);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
    
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(8);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
    
    [self.accesImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
}

@end

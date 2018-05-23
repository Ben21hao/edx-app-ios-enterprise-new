//
//  TDImageSelectCell.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/10.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDImageSelectCell.h"
#import "TDImageHandle.h"

#define collectionCell_Width (TDWidth - 16)/4

@implementation TDImageSelectCell

- (void)setModel:(TDSelectImageModel *)model {
    _model = model;
    
    BOOL isVideo = model.asset.mediaType == PHAssetMediaTypeVideo;

    self.durationLabel.hidden = !isVideo;
    self.videoImage.hidden = !isVideo;
    self.selectButton.hidden = isVideo;
    
    if (isVideo) {
 
        int minute = model.asset.duration / 60;
        int second = (int)model.asset.duration % 60;
        self.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    }

    [self reloadDataWithPHAsset:model.asset];
}

- (void)reloadDataWithPHAsset:(PHAsset *)asset { //将图片信息在cell显示出来

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        WS(weakSelf);
        [asset thumbnail:CGSizeMake(collectionCell_Width, collectionCell_Width) resultHandler:^(UIImage *result, NSDictionary *info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageView.image = result;
                weakSelf.model.image = result;
            });
        }];
    });
}

- (void)showShadow { //显示阴影
//    NSLog(@"--------%@",self.model.asset);
    self.selectButton.selected = self.model.selected;
    self.shadowView.hidden = self.model.selected;
}

- (void)hiddenShadow { //隐藏阴影
//    NSLog(@"----++++++-%@",self.model.asset);
    self.selectButton.selected = self.model.selected;
    self.shadowView.hidden = YES;
}

- (void)showVideoShadow {
    self.shadowView.hidden = self.model.asset.mediaType != PHAssetMediaTypeVideo;
}

- (void)hiddenVideoShadow {
    self.shadowView.hidden = YES;
}

#pragma mark - UI
- (void)setSelectCell {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showShadow) name:@"cell_showShadow" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenShadow) name:@"cell_hiddenShadow" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showVideoShadow) name:@"cell_video_showShadow" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hiddenVideoShadow) name:@"cell_video_hiddenShadow" object:nil];
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self addSubview:self.bgView];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.image = [UIImage imageNamed:@"image_loading"];
    [self.bgView addSubview:self.imageView];
    
    self.selectButton = [[UIButton alloc] init];
    [self.selectButton setImage:[UIImage imageNamed:@"select_not_roud"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"selected_roud"] forState:UIControlStateSelected];
    [self.bgView addSubview:self.selectButton];
    
    self.videoImage = [[UIImageView alloc] init];
    self.videoImage.image = [UIImage imageNamed:@"video_white_image"];
    [self.bgView addSubview:self.videoImage];
    
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.font = [UIFont fontWithName:@"OPenSans" size:12];
    self.durationLabel.textColor = [UIColor whiteColor];
    [self.bgView addSubview:self.durationLabel];
    
    self.shadowView = [[UIView alloc] init];
    self.shadowView.backgroundColor = [UIColor blackColor];
    self.shadowView.alpha = 0.6;
    [self.bgView addSubview:self.shadowView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.bgView);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(self.bgView);
        make.size.mas_equalTo(CGSizeMake(33, 33));
    }];
    
    [self.videoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-13);
    }];
    
    [self.durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.videoImage.mas_right).offset(8);
        make.centerY.mas_equalTo(self.videoImage.mas_centerY);
    }];
    
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.bgView);
    }];
    
    self.durationLabel.hidden = YES;
    self.videoImage.hidden = YES;
    
    self.shadowView.hidden = YES;
}

@end

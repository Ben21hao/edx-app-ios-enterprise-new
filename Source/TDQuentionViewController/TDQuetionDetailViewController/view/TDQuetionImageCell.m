//
//  TDQuetionImageCell.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDQuetionImageCell.h"

#define Image_Height (TDWidth - 26 - 4 * 10) / 4

@interface TDQuetionImageCell ()

@property (nonatomic,strong) UIView *photoView;

@end

@implementation TDQuetionImageCell

- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    
    for (int i = 0; i < imageArray.count; i ++) {
        UIImageView *headerImage = [[UIImageView alloc] init];
        headerImage.image = [UIImage imageNamed:imageArray[i]];
        [self.photoView addSubview:headerImage];
        
        [headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.photoView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(Image_Height, Image_Height));
            make.left.mas_equalTo(self.photoView.mas_left).offset((Image_Height + 10) * i);
        }];
    }
}

- (void)configView {
    
    self.photoView = [[UIView alloc] init];
    [self.bgView addSubview:self.photoView];
}

- (void)setViewConstraint {
    
    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.top.mas_equalTo(self.bgView.mas_top).offset(5);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-5);
    }];
}

@end

//
//  TDWebImagePreviewCell.m
//  edX
//
//  Created by Elite Edu on 2018/1/22.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDWebImagePreviewCell.h"

#import <UIImageView+WebCache.h>

@implementation TDWebImagePreviewCell

- (void)setUrlStr:(NSString *)urlStr {
    _urlStr = urlStr;
    
    NSString *imageStr = [NSString stringWithFormat:@"%@",urlStr];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"image_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        [self.activityView stopAnimating];
        
    }];
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
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(TDWidth / 2, TDHeight / 2, 30, 30)];
    [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.activityView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.activityView startAnimating];
}

@end

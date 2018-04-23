//
//  TDWebImagePreviewCell.h
//  edX
//
//  Created by Elite Edu on 2018/1/22.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDWebImagePreviewCell : UICollectionViewCell

- (void)setPreviewImageCell;

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;

@property (nonatomic,strong) NSString *urlStr;

@end

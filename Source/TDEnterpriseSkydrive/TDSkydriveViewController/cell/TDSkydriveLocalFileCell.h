//
//  TDSkydriveLocalFileCell.h
//  edX
//
//  Created by Elite Edu on 2018/6/12.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDSkydriveLocalFileCell : UITableViewCell

@property (nonatomic,strong) UIImageView *leftImageView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *sizeLabel;
@property (nonatomic,strong) UILabel *statusLabel;
@property (nonatomic,strong) UIButton *downloadButton;
@property (nonatomic,strong) UIButton *selectButton;

@end

//
//  TDSkydriveFileCell.h
//  edX
//
//  Created by Elite Edu on 2018/6/11.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDSkydrveFileModel.h"
#import "TDSkydriveProgressView.h"

@interface TDSkydriveFileCell : UITableViewCell

@property (nonatomic,strong) UIImageView *leftImageView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *sizeLabel;
@property (nonatomic,strong) UIButton *shareButton;
@property (nonatomic,strong) TDSkydriveProgressView *progressView;

@property (nonatomic,strong) TDSkydrveFileModel *fileModel;

@end

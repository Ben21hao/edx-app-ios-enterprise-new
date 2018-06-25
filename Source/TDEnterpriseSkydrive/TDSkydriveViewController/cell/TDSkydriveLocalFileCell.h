//
//  TDSkydriveLocalFileCell.h
//  edX
//
//  Created by Elite Edu on 2018/6/12.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDSkydrveFileModel.h"
#import "TDSkydriveProgressView.h"

@interface TDSkydriveLocalFileCell : UITableViewCell

@property (nonatomic,strong) UIImageView *leftImageView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *sizeLabel;
@property (nonatomic,strong) UILabel *statusLabel;

@property (nonatomic,strong) TDSkydriveProgressView *progressView;; //下载
@property (nonatomic,strong) UIButton *selectButton; //选择

@property (nonatomic,assign) BOOL isEditing;//是否正在编辑

@property (nonatomic,strong) TDSkydrveFileModel *fileModel;

@end

//
//  TDConsultImageCell.m
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDConsultImageCell.h"
#import "TDRoundHeadImageView.h"
#import <UIImageView+WebCache.h>

#define IMAGE_WIDTH (TDWidth - 95) / 4

@interface TDConsultImageCell ()

@property (nonatomic,strong) TDRoundHeadImageView *headerImage;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UIView *photoView;

@property (nonatomic,strong) NSArray *imageArray;

@end

@implementation TDConsultImageCell

- (void)setDetailModel:(TDConsultDetailModel *)detailModel {
    _detailModel = detailModel;
    
    [self dealWithCellData];
    
    if (detailModel.content.length > 0) {
        self.imageArray = [detailModel.content componentsSeparatedByString:@","];
        [self setImageViewConstraint:self.imageArray];
    }
}

- (void)dealWithCellData {
    
    self.timeView.timeLabel.text = self.detailModel.created_at;
    self.nameLabel.text = self.detailModel.username;
    
    NSURL *headerUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ELITEU_URL,self.detailModel.userprofile_image]];
    [self.headerImage sd_setImageWithURL:headerUrl placeholderImage:[UIImage imageNamed:@"default_dark_image"]];
    
    [self updateCellConstraint];
}

- (void)updateCellConstraint {
    
    BOOL isShow = [self.detailModel.is_show_time boolValue];
    
    if (!isShow) {
        [self.timeView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.bgView);
            make.top.mas_equalTo(self.bgView.mas_top).offset(0);
            make.height.mas_equalTo(0);
        }];
        
        [self.headerImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bgView.mas_left).offset(13);
            make.top.mas_equalTo(self.timeView.mas_bottom).offset(-11);
            make.size.mas_equalTo(CGSizeMake(38, 38));
        }];
        
        self.timeView.hidden = YES;
        self.headerImage.hidden = YES;
        self.nameLabel.hidden = YES;
    }
}

- (void)setImageViewConstraint:(NSArray *)imageArray {
    
    if (imageArray.count > 0) {
        for (int i = 0; i < imageArray.count; i ++) {
            
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.tag = i;
            imageView.userInteractionEnabled = YES;
            [self.photoView addSubview:imageView];
            
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.photoView);
                make.size.mas_equalTo(CGSizeMake(IMAGE_WIDTH, IMAGE_WIDTH));
                make.left.mas_equalTo(self.photoView.mas_left).offset(i * IMAGE_WIDTH);
            }];
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",imageArray[i]]];
            [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_loading"]];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            [imageView addGestureRecognizer:tap];
        }
        
        [self.photoView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.nameLabel.mas_left);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(3);
            make.size.mas_equalTo(CGSizeMake(imageArray.count * IMAGE_WIDTH, IMAGE_WIDTH));
        }];
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    
    if (self.tapImageHandle) {
        self.tapImageHandle(self.imageArray,tap.view.tag);
    }
}

#pragma mark - UI
- (void)configView {
    self.bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    self.timeView = [[TDConsultTimeView alloc] init];
    [self.bgView addSubview:self.timeView];
    
    self.headerImage = [[TDRoundHeadImageView alloc] initWithSize:CGSizeMake(38, 38) borderColor:colorHexStr13];
    self.headerImage.image = [UIImage imageNamed:@"default_dark_image"];
    [self.bgView addSubview:self.headerImage];
    
    self.nameLabel = [self setLabelStyle:14 color:colorHexStr8];
    [self.bgView addSubview:self.nameLabel];
    
    self.photoView = [[UIView alloc] init];
    [self.bgView addSubview:self.photoView];
    
    self.statusButton = [[UIButton alloc] init];
    [self.statusButton setImage:[UIImage imageNamed:@"consult_send_failed"] forState:UIControlStateNormal];
    [self.bgView addSubview:self.statusButton];

    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.bgView addSubview:self.activityView];
    
//    [self.activityView startAnimating];
    self.statusButton.hidden = YES;
}

- (void)setViewConstraint {
    
    [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.bgView);
        make.top.mas_equalTo(self.bgView.mas_top).offset(8);
        make.height.mas_equalTo(38);
    }];
    
    [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.top.mas_equalTo(self.timeView.mas_bottom).offset(8);
        make.size.mas_equalTo(CGSizeMake(38, 38));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headerImage.mas_right).offset(8);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.bottom.mas_equalTo(self.headerImage.mas_centerY).offset(-3);
    }];
    
    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(3);
        make.size.mas_equalTo(CGSizeMake(TDWidth - 95, IMAGE_WIDTH));
    }];
    
    [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.photoView.mas_centerY);
        make.left.mas_equalTo(self.photoView.mas_right).offset(3);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.statusButton.mas_centerY);
        make.centerX.mas_equalTo(self.statusButton.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
}

@end

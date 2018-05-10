
//
//  TDConsultAudioCell.m
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDConsultAudioCell.h"
#import "TDRoundHeadImageView.h"
#import "TDAudioPlayView.h"
#import <UIImageView+WebCache.h>

@interface TDConsultAudioCell ()

@property (nonatomic,strong) TDRoundHeadImageView *headerImage;
@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) TDAudioPlayView *audioPlayView;

@end

@implementation TDConsultAudioCell

- (void)setDetailModel:(TDConsultDetailModel *)detailModel {
    _detailModel = detailModel;
    
    [self dealWithCellData];
}

- (void)dealWithCellData {
    
    self.timeView.timeLabel.text = self.detailModel.created_at;
    self.nameLabel.text = self.detailModel.username;
    
    NSURL *headerUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ELITEU_URL,self.detailModel.userprofile_image]];
    [self.headerImage sd_setImageWithURL:headerUrl placeholderImage:[UIImage imageNamed:@"default_dark_image"]];
    
    CGFloat rate = [self.detailModel.content_duration floatValue] / 60;
    CGFloat width = rate * (TDWidth - 95);
    [self.timeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(3);
        make.size.mas_equalTo(CGSizeMake(width, 30));
    }];
    
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
    
    self.audioPlayView = [[TDAudioPlayView alloc] init];
    [self.bgView addSubview:self.audioPlayView];
    
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
    
    [self.audioPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(3);
        make.size.mas_equalTo(CGSizeMake(188, 30));
    }];
    
    [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.audioPlayView.mas_centerY);
        make.left.mas_equalTo(self.audioPlayView.mas_right).offset(3);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.statusButton.mas_centerY);
        make.centerX.mas_equalTo(self.statusButton.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
}

@end

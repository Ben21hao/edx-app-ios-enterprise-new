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
#import "TDSelectImageModel.h"
#import "NSString+OEXFormatting.h"

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
    
    if (detailModel.isSending || detailModel.sendFailed) { //正在发送的用本地图片，后台数据网络图片
        if (detailModel.imageArray.count > 0) {
            self.imageArray = detailModel.imageArray;
        }
    }
    else {
        if (detailModel.content.length > 0) {
            self.imageArray = [detailModel.content componentsSeparatedByString:@","];
        }
    }
    [self setImageViewConstraint:self.imageArray];
}

- (void)dealWithCellData {
    
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
    else {
        self.timeView.timeLabel.text = self.detailModel.created_at;
        if ([self.detailModel.is_reply boolValue]) {
            if ([self.detailModel.user_id isEqualToString:self.userId]) {
                self.nameLabel.attributedText = [self setDetailString:TDLocalizeSelect(@"ANSWERED_BY_ME", nil) name:TDLocalizeSelect(@"ME", nil)];
            } else {
                self.nameLabel.attributedText = [self setDetailString:[TDLocalizeSelect(@"CONSULTATION_REPLIED", nil) oex_formatWithParameters:@{@"name" : self.detailModel.username}] name:self.detailModel.username];
            }
        }
        else {
            self.nameLabel.text = self.detailModel.username;
        }
        
        NSURL *headerUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ELITEU_URL,self.detailModel.userprofile_image]];
        [self.headerImage sd_setImageWithURL:headerUrl placeholderImage:[UIImage imageNamed:@"default_dark_image"]];
    }
    
    self.detailModel.isSending ? [self.activityView startAnimating] : [self.activityView stopAnimating];
    self.statusButton.hidden = !self.detailModel.sendFailed;
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
            
            if (self.detailModel.isSending || self.detailModel.sendFailed) { //本地的图片
                TDSelectImageModel *model = imageArray[i];
                imageView.image = model.image;
            }
            else {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",imageArray[i]]];
                [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_loading"]];
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
                [imageView addGestureRecognizer:tap];
            }
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

- (NSMutableAttributedString *)setDetailString:(NSString *)titleStr name:(NSString *)nameStr {
    
    NSRange range = [titleStr rangeOfString:nameStr];//空格
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:titleStr
                                                                             attributes:@{                                                                                          NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr9]
                                                                                                                                                                                    }];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:nameStr
                                                                             attributes:@{                                                                                          NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr8]
                                                                                                                                                                                    }];
    [str1 replaceCharactersInRange:range withAttributedString:str2];
    return str1;
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
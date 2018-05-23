//
//  TDConsultVideoCell.m
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDConsultVideoCell.h"
#import "TDRoundHeadImageView.h"
#import "TDWebThumbImageModel.h"
#import <UIImageView+WebCache.h>
#import "NSString+OEXFormatting.h"

#define VIDEO_WIDTH (TDWidth - 95) / 4

@interface TDConsultVideoCell ()

@property (nonatomic,strong) TDRoundHeadImageView *headerImage;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *videoTimeLabel;

@end

@implementation TDConsultVideoCell

- (void)setDetailModel:(TDConsultDetailModel *)detailModel {
    _detailModel = detailModel;
    
    [self dealWithCellData];
}

- (void)dealWithCellData {
    
    if (self.detailModel.videoImage) {
        [self.videoButton setBackgroundImage:self.detailModel.videoImage forState:UIControlStateNormal];
    }
    else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            UIImage *videoImage = [TDWebThumbImageModel getVideoThumbnailImage:[NSString stringWithFormat:@"%@",self.detailModel.content] isLoacal:self.detailModel.isSending || self.detailModel.sendFailed];
            
            self.detailModel.videoImage = videoImage;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.videoButton setBackgroundImage:videoImage forState:UIControlStateNormal];
                
            });
        });
    }

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
    
    int time = [self.detailModel.content_duration intValue];
    int minute = time / 60;
    int second = time % 60;
    self.videoTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",minute,second];
    
    self.videoButton.userInteractionEnabled = !self.detailModel.isSending && !self.detailModel.sendFailed; //正在发送或发送失败的消息不能点
    self.detailModel.isSending ? [self.activityView startAnimating] : [self.activityView stopAnimating];
    self.statusButton.hidden = !self.detailModel.sendFailed;
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
    
    self.videoButton = [[UIButton alloc] init];
    self.videoButton.backgroundColor = [UIColor colorWithHexString:colorHexStr7];
    [self.videoButton setImage:[UIImage imageNamed:@"transparent_play"] forState:UIControlStateNormal];
//    [self.videoButton setBackgroundImage:[UIImage imageNamed:@"video_sending_image"] forState:UIControlStateNormal];
    [self.bgView addSubview:self.videoButton];
    
    self.videoTimeLabel = [self setLabelStyle:12 color:colorHexStr13];
    [self.bgView addSubview:self.videoTimeLabel];
    
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
        make.height.mas_equalTo(28);
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
    
    [self.videoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(3);
        make.size.mas_equalTo(CGSizeMake(VIDEO_WIDTH, VIDEO_WIDTH));
    }];
    
    [self.videoTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.videoButton.mas_right).offset(-8);
        make.bottom.mas_equalTo(self.videoButton.mas_bottom).offset(-3);
    }];
    
    [self.statusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.videoButton.mas_centerY);
        make.left.mas_equalTo(self.videoButton.mas_right).offset(3);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.statusButton.mas_centerY);
        make.centerX.mas_equalTo(self.statusButton.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
}

@end

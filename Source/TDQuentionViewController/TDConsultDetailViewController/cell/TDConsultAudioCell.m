
//
//  TDConsultAudioCell.m
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDConsultAudioCell.h"
#import "TDRoundHeadImageView.h"
#import <UIImageView+WebCache.h>

#import "NSString+OEXFormatting.h"

@interface TDConsultAudioCell ()

@property (nonatomic,strong) TDRoundHeadImageView *headerImage;
@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) NSTimer *playTimer;
@property (nonatomic,assign) NSInteger voiceDuration;
@property (nonatomic,assign) NSInteger playImageNum;

@end

@implementation TDConsultAudioCell

- (void)setDetailModel:(TDConsultDetailModel *)detailModel {
    _detailModel = detailModel;
    
    [self dealWithCellData];
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
    
    self.audioPlayView.timeLabel.text = [NSString stringWithFormat:@"%@”",self.detailModel.content_duration];
    CGFloat rate = [self.detailModel.content_duration floatValue] / 30;
    CGFloat width = rate * (TDWidth - 95);
    CGFloat audioWith = width > (TDWidth - 95) ? (TDWidth - 95) : width;
    [self.audioPlayView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(3);
        make.size.mas_equalTo(CGSizeMake(audioWith > 68 ? audioWith : 68, 30));
    }];
    
    if (self.detailModel.isPlaying) {
        [self voicePlaying:self.detailModel.content_duration];
    }
    
    self.detailModel.isSending ? [self.activityView startAnimating] : [self.activityView stopAnimating];
    self.statusButton.hidden = !self.detailModel.sendFailed;
    
    if (self.detailModel.isSending || self.detailModel.sendFailed) {
        return;
    }
    WS(weakSelf);
    self.audioPlayView.tapAction = ^(){
        [weakSelf playAudioWithVoiceUrl:weakSelf.detailModel.content duration:weakSelf.detailModel.content_duration];
    };
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

#pragma mark - 播放语音
- (void)playAudioWithVoiceUrl:(NSString *)voice_url duration:(NSString *)duration {
    
    if (self.playTimer) {
        [self invalidatePlayTimer:YES];
        return;
    }
    
    if (self.tapVoiceViewHandle) {
        self.tapVoiceViewHandle(YES);
    }
    
    self.voiceDuration = [duration integerValue] * 2 + 1;
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playTimerAction) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leaveVoiceNotifi:) name:@"user_leave_voiceView" object:nil];
}

- (void)voicePlaying:(NSString *)duration { //tableview 上下滑动，cell复用的动画处理
    
    if (self.playTimer) {
        [self invalidatePlayTimer:YES];
        return;
    }
    
    self.voiceDuration = [duration integerValue] * 2 + 1; //四舍五入少了1
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playTimerAction) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playToEndTime:) name:@"voice_play_endTime_notificatiion" object:nil];
}

- (void)playToEndTime:(NSNotification *)notifi {
    self.voiceDuration = 0;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"voice_play_endTime_notificatiion" object:nil];
}

- (void)leaveVoiceNotifi:(NSNotification *)notifi {
    if (self.playTimer) {
        [self invalidatePlayTimer:YES];
    }
}

- (void)playTimerAction { //开始
    
    if (self.voiceDuration <= 0) {
        [self invalidatePlayTimer:NO];
        return;
    }
    
    self.voiceDuration --;
    self.playImageNum ++;
    
    switch (self.playImageNum % 3) {
        case 0:
            self.audioPlayView.imageView.image = [UIImage imageNamed:@"player_three_image"];
            break;
        case 1:
            self.audioPlayView.imageView.image = [UIImage imageNamed:@"player_one_image"];
            break;
        default:
            self.audioPlayView.imageView.image = [UIImage imageNamed:@"player_two_image"];
            break;
    }
    
}

- (void)invalidatePlayTimer:(BOOL)stopVoice { //停止
    
    if (self.tapVoiceViewHandle) {
        self.tapVoiceViewHandle(NO);
    }
    
    [self.playTimer invalidate];
    self.playTimer = nil;
    
    self.audioPlayView.imageView.image = [UIImage imageNamed:@"player_black_image"];
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    
    //用户点击其他的语音时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapVoiceNotifi:) name:@"user_tap_other_voiceView" object:nil];
}

- (void)tapVoiceNotifi:(NSNotification *)notifi {
    
    NSString *indexStr = notifi.userInfo[@"row_user_tap"];
    if ([indexStr integerValue] != self.index) { //用户点击其他行的语音时，停止当前行的语音
        
        if (self.playTimer) {
            [self invalidatePlayTimer:YES];
            return;
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

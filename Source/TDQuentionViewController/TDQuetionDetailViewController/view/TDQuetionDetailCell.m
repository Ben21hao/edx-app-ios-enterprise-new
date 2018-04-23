//
//  TDQuetionDetailCell.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDQuetionDetailCell.h"
#import <UIImageView+WebCache.h>

#define Image_Height (TDWidth - 26 - 4 * 10) / 4

@interface TDQuetionDetailCell ()

@property (nonatomic,strong) UILabel *line;
@property (nonatomic,strong) TDBaseToolModel *baseTool;

@property (nonatomic,strong) NSTimer *playTimer;
@property (nonatomic,assign) NSInteger playImageNum;
@property (nonatomic,assign) NSInteger voiceDuration;

@end

@implementation TDQuetionDetailCell


- (void)setQuetionModel:(TDQuetionDetailModel *)quetionModel { //咨询内容
    _quetionModel = quetionModel;
    
    [self configQuetionView:YES voiceUrl:quetionModel.context.voice.voice_url duration:quetionModel.context.voice.voice_duration];
    [self setQuetionCellViewConstraint];
    
    self.quetionTitle.text = self.quetionModel.title;
    self.quetionDetail.text = self.quetionModel.context.text;
    
    if (self.quetionModel.isPlaying) {
        [self voicePlaying:self.quetionModel.context.voice.voice_duration];
    }
    
    if (self.quetionModel.context.pic_url.count == 0) {
        return;
    }
    [self dealImageViewArray:self.quetionModel.context.pic_url];
}

- (void)setReplyModel:(TDQuetionReplyInfoModel *)replyModel { //回复内容
    _replyModel = replyModel;
    
    [self configQuetionView:NO voiceUrl:replyModel.reply_context.reply_voice.voice_url duration:replyModel.reply_context.reply_voice.voice_duration];
    [self setReplyCellViewConstraint];
    
    self.quetionDetail.text = self.replyModel.reply_context.reply_text;
    
    if (self.replyModel.isPlaying) {
        [self voicePlaying:self.replyModel.reply_context.reply_voice.voice_duration];
    }
    
    if (self.replyModel.reply_context.reply_pic_url.count == 0) {
        return;
    }
    [self dealImageViewArray:self.replyModel.reply_context.reply_pic_url];
}

#pragma mark - 图片
- (void)dealImageViewArray:(NSArray *)imageArray { //显示图片
    
    for (int i = 0; i < imageArray.count; i ++) {
        
        NSString *imageStr = [NSString stringWithFormat:@"%@",imageArray[i]];
        
        UIImageView *headerImage = [[UIImageView alloc] init];
        headerImage.userInteractionEnabled = YES;
        headerImage.tag = i;
        [headerImage sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"image_loading"]];
        [self.photoView addSubview:headerImage];
        
        [headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.photoView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(Image_Height, Image_Height));
            make.left.mas_equalTo(self.photoView.mas_left).offset((Image_Height + 10) * i);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [headerImage addGestureRecognizer:tap];
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap { //点击图片
    NSLog(@"---->>> %ld",tap.view.tag);
    
    if (self.tapImageHandle) {
        self.tapImageHandle(tap.view.tag);
    }
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
- (void)configQuetionView:(BOOL)isQuetion voiceUrl:(NSString *)voiceUrl duration:(NSString *)duration {
    
    if (isQuetion) {
        
        self.quetionTitle = [self setLabelStyle:14 color:colorHexStr10];
        self.quetionTitle.numberOfLines = 0;
        [self.bgView addSubview:self.quetionTitle];
        
        self.line = [[UILabel alloc] init];
        self.line.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
        [self.bgView addSubview:self.line];
    }
    
    self.quetionDetail = [self setLabelStyle:14 color:colorHexStr9];
    self.quetionDetail.numberOfLines = 0;
    [self.bgView addSubview:self.quetionDetail];
    
    self.audioPlayView = [[TDAudioPlayView alloc] init];
    self.audioPlayView.layer.masksToBounds = YES;
    self.audioPlayView.layer.cornerRadius = 15.0;
    self.audioPlayView.layer.borderWidth = 1;
    self.audioPlayView.layer.borderColor = [UIColor colorWithHexString:colorHexStr6].CGColor;
    WS(weakSelf);
    self.audioPlayView.tapAction = ^(){
        [weakSelf playAudioWithVoiceUrl:voiceUrl duration:duration];
    };
    [self.bgView addSubview:self.audioPlayView];
    
    self.photoView = [[UIView alloc] init];
    [self.bgView addSubview:self.photoView];
    
}

- (void)setQuetionCellViewConstraint { //咨询内容
    
    CGFloat textHeight = [self.baseTool heightForString:self.quetionModel.context.text font:14 width:TDWidth - 26];
    CGFloat realHeight = self.quetionModel.context.text.length == 0 ? 0 : (textHeight > 43 ? textHeight : 43);
    
    CGFloat imageHeight = (TDWidth - 26 - 4 * 10) / 4 + 18;
    BOOL hasVoice = self.quetionModel.context.voice.voice_url.length > 0;
    BOOL hasImage = self.quetionModel.context.pic_url.count > 0;
    
    [self.quetionTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.top.mas_equalTo(self.bgView.mas_top).offset(0);
        make.height.mas_equalTo(48);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.quetionTitle);
        make.top.mas_equalTo(self.quetionTitle.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.quetionDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.quetionTitle);
        make.top.mas_equalTo(self.line.mas_bottom).offset(8);
        make.height.mas_equalTo(realHeight);
    }];
    
    self.audioPlayView.hidden = !hasVoice;
    CGFloat voiceWidth = 88;
    if (hasVoice) {
        self.audioPlayView.timeLabel.text = [NSString stringWithFormat:@"%@”",self.quetionModel.context.voice.voice_duration];
        voiceWidth = [self.quetionModel.context.voice.voice_duration floatValue] * (TDWidth - 88) / 60;
    }
    
    [self.audioPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.height.mas_equalTo(hasVoice ? 30 : 0);
        make.width.mas_equalTo(voiceWidth > 88 ? voiceWidth : 88);
        make.top.mas_equalTo(self.quetionDetail.mas_bottom).offset(8);
    }];
    
    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.top.mas_equalTo(self.audioPlayView.mas_bottom).offset(hasImage ? 5 : 0);
        make.height.mas_equalTo(imageHeight);
    }];

}

- (void)setReplyCellViewConstraint { //回复内容
    
    CGFloat textHeight = [self.baseTool heightForString:self.replyModel.reply_context.reply_text font:14 width:TDWidth - 26] + 10;
    CGFloat realHeight = self.replyModel.reply_context.reply_text.length == 0 ? 0 : (textHeight > 43 ? textHeight : 43);
    
    CGFloat imageHeight = (TDWidth - 26 - 4 * 10) / 4 + 18;
    BOOL hasVoice = self.replyModel.reply_context.reply_voice.voice_url.length > 0;
    BOOL hasImage = self.replyModel.reply_context.reply_pic_url.count > 0;
    
    [self.quetionDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.top.mas_equalTo(self.bgView.mas_top);
        make.height.mas_equalTo(realHeight);
    }];
    
    self.audioPlayView.hidden = !hasVoice;
    
    CGFloat voiceWidth = 88;
    if (hasVoice) {
        self.audioPlayView.timeLabel.text = [NSString stringWithFormat:@"%@”",self.replyModel.reply_context.reply_voice.voice_duration];
        voiceWidth = [self.replyModel.reply_context.reply_voice.voice_duration floatValue] * (TDWidth - 88) / 60;
    }
    
    [self.audioPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.height.mas_equalTo(hasVoice ? 30 : 0);
        make.width.mas_equalTo(voiceWidth > 88 ? voiceWidth : 88);
        make.top.mas_equalTo(self.quetionDetail.mas_bottom).offset(hasVoice ? 8 : 0);
    }];
    
    [self.photoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.top.mas_equalTo(self.audioPlayView.mas_bottom).offset(hasImage ? 5 : 0);
        make.height.mas_equalTo(imageHeight);
    }];

}

- (void)configView {
    
    self.baseTool = [[TDBaseToolModel alloc] init];
    
}

- (void)setViewConstraint {
    
}


@end

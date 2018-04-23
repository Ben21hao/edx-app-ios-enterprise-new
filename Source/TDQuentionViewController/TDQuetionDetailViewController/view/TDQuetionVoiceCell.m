//
//  TDQuetionVoiceCell.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDQuetionVoiceCell.h"

@implementation TDQuetionVoiceCell

- (void)configView {
    
    self.audioPlayView = [[TDAudioPlayView alloc] init];
    self.audioPlayView.layer.masksToBounds = YES;
    self.audioPlayView.layer.cornerRadius = 15.0;
    self.audioPlayView.layer.borderWidth = 1;
    self.audioPlayView.layer.borderColor = [UIColor colorWithHexString:colorHexStr6].CGColor;
    [self.bgView addSubview:self.audioPlayView];

}

- (void)setViewConstraint {
    
    [self.audioPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo((TDWidth - 26) * 48/60);
    }];

}

@end

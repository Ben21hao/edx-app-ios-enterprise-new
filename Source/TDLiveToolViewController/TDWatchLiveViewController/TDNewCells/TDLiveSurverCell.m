//
//  TDLiveSurverCell.m
//  edX
//
//  Created by Ben on 2017/7/28.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDLiveSurverCell.h"

@interface TDLiveSurverCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UILabel *lblNickName;
@property (nonatomic,strong) UILabel *lblTime;

@end

@implementation TDLiveSurverCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)surveyButtonAction:(UIButton *)sender {
    
    _clickSurveyItem(_model);
}

#pragma mark - UI
- (void)configView {
    
    self.bgView = [[UIView alloc] init];
    [self.contentView addSubview:self.bgView];

    self.surveyLabel = [[UILabel alloc] init];
    self.surveyLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.surveyLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.surveyLabel.text = TDLocalizeSelect(@"SURVEY_TEXT", nil);
    [self.bgView addSubview:self.surveyLabel];
    
    self.surveyButton = [[UIButton alloc] init];
    self.surveyButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    [self.surveyButton setTitleColor:[UIColor colorWithHexString:@"#FF7F00"] forState:UIControlStateNormal];
    [self.surveyButton setTitle:TDLocalizeSelect(@"ACQUIRE_SURVEY", nil) forState:UIControlStateNormal];
    [self.surveyButton addTarget:self action:@selector(surveyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.surveyButton];
}

- (void)setViewConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];

    [self.surveyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.width.mas_equalTo(158);
    }];
    
    [self.surveyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.surveyLabel.mas_right).offset(0);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(118, 39));
    }];
}

@end

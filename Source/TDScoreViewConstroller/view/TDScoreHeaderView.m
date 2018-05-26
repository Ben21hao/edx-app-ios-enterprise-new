//
//  TDScoreHeaderView.m
//  edX
//
//  Created by Elite Edu on 2018/5/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDScoreHeaderView.h"

@implementation TDScoreHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)setScoreModel:(TDCourseScoreModel *)scoreModel {
    _scoreModel = scoreModel;
    
    self.statusLabel.text = @"课程进行中";
    if ([scoreModel.course_status intValue] == 1) {
        self.statusLabel.text = @"恭喜！您已成功通过此课程!";
    }
    else if ([scoreModel.course_status intValue] == 3) {
        self.statusLabel.text = @"很遗憾！您未能通过此课程！";
    }
    
    self.scoreLabel.text = [NSString stringWithFormat:@"%.0lf%%",[scoreModel.current_grade floatValue]*100];
    self.progressView.progress = [scoreModel.current_grade floatValue];
    
    self.percentLabel.text = [NSString stringWithFormat:@"%.0lf%%",[scoreModel.course_passed_grade floatValue]*100];
    
    [self updateHeaderViewConstraint];
}

- (void)updateHeaderViewConstraint {
    
    [self.passImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.progressView.mas_centerY);
        make.centerX.mas_equalTo(self.progressView.mas_left).offset((TDWidth - 36) * [self.scoreModel.course_passed_grade floatValue]);
    }];
    
    self.leftImageView.backgroundColor = [UIColor colorWithHexString: [self.scoreModel.current_grade floatValue] <= 0 ? colorHexStr7 : colorHexStr1];
    
}

#pragma mark - UI
- (void)configView {
    
    self.statusLabel = [self setLabelStyleFont:16 color:@"#000000"];
    [self addSubview:self.statusLabel];
    
    self.scoreLabel = [self setLabelStyleFont:58 color:@"#8FC31F"];
    [self addSubview:self.scoreLabel];
    
    self.showLabel = [self setLabelStyleFont:12 color:colorHexStr9];
    self.showLabel.text = @"课程得分";
    [self addSubview:self.showLabel];
    
    self.bgImageView = [self setImageViewStyle:7 color:colorHexStr6];
    [self addSubview:self.bgImageView];
    
    self.leftImageView = [self setImageViewStyle:3 color:colorHexStr1];
    [self addSubview:self.leftImageView];
    
    self.rightImageView = [self setImageViewStyle:3 color:colorHexStr7];
    [self addSubview:self.rightImageView];
    
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.tintColor = [UIColor colorWithHexString:colorHexStr1];
    self.progressView.trackTintColor = [UIColor colorWithHexString:colorHexStr7];
    [self addSubview:self.progressView];
    
    self.passImageView = [[UIImageView alloc] init];
    self.passImageView.image = [UIImage imageNamed:@"score_pass_image"];
    [self addSubview:self.passImageView];
    
    self.passLabel = [self setLabelStyleFont:10 color:colorHexStr9];
    self.passLabel.text = @"及格线";
    [self addSubview:self.passLabel];
    
    self.percentLabel = [self setLabelStyleFont:8 color:colorHexStr13];
    [self addSubview:self.percentLabel];
}

- (void)setViewConstraint {
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.mas_top).offset(18);
    }];
    
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.statusLabel.mas_bottom).offset(8);
    }];
    
    [self.showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self.scoreLabel.mas_bottom).offset(0);
    }];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(18);
        make.right.mas_equalTo(self.mas_right).offset(-18);
        make.top.mas_equalTo(self.showLabel.mas_bottom).offset(28);
        make.height.mas_equalTo(14);
    }];
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgImageView.mas_centerY);
        make.left.mas_equalTo(self.bgImageView.mas_left).offset(5);
        make.size.mas_equalTo(CGSizeMake(6, 6));
    }];
    
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgImageView.mas_centerY);
        make.right.mas_equalTo(self.bgImageView.mas_right).offset(-5);
        make.size.mas_equalTo(CGSizeMake(6, 6));
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).offset(0);
        make.right.mas_equalTo(self.rightImageView.mas_left).offset(0);
        make.centerY.mas_equalTo(self.bgImageView.mas_centerY);
        make.height.mas_equalTo(2);
    }];
    
    [self.passImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.progressView.mas_centerY);
        make.centerX.mas_equalTo(self.progressView.mas_left).offset((TDWidth - 36) * 0.6);
    }];
    
    [self.passLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgImageView.mas_bottom).offset(5);
        make.centerX.mas_equalTo(self.passImageView.mas_centerX);
    }];
    
    [self.percentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.passImageView.mas_centerX);
        make.top.mas_equalTo(self.passImageView.mas_top).offset(3);
    }];

}

- (UILabel *)setLabelStyleFont:(NSInteger)font color:(NSString *)colorStr {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"OpenSans" size:font];
    label.textColor = [UIColor colorWithHexString:colorStr];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (UIImageView *)setImageViewStyle:(CGFloat)corradius color:(NSString *)colorStr {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.layer.masksToBounds = YES;
    imageView.layer.cornerRadius = corradius;
    imageView.backgroundColor = [UIColor colorWithHexString:colorStr];
    return imageView;
}

@end



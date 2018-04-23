//
//  TDAudioPlayView.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/9.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDAudioPlayView.h"

@interface TDAudioPlayView ()

@property (nonatomic,strong) UIView *bgView;

@end

@implementation TDAudioPlayView

- (void)configeView {
    
    self.bgView = [[UIView alloc] init];
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 15.0;
    self.bgView.layer.borderColor = [UIColor colorWithHexString:colorHexStr7].CGColor;
    self.bgView.layer.borderWidth = 1.0;
    [self addSubview:self.bgView];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"player_black_image"];
    [self.bgView addSubview:self.imageView];
    
    self.timeLabel = [self setLabelStyleFont:12 color:colorHexStr8];
    [self.bgView addSubview:self.timeLabel];
    
    self.timeLabel.text = @"48‘";

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self addGestureRecognizer:tap];
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (self.longPressAction) {
        self.longPressAction();
    }
}

- (void)tap:(UITapGestureRecognizer *)sender {
    if (self.tapAction) {
        self.tapAction();
    }
}

- (void)setViewConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(8);
        make.centerY.mas_equalTo(self.bgView);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.centerY.mas_equalTo(self.bgView);
    }];
}

@end

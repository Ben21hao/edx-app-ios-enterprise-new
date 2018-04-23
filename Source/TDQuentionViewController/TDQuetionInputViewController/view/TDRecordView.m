//
//  TDRecordView.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/8.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDRecordView.h"

@interface TDRecordView ()

@property (nonatomic,strong) UIView *bgView;

@end

@implementation TDRecordView

- (void)configeView {
//    self.backgroundColor = [UIColor colorWithHexString:colorHexStr3];
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr2];
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 10;
    [self addSubview:self.bgView];
    
    self.remindLabel = [self setLabelStyleFont:12 color:colorHexStr13];
    self.remindLabel.textAlignment = NSTextAlignmentCenter;
    self.remindLabel.layer.masksToBounds = YES;
    self.remindLabel.layer.cornerRadius = 4.0;
    [self.bgView addSubview:self.remindLabel];
    
    self.imageView = [[UIImageView alloc] init];
    [self.bgView addSubview:self.imageView];
    
    self.remindLabel.text = TDLocalizeSelect(@"SCROLL_UP_TO_CANCEL", nil);
    self.imageView.image = [UIImage imageNamed:@"record_white_image"];
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(148, 148));
    }];
    
    [self.remindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-8);
        make.height.mas_equalTo(28);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bgView.mas_centerX);
        make.centerY.mas_equalTo(self.bgView.mas_centerY).offset(-18);
    }];
}

@end

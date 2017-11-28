//
//  TDWelcomeView.m
//  edX
//
//  Created by Elite Edu on 2017/11/27.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDWelcomeView.h"

@interface TDWelcomeView ()

@property (nonatomic,strong) UILabel *mottoLabel;
@property (nonatomic,strong) UILabel *eMottoLabel;
@property (nonatomic,strong) UIImageView *logoImage;

@end

@implementation TDWelcomeView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    }
    return self;
}

- (void)startShowWelcome {
    
    [self configView];
    [self setViewConstrait];
}

- (void)configView {
    
    self.mottoLabel = [[UILabel alloc] init];
//    self.mottoLabel.text = @"学则变  变则进";
    self.mottoLabel.textAlignment = NSTextAlignmentCenter;
    self.mottoLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.mottoLabel.font = [UIFont fontWithName:@"OpenSans" size:18];
    [self addSubview:self.mottoLabel];
    
    self.eMottoLabel = [[UILabel alloc] init];
//    self.eMottoLabel.text = @"Learn to change, change to improve. ";
    self.eMottoLabel.textAlignment = NSTextAlignmentCenter;
    self.eMottoLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.eMottoLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    [self addSubview:self.eMottoLabel];
    
    self.logoImage = [[UIImageView alloc] init];
//    self.logoImage.image = [UIImage imageNamed:@"edx_logo_login"];
    [self addSubview:self.logoImage];
    
}
- (void)setViewConstrait {
    
    [self.mottoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_centerY);
        make.left.right.mas_equalTo(self);
    }];
    
    [self.eMottoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_centerY);
        make.left.right.mas_equalTo(self);
    }];
    
    [self.logoImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-18);
    }];
}


@end

//
//  TDNodataView.m
//  edX
//
//  Created by Elite Edu on 2018/6/11.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDNodataView.h"

@interface TDNodataView ()

@end

@implementation TDNodataView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self configeView];
        [self setViewConstraint];
    }
    return self;
}

- (void)configeView {
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.imageView = [[UIImageView alloc] init];
    [self addSubview:self.imageView];
    
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    [self addSubview:self.messageLabel];
}

- (void)setViewConstraint {
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(self.mas_centerY).offset(0);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.imageView.mas_centerX);
        make.top.mas_equalTo(self.imageView.mas_bottom).offset(11);
    }];

}

@end

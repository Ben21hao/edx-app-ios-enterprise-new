//
//  TDLoginVerticationView.m
//  edX
//
//  Created by Elite Edu on 2018/5/23.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDLoginVerticationView.h"

@implementation TDLoginVerticationView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)configView {
    
    self.phoneTextFied = [[UITextField alloc] init];
    self.phoneTextFied.placeholder = TDLocalizeSelect(@"PHONE_OR_EMAIL", nil);
    self.phoneTextFied.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.phoneTextFied.font = [UIFont fontWithName:@"OpenSans" size:15];
    self.phoneTextFied.borderStyle = UITextBorderStyleRoundedRect;
    self.phoneTextFied.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self addSubview:self.phoneTextFied];
    
    self.sendButton = [[TDBaseButton alloc] init];
    self.sendButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.sendButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.sendButton.layer.cornerRadius = 4.0;
        self.sendButton.showsTouchWhenHighlighted = YES;
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitle:@"发送验证码" forState:UIControlStateNormal];
    [self addSubview:self.sendButton];
    
}

- (void)setViewConstraint {
    
    [self.phoneTextFied mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(33);
        make.right.mas_equalTo(self.mas_right).offset(-33);
        make.top.mas_equalTo(self.mas_top).offset(18);
        make.height.mas_equalTo(41);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(33);
        make.right.mas_equalTo(self.mas_right).offset(-33);
        make.top.mas_equalTo(self.phoneTextFied.mas_bottom).offset(18);
        make.height.mas_equalTo(41);
    }];
}

@end

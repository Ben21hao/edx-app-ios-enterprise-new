//
//  TDLoginMessageView.m
//  edX
//
//  Created by Elite Edu on 2018/5/23.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDLoginMessageView.h"

@implementation TDLoginMessageView

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
    self.phoneTextFied.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.phoneTextFied.borderStyle = UITextBorderStyleRoundedRect;
    self.phoneTextFied.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self addSubview:self.phoneTextFied];
    
    self.codeTextFied = [[UITextField alloc] init];
    self.codeTextFied.placeholder = TDLocalizeSelect(@"ENTER_VERI_HOLDER", nil);
    self.codeTextFied.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.codeTextFied.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.codeTextFied.borderStyle = UITextBorderStyleRoundedRect;
    self.codeTextFied.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self addSubview:self.codeTextFied];

    self.codeButton = [[UIButton alloc] init];
    self.codeButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.codeButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.codeButton.layer.masksToBounds = YES;
    self.codeButton.layer.cornerRadius = 4.0;
    self.codeButton.showsTouchWhenHighlighted = YES;
    [self.codeButton setTitle:TDLocalizeSelect(@"GET_VERIFICATION", nil) forState:UIControlStateNormal];
    [self addSubview:self.codeButton];
    
    self.loginButton = [[TDBaseButton alloc] init];
    self.loginButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.loginButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.loginButton.layer.masksToBounds = YES;
    self.loginButton.layer.cornerRadius = 4.0;
    self.loginButton.showsTouchWhenHighlighted = YES;
    [self.loginButton setTitle:TDLocalizeSelect(@"SIGN_IN", nil) forState:UIControlStateNormal];
    [self addSubview:self.loginButton];
    
    self.codeActivitView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.codeActivitView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.codeActivitView];
    
    self.phoneTextFied.userInteractionEnabled = NO;
}

- (void)setViewConstraint {
    
    [self.phoneTextFied mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(18);
        make.left.mas_equalTo(self.mas_left).offset(33);
        make.right.mas_equalTo(self.mas_right).offset(-33);
        make.height.mas_equalTo(41);
    }];
    
    [self.codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneTextFied.mas_bottom).offset(9);
        make.right.mas_equalTo(self.mas_right).offset(-33);
        make.size.mas_equalTo(CGSizeMake(88, 41));
    }];
    
    [self.codeTextFied mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.codeButton.mas_top).offset(0);
        make.left.mas_equalTo(self.mas_left).offset(33);
        make.right.mas_equalTo(self.codeButton.mas_left).offset(-5);
        make.height.mas_equalTo(41);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.codeTextFied.mas_bottom).offset(18);
        make.left.mas_equalTo(self.mas_left).offset(33);
        make.right.mas_equalTo(self.mas_right).offset(-33);
        make.height.mas_equalTo(41);
    }];
    
    [self.codeActivitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.codeButton.mas_centerY);
        make.centerX.mas_equalTo(self.codeButton.mas_centerX);
    }];
}

@end

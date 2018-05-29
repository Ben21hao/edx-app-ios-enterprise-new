//
//  TDMessgeLoginView.m
//  edX
//
//  Created by Elite Edu on 2018/5/23.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDMessgeLoginView.h"

@interface TDMessgeLoginView ()

@property (nonatomic,strong) UIImageView *mapImageView;
@property (nonatomic,strong) UIImageView *logoImageView;

@end

@implementation TDMessgeLoginView

- (instancetype)initWithType:(TDLoginMessageViewType)type {
    
    self = [super init];
    if (self) {
        [self configView:type];
        [self setViewConstraint:type];
    }
    return self;
}

- (void)configView:(TDLoginMessageViewType)type {
    
    self.backgroundColor = [UIColor colorWithHexString:colorHexStr13];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.contentSize = CGSizeMake(TDWidth, TDHeight - BAR_ALL_HEIHT);
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    self.mapImageView = [[UIImageView alloc] init];
    self.mapImageView.image = [UIImage imageNamed:@"map_bg"];
    [self.scrollView addSubview:self.mapImageView];
    
    self.logoImageView = [[UIImageView alloc] init];
    self.logoImageView.image = [UIImage imageNamed:@"login_logo"];
    [self.scrollView addSubview:self.logoImageView];
    
    if (type == TDLoginMessageViewTypeVertication) {
        self.verticationView = [[TDLoginVerticationView alloc] init];
        [self.scrollView addSubview:self.verticationView];
    } else {
        self.messageView = [[TDLoginMessageView alloc] init];
        [self.scrollView addSubview:self.messageView];
    }

    self.passwordButton = [[TDBaseButton alloc] init];
    self.passwordButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.passwordButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.passwordButton.showsTouchWhenHighlighted = YES;
    [self.passwordButton setTitleColor:[UIColor colorWithHexString:colorHexStr1] forState:UIControlStateNormal];
    [self.passwordButton setTitle:TDLocalizeSelect(@"TD_LOGIN_ACCOUNT_BUTTON", nil) forState:UIControlStateNormal];
    [self.scrollView addSubview:self.passwordButton];
    
    self.bottomButton = [[UIButton alloc] init];
    self.bottomButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomButton.titleLabel.numberOfLines = 0;
    self.bottomButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.bottomButton.showsTouchWhenHighlighted = YES;
    [self.bottomButton setAttributedTitle:[self setAttribute] forState:UIControlStateNormal];
    [self addSubview:self.bottomButton];
    
    self.userInteractionEnabled = YES;
    self.exclusiveTouch = YES;
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedToDismiss)];
    [self addGestureRecognizer:tapGesture];
}

- (void)setViewConstraint:(TDLoginMessageViewType)type {
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self);
        make.width.mas_equalTo(TDWidth);
    }];
    
    [self.mapImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.scrollView.mas_left).offset(35);
        make.top.mas_equalTo(self.scrollView.mas_top).offset(10);
        make.size.mas_equalTo(CGSizeMake(TDWidth - 70, 151));
        make.bottom.mas_equalTo(self.scrollView.mas_bottom).offset(-(TDHeight - 161 - BAR_ALL_HEIHT));
    }];
    
    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mapImageView.mas_centerX);
        make.centerY.mas_equalTo(self.mapImageView.mas_centerY);
    }];
    
    if (type == TDLoginMessageViewTypeVertication) {
        
        [self.verticationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.scrollView);
            make.top.mas_equalTo(self.mapImageView.mas_bottom).offset(0);
            make.size.mas_equalTo(CGSizeMake(TDWidth, 118));
        }];
        
        [self.passwordButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.verticationView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(128, 39));
            make.top.mas_equalTo(self.verticationView.mas_bottom).offset(18);
        }];
    }
    else {
        [self.messageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.scrollView);
            make.top.mas_equalTo(self.mapImageView.mas_bottom).offset(0);
            make.size.mas_equalTo(CGSizeMake(TDWidth ,177));
        }];
        
        [self.passwordButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.messageView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(128, 39));
            make.top.mas_equalTo(self.messageView.mas_bottom).offset(18);
        }];
    }
    
    [self.bottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX).offset(0);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-18);
        make.right.mas_equalTo(self.mas_right).offset(-8);
        make.height.mas_equalTo(39);
    }];
}

- (NSMutableAttributedString *)setAttribute {
    NSString *str = [NSString stringWithFormat:@"%@\n",TDLocalizeSelect(@"SIGN_IP_AGREE_TEXT", nil)];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr8]}];
    
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:TDLocalizeSelect(@"AGREEMENT", nil) attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr1]}];
    [str1 appendAttributedString:str2];
    return str1;
}

- (void)tappedToDismiss {
    [self endEditing:YES];
}

@end

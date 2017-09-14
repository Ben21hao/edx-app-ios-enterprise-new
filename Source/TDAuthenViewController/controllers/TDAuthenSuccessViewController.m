//
//  TDAuthenSuccessViewController.m
//  edX
//
//  Created by Elite Edu on 17/2/8.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDAuthenSuccessViewController.h"

@interface TDAuthenSuccessViewController ()

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UILabel *messageLabel;

@end

@implementation TDAuthenSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = TDLocalizeSelect(@"AUTHENTICATION_MESSAGE", nil);
    
    [self configView];
    [self setViewConstraint];
}

#pragma mark - UI
- (void)configView {
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"success"];
    [self.view addSubview:self.imageView];
    
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.text = TDLocalizeSelect(@"AUTHENTE_SUCCESS", nil);
    self.messageLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.messageLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    [self.view addSubview:self.messageLabel];
}

- (void)setViewConstraint {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(48);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(self.imageView.mas_bottom).offset(8);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

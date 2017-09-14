//
//  TDSettingCell.m
//  edX
//
//  Created by Elite Edu on 16/12/27.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "TDSettingCell.h"
#import "OEXInterface.h"
#import "edX-Swift.h"

typedef NS_ENUM(NSUInteger, OEXMySettingsAlertTag) {
    OEXMySettingsAlertTagNone,
    OEXMySettingsAlertTagWifiOnly
};

@interface TDSettingCell ()<UIAlertViewDelegate>

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *messageLabel;
@property (nonatomic,strong) UISwitch *wifiSwicth;

@end

@implementation TDSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self config];
        [self setConstrait];
        
    }
    return self;
}

- (void)config {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self addSubview:self.bgView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    [self.titleLabel setText:TDLocalizeSelect(@"DOWNLOAD_ONLY_WIFI", nil)];
    [self.bgView addSubview:self.titleLabel];
    
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.messageLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    [self.messageLabel setText:TDLocalizeSelect(@"DOWNLOAD_IN_WIFI", nil)];
    self.messageLabel.numberOfLines = 0;
    [self.bgView addSubview:self.messageLabel];
    
    self.wifiSwicth = [[UISwitch alloc] init];
    self.wifiSwicth.onTintColor = [UIColor colorWithHexString:colorHexStr1];
    [self.wifiSwicth setOn:[OEXInterface shouldDownloadOnlyOnWifi]];//拿到初始状态
    [self.wifiSwicth addTarget:self action:@selector(downLoadChange:) forControlEvents:UIControlEventValueChanged];
    [self.bgView addSubview:self.wifiSwicth];
}

- (void)setConstrait {

    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.wifiSwicth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-5);
        make.size.mas_equalTo(CGSizeMake(58, 25));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(18);
        make.bottom.mas_equalTo(self.bgView.mas_centerY);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(18);
        make.right.mas_equalTo(self.wifiSwicth.mas_left).offset(-8);
        make.top.mas_equalTo(self.bgView.mas_centerY);
    }];
}

#pragma mark - action
- (void)downLoadChange:(UISwitch *)sender {
    
    if(self.wifiSwicth.isOn) {
        
        [OEXInterface setDownloadOnlyOnWifiPref:self.wifiSwicth.isOn];
        
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:TDLocalizeSelect(@"CELLULAR_DOWNLOAD_ENABLED_TITLE", nil)
                                                        message:TDLocalizeSelect(@"CELLULAR_DOWNLOAD_ENABLED_MESSAGE", nil)
                                                       delegate:self
                                              cancelButtonTitle:TDLocalizeSelect(@"ALLOW", nil)
                                              otherButtonTitles:TDLocalizeSelect(@"DO_NOT_ALLOW", nil), nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == OEXMySettingsAlertTagWifiOnly) {
        [self.wifiSwicth setOn:YES animated:YES];
    } else {
        [self.wifiSwicth setOn:NO animated:YES];
    }
    [OEXInterface setDownloadOnlyOnWifiPref:self.wifiSwicth.isOn];
}


@end

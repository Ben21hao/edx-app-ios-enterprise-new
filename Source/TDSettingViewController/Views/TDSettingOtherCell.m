//
//  TDSettingOtherCell.m
//  edX
//
//  Created by Elite Edu on 2018/6/8.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSettingOtherCell.h"

@implementation TDSettingOtherCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self configView];
        [self setConstrait];
    }
    return self;
}

- (void)configView {
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self addSubview:self.bgView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    [self.titleLabel setText:TDLocalizeSelect(@"DOWNLOAD_ONLY_WIFI", nil)];
    [self.bgView addSubview:self.titleLabel];
}

- (void)setConstrait {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(16);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
}

@end

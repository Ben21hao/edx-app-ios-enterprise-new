//
//  TDWaitforPayBottomCell.m
//  edX
//
//  Created by Ben on 2017/6/29.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDWaitforPayBottomCell.h"

@interface TDWaitforPayBottomCell ()

@property (nonatomic,strong) UIView *bgView;

@end

@implementation TDWaitforPayBottomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - UI
- (void)configView {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.bgView];
    
    self.moneyLabel = [[UILabel alloc] init];
    self.moneyLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.moneyLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.bgView addSubview:self.moneyLabel];
    
    self.payButton = [[UIButton alloc] init];
    self.payButton.layer.masksToBounds = YES;
    self.payButton.layer.cornerRadius = 4.0;
    self.payButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.payButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.payButton.showsTouchWhenHighlighted = YES;
    [self.payButton setTitleColor:[UIColor colorWithHexString:colorHexStr13] forState:UIControlStateNormal];
    [self.payButton setTitle:TDLocalizeSelect(@"PAY_TITLE", nil) forState:UIControlStateNormal];
    [self.bgView addSubview:self.payButton];
    
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.size.mas_equalTo(CGSizeMake(88, 39));
    }];
    
    [self.moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.right.mas_equalTo(self.payButton.mas_left).offset(-8);
    }];
    
}

@end

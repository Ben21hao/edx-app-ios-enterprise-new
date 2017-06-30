//
//  TDWaitforPayTopCell.m
//  edX
//
//  Created by Ben on 2017/6/29.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDWaitforPayTopCell.h"

@interface TDWaitforPayTopCell ()

@property (nonatomic,strong) UIView *bgView;

@end

@implementation TDWaitforPayTopCell

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
    
    self.orderLabel = [[UILabel alloc] init];
    self.orderLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.orderLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.bgView addSubview:self.orderLabel];
    
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.cancelButton setTitleColor:[UIColor colorWithHexString:colorHexStr1] forState:UIControlStateNormal];
    [self.cancelButton setTitle:NSLocalizedString(@"CANCEL", nil) forState:UIControlStateNormal];
    [self.bgView addSubview:self.cancelButton];
    
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.orderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.left.mas_equalTo(self.bgView.mas_left).offset(8);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.size.mas_equalTo(CGSizeMake(58, 39));
    }];
}

@end

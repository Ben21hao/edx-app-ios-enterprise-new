//
//  TDAssistantCell.m
//  edX
//
//  Created by Elite Edu on 17/2/13.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDAssistantCell.h"

@interface TDAssistantCell ()

@property (nonatomic,strong) UIView *bgView;

@end

@implementation TDAssistantCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)setWhereFrom:(NSInteger)whereFrom {
    _whereFrom = whereFrom;
    if (_whereFrom == 2) {
        _bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    } else {
        _bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr14];
    }
}

#pragma mark - UI
- (void)configView {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr14];
    [self addSubview:self.bgView];
    
    self.headerImage = [[UIImageView alloc] init];
    self.headerImage.layer.masksToBounds = YES;
    self.headerImage.layer.cornerRadius = 29.0;
    self.headerImage.layer.borderColor = [UIColor colorWithHexString:colorHexStr6].CGColor;
    self.headerImage.layer.borderWidth = 0.5;
    [self.bgView addSubview:self.headerImage];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.nameLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    [self.bgView addSubview:self.nameLabel];
    
    self.quetionLabel = [[UILabel alloc] init];
    self.quetionLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.quetionLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.quetionLabel.numberOfLines = 0;
    [self.bgView addSubview:self.quetionLabel];
    
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(11);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(58, 58));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_top).mas_equalTo(8);
        make.left.mas_equalTo(self.headerImage.mas_right).offset(11);
        make.height.mas_equalTo(22);
    }];
    
    [self.quetionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(0);
        make.left.mas_equalTo(self.headerImage.mas_right).offset(11);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-8);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
    }];
}


@end

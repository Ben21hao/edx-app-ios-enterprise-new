//
//  TDSuTitleCell.m
//  edX
//
//  Created by Elite Edu on 17/3/8.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDSuTitleCell.h"

@interface TDSuTitleCell ()

@property (nonatomic,strong) UIView *bgView;

@end

@implementation TDSuTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setViewConstraint];
    }
    return self;
}

- (void)setViewConstraint {
    self.bgView = [[UIView alloc] init];
    [self addSubview:self.bgView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    [self.bgView addSubview:self.titleLabel];
    
    self.subTitileLabel = [[UILabel alloc] init];
    self.subTitileLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.subTitileLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.subTitileLabel.numberOfLines = 0;
    [self.bgView addSubview:self.subTitileLabel];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(18);
        make.top.mas_equalTo(self.bgView.mas_top).offset(8);
        make.height.mas_equalTo(22);
    }];
    
    [self.subTitileLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-11);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(0);
        make.bottom.mas_equalTo(self.bgView.mas_bottom);
    }];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

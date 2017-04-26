//
//  SubmiteSecondCell.m
//  edX
//
//  Created by Elite Edu on 16/12/1.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "SubmiteSecondCell.h"

@interface SubmiteSecondCell ()
@property (nonatomic,strong) UIView *bgView;

@end

@implementation SubmiteSecondCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self config];
        [self constraint];
    }
    return self;
}

- (void)config {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    self.leftLabel = [[UILabel alloc] init];
    self.leftLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.leftLabel.font = [UIFont systemFontOfSize:15];
    [self.bgView addSubview:self.leftLabel];
    
    self.rightLabel = [[UILabel alloc] init];
    self.rightLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.rightLabel.font = [UIFont systemFontOfSize:14];
    [self.bgView addSubview:self.rightLabel];
}

- (void)constraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
    }];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-39);
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

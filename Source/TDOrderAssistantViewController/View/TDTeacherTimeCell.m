//
//  TDTeacherTimeCell.m
//  edX
//
//  Created by Elite Edu on 17/3/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDTeacherTimeCell.h"

@interface TDTeacherTimeCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UIButton *selectButton;

@end

@implementation TDTeacherTimeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setViewConstraint];
    }
    return self;
}

- (void)setModel:(TDTimeModel *)model {
    _model = model;
    self.timeLabel.text = model.time_slice;
    self.selectButton.selected = model.isSelected;
    self.userInteractionEnabled = model.canSelected;
    self.bgView.backgroundColor = [UIColor colorWithHexString:model.canSelected ? colorHexStr13 : colorHexStr5];
}

- (void)setViewConstraint {
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.timeLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    [self.bgView addSubview:self.timeLabel];
    
    self.selectButton = [[UIButton alloc] init];
    [self.selectButton setImage:[UIImage imageNamed:@"Shape1"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"Shape"] forState:UIControlStateSelected];
    self.selectButton.userInteractionEnabled = NO;
    [self.bgView addSubview:self.selectButton];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.left.mas_equalTo(self.bgView.mas_left).offset(11);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-11);
        make.size.mas_equalTo(CGSizeMake(19, 19));
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

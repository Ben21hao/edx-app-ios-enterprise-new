//
//  TDSelectPayCell.m
//  edX
//
//  Created by Elite Edu on 16/12/4.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "TDSelectPayCell.h"

@interface TDSelectPayCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIImageView *headerImage;
@property (nonatomic,strong) UILabel *typeLabel;
@property (nonatomic,strong) UIButton *selectButton;

@end

@implementation TDSelectPayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self config];
        [self  setConstraint];
    }
    return self;
}

- (void)config {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    self.headerImage = [[UIImageView alloc] init];
    self.headerImage.image = [UIImage imageNamed:@"zhifu"];
    self.headerImage.layer.masksToBounds = YES;
    self.headerImage.layer.cornerRadius = 4.0;
    [self.bgView addSubview:self.headerImage];
    
    self.typeLabel = [[UILabel alloc] init];
    self.typeLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.typeLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    [self.bgView addSubview:self.typeLabel];
    
    self.selectButton = [[UIButton alloc] init];
    [self.selectButton setImage:[UIImage imageNamed:@"selectedNo"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"selected"] forState:UIControlStateSelected];
    [self.bgView addSubview:self.selectButton];
    
}

- (void)setConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.left.mas_equalTo(self.bgView.mas_left).offset(18);
    }];
    
    [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.left.mas_equalTo(self.headerImage.mas_right).offset(18);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.size.mas_equalTo(CGSizeMake(19, 19));
    }];
}

#pragma mark - data
- (void)setPayModel:(TDSelectPayModel *)payModel {
    _payModel = payModel;
    
    if (_payModel) {
        self.selectButton.selected = _payModel.isSelected;
        self.headerImage.image = [UIImage imageNamed:_payModel.imageStr];
        self.typeLabel.text = [NSString stringWithFormat:@"%@",_payModel.payStr];
    }
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

//
//  TDUserInformationCell.m
//  edX
//
//  Created by Ben on 2017/4/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDUserInformationCell.h"

@interface TDUserInformationCell ()

@property (nonatomic,strong) UIView *bgView;

@end


@implementation TDUserInformationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)setIsDisclosure:(BOOL)isDisclosure {
    _isDisclosure = isDisclosure;
    
    if (!_isDisclosure) {
        [self.detailTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self.bgView);
            make.right.mas_equalTo(self.bgView.mas_right).offset(-16);
            make.left.mas_equalTo(self.titleLabel.mas_right).offset(0);
        }];
    }
}

#pragma mark - UI
- (void)configView {
    self.bgView = [[UIView alloc] init];
    [self.contentView addSubview:self.bgView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    [self.bgView addSubview:self.titleLabel];
    
    self.detailTextField = [[UITextField alloc] init];
    self.detailTextField.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.detailTextField.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.detailTextField.textAlignment = NSTextAlignmentRight;
    [self.bgView addSubview:self.detailTextField];
    
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.left.mas_equalTo(self.bgView.mas_left).offset(16);
        make.width.mas_equalTo(98);
    }];
    
    [self.detailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.bgView);
        make.right.mas_equalTo(self.bgView.mas_right).offset(0);
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(0);
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

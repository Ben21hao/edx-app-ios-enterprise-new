//
//  TDScoreCellCell.m
//  edX
//
//  Created by Elite Edu on 2018/5/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDScoreCellCell.h"

@implementation TDScoreCellCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)setUnitScoreModel:(TDUnitScoreModel *)unitScoreModel {
    _unitScoreModel = unitScoreModel;
    
    self.titleLabel.text = unitScoreModel.problem_display_name;
    self.scoreLabel.attributedText = [self setScoreLabelTextColor:unitScoreModel.earned allScore:[NSString stringWithFormat:@"/%@",unitScoreModel.possible]];
}

#pragma mark - UI
- (void)configView {
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    self.leftLabel = [[UILabel alloc] init];
    self.leftLabel.font = [UIFont fontWithName:@"FontAwesome" size:12];
    self.leftLabel.text = @"\U0000f00b";
    self.leftLabel.textColor = [UIColor colorWithHexString:colorHexStr1];
    [self.bgView addSubview:self.leftLabel];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:13];
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    [self.bgView addSubview:self.titleLabel];
    
    self.scoreLabel = [[UILabel alloc] init];
    self.scoreLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    [self.bgView addSubview:self.scoreLabel];
    
    self.line = [[UILabel alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:colorHexStr7];
    [self.bgView addSubview:self.line];
    
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.left.mas_equalTo(self.bgView.mas_left).offset(28);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.left.mas_equalTo(self.leftLabel.mas_right).offset(8);
    }];
    
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(18);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.bottom.mas_equalTo(self.bgView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
}

- (NSMutableAttributedString *)setScoreLabelTextColor:(NSString *)scoreStr allScore:(NSString *)allScoreStr {
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:scoreStr
                                                                             attributes:@{
                                                                                          NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#8FC31F"]
                                                                                          }];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:allScoreStr
                                                                             attributes:@{
                                                                                          NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr10]
                                                                                          }];
    [str1 appendAttributedString:str2];
    return str1;
}


@end

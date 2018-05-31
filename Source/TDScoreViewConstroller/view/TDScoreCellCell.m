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
    
    if ([self.unitScoreModel.attempted boolValue]) {
        
        NSString *str1 = [NSString stringWithFormat:@"%.2f",unitScoreModel.earned.floatValue];
        NSString *str2 = [NSString stringWithFormat:@"%.2f",unitScoreModel.possible.floatValue];
        NSString *enrnGrade = [NSString stringWithFormat:@"%@",@(str1.floatValue)];
        NSString *allGrade = [NSString stringWithFormat:@"/%@",@(str2.floatValue)];
        self.scoreLabel.attributedText = [self setScoreLabelTextColor:enrnGrade allScore:allGrade];
    }
    else {
        self.scoreLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
        self.scoreLabel.text = TDLocalizeSelect(@"COURSE_UM_SUBMITED", nil);
    }
    
    TDBaseToolModel *toolModel = [[TDBaseToolModel alloc] init];
    CGFloat width = [toolModel widthForString:self.scoreLabel.text font:12];
    
    [self.scoreLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.width.mas_equalTo(width);
    }];

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
    self.scoreLabel.text = TDLocalizeSelect(@"COURSE_UM_SUBMITED", nil);
//    self.scoreLabel.textAlignment = NSTextAlignmentRight;
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
    
    TDBaseToolModel *toolModel = [[TDBaseToolModel alloc] init];
    CGFloat width = [toolModel widthForString:self.scoreLabel.text font:12];
    
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.width.mas_equalTo(width);
    }];
    

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.left.mas_equalTo(self.bgView.mas_left).offset(48);
        make.right.mas_equalTo(self.scoreLabel.mas_left).offset(-8);
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

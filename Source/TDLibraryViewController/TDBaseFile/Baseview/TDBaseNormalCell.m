//
//  TDBaseNormalCell.m
//  EdxProject
//
//  Created by Elite Edu on 2017/12/19.
//  Copyright © 2017年 Elite Edu. All rights reserved.
//

#import "TDBaseNormalCell.h"

@implementation TDBaseNormalCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBgViewConstraint];
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)setBgViewConstraint {
    
    self.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.mas_equalTo(self);
    }];
}

- (void)configView {
    
}

- (void)setViewConstraint {
    
}

- (UILabel *)setLabelStyle:(NSInteger)font color:(NSString *)colorStr {
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"OpenSans" size:font];
    label.textColor = [UIColor colorWithHexString:colorStr];
    return label;
}

@end

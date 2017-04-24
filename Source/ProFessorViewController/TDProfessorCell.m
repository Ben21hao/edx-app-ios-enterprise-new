//
//  TDProfessorCell.m
//  edX
//
//  Created by Elite Edu on 16/12/22.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "TDProfessorCell.h"

@implementation TDProfessorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:@"TDProfessorCell"];
    if (self) {
        self.professorLabel = [[UILabel alloc] init];
        self.professorLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
        self.professorLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
        self.professorLabel.numberOfLines = 0;
        
        [self addSubview:self.professorLabel];
        
        [self.professorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self);
            make.left.mas_equalTo(self.mas_left).offset(0);
            make.right.mas_equalTo(self.mas_right).offset(0);
        }];
        
    }
    return self;
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

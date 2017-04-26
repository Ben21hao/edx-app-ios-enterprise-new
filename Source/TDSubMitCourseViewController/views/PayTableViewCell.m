//
//  PayTableViewCell.m
//  edX
//
//  Created by Elite Edu on 16/10/10.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "PayTableViewCell.h"

@implementation PayTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (self.selected == YES) {
        _imgV2.image = [UIImage imageNamed:@"selected"];
    }
    if (self.selected == NO) {
        _imgV2.image = [UIImage imageNamed:@"selectedNo"];
    }
}

@end

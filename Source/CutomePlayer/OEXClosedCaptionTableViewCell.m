//
//  OEXClosedCaptionTableViewCell.m
//  edXVideoLocker
//
//  Created by Rahul Varma on 18/09/14.
//  Copyright (c) 2014 edX. All rights reserved.
//

#import "OEXClosedCaptionTableViewCell.h"

@implementation OEXClosedCaptionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

// MOB - 588
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
    if(highlighted) {
        self.backgroundColor = GREY_COLOR;
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end

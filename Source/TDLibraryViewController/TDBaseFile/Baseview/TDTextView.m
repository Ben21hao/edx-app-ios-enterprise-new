//
//  TDTextView.m
//  edX
//
//  Created by Elite Edu on 17/1/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDTextView.h"

@interface TDTextView ()


@end

@implementation TDTextView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configPlaceholder];
    }
    return self;
}

- (void)configPlaceholder {

    self.placeholderLabel = [[UILabel alloc]init];
    self.placeholderLabel.backgroundColor = [UIColor whiteColor];
    self.placeholderLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.placeholderLabel.textColor = [UIColor colorWithHexString:colorHexStr7];
    [self addSubview:self.placeholderLabel];
    
    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(8);
        make.top.mas_equalTo(8);
    }];
}



@end

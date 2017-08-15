//
//  TDBaseButton.m
//  edX
//
//  Created by Elite Edu on 2017/8/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDBaseButton.h"

@implementation TDBaseButton

- (instancetype)initWithFrame:(CGRect)frame colorStr:(NSString *)colorStr {
    self = [super init];
    if (self) {
        [self setViewConstrait];
    }
    return self;
}

- (void)setViewConstrait {
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.activityView];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(self.mas_right).offset(-8);
    }];
}

@end

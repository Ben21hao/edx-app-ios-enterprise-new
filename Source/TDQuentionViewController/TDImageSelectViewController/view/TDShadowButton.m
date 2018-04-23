//
//  TDShadowButton.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/12.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDShadowButton.h"

@implementation TDShadowButton

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.shadowView = [[UIView alloc] init];
        self.shadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [self addSubview:self.shadowView];
        
        [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(self);
        }];
    }
    return self;
}

@end

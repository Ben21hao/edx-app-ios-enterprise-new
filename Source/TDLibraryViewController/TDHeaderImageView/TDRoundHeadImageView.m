//
//  TDRoundHeadImageView.m
//  EdxProject
//
//  Created by Elite Edu on 2017/11/29.
//  Copyright © 2017年 Elite Edu. All rights reserved.
//

#import "TDRoundHeadImageView.h"

@implementation TDRoundHeadImageView

- (instancetype)initWithSize:(CGSize)size borderColor:(NSString *)colorStr {
    
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.image = [UIImage imageNamed:@"default_big"];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = size.width / 2;
        self.layer.borderColor = [UIColor colorWithHexString:colorStr].CGColor;
        self.layer.borderWidth = 1.0;
    }
    return self;
}

@end

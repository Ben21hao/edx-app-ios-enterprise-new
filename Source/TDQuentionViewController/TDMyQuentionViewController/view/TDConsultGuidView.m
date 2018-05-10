//
//  TDConsultGuidView.m
//  edX
//
//  Created by Elite Edu on 2018/5/2.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDConsultGuidView.h"

@interface TDConsultGuidView ()

@property (nonatomic,strong) UIImageView *guidImage;

@end

@implementation TDConsultGuidView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setViewConstaint];
    }
    return self;
}

- (void)setViewConstaint {
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.41];
    self.userInteractionEnabled = YES;
    
    self.guidImage = [[UIImageView alloc] init];
    self.guidImage.image = [UIImage imageNamed:@"remid_consult"];
    [self addSubview:self.guidImage];
    
    [self.guidImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-28);
        make.top.mas_equalTo(self.mas_top).offset(BAR_ALL_HEIHT - 13);
    }];
    
    self.tapButton = [[UIButton alloc] init];
    [self addSubview:self.tapButton];
    
    [self.tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

@end

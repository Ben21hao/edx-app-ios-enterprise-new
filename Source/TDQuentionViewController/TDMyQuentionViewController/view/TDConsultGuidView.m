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
@property (nonatomic,strong) UILabel *guidLabel;

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
    
    self.guidLabel = [[UILabel alloc] init];
    self.guidLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.guidLabel.textColor = [UIColor whiteColor];
    self.guidLabel.text = TDLocalizeSelect(@"TAB_CONSTULT_NEW", nil);
    self.guidLabel.textAlignment = NSTextAlignmentCenter;
    self.guidLabel.numberOfLines = 0;
    [self addSubview:self.guidLabel];
    
    self.tapButton = [[UIButton alloc] init];
    [self addSubview:self.tapButton];
    
    [self.guidImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-28);
        make.top.mas_equalTo(self.mas_top).offset(BAR_ALL_HEIHT - 13);
        make.size.mas_equalTo(CGSizeMake(177, 93));
    }];
    
    [self.guidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.guidImage.mas_left).offset(8);
        make.right.mas_equalTo(self.guidImage.mas_right).offset(-8);
        make.centerY.mas_equalTo(self.guidImage.mas_centerY).offset(8);
    }];
    
    [self.tapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

@end

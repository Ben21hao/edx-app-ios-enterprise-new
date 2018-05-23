
//
//  TDConsultRemidView.m
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDConsultRemidView.h"

@interface TDConsultRemidView ()

@property (nonatomic,strong) UILabel *remindLabel;

@end

@implementation TDConsultRemidView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self setviewConstraint];
    }
    return self;
}

- (void)setviewConstraint {
    
    self.backgroundColor = [UIColor colorWithHexString:@"#F8F3E6"];
    
    self.remindLabel = [[UILabel alloc] init];
    self.remindLabel.text = TDLocalizeSelect(@"REMIND_TIPS", nil);
    self.remindLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.remindLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.remindLabel.numberOfLines = 0;
    [self addSubview:self.remindLabel];
    
    self.cancelButton = [[UIButton alloc] init];
    [self.cancelButton setImage:[UIImage imageNamed:@"close_circle"] forState:UIControlStateNormal];
    [self addSubview:self.cancelButton];
    
    [self.remindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(13);
        make.top.bottom.mas_equalTo(self);
        make.right.mas_equalTo(self.mas_right).offset(-68);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-13);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(39, 39));
    }];
}

@end

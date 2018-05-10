//
//  TDSelectBottomView.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/12.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDSelectBottomView.h"

@implementation TDSelectBottomView

- (void)setSelectNum:(NSInteger)selectNum {
    
    BOOL isEnable = selectNum > 0;
    
    [self.previewButton setTitleColor:[UIColor colorWithHexString:isEnable ? colorHexStr13 : colorHexStr8] forState:UIControlStateNormal];
    [self.sureButton setTitleColor:[UIColor colorWithHexString:isEnable ? colorHexStr13 : colorHexStr8] forState:UIControlStateNormal];
    
    self.sureButton.shadowView.hidden = isEnable;
    
    self.sureButton.userInteractionEnabled = isEnable;
    self.previewButton.userInteractionEnabled = self.isPreView ? YES : isEnable;
    
    NSString *selectStr = selectNum == 0 ? TDLocalizeSelect(@"OK", nil) : [NSString stringWithFormat:@"%@(%ld)",TDLocalizeSelect(@"OK", nil),(long)selectNum];
    [self.sureButton setTitle:selectStr forState:UIControlStateNormal];
}

- (void)setIsPreView:(BOOL)isPreView {
    _isPreView = isPreView;
    
    if (isPreView) {
        [self.previewButton setImage:[UIImage imageNamed:@"select_not_roud"] forState:UIControlStateNormal];
        [self.previewButton setImage:[UIImage imageNamed:@"selected_roud"] forState:UIControlStateSelected];
    } else {
        [self.previewButton setTitle:TDLocalizeSelect(@"PREVIEW_TITLE", nil) forState:UIControlStateNormal];
    }
}

- (void)configeView {
    self.backgroundColor = [[UIColor colorWithHexString:colorHexStr10] colorWithAlphaComponent:0.9];
    
    self.previewButton = [[UIButton alloc] init];
    self.previewButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    [self.previewButton setTitleColor:[UIColor colorWithHexString:colorHexStr8] forState:UIControlStateNormal];
    [self addSubview:self.previewButton];
    
    self.sureButton = [[TDShadowButton alloc] init];
    self.sureButton.layer.masksToBounds = YES;
    self.sureButton.layer.cornerRadius = 5.0;
    self.sureButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.sureButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.sureButton setTitleColor:[UIColor colorWithHexString:colorHexStr8] forState:UIControlStateNormal];
    [self.sureButton setTitle:TDLocalizeSelect(@"OK", nil) forState:UIControlStateNormal];
    [self addSubview:self.sureButton];

}

- (void)setViewConstraint {
    
    [self.previewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(13);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(68, 39));
    }];
    
    [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-13);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(68, 39));
    }];
    
}

@end

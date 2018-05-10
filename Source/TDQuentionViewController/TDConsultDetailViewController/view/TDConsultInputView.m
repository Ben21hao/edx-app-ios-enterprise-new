//
//  TDConsultInputView.m
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDConsultInputView.h"

@interface TDConsultInputView ()

@property (nonatomic,strong) UILabel *line;
@end

@implementation TDConsultInputView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self configView];
        [self setviewConstraint];
    }
    return self;
}

- (void)configView {
    
    self.backgroundColor = [UIColor colorWithHexString:colorHexStr13];
    
    self.inputTypeButton = [[UIButton alloc] init];
    [self.inputTypeButton setImage:[UIImage imageNamed:@"record_audio_circle"] forState:UIControlStateNormal];
    [self.inputTypeButton setImage:[UIImage imageNamed:@"keybord_circle_round"] forState:UIControlStateSelected];
    [self addSubview:self.inputTypeButton];
    
    self.imageButton = [[UIButton alloc] init];
    [self.imageButton setImage:[UIImage imageNamed:@"image_circle_round"] forState:UIControlStateNormal];
    [self addSubview:self.imageButton];
    
    self.inputTextView = [[UITextView alloc] init];
    self.inputTextView.returnKeyType = UIReturnKeySend;
    self.inputTextView.layer.masksToBounds = YES;
    self.inputTextView.layer.cornerRadius = 4.0;
    self.inputTextView.layer.borderColor = [UIColor colorWithHexString:colorHexStr6].CGColor;
    self.inputTextView.layer.borderWidth = 0.5;
    self.inputTextView.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self addSubview:self.inputTextView];
    
    self.recordButton = [[UIButton alloc] init];
    self.recordButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.recordButton.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    self.recordButton.imageEdgeInsets = UIEdgeInsetsMake(0, -13, 0, 0);
    self.recordButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -13);
    [self.recordButton setTitleColor:[UIColor colorWithHexString:colorHexStr9] forState:UIControlStateNormal];
    [self.recordButton setTitle:TDLocalizeSelect(@"HOLD_TO_RECORD", nil) forState:UIControlStateNormal];
    [self.recordButton setImage:[UIImage imageNamed:@"record_not_image"] forState:UIControlStateNormal];
    self.recordButton.layer.masksToBounds = YES;
    self.recordButton.layer.cornerRadius = 4.0;
    self.recordButton.layer.borderColor = [UIColor colorWithHexString:colorHexStr6].CGColor;
    self.recordButton.layer.borderWidth = 0.5;
    [self addSubview:self.recordButton];
    
    self.line = [[UILabel alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    [self addSubview:self.line];
    
    self.recordButton.hidden = YES;
}

- (void)setviewConstraint {
    
    [self.inputTypeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(9);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(39, 39));
    }];
    
    [self.imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-9);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(39, 39));
    }];
    
    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.inputTypeButton.mas_right).offset(8);
        make.right.mas_equalTo(self.imageButton.mas_left).offset(-8);
        make.top.mas_equalTo(self.mas_top).offset(9);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-9);
    }];
    
    [self.recordButton  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.inputTextView);
    }];

    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
}

@end

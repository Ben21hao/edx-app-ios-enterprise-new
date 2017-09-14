//
//  TDTakePitureView.m
//  edX
//
//  Created by Ben on 2017/4/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDTakePitureView.h"

@implementation TDTakePitureView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)setType:(NSInteger)type {
    _type = type;
    self.titleLabel.text = _type == TDPhotoTypeFace ? TDLocalizeSelect(@"FIRST_FACE", nil): TDLocalizeSelect(@"SECOND_IDENTIFY", nil);
    self.topLabel.text = _type == TDPhotoTypeFace ? TDLocalizeSelect(@"AIM_CAMERA", nil) : TDLocalizeSelect(@"SHOW_CARD", nil);
    self.imageView.image = [UIImage imageNamed:_type == TDPhotoTypeFace ? @"tdFaceImage" : @"tdIdentify"];
    [self setStrAttibute];
    
    if (_type != TDPhotoTypeFace) {
        [self.remindLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.imageView.mas_bottom).offset(39);
            make.left.mas_equalTo(self.scrollview.mas_left).offset(18);
            make.bottom.mas_equalTo(self.scrollview.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(TDWidth - 36, 198));
        }];
    }
}

- (void)setStrAttibute {
    
    NSArray *array1 = [NSArray arrayWithObjects:TDLocalizeSelect(@"FACE_NOTES", nil),TDLocalizeSelect(@"FACE_USE_FOR", nil),TDLocalizeSelect(@"IMAGE_USE_CAMERA", nil), nil];
    NSArray *array2 = [NSArray arrayWithObjects:TDLocalizeSelect(@"IDENTIFY_AUTHENTICATION", nil),TDLocalizeSelect(@"IDENTIFY_USE_FOR", nil), nil];
    
    NSArray *array = [[NSArray alloc] initWithArray:_type == TDPhotoTypeFace ? array1 : array2];
    NSMutableAttributedString *attibuteStr = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i < array.count; i ++) {
        NSString *str = array[i];
        NSRange range = [str rangeOfString:@":"];
        NSMutableString *mutableStr = [[NSMutableString alloc] initWithString:str];
        NSString *str1 = [mutableStr substringToIndex:range.location + 1];
        NSString *str2 = [mutableStr substringFromIndex:range.location + 1];
        
        NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:str1 attributes:@{
                                                                                                              NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr10],
                                                                                                              NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:14]
                                                                                                              }];
        NSMutableAttributedString *str4 = [[NSMutableAttributedString alloc] initWithString:str2 attributes:@{
                                                                                                              NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr9],
                                                                                                              NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:14]
                                                                                                              }];
        [str3 appendAttributedString:str4];
        [attibuteStr appendAttributedString:str3];
    }
    self.remindLabel.attributedText = attibuteStr;
}

#pragma mark - UI
- (void)configView {
    
    self.scrollview = [[UIScrollView alloc] init];
    self.scrollview.contentSize = CGSizeMake(TDWidth, 688);
    [self addSubview:self.scrollview];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:18];
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollview addSubview:self.titleLabel];
    
    self.topLabel = [[UILabel alloc] init];
    self.topLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.topLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollview addSubview:self.topLabel];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"people"];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderColor = [UIColor colorWithHexString:colorHexStr6].CGColor;
    self.imageView.layer.borderWidth = 0.5;
    [self.scrollview addSubview:self.imageView];
    
    self.imageButton = [self setButtonConfig:TDLocalizeSelect(@"CLICK_PHOTO", nil)];
    self.imageButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    [self.imageButton setImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
    self.imageButton.contentEdgeInsets = UIEdgeInsetsMake(18, -18, -18, 18);
    self.imageButton.imageEdgeInsets = UIEdgeInsetsMake(-18, 39, 18, -39);
    self.imageButton.backgroundColor = [UIColor blackColor];
    self.imageButton.alpha = 0.5;
    [self.scrollview addSubview:self.imageButton];
    
    self.buttonView = [[UIView alloc] init];
    self.buttonView.userInteractionEnabled = NO;
    [self.scrollview addSubview:self.buttonView];
    
    self.resetButton = [self setButtonConfig:TDLocalizeSelect(@"TD_RETAKE", nil)];
    self.resetButton.alpha = 0.6;
    [self.buttonView addSubview:self.resetButton];
    
    self.nextButton = [self setButtonConfig:TDLocalizeSelect(@"NEXT_TEST", nil)];
    self.nextButton.alpha = 0.6;
    [self.buttonView addSubview:self.nextButton];
    
    self.remindLabel = [[UILabel alloc] init];
    self.remindLabel.numberOfLines = 0;
    self.remindLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    self.remindLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.scrollview addSubview:self.remindLabel];
    
}

- (void)setViewConstraint {
    
    [self.scrollview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollview.mas_centerX);
        make.top.mas_equalTo(self.scrollview.mas_top).offset(18);
    }];
    
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollview.mas_centerX);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollview.mas_centerX);
        make.top.mas_equalTo(self.topLabel.mas_bottom).offset(8);
        make.size.mas_equalTo(CGSizeMake(182, 182));
    }];
    
    [self.imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollview.mas_centerX);
        make.top.mas_equalTo(self.topLabel.mas_bottom).offset(8);
        make.size.mas_equalTo(CGSizeMake(182, 182));
    }];
    
    [self.buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.scrollview.mas_centerX);
        make.top.mas_equalTo(self.imageView.mas_bottom).offset(18);
        make.size.mas_equalTo(CGSizeMake(268, 39));
    }];
    
    [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.buttonView.mas_centerY);
        make.left.mas_equalTo(self.buttonView.mas_left).offset(0);
        make.size.mas_equalTo(CGSizeMake(128, 39));
    }];
    
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.buttonView.mas_centerY);
        make.right.mas_equalTo(self.buttonView.mas_right).offset(0);
        make.size.mas_equalTo(CGSizeMake(128, 39));
    }];
    
    [self.remindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageView.mas_bottom).offset(39);
        make.left.mas_equalTo(self.scrollview.mas_left).offset(18);
        make.bottom.mas_equalTo(self.scrollview.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(TDWidth - 36, 268));
    }];
    
}


- (UIButton *)setButtonConfig:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    button.layer.cornerRadius = 4.0;
    button.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    button.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}


@end

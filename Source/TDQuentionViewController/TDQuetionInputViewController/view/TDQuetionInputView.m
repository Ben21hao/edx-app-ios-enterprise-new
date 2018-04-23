//
//  TDQuetionInputView.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/10.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDQuetionInputView.h"

@interface TDQuetionInputView () <UITextViewDelegate>

@end

@implementation TDQuetionInputView

- (instancetype)initWithType:(NSInteger)whereFrom {
    self = [super init];
    if (self) {
        [self configView:whereFrom];
        [self setViewConstraint:whereFrom];
    }
    return self;
}


#pragma - textViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {//禁止使用回车
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    NSLog(@"DidChange ------->>> %@",textView.text);
    
    if ([textView isEqual:self.quetionTextView]) {
        
        self.quetionTextView.placeholderLabel.hidden = textView.text.length > 0;
        
        if (textView.text.length >= 300) {
            self.numLabel.text = @"300/300";
            self.quetionTextView.text = [textView.text substringToIndex:300];
            
        } else {
            self.numLabel.text = [NSString stringWithFormat:@"%ld/300",(unsigned long)textView.text.length];
        }
        
    } else if ([textView isEqual:self.titleTextView]) {
        
        self.titleTextView.placeholderLabel.hidden = textView.text.length > 0;
        
        if (self.titleTextView.text.length >= 20) {
            self.titleTextView.text = [self.titleTextView.text substringToIndex:20];
            self.titleNumLabel.text = @"20/20";
            
        } else {
            self.titleNumLabel.text = [NSString stringWithFormat:@"%ld/20",(unsigned long)self.titleTextView.text.length];;
        }
    }
}

#pragma mark - UI
- (void)configView:(NSInteger)whereFrom {
    
    self.backgroundColor = [UIColor whiteColor];
    
    if (whereFrom == 0) {
        self.titleView = [[UIView alloc] init];
        [self addSubview:self.titleView];
        
        self.titleTextView = [[TDTextView alloc] init];
        self.titleTextView.font = [UIFont fontWithName:@"OpenSans" size:14];
        self.titleTextView.textColor = [UIColor colorWithHexString:colorHexStr10];
        self.titleTextView.placeholderLabel.text = TDLocalizeSelect(@"ENTER_CONSULTATION_TITLE", nil);
        self.titleTextView.delegate = self;
        self.titleTextView.returnKeyType = UIReturnKeyDone;
        [self.titleView addSubview:self.titleTextView];
        
        self.line = [[UILabel alloc] init];
        self.line.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
        [self.titleView addSubview:self.line];
        
        self.titleNumLabel = [[UILabel alloc] init];
        self.titleNumLabel.font = [UIFont fontWithName:@"OpenSans" size:10];
        self.titleNumLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
        [self.titleView addSubview:self.titleNumLabel];
        
        self.titleNumLabel.text = @"0/20";
    }
    
    self.quetionTextView = [[TDTextView alloc] init];
    self.quetionTextView.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.quetionTextView.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.quetionTextView.returnKeyType = UIReturnKeyDone;
    if (whereFrom == 1) {
        self.quetionTextView.placeholderLabel.text = TDLocalizeSelect(@"ENTER_REPLY_CONTENT", nil);
    } else {
      self.quetionTextView.placeholderLabel.text = TDLocalizeSelect(@"ENTER_CONSULTATION_CONTENT", nil);
    }
    
    self.quetionTextView.delegate = self;
    [self addSubview:self.quetionTextView];
    
    self.bottomLine = [[UILabel alloc] init];
    self.bottomLine.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    [self addSubview:self.bottomLine];
    
    self.numLabel = [[UILabel alloc] init];
    self.numLabel.font = [UIFont fontWithName:@"OpenSans" size:10];
    self.numLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    [self addSubview:self.numLabel];
    
    self.imageView = [[TDImageSelectView alloc] init];
    [self addSubview:self.imageView];
    
    self.audioPlayView = [[TDAudioPlayView alloc] init];
    [self addSubview:self.audioPlayView];
    
    self.recordButton = [[UIButton alloc] init];
    self.recordButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.recordButton.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    self.recordButton.imageEdgeInsets = UIEdgeInsetsMake(0, -13, 0, 0);
    self.recordButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -13);
    [self.recordButton setTitleColor:[UIColor colorWithHexString:colorHexStr9] forState:UIControlStateNormal];
    [self.recordButton setTitle:TDLocalizeSelect(@"HOLD_TO_RECORD", nil) forState:UIControlStateNormal];
    [self.recordButton setImage:[UIImage imageNamed:@"record_not_image"] forState:UIControlStateNormal];
    [self addSubview:self.recordButton];
    
    self.audioPlayView.hidden = YES;
    
    self.numLabel.text = @"0/300";
}

- (void)setViewConstraint:(NSInteger)whereFrom {
    
    if (whereFrom == 0) {
        
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(self);
            make.height.mas_equalTo(48);
        }];
        
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.titleView.mas_bottom);
            make.left.mas_equalTo(self.titleView.mas_left).offset(13);
            make.right.mas_equalTo(self.titleView.mas_right).offset(-48);
            make.height.mas_equalTo(1);
        }];
        
        [self.titleNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.titleView.mas_right).offset(-13);
            make.centerY.mas_equalTo(self.line.mas_centerY);
        }];
        
        [self.titleTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.titleView.mas_left).offset(13);
            make.right.mas_equalTo(self.titleView.mas_right).offset(-13);
            make.centerY.mas_equalTo(self.titleView.mas_centerY);
            make.height.mas_equalTo(38);
        }];
        
        [self.quetionTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleView.mas_bottom).offset(5);
            make.left.mas_equalTo(self.mas_left).offset(8);
            make.right.mas_equalTo(self.titleView.mas_right).offset(-8);
            make.height.mas_equalTo(TDHeight * 7 / 24);
        }];
        
    } else {
        
        [self.quetionTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(13);
            make.left.mas_equalTo(self.mas_left).offset(13);
            make.right.mas_equalTo(self.mas_right).offset(-13);
            make.height.mas_equalTo(198);
        }];
    }
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(13);
        make.right.mas_equalTo(self.mas_right).offset(-53);
        make.top.mas_equalTo(self.quetionTextView.mas_bottom).offset(8);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-13);
        make.centerY.mas_equalTo(self.bottomLine.mas_centerY);
    }];
    
    [self.recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(48);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(13);
        make.right.mas_equalTo(self.mas_right).offset(-13);
        make.bottom.mas_equalTo(self.recordButton.mas_top).offset(-18);
        make.height.mas_equalTo((TDWidth - 26 - 30) / 4);
    }];
    
    [self.audioPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(13);
        make.bottom.mas_equalTo(self.imageView.mas_top).offset(-18);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(88);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.titleTextView resignFirstResponder];
    [self.quetionTextView resignFirstResponder];
}

@end

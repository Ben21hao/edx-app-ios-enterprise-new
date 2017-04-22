//
//  TDTextView.m
//  edX
//
//  Created by Elite Edu on 17/1/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDTextView.h"

@interface TDTextView () <UITextViewDelegate>

@property (nonatomic,strong) UILabel *placeholderLabel;

@end

@implementation TDTextView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configPlaceholder];
    }
    return self;
}

- (void)configPlaceholder {
    
    self.backgroundColor= [UIColor whiteColor];
    self.font = [UIFont fontWithName:@"OpenSans" size:15];
    self.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.layer.cornerRadius = 4.0;
    self.delegate = self;
    self.showsHorizontalScrollIndicator = YES;
    self.contentInset = UIEdgeInsetsMake(0, 0, 0, 88);
    
    self.placeholderLabel = [[UILabel alloc]init];
    self.placeholderLabel.backgroundColor = [UIColor whiteColor];
    self.placeholderLabel.font = [UIFont fontWithName:@"OpenSans" size:15];
    self.placeholderLabel.textColor = [UIColor colorWithHexString:colorHexStr7];
    [self addSubview:self.placeholderLabel];
    
    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self.mas_left).offset(8);
    }];
}

#pragma mark - placeholder
- (void)setBackPlaceholder:(NSString *)placeholder {
    [self setNeedsDisplay];
    if (placeholder) {
        self.placeholderLabel.text = placeholder;
    }
}

#pragma mark - textview delegate
- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = textView.text.length > 0 ? YES : NO;
}



@end

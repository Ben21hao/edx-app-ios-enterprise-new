//
//  TDBindEmailNewView.m
//  edX
//
//  Created by Ben on 2017/6/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDBindEmailNewView.h"
#import "TDBaseToolModel.h"

@interface TDBindEmailNewView () <UITextFieldDelegate>

@property (nonatomic,strong) TDBaseToolModel *toolModel;

@property (nonatomic,strong) UIView *emailInputView;
@property (nonatomic,strong) UIView *codeInputView;
@property (nonatomic,strong) UIButton *handinButton;

@end

@implementation TDBindEmailNewView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.toolModel = [[TDBaseToolModel alloc] init];
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - action
- (void)codeButtonAction:(UIButton *)sender {
    
    if (![self.toolModel networkingState]) {
        return;
    }
    
    if (![self judgeEmailFommat]) {
        return;
    }
    
    if (self.codeButtonClickHandle) {
        self.codeButtonClickHandle();
    }
}

- (void)handinButtonAction:(UIButton *)sender {
    
    if (![self.toolModel networkingState]) {
        return;
    }
    
    if (![self judgeEmailFommat]) {
        return;
    }
    
    if (self.codeInputField.text.length == 0) {
        [self makeToast:NSLocalizedString(@"VERIFICATION_CODE_IS_EMPTY", nil) duration:1.08 position:CSToastPositionCenter];
        return;
    }
    
    if (self.handinButtonClickHandle) {
        self.handinButtonClickHandle();
    }
}

#pragma mark - textField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([textField isEqual:self.emailInputField]) {
        if (self.emailInputField.text.length > 0 && ![self.toolModel isValidateEmail:self.emailInputField.text]) {
            [self makeToast:NSLocalizedString(@"EMAIL_FORMAT_ERROR", nil) duration:1.08 position:CSToastPositionCenter];
        }
    }
}

- (BOOL)judgeEmailFommat {
    
    if (self.emailInputField.text.length == 0) {
        
        [self makeToast:NSLocalizedString(@"EMAIL_ADDRESS_EMPTY", nil) duration:1.08 position:CSToastPositionCenter];
        return NO;
        
    } else if (![self.toolModel isValidateEmail:self.emailInputField.text]) {
        [self makeToast:NSLocalizedString(@"EMAIL_FORMAT_ERROR", nil) duration:1.08 position:CSToastPositionCenter];
        return NO;
    }
    return YES;
}

#pragma mark - UI
- (void)configView {
    self.emailInputView = [self setBgViewStlye];
    [self addSubview:self.emailInputView];
    
    self.codeInputView = [self setBgViewStlye];
    [self addSubview:self.codeInputView];
    
    self.emailInputField = [self setTextFieldStyle:NSLocalizedString(@"EMAIL_ADDRESS_PROMPT", nil)];
    [self.emailInputView addSubview:self.emailInputField];
    
    self.codeInputField = [self setTextFieldStyle:NSLocalizedString(@"ENTER_VERI_HOLDER", nil)];
    [self.codeInputView addSubview:self.codeInputField];
    
    self.codeButton = [self setButtonStyle:NSLocalizedString(@"GET_VERIFICATION", nil) font:14];
    [self.codeButton addTarget:self action:@selector(codeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.codeButton];
    
    self.handinButton = [self setButtonStyle:NSLocalizedString(@"OK", nil) font:18];
    [self.handinButton addTarget:self action:@selector(handinButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.handinButton];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.activityView];
    
    self.codeActivitView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.codeActivitView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.codeActivitView];
}

- (void)setViewConstraint {
    [self.emailInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(18);
        make.right.mas_equalTo(self.mas_right).offset(-18);
        make.top.mas_equalTo(self.mas_top).offset(18);
        make.height.mas_equalTo(44);
    }];
    
    [self.emailInputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.emailInputView.mas_left).offset(8);
        make.right.mas_equalTo(self.emailInputView.mas_right).offset(-8);
        make.bottom.top.mas_equalTo(self.emailInputView);
    }];
    
    [self.codeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.emailInputView.mas_bottom).offset(13);
        make.right.mas_equalTo(self.mas_right).offset(-18);
        make.size.mas_equalTo(CGSizeMake(83, 44));
    }];
    
    [self.codeInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(18);
        make.right.mas_equalTo(self.codeButton.mas_left).offset(-8);
        make.top.mas_equalTo(self.emailInputView.mas_bottom).offset(13);
        make.height.mas_equalTo(44);
    }];
    
    [self.codeInputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.codeInputView.mas_left).offset(8);
        make.right.mas_equalTo(self.codeInputView.mas_right).offset(-8);
        make.bottom.top.mas_equalTo(self.codeInputView);
    }];
    
    [self.handinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.codeInputView.mas_bottom).offset(18);
        make.left.mas_equalTo(self.mas_left).offset(18);
        make.right.mas_equalTo(self.mas_right).offset(-18);
        make.height.mas_equalTo(44);
    }];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.handinButton.mas_centerY);
        make.right.mas_equalTo(self.handinButton.mas_right).offset(-8);
    }];
    
    
    [self.codeActivitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.codeButton.mas_centerY);
        make.centerX.mas_equalTo(self.codeButton.mas_centerX);
    }];
}

- (UIView *)setBgViewStlye {
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 4.0;
    bgView.layer.borderColor = [UIColor colorWithHexString:colorHexStr6].CGColor;
    bgView.layer.borderWidth = 0.5;
    return bgView;
}

- (UIButton *)setButtonStyle:(NSString *)title font:(NSInteger)font {
    UIButton *button = [[UIButton alloc] init];
    button.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:font];
    button.layer.cornerRadius = 4.0;
    button.layer.masksToBounds = YES;
    button.showsTouchWhenHighlighted = YES;
    button.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    [button setTitleColor:[UIColor colorWithHexString:colorHexStr13] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

- (UITextField *)setTextFieldStyle:(NSString *)holderStr {
    UITextField *textField = [[UITextField alloc] init];
    textField.font = [UIFont fontWithName:@"OpenSans" size:14];
    textField.placeholder = holderStr;
    textField.textColor = [UIColor colorWithHexString:colorHexStr10];
    textField.delegate = self;
    return textField;
}

@end




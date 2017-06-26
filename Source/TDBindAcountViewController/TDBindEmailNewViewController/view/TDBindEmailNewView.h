//
//  TDBindEmailNewView.h
//  edX
//
//  Created by Ben on 2017/6/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDBindEmailNewView : UIView

@property (nonatomic,strong) UIButton *codeButton;
@property (nonatomic,strong) UITextField *emailInputField;
@property (nonatomic,strong) UITextField *codeInputField;

@property (nonatomic,strong) UIActivityIndicatorView *activityView;
@property (nonatomic,strong) UIActivityIndicatorView *codeActivitView;

@property (nonatomic,copy) void(^codeButtonClickHandle)();
@property (nonatomic,copy) void(^handinButtonClickHandle)();

@end

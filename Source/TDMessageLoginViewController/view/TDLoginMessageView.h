//
//  TDLoginMessageView.h
//  edX
//
//  Created by Elite Edu on 2018/5/23.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseButton.h"

@interface TDLoginMessageView : UIView

@property (nonatomic,strong) UITextField *phoneTextFied;
@property (nonatomic,strong) UITextField *codeTextFied;
@property (nonatomic,strong) UIButton *codeButton;
@property (nonatomic,strong) TDBaseButton *loginButton;
@property (nonatomic,strong) UIActivityIndicatorView *codeActivitView;

@end

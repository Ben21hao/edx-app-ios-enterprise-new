//
//  TDQuetionInputView.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/10.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDAudioPlayView.h"
#import "TDImageSelectView.h"
#import "TDTextView.h"

@interface TDQuetionInputView : UIView

- (instancetype)initWithType:(NSInteger)whereFrom;

@property (nonatomic,strong) UIView *titleView;
@property (nonatomic,strong) TDTextView *titleTextView;
@property (nonatomic,strong) UILabel *line;
@property (nonatomic,strong) UILabel *titleNumLabel;

@property (nonatomic,strong) TDTextView *quetionTextView;
@property (nonatomic,strong) UILabel *bottomLine;
@property (nonatomic,strong) UILabel *numLabel;

@property (nonatomic,strong) TDImageSelectView *imageView;
@property (nonatomic,strong) TDAudioPlayView *audioPlayView;
@property (nonatomic,strong) UIButton *recordButton;

@end

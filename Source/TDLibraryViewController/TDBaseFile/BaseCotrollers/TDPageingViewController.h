//
//  TDPageingViewController.h
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDBaseScrollView.h"

@interface TDPageingViewController : UIViewController

@property (nonatomic,strong) NSMutableArray <UIViewController *> *childVcArray;

@property (nonatomic,strong) TDBaseScrollView *contentView;
@property (nonatomic,strong) NSMutableArray *titleButtons;

- (void)setSubTitleConstraint; //子标题的布局

@property (nonatomic,strong) UIButton *leftButton;
- (void)setLeftNavigationBar; //设置左边导航
- (void)backButtonAction:(UIButton *)sender; //返回

@end

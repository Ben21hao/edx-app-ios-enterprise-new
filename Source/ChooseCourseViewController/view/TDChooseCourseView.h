//
//  TDChooseCourseView.h
//  edX
//
//  Created by Elite Edu on 16/12/10.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDChooseCourseView : UIView

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIButton *totalButton;
@property (nonatomic,strong) UIButton *summitButton;

@property (nonatomic,strong) UILabel *totalMoney;
@property (nonatomic,strong) UILabel *originalMoney;

@property (nonatomic,strong) void(^totalButtonHandle)(BOOL isSelected);
@property (nonatomic,strong) void(^summitButtonHandle)();

@end

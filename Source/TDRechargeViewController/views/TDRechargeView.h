//
//  TDRechargeView.h
//  edX
//
//  Created by Elite Edu on 16/12/4.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDRechargeView : UIView

@property (nonatomic,strong) UITableView *tableView; 
@property (nonatomic,strong) UILabel *topLabel; //当前宝典
@property (nonatomic,strong) UITextField *inputField; //输入框
@property (nonatomic,strong) UILabel *exchangeLabel; //换算宝典
@property (nonatomic,strong) NSArray *moneyArray; //充值价格
@property (nonatomic,strong) UIButton *rechargeButton; //确定充值
@property (nonatomic,strong) UIButton *selectedButton; //选中的按钮

@property (nonatomic,copy) void(^selectMoneyButtonHandle)(NSInteger tag);
- (instancetype)initWithType:(NSInteger)type;
- (void)setMoneyViewData:(NSArray *)moneyArray withType:(NSInteger)type;

@end

//
//  TDPaySheetView.m
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDPaySheetView.h"
#import "TDBaseView.h"
#import "TDPayMoneyView.h"
#import "TDPayTypeView.h"
#import "WXApi.h"

#define sheetHeight 228

@interface TDPaySheetView ()

@property (nonatomic,strong) UIView *sheetView;
@property (nonatomic,strong) TDBaseView *topView;
@property (nonatomic,strong) UIView *payTypeView;
@property (nonatomic,strong) TDPayMoneyView *payMoneyView;
@property (nonatomic,strong) TDPayTypeView *wechatView;
@property (nonatomic,strong) TDPayTypeView *alipayView;
@property (nonatomic,strong) UILabel *line;

@end

@implementation TDPaySheetView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)payButtonAction:(UIButton *)sender {
    
}

#pragma mark - UI
- (void)configView {
    self.backgroundColor = [UIColor blackColor];
    
    self.sheetView = [[UIView alloc] init];
    self.sheetView.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    [self addSubview:self.sheetView];
    
    self.topView = [[TDBaseView alloc] initWithTitle:NSLocalizedString(@"SELECT_PAYWAY", nil)];
    [self.sheetView addSubview:self.topView];
    
    self.payTypeView = [[UIView alloc] init];
    self.payTypeView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self.sheetView addSubview:self.payTypeView];
    
    self.payMoneyView = [[TDPayMoneyView alloc] init];
//    payMoneyView.moneyLabel.attributedText = [self setRealMoney:[NSString stringWithFormat:@"¥%.2f",[self.orderMoney floatValue]]];//订单价格
    [self.payMoneyView.payButton addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];//支付按钮
    [self.sheetView addSubview:self.payMoneyView];
    
    self.wechatView = [[TDPayTypeView alloc] init];
    self.wechatView.typeLabel.text = NSLocalizedString(@"WECHAT_PAY", nil);
    self.alipayView.headerImage.image = [UIImage imageNamed:@"weChat"];
    [self.payTypeView addSubview:self.wechatView];
    
    self.alipayView = [[TDPayTypeView alloc] init];
    self.alipayView.typeLabel.text = NSLocalizedString(@"ALI_PAY", nil);
    self.alipayView.headerImage.image = [UIImage imageNamed:@"zhifu"];
    [self.payTypeView addSubview:self.alipayView];
    
    self.line = [[UILabel alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    [self.payTypeView addSubview:self.line];
}

- (void)setViewConstraint {
    [self.sheetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(sheetHeight);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.sheetView);
        make.height.mas_equalTo(60);
    }];
    
    [self.payMoneyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.sheetView);
        make.height.mas_equalTo(48);
    }];
    
    [self.payTypeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.sheetView);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.bottom.mas_equalTo(self.payMoneyView.mas_top);
    }];
    
    [self.wechatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.payTypeView);
        make.height.mas_equalTo(60);
    }];
    
    [self.alipayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.payTypeView);
        make.height.mas_equalTo(60);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.payTypeView);
        make.centerY.mas_equalTo(self.payTypeView);
        make.height.mas_equalTo(1);
    }];
}

@end





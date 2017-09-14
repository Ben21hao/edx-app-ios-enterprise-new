//
//  TDPaySheetView.m
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDPaySheetView.h"
#import "TDBaseView.h"
#import "WXApi.h"

#define sheetHeight 228
#define noWechatHeight 168

@interface TDPaySheetView ()

@property (nonatomic,strong) UIView *sheetView;
@property (nonatomic,strong) UIView *payTypeBgView;
@property (nonatomic,strong) UILabel *line;

@property (nonatomic,strong) TDBaseView *topView;


@property (nonatomic,assign) BOOL isInstallWechat;
@property (nonatomic,assign) CGFloat payHeight;

@end

@implementation TDPaySheetView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isInstallWechat = [WXApi isWXAppInstalled];
        self.payHeight = self.isInstallWechat ? sheetHeight : noWechatHeight;
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - UI
- (void)configView {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    self.tapView = [[UIView alloc] init];
    [self addSubview:self.tapView];
    
    self.sheetView = [[UIView alloc] init];
    self.sheetView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    self.sheetView.frame = CGRectMake(0, TDHeight, TDWidth, self.payHeight);
    [self addSubview:self.sheetView];
    
    self.topView = [[TDBaseView alloc] initWithTitle:TDLocalizeSelect(@"SELECT_PAYWAY", nil)];
    [self.sheetView addSubview:self.topView];
    
    self.payTypeBgView = [[UIView alloc] init];
    self.payTypeBgView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self.sheetView addSubview:self.payTypeBgView];
    
    self.payMoneyView = [[TDPayMoneyView alloc] init];
    [self.sheetView addSubview:self.payMoneyView];
    
    self.wechatView = [[TDPayTypeView alloc] init];
    self.wechatView.typeLabel.text = TDLocalizeSelect(@"WECHAT_PAY", nil);
    self.wechatView.headerImage.image = [UIImage imageNamed:@"weChat"];
    [self.payTypeBgView addSubview:self.wechatView];
    
    self.alipayView = [[TDPayTypeView alloc] init];
    self.alipayView.typeLabel.text = TDLocalizeSelect(@"ALI_PAY", nil);
    self.alipayView.headerImage.image = [UIImage imageNamed:@"zhifu"];
    [self.payTypeBgView addSubview:self.alipayView];
    
    self.line = [[UILabel alloc] init];
    self.line.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    [self.payTypeBgView addSubview:self.line];
    
    self.wechatView.selectButton.selected = self.isInstallWechat;
    self.alipayView.selectButton.selected = !self.isInstallWechat;
}

- (void)setViewConstraint {
    
    [self.tapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo(TDHeight - self.payHeight);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.sheetView);
        make.height.mas_equalTo(60);
    }];
    
    [self.payMoneyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.sheetView);
        make.height.mas_equalTo(48);
    }];
    
    [self.payTypeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.sheetView);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.bottom.mas_equalTo(self.payMoneyView.mas_top);
    }];
    
    [self.wechatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.payTypeBgView);
        make.height.mas_equalTo(60);
    }];
    
    [self.alipayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.payTypeBgView);
        make.height.mas_equalTo(60);
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.payTypeBgView);
        make.centerY.mas_equalTo(self.payTypeBgView);
        make.height.mas_equalTo(0.5);
    }];
    
    self.wechatView.hidden = !self.isInstallWechat;
    self.line.hidden = !self.isInstallWechat;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.sheetView.frame = CGRectMake(0, TDHeight - self.payHeight, TDWidth, self.payHeight);
    }];
}

@end





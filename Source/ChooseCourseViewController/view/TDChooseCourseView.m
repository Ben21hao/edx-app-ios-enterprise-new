//
//  TDChooseCourseView.m
//  edX
//
//  Created by Elite Edu on 16/12/10.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "TDChooseCourseView.h"

@interface TDChooseCourseView ()

@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UILabel *totalLabel;

@end

@implementation TDChooseCourseView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        [self config];
        [self setContstraint];
    }
    return self;
}

- (void)config {
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self addSubview:self.tableView];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bottomView];
    
    self.totalButton = [[UIButton alloc] init];
    [self.totalButton setImage:[UIImage imageNamed:@"Shape1"] forState:UIControlStateNormal];
    [self.totalButton setImage:[UIImage imageNamed:@"Shape"] forState:UIControlStateSelected];
    [self.totalButton setTitle:NSLocalizedString(@"SELCT_ALL", nil) forState:UIControlStateNormal];
    [self.totalButton setTitleColor:[UIColor colorWithHexString:colorHexStr1] forState:UIControlStateNormal];
    self.totalButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.totalButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    [self.totalButton addTarget:self action:@selector(totalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.totalButton];
    
    self.totalLabel = [[UILabel alloc] init];
    self.totalLabel.text = NSLocalizedString(@"IN_TOTAL_PRICE", nil);
    self.totalLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.totalLabel.font = [UIFont systemFontOfSize:14];
    [self.bottomView addSubview:self.totalLabel];
    
    self.totalMoney = [[UILabel alloc] init];
    self.totalMoney.textColor = [UIColor colorWithHexString:@"#fa7f2b"];
    self.totalMoney.font = [UIFont systemFontOfSize:14];
    self.totalMoney.text = @"￥0.00";
    [self.bottomView addSubview:self.totalMoney];
    
    self.originalMoney = [[UILabel alloc] init];
    self.originalMoney.textColor = [UIColor colorWithHexString:colorHexStr8];
    self.originalMoney.font = [UIFont systemFontOfSize:13];
    self.originalMoney.attributedText = [self setOriginMoneyLabelWithStr:@"￥0.00"];
    [self.bottomView addSubview:self.originalMoney];
    
    self.summitButton = [[UIButton alloc] init];
    self.summitButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.summitButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.summitButton.titleLabel.numberOfLines = 0;
    self.summitButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.summitButton setTitle:NSLocalizedString(@"HANDIN_COURSE_LIST", nil) forState:UIControlStateNormal];
    [self.summitButton addTarget:self action:@selector(submitCoursesButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.summitButton];
}

- (void)setContstraint {
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(48);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self.bottomView.mas_top).offset(0);
    }];
    

    [self.totalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bottomView.mas_left).offset(18);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
    }];
    
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.totalButton.mas_right).offset(8);
        make.centerY.mas_equalTo(self.bottomView);
    }];
    
    [self.totalMoney mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.totalLabel.mas_right).offset(0);
        make.centerY.mas_equalTo(self.bottomView);
    }];
    
    [self.originalMoney mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.totalMoney.mas_right).offset(3);
        make.centerY.mas_equalTo(self.bottomView);
    }];
    
    float btWidth = TDWidth > 320 ? 99 :79;
    [self.summitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.mas_equalTo(self.bottomView);
        make.width.mas_equalTo(btWidth);
    }];
    
}


#pragma mark - action
- (void)totalButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (self.totalButtonHandle) {
        self.totalButtonHandle(sender.isSelected);
    }
}

- (void)submitCoursesButtonAction:(UIButton *)sender {
    if (self.summitButtonHandle) {
        self.summitButtonHandle();
    }
}

- (NSAttributedString *)setOriginMoneyLabelWithStr:(NSString *)originMoney {
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:originMoney attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
    return string;
}

@end

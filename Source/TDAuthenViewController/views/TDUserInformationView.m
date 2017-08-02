//
//  TDUserInformationView.m
//  edX
//
//  Created by Ben on 2017/4/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDUserInformationView.h"


@interface TDUserInformationView() <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *topLabel;

@property (nonatomic,strong) UIView *headerview;
@property (nonatomic,strong) UIView *footView;

@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) UIButton *sureButton;
@property (nonatomic,strong) UIView *pickerView;
@property (nonatomic,strong) UIDatePicker *datePicker;
@property (nonatomic,strong) UIPickerView *sexPicker;

@property (nonatomic,assign) NSInteger height;
@property (nonatomic,strong) NSString *sexStr;

@end

@implementation TDUserInformationView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sexStr = NSLocalizedString(@"TD_MAN", nil);
        [self setViewConstraint];
    }
    return self;
}

- (void)setViewConstraint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    self.headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, 99)];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:18];
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.titleLabel.text = NSLocalizedString(@"THIRD_MESSAGE", nil);
    [self.headerview addSubview:self.titleLabel];
    
    self.topLabel = [[UILabel alloc] init];
    self.topLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.topLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.topLabel.text = NSLocalizedString(@"ENTER_MESSAGE", nil);
    [self.headerview addSubview:self.topLabel];
    
    self.tableView.tableHeaderView = self.headerview;
    
    self.footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight - 335)];
    
    self.handinButton = [[UIButton alloc] init];
    [self.handinButton setTitle:NSLocalizedString(@"SUBMIT", nil) forState:UIControlStateNormal];
    self.handinButton.layer.cornerRadius = 4.0;
    self.handinButton.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    [self.handinButton addTarget:self action:@selector(handinButtonAciton:) forControlEvents:UIControlEventTouchUpInside];
    [self.footView addSubview:self.handinButton];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.footView addSubview:self.activityView];
    
    self.tableView.tableFooterView = self.footView;
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.headerview.mas_centerX);
        make.top.mas_equalTo(self.headerview.mas_top).offset(18);
    }];
    
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.headerview.mas_centerX);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
    }];
    
    [self.handinButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.footView.mas_centerX);
        make.top.mas_equalTo(self.footView.mas_top).offset(18);
        make.size.mas_equalTo(CGSizeMake(TDWidth - 36, 41));
    }];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.handinButton.mas_centerY);
        make.right.mas_equalTo(self.handinButton.mas_right).offset(-8);
    }];
    
    [self setUpDatePickerView];
}

- (void)setUpDatePickerView { //设置弹出界面
    self.height = 268;
    
    self.dateView = [[UIView alloc] initWithFrame:CGRectMake(0, TDHeight, TDWidth, self.height)];
    self.dateView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self addSubview:self.dateView];
    
    self.cancelButton = [self setButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
    [self.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.dateView addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dateView.mas_left).offset(8);
        make.top.mas_equalTo(self.dateView.mas_top).offset(0);
        make.height.mas_equalTo(CGSizeMake(48, 40));
    }];
    
    self.sureButton = [self setButtonWithTitle:NSLocalizedString(@"OK", nil)];
    [self.sureButton addTarget:self action:@selector(sureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.dateView addSubview:self.sureButton];
    [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.dateView.mas_right).offset(-8);
        make.top.mas_equalTo(self.dateView.mas_top).offset(0);
        make.size.mas_equalTo(CGSizeMake(48, 40));
    }];
    
    self.pickerView = [[UIView alloc] init];
    self.pickerView.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    [self.dateView addSubview:self.pickerView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.dateView);
        make.top.mas_equalTo(self.cancelButton.mas_bottom);
    }];
    
    [self addDatePicker]; //时间
    [self addSexPickerView]; //性别
}

- (void)addDatePicker { //日期选择器
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-mm-dd";
    
    NSDate *minDate = [dateFormatter dateFromString:@"1900-01-01"];
    NSDate *maxDate = [NSDate date];
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    
    self.datePicker.minimumDate = minDate;
    self.datePicker.maximumDate = maxDate;
    [self.datePicker addTarget:self action:@selector(dateChageAction:) forControlEvents:UIControlEventValueChanged];
    [self.pickerView addSubview:self.datePicker];
    
    self.datePicker.hidden = YES;
}

- (void)addSexPickerView { //性别选择
    
    self.sexPicker = [[UIPickerView alloc] init];
    self.sexPicker.delegate = self;
    self.sexPicker.dataSource = self;
    [self.pickerView addSubview:self.sexPicker];
    
    [self.sexPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.pickerView);
        make.bottom.mas_equalTo(self.pickerView.mas_bottom).offset(-43);
    }];
}

#pragma mark - pickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return row == 0 ? NSLocalizedString(@"TD_MAN", nil) : NSLocalizedString(@"TD_WOMEN", nil);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.sexStr = row == 0 ? NSLocalizedString(@"TD_MAN", nil) : NSLocalizedString(@"TD_WOMEN", nil);
}

- (UIButton *)setButtonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:colorHexStr1] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    return button;
}

#pragma mark - 提交
- (void)handinButtonAciton:(UIButton *)sender {
    [self.tableView reloadData];
}

#pragma mark - 选择显示的弹窗
- (void)setIsDate:(BOOL)isDate {
    _isDate = isDate;
    
    self.height = _isDate ? 268 : 198;
    [self showDateView:_isDate];
}

- (void)showDateView:(BOOL)show {
    self.datePicker.hidden = !show;
    self.sexPicker.hidden = show;
}

#pragma mark - action
- (void)dateChageAction:(UIDatePicker *)sender { //选择日期
    NSLog(@" -------- %@",sender.date);
}

- (void)cancelButtonAction:(UIButton *)sender { //取消
    [UIView animateWithDuration:0.5 animations:^{
        self.dateView.frame = CGRectMake(0, TDHeight, TDWidth, self.height);
    }];
}

- (void)sureButtonAction:(UIButton *)sender { //确定
    [UIView animateWithDuration:0.5 animations:^{
        self.dateView.frame = CGRectMake(0, TDHeight, TDWidth, self.height);
    }];
    
    if (self.isDate) {
        NSDate *sendDate = self.datePicker.date;
        
        NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateStyle:NSDateFormatterMediumStyle];
        [dateformatter setDateFormat:@"YYYY-MM-dd"];
        NSString *locationString=[dateformatter stringFromDate:sendDate];
        
        if (self.selectDateHandle) {
            self.selectDateHandle(locationString);
        }
        
        NSLog(@"选择的时间 -- %@ ++ 显示时间 -- %@",self.datePicker.date,locationString);
    } else {
        if (self.selectSexHandle) {
            self.selectSexHandle(self.sexStr);
        }
        NSLog(@"选择的时间 -- %@",self.sexStr);
    }
    
    [self.tableView reloadData];
}


@end

//
//  TDLiveLotteryView.m
//  edX
//
//  Created by Elite Edu on 2017/9/4.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDLiveLotteryView.h"


@interface TDLiveLotteryView () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) UILabel *lotteryTip;
@property (nonatomic,strong) UILabel *winTip;
@property (nonatomic,strong) UIButton *closeBtn;
@property (nonatomic,strong) UITableView *resultTable;
@property (nonatomic,strong) UILabel *lblName;
@property (nonatomic,strong) UILabel *lblPhone;
@property (nonatomic,strong) UIButton *btnSubmit;

@property (nonatomic,strong) UIView *resultView;
@property (nonatomic,strong) UIView *bottomView;

@end

@implementation TDLiveLotteryView

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeText) userInfo:nil repeats:YES];
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

-(void)changeText {//抽奖中
    
    if ([self.lotteryTip.text isEqualToString:[NSString stringWithFormat:@"%@...",TDLocalizeSelect(@"PROCESSING_TIP_TEXT", nil)]]) {
        self.lotteryTip.text = TDLocalizeSelect(@"PROCESSING_TIP_TEXT", nil);
    } else{
        self.lotteryTip.text = [self.lotteryTip.text stringByAppendingString:@"."];
    }
}

- (void)closeBtnAction:(UIButton *)sender { //关闭
    [self setNilTimer];
    [self tablAction];
    
    if (self.closeButtonHandle) {
        self.closeButtonHandle();
    }
}

- (void)btnSubmitAction:(UIButton *)sender { //提交
    
    [self tablAction];
    
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:self.tfName, @"name", self.tfPhone, @"phone", nil];
    
    [_lottery submitLotteryInfo:dict success:^{
        
        [self closeBtnAction:self.closeBtn];
        [self makeToast:TDLocalizeSelect(@"HANDIN_SUCCESS", nil) duration:1.08 position:CSToastPositionCenter];
        
    } failed:^(NSDictionary *failedData) {
        
        [self makeToast:failedData[@"content"] duration:1.08 position:CSToastPositionCenter];
    }];
    
}


- (void)setEndLotteryModel:(VHallEndLotteryModel *)endLotteryModel {
    _endLotteryModel = endLotteryModel;
    
    [self setNilTimer];
    self.lotteryTip.hidden = YES;
    self.resultView.hidden = NO;
    
    if (self.endLotteryModel.isWin) { //是否中奖
        self.bottomView.hidden = NO;
        self.winTip.text = TDLocalizeSelect(@"CONGRATULATIONS", nil);
    } else {
        self.bottomView.hidden = YES;
        self.winTip.text = TDLocalizeSelect(@"LUCKY_DRAW_RESULT", nil);
    }
    
    [self.resultTable reloadData];
}

- (void)setNilTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)tablAction {
    [self.tfName resignFirstResponder];
    [self.tfPhone resignFirstResponder];
}

#pragma makr - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.endLotteryModel.resultModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VHallLotteryResultModel *model = self.endLotteryModel.resultModels[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TDLiveLotteryCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDLiveLotteryCell"];
    }
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = model.nick_name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - textField Delegate 
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [UIView animateWithDuration:1.3 animations:^{
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.resultView);
            make.height.mas_equalTo(48);
            make.bottom.mas_equalTo(-TDKeybordHeight - 88);
            
        }];
    }];

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.resultView);
        make.height.mas_equalTo(48);
        
    }];
}


#pragma mark - UI
- (void)configView {
    
    UIColor *red = [UIColor redColor];
    self.backgroundColor = [red colorWithAlphaComponent:0.8];
    self.exclusiveTouch = YES;//避免错点
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tablAction)];
    
    self.lotteryTip = [self labelStly:TDLocalizeSelect(@"PROCESSING_TIP_TEXT", nil) font:18];
    [self addSubview:self.lotteryTip];
    
    self.closeBtn = [[UIButton alloc] init];
    self.closeBtn.showsTouchWhenHighlighted = YES;
    [self.closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [self.closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeBtn];
    
    self.resultView = [[UIView alloc] init];
    self.resultView.backgroundColor = [UIColor clearColor];
    [self.resultView addGestureRecognizer:tap];
    [self addSubview:self.resultView];

    self.winTip = [self labelStly:TDLocalizeSelect(@"LUCKY_DRAW_RESULT", nil) font:18];
    [self.resultView addSubview:self.winTip];
    
    self.resultTable = [[UITableView alloc] init];
    self.resultTable.delegate = self;
    self.resultTable.dataSource = self;
    self.resultTable.backgroundColor = [UIColor clearColor];
    self.resultTable.tableFooterView = [UIView new];
    [self.resultView addSubview:self.resultTable];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor redColor];
    self.bottomView.userInteractionEnabled = YES;
    [self.resultView addSubview:self.bottomView];
    
    self.lblName = [self labelStly:TDLocalizeSelect(@"TRURE_NAME_TEXT", nil) font:14];
    [self.bottomView addSubview:self.lblName];

    self.tfName = [[UITextField alloc] init];
    self.tfName.borderStyle = UITextBorderStyleRoundedRect;
    self.tfName.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.tfName.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.bottomView addSubview:self.tfName];
    
    self.lblPhone = [self labelStly:TDLocalizeSelect(@"PHONE_NUMBER", nil) font:14];
    [self.bottomView addSubview:self.lblPhone];
    
    self.tfPhone = [[UITextField alloc] init];
    self.tfPhone.borderStyle = UITextBorderStyleRoundedRect;
    self.tfPhone.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.tfPhone.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.bottomView addSubview:self.tfPhone];
    
    self.btnSubmit = [[UIButton alloc] init];
    self.btnSubmit.showsTouchWhenHighlighted = YES;
    self.btnSubmit.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnSubmit setTitle:TDLocalizeSelect(@"SUBMIT", nil) forState:UIControlStateNormal];
    [self.btnSubmit addTarget:self action:@selector(btnSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnSubmit];
    
    self.tfPhone.delegate = self;
    self.tfName.delegate = self;
    
    self.resultView.hidden = YES;
//    self.bottomView.hidden = YES;
//    self.lotteryTip.hidden = YES;
}

- (UILabel *)labelStly:(NSString *)title font:(NSInteger)font {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"OpenSans" size:font];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    return label;
}

- (void)setViewConstraint {

    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(43, 43));
    }];
    
    [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.top.mas_equalTo(self.closeBtn.mas_bottom);
    }];
    
    [self.winTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.resultView.mas_top).offset(0);
        make.left.right.mas_equalTo(self.resultView);
        make.height.mas_equalTo(39);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.resultView);
        make.height.mas_equalTo(48);
    }];
    
    [self.lblName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bottomView.mas_left).offset(8);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(48, 39));
    }];
    
    [self.tfName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lblName.mas_right).offset(0);
        make.centerY.mas_equalTo(self.lblName.mas_centerY);
        make.size.mas_equalTo(CGSizeMake((TDWidth - 56 * 2 - 79) / 2, 33));
        
    }];
    
    [self.lblPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tfName.mas_right);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(79, 39));
    }];
    
    [self.tfPhone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lblPhone.mas_right);
        make.centerY.mas_equalTo(self.lblPhone.mas_centerY);
        make.size.mas_equalTo(CGSizeMake((TDWidth - 56 * 2 - 79) /2, 33));
    }];
    
    [self.btnSubmit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tfPhone.mas_right);
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.right.mas_equalTo(self.bottomView.mas_right);
        make.height.mas_equalTo(39);
    }];
    
    [self.resultTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.winTip.mas_bottom);
        make.bottom.mas_equalTo(self.self.resultView.mas_bottom).offset(-56);
        make.left.right.mas_equalTo(self.resultView);
    }];
    
    [self.lotteryTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.center);
    }];
}

@end





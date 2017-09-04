//
//  WatchLiveLotteryViewController.m
//  VHallSDKDemo
//
//  Created by Ming on 16/10/14.
//  Copyright © 2016年 vhall. All rights reserved.
//

#import "WatchLiveLotteryViewController.h"
#import "WatchLiveLotteryTableViewCell.h"
#import "VHallLottery.h"

@interface WatchLiveLotteryViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@end

@implementation WatchLiveLotteryViewController
{
    NSTimer * timer;
    __weak IBOutlet UILabel *lotteryTip;
    __weak IBOutlet UILabel *winTip;
    __weak IBOutlet UIButton *closeBtn;
    __weak IBOutlet UITableView *resultTable;
    __weak IBOutlet UILabel *lblName;
    __weak IBOutlet UITextField *tfName;
    __weak IBOutlet UILabel *lblPhone;
    __weak IBOutlet UITextField *tfPhone;
    __weak IBOutlet UIButton *btnSubmit;
}

- (id)init {
    
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:meetingResourcesBundle];
    if (self) {
        _lotteryOver = NO;
        resultTable.hidden = YES;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeText) userInfo:nil repeats:YES];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    lotteryTip.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    lotteryTip.text = NSLocalizedString(@"PROCESSING_TIP_TEXT", nil);
    
    lblName.text = NSLocalizedString(@"TRURE_NAME_TEXT", nil);
    lblName.font = [UIFont fontWithName:@"OpenSans" size:13];
    lblPhone.text = [NSString stringWithFormat:@"%@",NSLocalizedString(@"PHONE_NUMBER", nil)];
    lblPhone.font = [UIFont fontWithName:@"OpenSans" size:13];
    [btnSubmit setTitle:NSLocalizedString(@"SUBMIT", nil) forState:UIControlStateNormal];
    btnSubmit.titleLabel.font =[UIFont fontWithName:@"OpenSans" size:13];
    
    if (_lotteryOver) {
        [lotteryTip removeFromSuperview];
        lotteryTip = nil;
        resultTable.hidden = NO;
        
        if (_endLotteryModel.isWin) {
            lblName.hidden = NO;
            tfName.hidden = lblName.hidden;
            lblPhone.hidden = lblName.hidden;
            tfPhone.hidden = lblName.hidden;
            btnSubmit.hidden = lblName.hidden;
            winTip.text = NSLocalizedString(@"CONGRATULATIONS", nil);
        } else {
            winTip.text = NSLocalizedString(@"LUCKY_DRAW_RESULT", nil);
        }
    }
}

-(void)dealloc {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}


-(void)changeText {
    
    if ([lotteryTip.text isEqualToString:[NSString stringWithFormat:@"%@...",NSLocalizedString(@"PROCESSING_TIP_TEXT", nil)]]) {
        lotteryTip.text = NSLocalizedString(@"PROCESSING_TIP_TEXT", nil);
    } else{
        lotteryTip.text = [lotteryTip.text stringByAppendingString:@"."];
    }
}


-(void)setLotteryOver:(BOOL)lotteryOver {
    
    _lotteryOver = lotteryOver;
    
    if (_lotteryOver) {
        if (timer) {
            [timer invalidate];
            timer = nil;
        }
        [self loadView];
    }
}

- (IBAction)closeBtnClick:(id)sender {
    [self destory];
}

- (void)destory {
    
    self.lotteryOver = YES;
    self.view.hidden = YES;
}

- (IBAction)submitBtnClick:(id)sender { //提交
    
    NSString *name = tfName.text;
    NSString *phone = tfPhone.text;
    
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", phone, @"phone", nil];
    
    [_lottery submitLotteryInfo:dict success:^{
        
        [self closeBtnClick:nil];
        [self.view makeToast:NSLocalizedString(@"HANDIN_SUCCESS", nil) duration:1.08 position:CSToastPositionCenter];
        
    } failed:^(NSDictionary *failedData) {
        
//        NSString* code = [NSString stringWithFormat:@"%@", failedData[@"code"]];
//        [UIAlertView popupAlertByDelegate:nil title:failedData[@"content"] message:code];
        [self.view makeToast:failedData[@"content"] duration:1.08 position:CSToastPositionCenter];
    }];
}

#pragma mark - tableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _endLotteryModel.resultModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *qaIndetify = @"WatchLiveLotteryCell";
    WatchLiveLotteryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:qaIndetify];
    if (!cell) {
        cell = [[WatchLiveLotteryTableViewCell alloc] init];
    }
    cell.model = [_endLotteryModel.resultModels objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.view endEditing:YES];
    [self resignFirstResonder];
}

#pragma mark - textField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self resignFirstResonder];
    
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self resignFirstResonder];
}

- (void)resignFirstResonder {
    [tfName resignFirstResponder];
    [tfPhone resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

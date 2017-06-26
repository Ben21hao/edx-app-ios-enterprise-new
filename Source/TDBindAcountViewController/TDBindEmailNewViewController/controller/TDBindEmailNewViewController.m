//
//  TDBindEmailNewViewController.m
//  edX
//
//  Created by Ben on 2017/6/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDBindEmailNewViewController.h"
#import "TDBindSuccessViewController.h"
#import "TDBindEmailNewView.h"

@interface TDBindEmailNewViewController ()

@property (nonatomic,strong) TDBindEmailNewView *bindView;
@property (nonatomic,assign) int timeNum;
@property (nonatomic,strong) NSTimer *timer;//定时器
@property (nonatomic,strong) NSString *randomNumber;//本地随机生成的验证码

@property (nonatomic,strong) TDBaseToolModel *toolModel;

@end

@implementation TDBindEmailNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = NSLocalizedString(@"BIND_EMAIL", nil);
    
    [self setViewConstraint];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.toolModel = [[TDBaseToolModel alloc] init];
}

#pragma mark - 获取验证码
- (void)getCodeAction {
    
    [self handleResendButton:NO];
    [self cutDownTime];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    
//    int num = (arc4random() % 1000000);
//    NSString *randomNumber = [NSString stringWithFormat:@"%.6d", num];//六位数验证码
//    self.randomNumber = randomNumber;
//    
//    NSString *message = [NSString stringWithFormat:@"您正在注册英荔账号，验证码为%@，5分钟内有效。",self.randomNumber];
//    
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setValue:self.bindView.emailInputField.text forKey:@"mobile"];
//    [params setValue:message forKey:@"msg"];
//    
//    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/v0.5/account/send_captcha_message_for_register/",ELITEU_URL];
//    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        NSDictionary *dict = (NSDictionary *)responseObject;
//        id code = dict[@"code"];
//        
//        if ([code intValue] == 403) {
//            [self handleResendButton:YES];
//            
//            [self showPhoneNumberUsed];
//            
//        } else if([code intValue] == 200){
//            [self.view makeToast:NSLocalizedString(@"AUTHENTICATION_CODE_SENT", nil) duration:1.08 position:CSToastPositionCenter];
//            
//            [self cutDownTime];
//            
//        } else {
//            [self handleResendButton:YES];
//            
//            [self.view makeToast:NSLocalizedString(@"FAILED_GET_VERIFICATION", nil) duration:1.08 position:CSToastPositionCenter];
//            
//            NSLog(@"验证登录密码失败 -- %@",code);
//        }
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//        [self handleResendButton:YES];
//        [self.view makeToast:NSLocalizedString(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
//        NSLog(@"%ld",(long)error.code);
//    }];
}

#pragma mark - 已注册过
- (void)showPhoneNumberUsed {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"PHONE_NUMBER_HAS_BEEN_REGISTERED", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark -- 倒计时
- (void)cutDownTime {
    
    self.bindView.codeButton.userInteractionEnabled = NO;
    self.timeNum = 60;
    
    NSString *timeStr = [self.toolModel addSecondsForNow:[NSNumber numberWithInteger:60]];
    [[NSUserDefaults standardUserDefaults] setValue:timeStr forKey:@"Get_Code_Date_Str"]; //结束时间 = 当前时间 + 剩余秒数
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)timeChange {
    
    [self.bindView.codeActivitView stopAnimating];
    self.bindView.codeButton.userInteractionEnabled = NO;
    [self.bindView.codeButton setTitle:[NSString stringWithFormat:@"%d%@",self.timeNum,NSLocalizedString(@"SECOND", nil)] forState:UIControlStateNormal];
    self.bindView.codeButton.alpha = 0.8;
    
    self.timeNum -= 1;
    
    if (self.timeNum <= 0) {
        [self.timer invalidate];
        [self handleResendButton:YES];
    }
}

- (void)handleResendButton:(BOOL)isEnable {
    
    isEnable ? [self.bindView.codeActivitView stopAnimating] : [self.bindView.codeActivitView startAnimating];
    self.bindView.codeButton.userInteractionEnabled = isEnable;
    [self.bindView.codeButton setTitle:isEnable ? NSLocalizedString(@"RESEND", nil) : @"" forState:UIControlStateNormal];
    self.bindView.codeButton.alpha = isEnable ? 1 : 0.8;
}


#pragma mark - 确定
- (void)handinAction {
    
    [self.bindView.activityView startAnimating];
    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    [params setValue:self.username forKey:@"username"];
//    [params setValue:self.bindView.emailInputField.text forKey:@"email"];
//    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/v0.5/account/bind_email/",ELITEU_URL];
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        [self.bindView.activityView stopAnimating];
//        
//        NSDictionary *respondDic = (NSDictionary *)responseObject;
//        id code = respondDic[@"code"];
//        
//        if ([code intValue] == 200) {
//            if (self.bindEmailHandle) {
//                self.bindEmailHandle(self.bindView.emailInputField.text);
//            }
//            TDBindSuccessViewController *successVC = [[TDBindSuccessViewController alloc] init];
//            [self.navigationController pushViewController:successVC animated:YES];
//            
//        }  else if ([code intValue] == 500) {
//            [self.view makeToast:NSLocalizedString(@"UNKNOWN_ERROR", nil) duration:1.08 position:CSToastPositionCenter];
//            
//        } else if ([code  intValue] == 403) {
//            [self.view makeToast:NSLocalizedString(@"EMAIL_IS_REGISTERED", nil) duration:1.08 position:CSToastPositionCenter];
//            
//        }  else {
//            NSLog(@"验证登录密码 -- %@",respondDic[@"msg"]);
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [self.bindView.activityView stopAnimating];
//        NSLog(@"验证登录密码 -- %ld",(long)error.code);
//    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.bindView endEditing:YES];
}

#pragma mark - UI
- (void)setViewConstraint {
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    self.bindView = [[TDBindEmailNewView alloc] init];
    [self.view addSubview:self.bindView];
    
    [self.bindView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    WS(weakSelf);
    self.bindView.codeButtonClickHandle = ^(){
        [weakSelf getCodeAction];
    };
    
    self.bindView.handinButtonClickHandle = ^(){
        [weakSelf handinAction];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  TDMsmCodeLoginViewController.m
//  edX
//
//  Created by Elite Edu on 2018/5/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDMsmCodeLoginViewController.h"
#import "TDMessgeLoginView.h"

#import "TDWebViewController.h"
#import "OEXAccessToken.h"
#import "OEXAuthentication.h"

#define USER_LOGIN_NAME @"User_Login_Name_Enterprise"

@interface TDMsmCodeLoginViewController () <UITextFieldDelegate>

@property (nonatomic,strong) TDMessgeLoginView *loginView;
@property (nonatomic,strong) TDBaseToolModel *baseTool;

@property (nonatomic,assign) int timeNum;
@property (nonatomic,strong) NSTimer *timer;//定时器

@property (nonatomic,assign) BOOL isRequesting;

@end

@implementation TDMsmCodeLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = TDLocalizeSelect(@"SIGN_IN_TEXT", nil);
    [self setViewConstraint];
    
    self.baseTool = [[TDBaseToolModel alloc] init];
    self.timeNum = 0;
    self.isRequesting = NO;
    
    [self cutDownTime];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterForeground) name:@"App_EnterForeground_Get_Code" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self timerInvalidate];
    [self handleResendButton:YES];
    
    [self.view endEditing:YES];
    [self.loginView.messageView.loginButton.activityView stopAnimating];
}

#pragma mark - Action
- (void)passwordButtonAction:(UIButton *)sender { //账号密码登录
    [self.view endEditing:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)bottomButtonAction:(UIButton *)sender { //协议
    [self.view endEditing:YES];
    if (![self.baseTool networkingState]) {
        return;
    }
    
    TDWebViewController *webViewcontroller = [[TDWebViewController alloc] init];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"stipulation" withExtension:@"htm"];
    webViewcontroller.url = url;
    webViewcontroller.titleStr = TDLocalizeSelect(@"AGREEMENT", nil);
    [self.navigationController pushViewController:webViewcontroller animated:YES];
}

- (void)codeButtonAction:(UIButton *)sender { //验证码
    [self.view endEditing:YES];
    
    if (![self.baseTool networkingState]) {
        return;
    }
    
    [self getLoginMessage:self.phoneStr];
}

- (void)loginButtonAction:(UIButton *)sender { //登录
    [self.view endEditing:YES];
    
    if (![self.baseTool networkingState]) {
        return;
    }
    
    NSString *codeStr = self.loginView.messageView.codeTextFied.text;
    if (codeStr.length == 0) {
        [self showAlertView:TDLocalizeSelect(@"PLEASE_ENTER_CODE", nil) isLogin:YES];
        return;
    }
    
    [self loginByMessageCode:codeStr];
}

#pragma mark - 获取验证码
- (void)getLoginMessage:(NSString *)phoneStr {
    
    [self handleResendButton:NO];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@/oauth2/signin_validate_code",ELITEU_URL];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:phoneStr forKey:@"login_account"];
    
    [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            [self cutDownTime];
            self.messageStr = responseDic[@"msg"];
            [self.view makeToast:TDLocalizeSelect(@"TD_CODE_SENT_SUCCESS", nil) duration:1.08 position:CSToastPositionCenter];
        }
        else if ([code intValue] == 400) {
            [self handleResendButton:YES];
            [self showAlertView:TDLocalizeSelect(@"TD_ACCOUNT_NOEXIST_TEXT", nil) isLogin:YES];
        }
        else {
            [self handleResendButton:YES];
            [self.view makeToast:TDLocalizeSelect(@"CODE_SEND_FAILED", nil) duration:1.08 position:CSToastPositionCenter];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleResendButton:YES];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"发送登录验证码 -- %ld",(long)error.code);
    }];
}

#pragma mark -- 倒计时
- (void)cutDownTime {
    
    self.loginView.messageView.codeButton.userInteractionEnabled = NO;
    
    self.timeNum = 60;
    
    NSString *timeStr = [self.baseTool addSecondsForNow:[NSNumber numberWithInteger:60]];
    [[NSUserDefaults standardUserDefaults] setValue:timeStr forKey:@"Get_Code_Date_Str"]; //结束时间 = 当前时间 + 剩余秒数
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)timeChange {
    
    self.timeNum -= 1;
    
    [self.loginView.messageView.codeActivitView stopAnimating];
    
    self.loginView.messageView.codeButton.userInteractionEnabled = NO;
    [self.loginView.messageView.codeButton setTitle:[NSString stringWithFormat:@"%d%@",self.timeNum,TDLocalizeSelect(@"SECOND", nil)] forState:UIControlStateNormal];
    self.loginView.messageView.codeButton.alpha = 0.8;
    
    if (self.timeNum <= 0) {
        [self timerInvalidate];
        [self handleResendButton:YES];
    }
}

- (void)handleResendButton:(BOOL)isEnable {
    
    isEnable ? [self.loginView.messageView.codeActivitView stopAnimating] : [self.loginView.messageView.codeActivitView startAnimating];
    self.loginView.messageView.codeButton.userInteractionEnabled = isEnable;
    [self.loginView.messageView.codeButton setTitle:isEnable ? TDLocalizeSelect(@"RESEND", nil) : @"" forState:UIControlStateNormal];
    self.loginView.messageView.codeButton.alpha = 1;
}

- (void)appEnterForeground {
    self.timeNum = [self.baseTool getFreeCourseSecond:@"Get_Code_Date_Str"];
}

- (void)timerInvalidate { //注销timer
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - 登录
- (void)loginByMessageCode:(NSString *)codeStr {
    
    if (self.isRequesting) {
        return;
    }
    [self activityViewStart:YES];
    
    NSString *clientID = [[OEXConfig sharedConfig] oauthClientID];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@/oauth2/access_token_by_code",ELITEU_URL];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.loginView.messageView.codeTextFied.text forKey:@"verification_code"];
    [dict setValue:self.messageStr forKey:@"Msg"];
    
    [dict setValue:self.phoneStr forKey:@"username"];
    [dict setValue:clientID forKey:@"client_id"];
    [dict setValue:@"1" forKey:@"is_enterprise"];
    [dict setValue:@"password" forKey:@"grant_type"];
    
    [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self activityViewStart:NO];
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        
        if (![responseDic.allKeys containsObject:@"code"]) { //没有code为成功
            [self loginSuccess:responseDic];
        }
        else {
            id code = responseDic[@"code"];
            
            if ([code intValue] == 402) {//账号未激活
                [self showSentEailAlert];
            }
            else if ([code intValue] == 403) {//账号不属于任何公司
                [self showAlertView:TDLocalizeSelect(@"STUDENT_NO_LINKE_ORGANIZATION", nil) isLogin:YES];
            }
            else if ([code intValue] == 404) {//账号不存在
                [self showAlertView:TDLocalizeSelect(@"TD_ACCOUNT_NOEXIST_TEXT", nil) isLogin:YES];
            }
            else if ([code intValue] == 405) {//验证码已过期或不正确
                [self showAlertView:TDLocalizeSelect(@"ERROR_CODE_RE_ENTER", nil) isLogin:YES];
            }
            else if ([code intValue] == 406) {//账号已不可用
                [self showAlertView:TDLocalizeSelect(@"ACCOUNT_DISABLE", nil) isLogin:YES];
            }
            else if ([code intValue] == 500) {//登录失败
                [self showAlertView:TDLocalizeSelect(@"FLOATING_ERROR_LOGIN_TITLE", nil) isLogin:YES];
            }
            else {
                [self.view makeToast:TDLocalizeSelect(@"FLOATING_ERROR_LOGIN_TITLE", nil) duration:1.08 position:CSToastPositionCenter];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self activityViewStart:NO];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"发送登录验证码 -- %ld",(long)error.code);
    }];
}

- (void)loginSuccess:(NSDictionary *)dictionary {
    
    [[NSUserDefaults standardUserDefaults] setObject:self.phoneStr forKey:USER_LOGIN_NAME];
    
    OEXAccessToken *token = [[OEXAccessToken alloc] initWithTokenDetails:dictionary];
    
    WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [OEXAuthentication handleSuccessfulLoginWithToken:token completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            [weakSelf handleLoginResponseWith:data response:response error:error];
        }];
    });
}

- (void)handleLoginResponseWith:(NSData*)data response:(NSURLResponse*)response error:(NSError*)error {
    
    if(!error) {
        NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) response;
        
        if(httpResp.statusCode == 200) {
            [self loginSuccessful];
        }
        else if(httpResp.statusCode == 426) {
            [self showAlertView:TDLocalizeSelect(@"FLOATING_ERROR_LOGIN_TITLE", nil) isLogin:YES];
        }
        else if(httpResp.statusCode >= 400 && httpResp.statusCode <= 500) {
            [self showAlertView:TDLocalizeSelect(@"INVALID_USERNAME_PASSWORD", nil) isLogin:YES];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertView:TDLocalizeSelect(@"INVALID_USERNAME_PASSWORD", nil) isLogin:YES];
            });
        }
    }
    else {
        [self showAlertView:TDLocalizeSelect(@"FLOATING_ERROR_LOGIN_TITLE", nil) isLogin:YES];
    }
}

- (void)loginSuccessful { //登录成功
    
    [[NSUserDefaults standardUserDefaults] setObject:self.phoneStr forKey:USER_LOGIN_NAME];

    [self.view endEditing:YES];
    [self.loginView.messageView.loginButton.activityView stopAnimating];
    
    if (self.loginActionHandle) {
        self.loginActionHandle();
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - 402 账号未激活 - 只有邮箱账号需要激活
- (void)showSentEailAlert {
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:TDLocalizeSelect(@"NEED_ACTIVITY", nil) message:TDLocalizeSelect(@"SEND_EMAIL_ACTIVITY", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    WS(weakSelf);
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf resendEmail];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"CANCEL", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVc addAction:sureAction];
    [alertVc addAction:cancelAction];
    [self.navigationController presentViewController:alertVc animated:YES completion:nil];
}

#pragma mark - 重发邮件
- (void)resendEmail {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:self.phoneStr forKey:@"email"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/mobile/v0.5/account/resend_active_email/",ELITEU_URL];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.view makeToast:TDLocalizeSelect(@"SEND_EMAIL_SUCCESS", nil) duration:1.08 position:CSToastPositionTop];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"重发邮件 -- %ld",(long)error.code);
    }];
}

- (void)activityViewStart:(BOOL)isStart {
    self.isRequesting = isStart;
    if (isStart) {
        [self.loginView.messageView.loginButton setTitle:TDLocalizeSelect(@"SIGN_IN_BUTTON_TEXT_ON_SIGN_IN", nil) forState:UIControlStateNormal];
        [self.loginView.messageView.loginButton.activityView startAnimating];
    } else {
        [self.loginView.messageView.loginButton setTitle:TDLocalizeSelect(@"SIGN_IN", nil) forState:UIControlStateNormal];
        [self.loginView.messageView.loginButton.activityView stopAnimating];
    }
    
    self.view.userInteractionEnabled = !isStart;
}

- (void)showAlertView:(NSString *)messageStr isLogin:(BOOL)isLogin {
    
    NSString *titleStr = @"";
    if (isLogin) {
        titleStr = TDLocalizeSelect(@"FLOATING_ERROR_LOGIN_TITLE", nil);
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:titleStr message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:sureAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - textField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (TDHeight < 667) {
        self.loginView.scrollView.contentSize = CGSizeMake(TDWidth, TDHeight - BAR_ALL_HEIHT + 88);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (TDHeight < 667) {
        self.loginView.scrollView.contentSize = CGSizeMake(TDWidth, TDHeight - BAR_ALL_HEIHT);
    }
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.loginView = [[TDMessgeLoginView alloc] initWithType:TDLoginMessageViewTypeSendCode];
    self.loginView.messageView.phoneTextFied.text = self.phoneStr;
    self.loginView.messageView.codeTextFied.delegate = self;
    [self.view addSubview:self.loginView];
    
    [self.loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.loginView.messageView.loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView.messageView.codeButton addTarget:self action:@selector(codeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView.passwordButton addTarget:self action:@selector(passwordButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView.bottomButton addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end


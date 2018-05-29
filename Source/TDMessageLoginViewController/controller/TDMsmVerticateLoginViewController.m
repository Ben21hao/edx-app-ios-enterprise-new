//
//  TDMsmVerticateLoginViewController.m
//  edX
//
//  Created by Elite Edu on 2018/5/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDMsmVerticateLoginViewController.h"
#import "TDMessgeLoginView.h"

#include "TDMsmCodeLoginViewController.h"
#import "TDWebViewController.h"

@interface TDMsmVerticateLoginViewController ()

@property (nonatomic,strong) TDMessgeLoginView *loginView;

@property (nonatomic,strong) TDBaseToolModel *baseTool;
@property (nonatomic,strong) NSString *messageStr;

@property (nonatomic,assign) BOOL isRequesting;

@end

@implementation TDMsmVerticateLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = TDLocalizeSelect(@"SIGN_IN_TEXT", nil);
    self.leftButton.hidden = YES;
    self.baseTool = [[TDBaseToolModel alloc] init];
    [self setViewConstraint];
    
    self.isRequesting = NO;
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

- (void)sendButtonAction:(UIButton *)sender { //发送验证码
    [self.view endEditing:YES];
    
//    if (![self.baseTool networkingState]) {
//        return;
//    }
//    
//    NSString *phoneStr = self.loginView.verticationView.phoneTextFied.text;
//    if (phoneStr.length == 0) {
//        [self showAlertView:TDLocalizeSelect(@"ENTER_PHONE_OR_EMAIL", nil)];
//        return;
//    }
//    else if (![self.baseTool isValidateMobile:phoneStr] && ![self.baseTool isValidateEmail:phoneStr]) { //不是手机/邮箱
//        [self showAlertView:TDLocalizeSelect(@"ENTER_RIGHT_PHONE_OR_EMAIL", nil)];
//        return;
//    }
//    
//    [self getLoginMessage:phoneStr];
    
    [self gotoCodeViewController];
}

#pragma mark - 获取验证码
- (void)getLoginMessage:(NSString *)phoneStr {
    
    if (self.isRequesting) {
        return;
    }
    
    [self activityViewStart:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@/oauth2/signin_validate_code",ELITEU_URL];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:phoneStr forKey:@"login_account"];
    
    [manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        [self activityViewStart:NO];
        
        NSDictionary *responseDic = (NSDictionary *)responseObject;
        id code = responseDic[@"code"];
        
        if ([code intValue] == 200) {
            [self.view makeToast:TDLocalizeSelect(@"TD_CODE_SENT_SUCCESS", nil) duration:1.08 position:CSToastPositionCenter];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.08 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.messageStr = responseDic[@"msg"];
                [self gotoCodeViewController];
            });
        }
        else if ([code intValue] == 400) {
            [self showAlertView:TDLocalizeSelect(@"TD_ACCOUNT_NOEXIST_TEXT", nil)];
        }
        else {
            [self.view makeToast:TDLocalizeSelect(@"CODE_SEND_FAILED", nil) duration:1.08 position:CSToastPositionCenter];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self activityViewStart:NO];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"发送登录验证码 -- %ld",(long)error.code);
    }];
}

- (void)activityViewStart:(BOOL)isStart {
    self.isRequesting = isStart;
    if (isStart) {
        [self.loginView.verticationView.sendButton.activityView startAnimating];
    } else {
        [self.loginView.verticationView.sendButton.activityView stopAnimating];
    }
}

#pragma mark - 验证码页面
- (void)gotoCodeViewController {
    
    TDMsmCodeLoginViewController *codeVc = [[TDMsmCodeLoginViewController alloc] init];
    codeVc.phoneStr = self.loginView.verticationView.phoneTextFied.text;
    codeVc.messageStr = self.messageStr;
    WS(weakSelf);
    codeVc.loginActionHandle = ^(){
        [weakSelf LoginSuccess];
    };
    [self.navigationController pushViewController:codeVc animated:YES];
}

- (void)LoginSuccess {
    if (self.loginActionHandle) {
        self.loginActionHandle();
    }
}

- (void)showAlertView:(NSString *)titleStr {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:titleStr preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:sureAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - UI
- (void)setViewConstraint {
    self.loginView = [[TDMessgeLoginView alloc] initWithType:TDLoginMessageViewTypeVertication];
    [self.view addSubview:self.loginView];
    
    [self.loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.loginView.verticationView.sendButton addTarget:self action:@selector(sendButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView.passwordButton addTarget:self action:@selector(passwordButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginView.bottomButton addTarget:self action:@selector(bottomButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

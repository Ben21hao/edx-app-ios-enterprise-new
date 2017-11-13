//
//  TDLanguageViewController.m
//  edX
//
//  Created by Elite Edu on 2017/9/12.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDLanguageViewController.h"
#import "OEXAuthentication.h"
#import "OEXUserDetails.h"
#import "OEXSession.h"
#import "OEXAccessToken.h"

@interface TDLanguageViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation TDLanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = TDLocalizeSelect(@"LANGUAGE_SETTING_TEXT", nil);
    [self setViewConstraint];
}

- (void)setViewConstraint {
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorColor = [UIColor colorWithHexString:colorHexStr7];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

- (void)languageChangeAction {
    self.titleViewLabel.text = TDLocalizeSelect(@"LANGUAGE_SETTING_TEXT", nil);
}

- (void)handinToService:(NSString *)languageStr { // 0 中文， 1 英语
    
    TDBaseToolModel *model = [[TDBaseToolModel alloc] init];
    if (![model networkingState]) {
        return;
    }
    
    [SVProgressHUD showWithStatus:TDLocalizeSelect(@"REFRESHING_TEXT", nil)];
    SVProgressHUD.defaultMaskType = SVProgressHUDMaskTypeBlack;
    SVProgressHUD.defaultStyle = SVProgressHUDAnimationTypeNative;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:languageStr forKey:@"language"];
    NSString *url = [NSString stringWithFormat:@"%@/api/user/v1/accounts/%@",ELITEU_URL,self.username];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer]; // 返回的格式 JSON
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", nil];// 可接受的文本参数规格
    manager.requestSerializer = [AFJSONRequestSerializer serializer]; //先讲请求设置为json
    [manager.requestSerializer setValue:@"application/merge-patch+json" forHTTPHeaderField:@"Content-Type"];// 开始设置请求头
    
    NSString* authValue = [NSString stringWithFormat:@"%@", [OEXAuthentication authHeaderForApiAccess]];
    [manager.requestSerializer setValue:authValue forHTTPHeaderField:@"Authorization"];//安全验证
    
    [manager PATCH:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *respondDic = (NSDictionary *)responseObject;
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:respondDic];
        [dic setValue:respondDic[@"nickname"] forKey:@"nick_name"];
        [dic setValue:respondDic[@"user_id"] forKey:@"id"];
        //更新本地的缓存
        OEXSession* session = [OEXSession sharedSession];
        OEXUserDetails* userDetails = [[OEXUserDetails alloc] initWithUserDictionary:dic];
        [session saveAccessToken:session.token userDetails:userDetails];//保存登录信息
        
        NSLog(@"更新语言 ---->>>> %@ ---- %@",respondDic[@"language"],userDetails);
        [SVProgressHUD dismiss];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_CONNET_FAIL", nil) duration:1.08 position:CSToastPositionCenter];
        NSLog(@"绑定出错 -- %ld, %@",(long)error.code, error.userInfo[@"com.alamofire.serialization.response.error.data"]);
    }];
}

#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"languageViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"languageViewCell"];
    }
    cell.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    cell.textLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    
    NSString *languageStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"userLanguage"];
//    NSLog(@"%@ -- >> %@",rowStr,languageStr);
    NSUInteger row = [languageStr isEqualToString:@"en-CN"] || [languageStr isEqualToString:@"en"] ? 1 : 0;
    cell.accessoryType = row == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"中文";
            break;
        case 1:
            cell.textLabel.text = @"English";
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *rowStr = indexPath.row == 0 ? @"zh-Hans" : @"en";
    NSString *languageStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"userLanguage"];
    
    if ([languageStr isEqualToString:rowStr]) {
        return;
    }
    
    [LanguageChangeTool setUserlanguage:rowStr]; //zh-Hans-CN
    [self handinToService:rowStr]; //更新语言
    [[NSNotificationCenter defaultCenter] postNotificationName:@"languageSelectedChange" object:nil]; //通知语言发生变化
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end




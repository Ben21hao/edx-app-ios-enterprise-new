//
//  TDSettingViewController.m
//  edX
//
//  Created by Elite Edu on 16/12/27.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "TDSettingViewController.h"
#import "TDSettingCell.h"

#import "TDAboutWeViewController.h"
#import "TDLanguageViewController.h"

#import "edX-Swift.h"
#import "WYAlertView.h"

#import "TDRequestManager.h"
#import "NSObject+OEXReplaceNull.h"

@interface TDSettingViewController () <UITableViewDataSource, UITableViewDelegate,WYAlertViewDelegate>

@property (strong, nonatomic) UILabel *titleLabel;//自定义标题
@property (nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSString *download_url;

@end

@implementation TDSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [TDNotificationCenter addObserver:self selector:@selector(languageChangeAction) name:@"languageSelectedChange" object:nil];
    
    [self setTableViewConstraint];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:18.0];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = TDLocalizeSelect(@"ACCESSIBILITY_SETTINGS", nil);
    self.navigationItem.titleView = self.titleLabel;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)languageChangeAction {
    
    self.titleLabel.text = TDLocalizeSelect(@"ACCESSIBILITY_SETTINGS", nil);
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)setTableViewConstraint {
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}


#pragma mark - tableview Delegate 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

-  (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.separatorColor = [UIColor colorWithHexString:colorHexStr7];
    tableView.separatorInset = UIEdgeInsetsZero;
    
    if (indexPath.row == 0) {
        TDSettingCell *cell = [[TDSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDWifiCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell; 
        
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingCell"];
        }
        cell.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
        cell.textLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
        
        if (indexPath.row == 1) {
            cell.textLabel.text = TDLocalizeSelect(@"APP_VERSION_UPDATE", nil);
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = TDLocalizeSelect(@"LANGUAGE_TEXT", nil);
        }
        else {
            cell.textLabel.text = TDLocalizeSelect(@"ABOUT_APP", nil);
        }
        
        return cell;
    } 
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 68;
    } else {
        return 48;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 1) {
        [self judgeAppStoreVersion];
    }
    else if (indexPath.row == 2) {
        [self gotoLanguageViewController];
        
    } else if (indexPath.row == 3) {
        [self gotoAboutViewController];
    }
}

#pragma mark - action
- (void)gotoAboutViewController {//关于
    TDAboutWeViewController *aboutVc = [[TDAboutWeViewController alloc] init];
    [self.navigationController pushViewController:aboutVc animated:YES];
}

- (void)gotoLanguageViewController { //多语言
    TDLanguageViewController *languageVc = [[TDLanguageViewController alloc] init];
    languageVc.username = self.username;
    [self.navigationController pushViewController:languageVc animated:YES];
}

- (void)judgeAppStoreVersion { //通过App Store来判断
    
    TDBaseToolModel *model = [[TDBaseToolModel alloc] init];
    if (![model networkingState]) {
        return;
    }
    
    AFHTTPSessionManager * manager = [AFHTTPSessionManager shareManager];
    NSString *path = @"https://itunes.apple.com/lookup?bundleId=cn.eliteu.enterprise.mobile.ios&country=cn";
    
    [manager GET:path parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *appInfo = (NSDictionary *)responseObject;
        NSArray *infoArray = appInfo[@"results"];
        
        if (infoArray.count == 0) {
            return;
        }
        
        NSDictionary *versionDic = [infoArray[0] oex_replaceNullsWithEmptyStrings];
        NSString *version = versionDic[@"version"]; //线上版本号
        
        NSString *appVersionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]; //当前版本号
        BOOL isDescending = [version compare:appVersionStr options:NSNumericSearch] == NSOrderedDescending; //是否是降序
        if (!isDescending) { //App store 版本号 <= 本地的版本号
            [self lastVersionAlertView];
            
        }
        else {
            [self updateAlertView];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"查询iTunes应用信息错误：%@",error.description);
    }];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateAlertView {
    /*App store 版本号 > 本地的版本号*/
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TDLocalizeSelect(@"SYSTEM_WARING", nil) message:TDLocalizeSelect(@"NEW_VERSION_UPDATE", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/e-ducation-%E4%B8%AA%E6%80%A7%E5%8C%96%E5%9C%A8%E7%BA%BF%E5%AD%A6%E4%B9%A0%E5%9F%B9%E8%AE%AD%E5%B9%B3%E5%8F%B0/id1208911496?mt=8"]];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"CANCEL", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)lastVersionAlertView {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TDLocalizeSelect(@"SYSTEM_WARING", nil) message:TDLocalizeSelect(@"LASTEST_VERSION", nil) preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:TDLocalizeSelect(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:sureAction];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return [OEXStyles sharedStyles].standardStatusBarStyle;
}

#pragma mark --WYAlertViewDelegate
- (void)beginDownLoad{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.download_url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

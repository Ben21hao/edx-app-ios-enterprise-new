//
//  TDLanguageViewController.m
//  edX
//
//  Created by Elite Edu on 2017/9/12.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDLanguageViewController.h"

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
    self.titleViewLabel.text = TDLocalizeSelect(@"LANGUAGE_TEXT", nil);
}

#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
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
    
    NSString *rowStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"languageSelected"];
    NSString *languageStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"userLanguage"];
    NSLog(@"%@ -- >> %@",rowStr,languageStr);
    
    cell.accessoryType = [rowStr intValue] == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = TDLocalizeSelect(@"FOLLOW_SYSTEM_LANGUAGE", nil);
            break;
        case 1:
            cell.textLabel.text = @"中文";
            break;
        case 2:
            cell.textLabel.text = @"English";
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"languageSelected"];
    [tableView reloadData];
    
    if (indexPath.row == 0) {
        
        NSArray* languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        NSString *systemStr = [languages objectAtIndex:0];
        [LanguageChangeTool setUserlanguage: [systemStr isEqualToString:@"en"] ? @"en" : @"zh-Hans"];//zh-Hans-CN

    } else {
         [LanguageChangeTool setUserlanguage: indexPath.row == 1 ? @"zh-Hans" : @"en"];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"languageSelectedChange" object:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end




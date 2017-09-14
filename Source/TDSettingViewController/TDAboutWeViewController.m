//
//  TDAboutWeViewController.m
//  edX
//
//  Created by Elite Edu on 16/12/27.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "TDAboutWeViewController.h"

@interface TDAboutWeViewController ()

@property (nonatomic,strong) UIImageView *mapImage;
@property (nonatomic,strong) UIImageView *eliteuImage;
@property (nonatomic,strong) UITextView *webTextView;
@property (nonatomic,strong) UILabel *verctionLabel;
@property (nonatomic,strong) UILabel *companyLabel;

@end

@implementation TDAboutWeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configView];
    [self setConstraint];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [self languageChangeAction];
}

- (void)languageChangeAction {
    
    self.titleViewLabel.text = TDLocalizeSelect(@"ABOUT_APP", nil);
    NSString *webSiteStr = [NSString stringWithFormat:@"%@：www.e-ducation.cn",TDLocalizeSelect(@"WEBSITE_COMPANY", nil)];
    self.webTextView.text = webSiteStr;
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger uniFlags = NSCalendarUnitYear;
    NSDateComponents *dateComponent = [calendar components:uniFlags fromDate:now];
    NSInteger year = [dateComponent year];
    NSString *yearStr = [NSString stringWithFormat:@"©%ld %@",(long)year,TDLocalizeSelect(@"COMPANY_NAME", nil)];
    self.companyLabel.text = yearStr;
    
    TDBaseToolModel *baseTool = [[TDBaseToolModel alloc] init];
    NSString *versionStr = [baseTool getAppVersionNum:0];
    self.verctionLabel.text = versionStr;
}

#pragma mark - UI
- (void)configView {
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    self.mapImage = [[UIImageView alloc] init];
    self.mapImage.image = [UIImage imageNamed:@"map_bg"];
    [self.view addSubview:self.mapImage];
    
    self.eliteuImage = [[UIImageView alloc] init];
    self.eliteuImage.image = [UIImage imageNamed:@"edx_logo_login"];
    [self.view addSubview:self.eliteuImage];
    
    self.webTextView = [[UITextView alloc] init];
    self.webTextView.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.webTextView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    self.webTextView.textColor = [UIColor colorWithHexString:colorHexStr8];
    self.webTextView.editable = NO;
    self.webTextView.showsVerticalScrollIndicator = NO;
    self.webTextView.scrollEnabled = NO;
    [self.view addSubview:self.webTextView];
    
    self.verctionLabel = [self setLabelConstraint];
    
    self.companyLabel = [self setLabelConstraint];
    self.companyLabel.numberOfLines = 0;
    
}

- (UILabel *)setLabelConstraint {
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"OpenSans" size:12];
    label.textColor = [UIColor colorWithHexString:colorHexStr9];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    return label;
}

- (void)setConstraint {
    
    NSInteger height = 151;
    if (TDWidth  > 320 && TDWidth < 400) {
        height = 159;
    } else if (TDWidth > 400) {
        height = 168;
    }
    [self.mapImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(58);
        make.left.mas_equalTo(self.view.mas_left).offset(18);
        make.right.mas_equalTo(self.view.mas_right).offset(-18);
        make.height.mas_equalTo(height);
    }];
    
    [self.eliteuImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mapImage.mas_centerX);
        make.centerY.mas_equalTo(self.mapImage.mas_centerY);
    }];
    
    [self.webTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mapImage.mas_centerX);
        make.top.mas_equalTo(self.eliteuImage.mas_bottom).offset(18);
    }];
    
    [self.companyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view.mas_left).offset(18);
        make.right.mas_equalTo(self.view.mas_right).offset(-18);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-18);
    }];
    
    [self.verctionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.companyLabel.mas_top).offset(-3);
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

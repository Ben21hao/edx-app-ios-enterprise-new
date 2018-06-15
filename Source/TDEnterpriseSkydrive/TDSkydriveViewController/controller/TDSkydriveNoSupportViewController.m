//
//  TDSkydriveNoSupportViewController.m
//  edX
//
//  Created by Elite Edu on 2018/6/14.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveNoSupportViewController.h"
#import "TDNodataView.h"

@interface TDSkydriveNoSupportViewController ()

@property (nonatomic,strong) TDNodataView *noDataView;
@property (nonatomic,strong) UIButton *openButton;
@property (nonatomic,strong) UIButton *deleteButton;

@end

@implementation TDSkydriveNoSupportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = self.titleStr;
    
    [self setViewConstraint];
}

#pragma mark - Action
- (void)openButtonAction:(UIButton *)sender {
    [self systemActivity];
}

- (void)deleteButtonAction:(UIButton *)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认删除" message:@"是否删除当前文件？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    WS(weakSelf);
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf deleteFile];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)systemActivity { //系统分享
    
    //    UIImage *image = [UIImage imageNamed:@"tubiao"];
//    NSURL *url = [NSURL URLWithString:@"https://www.jianshu.com/p/d500fb72a079"];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"111112" withExtension:@"pdf"];
    
    NSArray *itemArray = @[@"文件分享",url];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:itemArray applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
    activityController.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        
        if (completed) {//成功
            NSLog(@"---->> 分享成功");
        }
        else {
            NSLog(@"---->> 分享失败");
        }
    };
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)deleteFile { //删除该文件
    
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.noDataView = [[TDNodataView alloc] init];
    self.noDataView.imageView.image = [UIImage imageNamed:@"file_no_support"];
    self.noDataView.messageLabel.text = @"抱歉，该文件暂时无法查看!";
    [self.view addSubview:self.noDataView];
    
    self.openButton = [self buttonTitle:@"打开" color:@"#3e4147"];
    [self.openButton addTarget:self action:@selector(openButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.openButton];
    
    self.deleteButton = [self buttonTitle:@"删除" color:@"#555a5f"];
    [self.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.deleteButton];
    
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-48);
    }];
    
    [self.openButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(TDWidth/2, 48));
    }];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(TDWidth/2, 48));
    }];
}

- (UIButton *)buttonTitle:(NSString *)titleStr color:(NSString *)colorStr {
    
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor colorWithHexString:colorStr];
    button.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [button setTitleColor:[UIColor colorWithHexString:colorHexStr13] forState:UIControlStateNormal];
    [button setTitle:titleStr forState:UIControlStateNormal];
    
    return button;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end

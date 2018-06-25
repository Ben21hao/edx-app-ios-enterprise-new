//
//  TDSkydriveImageViewController.m
//  edX
//
//  Created by Elite Edu on 2018/6/13.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveImageViewController.h"
#import <UIImage+GIF.h>

@interface TDSkydriveImageViewController ()

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation TDSkydriveImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = self.titleStr;
    
    [self setViewConstraint];
    [self setimageData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    [self navigationbarHidden:NO];
}

- (void)setimageData {
    
//    self.filePath = [[NSBundle mainBundle] pathForResource:@"111132" ofType:@"JPG"];
    NSData *data = [NSData dataWithContentsOfFile:self.filePath];
    if ([self.typeStr isEqualToString:@"gif"]) {//GIF
        self.imageView.image = [UIImage sd_animatedGIFWithData:data];
    }
    else {
        self.imageView.image = [UIImage imageWithData:data];
//        self.imageView.image = [[UIImage alloc] initWithContentsOfFile:self.filePath];
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    
    if (self.navigationController.navigationBar.isHidden) {
        [self navigationbarHidden:NO];
    }
    else {
        [self navigationbarHidden:YES];
    }
}

- (void)navigationbarHidden:(BOOL)isHidden {
    
    [self.navigationController setNavigationBarHidden:isHidden animated:YES];
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    statusBar.hidden = isHidden;
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    self.imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.imageView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

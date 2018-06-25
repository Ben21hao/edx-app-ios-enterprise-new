//
//  TDSkydriveVideoViewController.m
//  edX
//
//  Created by Elite Edu on 2018/6/7.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveVideoViewController.h"
#import "TDSkydriveVideoView.h"

#define scaleRate 9/16
@interface TDSkydriveVideoViewController ()

@property (nonatomic,strong) TDSkydriveVideoView *videoView;

@end

@implementation TDSkydriveVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self popGestureStatus:NO];
    
    [self setViewConstraint];
    [self.videoView videoFullScreenAction];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.videoView destroyPlayer];
    
    [self popGestureStatus:YES];
}

- (void)returnButtonAction:(UIButton *)sender {
    
    [self navigationbarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)popGestureStatus:(BOOL)isEnable {
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = isEnable;
    }
}

- (void)navigationbarHidden:(BOOL)isHidden {
    
    [self.navigationController setNavigationBarHidden:isHidden animated:YES];
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    statusBar.hidden = isHidden;
}

#pragma mark - UI
- (void)setViewConstraint {
    
//    self.filePath = [[NSBundle mainBundle] pathForResource:@"111114" ofType:@"mp4"];
//    self.filePath = @"http://1251349076.vod2.myqcloud.com/45e704edvodtransgzp1251349076/97108aa94564972818961641021/v.f30.mp4";

    self.videoView = [[TDSkydriveVideoView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDWidth * scaleRate)];
    self.videoView.videoController = self;
    self.videoView.videoUrl = self.filePath;
    self.videoView.videoMaskView.titleStr = self.titleStr;
    
    WS(weakSelf);
    self.videoView.navigationBarHandle = ^(BOOL hidden) {
        [weakSelf navigationbarHidden:hidden];
    };
    [self.videoView.videoMaskView.returnButton addTarget:self action:@selector(returnButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.videoView];
    
    NSLog(@"--->> %@",self.filePath);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

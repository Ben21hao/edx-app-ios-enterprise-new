//
//  TDDownloadViewController.m
//  edX
//
//  Created by Ben on 2017/6/12.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDDownloadViewController.h"
#import "TDBaseScrollView.h"
#import "TDSubDownloadViewController.h"
#import "TDVidoDownloadViewController.h"

#import "edX-Swift.h"
#import "Logger+OEXObjC.h"
#import "NSArray+OEXSafeAccess.h"

#define TITLTE_BUTTON_WIDTH TDWidth / self.childViewControllers.count

#define TitleView_Height 48

@interface TDDownloadViewController () <UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) TDSubDownloadViewController *courseVC;
@property (nonatomic,strong) TDVidoDownloadViewController *videoSubVC;

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIScrollView *titleView;
@property (nonatomic,strong) TDBaseScrollView *contentView;
@property (nonatomic,strong) UIView *sepView; //分割线
@property (nonatomic,strong) UIView *selectView;

@property (nonatomic,strong) TDBaseView *loadingView;

@property (nonatomic,strong) NSMutableArray *titleButtonArray;

@property (nonatomic, strong) OEXInterface *dataInterface;
@property (nonatomic, strong) NSMutableArray *courseDataArray; //下载课程的数组

@property (strong, nonatomic) OEXCheckBox *selectAllButton;//全选按钮
@property (strong, nonatomic) ProgressController *progressController;//下载进度

@property (nonatomic,assign) BOOL isTableEditing;
@property (nonatomic,assign) BOOL isFullScreen;

@end

@implementation TDDownloadViewController

- (NSMutableArray *)titleButtonArray {
    if (!_titleButtonArray) {
        _titleButtonArray = [[NSMutableArray alloc] init];
    }
    return _titleButtonArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [LanguageChangeTool initUserLanguage]; //语言
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    
    [self setViewConstraint];
    
    [self addAllChildViewController];
    [self setSepView];
    [self addTopTitlebutton];
    
    [self setNavigationStyle];
    
    self.dataInterface = [OEXInterface sharedInterface];
    [self.dataInterface setNumberOfRecentDownloads:0];
    
    self.selectAllButton.tintColor = [[OEXStyles sharedStyles] navigationItemTintColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self addObservers];
    
    [self showLoadingView];
    [self getMyVideosTableData];
    
    [self performSelector:@selector(reloadTable) withObject:self afterDelay:8.0];
}

- (void)reloadTable {
    
    [self.loadingView removeFromSuperview];
        
    [self getMyVideosTableData];
}

- (void)downloadDataAppear:(NSNotification *)info {
    
    [self reloadTable];
}

- (void)showLoadingView {
    
    self.loadingView = [[TDBaseView alloc] initWithLoadingFrame:self.view.bounds];
    [self.view addSubview:self.loadingView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TD_Download_Disapear" object:nil];
    
    [self removeAbservers];
}

- (void)addObservers {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadCompleteNotification:) name:OEXDownloadEndedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTotalDownloadProgress:) name:OEXDownloadProgressChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDataAppear:) name:NOTIFICATION_DOWNLOAD_DATA object:nil];
}

- (void)removeAbservers {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OEXDownloadProgressChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OEXDownloadEndedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_DOWNLOAD_DATA object:nil];
}

#pragma mark - update total download progress

- (void)downloadCompleteNotification:(NSNotification *)notification {
    
    NSDictionary* dict = notification.userInfo;
    
    NSURLSessionTask* task = [dict objectForKey:VIDEO_DL_COMPLETE_N_TASK];
    NSURL* url = task.originalRequest.URL;
    
    if([OEXInterface isURLForVideo:url.absoluteString]) {
        [self reloadTable];
    }
}

- (void)updateTotalDownloadProgress:(NSNotification *)notification {
    [self updateNavigationItemButtons];
}

#pragma mark - 导航栏
- (void)setNavigationStyle {
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, TDWidth - 188, 44)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:18.0];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = TDLocalizeSelect(@"MY_VIDEOS", nil);
    self.navigationItem.titleView = self.titleLabel;
    
    self.selectAllButton = [[OEXCheckBox alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.selectAllButton.tintColor = [[OEXStyles sharedStyles] navigationItemTintColor];
    self.selectAllButton.hidden = YES;
    [self.selectAllButton addTarget:self action:@selector(selectAllChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    //隐藏下载进度条
//    self.progressController = [[ProgressController alloc] initWithOwner:self router:self.environment.router dataInterface:self.environment.interface];
//    self.navigationItem.rightBarButtonItem = [self.progressController navigationItem];
//    [self.progressController hideProgessView];
}

- (void)updateNavigationItemButtons { //更新导航栏
    
    NSMutableArray *barButtons = [[NSMutableArray alloc] init];
    if(self.isTableEditing) {
        [barButtons addObject:[[UIBarButtonItem alloc] initWithCustomView:self.selectAllButton]];
    }
    //隐藏下载进度条
//    if(![self.progressController progressView].hidden){
//        [barButtons addObject:[self.progressController navigationItem]];
//    }
    self.navigationItem.rightBarButtonItems = barButtons;
}

- (void)selectAllChanged:(UIButton *)sender { //全选
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Navigation_SelectAll_Handle" object:nil];
}

#pragma mark - 数据
- (void)getMyVideosTableData {
    
    self.courseDataArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *arrCourseAndVideo = [[NSMutableArray alloc] initWithArray: [self.dataInterface coursesAndVideosForDownloadState:OEXDownloadStateComplete] ];
    
    // Populate both ALL & RECENT Videos Table data
    for(NSDictionary *dict in arrCourseAndVideo) {
        
        NSMutableDictionary *mutableDict = [dict mutableCopy];
        NSString *strSize = [[NSString alloc] initWithString: [self calculateVideosSizeInCourse:[mutableDict objectForKey:CAV_KEY_VIDEOS]]];
        
        NSMutableArray *sortedArray = [mutableDict objectForKey:CAV_KEY_VIDEOS];
        NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"completedDate" ascending:NO selector:@selector(compare:)];
        [sortedArray sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
        NSMutableArray* arr_SortedArray = [sortedArray mutableCopy];
        NSDictionary* videos = @{CAV_KEY_COURSE: [mutableDict objectForKey:CAV_KEY_COURSE],
                                 CAV_KEY_VIDEOS: [mutableDict objectForKey:CAV_KEY_VIDEOS],
                                 CAV_KEY_RECENT_VIDEOS: arr_SortedArray,
                                 CAV_KEY_VIDEOS_SIZE: strSize};
        
        [self.courseDataArray addObject:videos];
    }
    
    [self reloadDownloadData];
    
    if (self.courseDataArray.count > 0) {
        [self.loadingView removeFromSuperview];
    }
}

- (NSString *)calculateVideosSizeInCourse:(NSArray *)arrvideo {
    
    NSString *strSize = nil;
    double size = 0.0;
    
    for(OEXHelperVideoDownload* video in arrvideo) {
        double videoSize = [video.summary.size doubleValue];
        double sizeInMegabytes = (videoSize / 1024) / 1024;
        size += sizeInMegabytes;
    }
    strSize = [NSString stringWithFormat:@"%.2fMB", size];
    return strSize;
}

- (void)reloadDownloadData { //刷新数据
    
    self.courseVC.courseDataArray = self.courseDataArray;
    [self.courseVC.tableView reloadData];
    
    self.videoSubVC.courseDataArray = self.courseDataArray;
    [self.videoSubVC.tableView reloadData];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.titleView = [[UIScrollView  alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TitleView_Height)];
    self.titleView.backgroundColor = [UIColor colorWithHexString:colorHexStr13];
    [self.view addSubview:self.titleView];
    
    self.contentView = [[TDBaseScrollView alloc] init];
    self.contentView.pagingEnabled = YES;
    self.contentView.delegate = self;
    self.contentView.bounces = NO;
    self.contentView.frame = CGRectMake(0, TitleView_Height, TDWidth, TDHeight - TitleView_Height - 60);
    self.contentView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self.view addSubview:self.contentView];
}

//添加分割线
- (void)setSepView {
    
    CGFloat y = CGRectGetMaxY(self.titleView.frame);
    self.sepView = [[UIView alloc] init];
    self.sepView.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
    self.sepView.frame = CGRectMake(0, y, TDWidth, 1);
    [self.view addSubview:self.sepView];
    
    self.selectView = [[UIView alloc] init];
    self.selectView.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.selectView.frame = CGRectMake(0, -1, TITLTE_BUTTON_WIDTH, 2);
    [self.sepView addSubview:self.selectView];

}

- (void)addAllChildViewController {
    
    self.courseVC = [[TDSubDownloadViewController alloc] init];
    self.courseVC.environment = self.environment;
    [self addChildViewController:self.courseVC];
    
    self.videoSubVC = [[TDVidoDownloadViewController alloc] init];
    self.videoSubVC.dataInterface = self.dataInterface;
    
    WS(weakSelf);
    self.videoSubVC.judgEditeHandle = ^(BOOL isTableEditing){
        weakSelf.isTableEditing = isTableEditing;
        [weakSelf updateNavigationItemButtons];
    };
    self.videoSubVC.hideEditeHandle = ^(BOOL isHidden){ //隐藏全选按钮
        weakSelf.selectAllButton.hidden = isHidden;
    };
    self.videoSubVC.checkEditeHandle = ^(BOOL isChecked){
        weakSelf.selectAllButton.checked = isChecked;
    };
    self.videoSubVC.reloadSubDataHandle = ^{
        [weakSelf.courseVC.tableView reloadData];
    };
    self.videoSubVC.fullScreenHanle = ^(BOOL isFullScreen){
        weakSelf.isFullScreen = isFullScreen;
    };
    [self addChildViewController:self.videoSubVC];
}

- (void)addTopTitlebutton {

    NSInteger count = self.childViewControllers.count;
    CGFloat height = TitleView_Height - 2;
    CGFloat width = TDWidth / count;
    
    for (int i = 0; i < count; i ++) {
        UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectMake(i * width, 0, width, height)];
        titleButton.tag = i;
        titleButton.showsTouchWhenHighlighted = YES;
        titleButton.exclusiveTouch = YES;
        titleButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
        [titleButton setTitleColor:[UIColor colorWithHexString:colorHexStr9] forState:UIControlStateNormal];
        [titleButton addTarget:self action:@selector(titleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleView addSubview:titleButton];
        
        [self.titleButtonArray addObject:titleButton];
        
        if (i == 0) {
            [titleButton setTitle:TDLocalizeSelect(@"ALL_VIDEOS", nil) forState:UIControlStateNormal];
            [self titleButtonAction:titleButton];
        } else {
            [titleButton setTitle:TDLocalizeSelect(@"RECENT_VIDEOS", nil) forState:UIControlStateNormal];
        }
    }
    self.contentView.contentSize = CGSizeMake(count * TDWidth, 0);
}

- (void)titleButtonAction:(UIButton *)sender {
    
    [self selectButton:sender]; //让选中的标题颜色变蓝色
    [self setUpChildViewController:sender.tag];//把对应的子控制器添加上去
    
    CGFloat x = sender.tag * TDWidth; //滚动到对应位置
    self.contentView.contentOffset = CGPointMake(x, 0);
}

- (void)selectButton:(UIButton *)sender {
    
    if (sender.tag == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TD_SubDowload_Appear" object:nil];
        self.selectAllButton.hidden = YES;
        self.selectAllButton.checked = NO;
    }
    
    for (int i = 0 ; i < self.titleButtonArray.count; i ++) {
        UIButton *button = self.titleButtonArray[i];
        NSString *colorStr = i == sender.tag ? colorHexStr1 : colorHexStr9;
        [button setTitleColor:[UIColor colorWithHexString:colorStr] forState:UIControlStateNormal];
    }
    
    [self setSelectViewFrame:sender.tag * TITLTE_BUTTON_WIDTH];
}

- (void)setSelectViewFrame:(CGFloat)x {
    WS(weakSelf);
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.selectView.frame = CGRectMake(x, -1, TITLTE_BUTTON_WIDTH, 2); //处理指示线的位置
    }];
}

#pragma mark - UIViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger page = scrollView.contentOffset.x / TDWidth;
    UIButton *selButton = self.titleButtonArray[page];
    [self selectButton:selButton];
    [self setUpChildViewController:page];//添加子控制器的view
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self setSelectViewFrame:scrollView.contentOffset.x / self.childViewControllers.count];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (otherGestureRecognizer.state == UIGestureRecognizerStateBegan && self.contentView.contentOffset.x == 0) {
        return YES;
    }
    return NO;
}

/* 添加对应的子控制器 */
- (void)setUpChildViewController:(NSInteger)index {
    
    UIViewController *vc = self.childViewControllers[index];
    if (vc.view.superview) {
        return;
    }
    CGFloat x = index * TDWidth;
    vc.view.frame = CGRectMake(x, 0, TDWidth, self.contentView.bounds.size.height);
    [self.contentView addSubview:vc.view];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [OEXStyles sharedStyles].standardStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    return self.isFullScreen;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

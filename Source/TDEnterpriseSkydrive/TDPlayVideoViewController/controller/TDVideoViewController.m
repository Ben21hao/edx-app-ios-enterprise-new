//
//  TDVideoViewController.m
//  EdxProject
//
//  Created by Elite Edu on 2018/4/11.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDVideoViewController.h"
#import "TDVideoView.h"

#define scaleRate 9/16

@interface TDVideoViewController () <UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,TDVideoViewDelegate>

@property (nonatomic,strong) TDVideoView *videoView;

//@property (nonatomic,strong) UIButton *nextButton;

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,assign) NSInteger heighLightRow;
@property (nonatomic,strong) NSArray *captionArray;

@property (nonatomic,assign) BOOL isTableDragging; //正在滑动字幕tableview
@property (nonatomic,strong) NSTimer *draggingTimer;

@end

@implementation TDVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = self.courseName;
    self.rightButton.hidden = NO;
    [self.rightButton setTitle:@"设置" forState:UIControlStateNormal];
    
    [self setViewConstraint];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    if ([self.draggingTimer isValid]) {
        [self.draggingTimer invalidate];
    }
    
    [self.videoView destroyPlayer];
}

- (void)rightButtonAciton:(UIButton *)sender {
    [self.videoView chooseVideoPlayerRate];
}

#pragma mark - tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.captionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *captionDic = self.captionArray[indexPath.row];
    NSString *captionText = captionDic[TDVideoViewkText];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCaptionCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"videoCaptionCell"];
    }
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14];
    cell.textLabel.textColor = [UIColor colorWithHexString:indexPath.row == self.heighLightRow ? colorHexStr10 : colorHexStr1];
    cell.textLabel.text = captionText;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 39.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.videoView.selectedRow = indexPath.row;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isTableDragging = YES;
    
    if ([self.draggingTimer isValid]) {
        [self.draggingTimer invalidate];
    }
    self.draggingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(invalidateDragging) userInfo:nil repeats:YES];
    
}

- (void)invalidateDragging {
    self.isTableDragging = NO;
    [self.draggingTimer invalidate];
}

#pragma mark - TDVideoPlayViewDelegate
- (void)getCaptionItemArray:(NSArray *)captionArray {
    self.captionArray = captionArray;
    [self.tableView reloadData];
}

- (void)heightLightCaptionText:(NSInteger)row {
    
    self.heighLightRow = row;
    [self.tableView reloadData];
    
    if (!self.isTableDragging) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}


#pragma mark - UI
- (void)setViewConstraint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.frame = CGRectMake(0, TDWidth * scaleRate, TDWidth, TDHeight - TDWidth * scaleRate - BAR_ALL_HEIHT);
    [self.view addSubview:self.tableView];
    
    
    self.videoView = [[TDVideoView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDWidth * scaleRate)];
    self.videoView.delegate = self;
    self.videoView.videoController = self;
    self.videoView.videoUrl = @"http://1251349076.vod2.myqcloud.com/45e704edvodtransgzp1251349076/97108aa94564972818961641021/v.f30.mp4";
//    self.videoView.videoUrl = self.videoUrl;
    
    WS(weakSelf);
    self.videoView.navigationBarHandle = ^(BOOL hidden) {
        [weakSelf.navigationController setNavigationBarHidden:hidden animated:YES];
    };
    [self.view addSubview:self.videoView];

//    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(88, 288, 66, 66)];
//    [self.nextButton setTitle:@"下一视频" forState:UIControlStateNormal];
//    [self.nextButton setTitleColor:[UIColor colorWithHexString:colorHexStr9] forState:UIControlStateNormal];
//    self.nextButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
//    [self.nextButton addTarget:self action:@selector(nextButtonAtion:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.nextButton];
}

- (void)nextButtonAtion:(UIButton *)sender {
    self.videoView.videoUrl = @"http://wvideo.spriteapp.cn/video/2016/1203/58425ad2a0c1d_wpd.mp4";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end

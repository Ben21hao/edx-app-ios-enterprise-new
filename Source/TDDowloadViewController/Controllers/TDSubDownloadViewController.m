//
//  TDSubDownloadViewController.m
//  edX
//
//  Created by Ben on 2017/6/12.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDSubDownloadViewController.h"
#import "TDDownloadCell.h"

#import "edX-Swift.h"
#import "Logger+OEXObjC.h"
#import "NSArray+OEXSafeAccess.h"

@interface TDSubDownloadViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UILabel *noDataLabel;

@end

@implementation TDSubDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = TDLocalizeSelect(@"ALL_VIDEOS", nil);
    
    [self setViewConstraint];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
}


#pragma mark - tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    self.noDataLabel.hidden = self.courseDataArray.count == 0 ? NO : YES;
    
    return self.courseDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TDDownloadCell *cell = [[TDDownloadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDPlayerCell"];
    
    CourseCardView *infoView = cell.infoView;
    __typeof(self) owner = self;
    cell.infoView.tapAction = ^(CourseCardView* card){
        [owner choseCourse:card.course];
    };
    
    NSDictionary *dictVideo = [self.courseDataArray objectAtIndex:indexPath.section];
    OEXCourse *obj_course = [dictVideo objectForKey:CAV_KEY_COURSE];
    
    NSInteger count = [[dictVideo objectForKey:CAV_KEY_VIDEOS] count];
    
    NSString *Vcount = [NSString stringWithFormat:@"%ld %@", (long)count,count == 1 ? @"Video" : @"Videos"];
    NSString *videoDetails = [NSString stringWithFormat:@"%@, %@", Vcount, [dictVideo objectForKey:CAV_KEY_VIDEOS_SIZE]];
    
    [[CourseCardViewModel onMyVideos:obj_course collectionInfo:videoDetails] apply:infoView networkManager:self.environment.networkManager type: 5];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (TDWidth == 320) {
        return 153;
    } else if (TDWidth > 320 && TDWidth < 400) {
        return 185;
    }
    return 215;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (void)choseCourse:(OEXCourse*)course {
    
    [self.environment.router showVideoSubSectionFromViewController:self forCourse:course withCourseData:nil];
}

#pragma mark - UI
- (void)setViewConstraint {
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    self.noDataLabel = [[UILabel alloc] init];
    self.noDataLabel.font = [UIFont fontWithName:@"OpenSans" size:16];
    self.noDataLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    self.noDataLabel.text = TDLocalizeSelect(@"NO_VIDEOS_DOWNLOADED", nil);
    self.noDataLabel.hidden = YES;
    self.noDataLabel.numberOfLines = 0;
    self.noDataLabel.textAlignment = NSTextAlignmentCenter;
    [self.tableView addSubview:self.noDataLabel];
    
    [self.noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.tableView);
        make.width.mas_equalTo(TDWidth - 18);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end

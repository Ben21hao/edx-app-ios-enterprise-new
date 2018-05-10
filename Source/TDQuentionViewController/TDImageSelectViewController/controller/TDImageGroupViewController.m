//
//  TDImageGroupViewController.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/12.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDImageGroupViewController.h"
#import "TDImageGroupCell.h"

#import "TDImageSelectViewController.h"
#import "TDImageHandle.h"

@interface TDImageGroupViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *groupArray;
@property (nonatomic,strong) dispatch_queue_t currentQuere;

@property (nonatomic,strong) TDImageHandle *imageHandle;

@end

@implementation TDImageGroupViewController

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationStyle];
    [self setViewConstraint];
    [self loadingPhotos];
}

- (void)setNavigationStyle {
    
    self.titleViewLabel.text = TDLocalizeSelect(@"ALBUM_TITLE", nil);
    self.leftButton.hidden = YES;
    self.rightButton.hidden = NO;
    [self.rightButton setTitle:TDLocalizeSelect(@"CANCEL", nil) forState:UIControlStateNormal];
    WS(weakSelf);
    self.rightButtonHandle = ^(){
      [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
    };
    
    self.currentQuere = dispatch_queue_create("com.TDImageSelectViewController.global", DISPATCH_QUEUE_CONCURRENT);
    self.imageHandle = [[TDImageHandle alloc] init];
}

- (void)loadingPhotos { //加载相册
    WS(weakSelf);
    [self.imageHandle enumeratePHAssetCollectionsWithResultHandler:^(NSArray<PHAssetCollection *> *result) {

        weakSelf.groupArray = [NSMutableArray arrayWithArray:result]; //相册
        [weakSelf.tableView reloadData];
        
        if (weakSelf.groupArray.count > 3) {
            [weakSelf gotoSelectImageVc:3 animated:NO];
        } else {
            [weakSelf gotoSelectImageVc:0 animated:NO];
        }
    }];
}

#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PHAssetCollection *assetCollection = self.groupArray[indexPath.row];
    
    TDImageGroupCell *cell = [[TDImageGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photoGroupCell"];
    [cell reloadDataWithAssetCollection:assetCollection];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self gotoSelectImageVc:indexPath.row animated:YES];
}

#pragma mark - 显示图片
- (void)gotoSelectImageVc:(NSInteger)index animated:(BOOL)animate {
    
    if (self.groupArray.count <= 0) {
        return;
    }
    
    TDImageSelectViewController *imageVC = [[TDImageSelectViewController alloc] init];
    imageVC.assetCollection = self.groupArray[index];
    imageVC.hadImageArray = self.hadImageArray;
 
    [self.navigationController pushViewController:imageVC animated:animate];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end

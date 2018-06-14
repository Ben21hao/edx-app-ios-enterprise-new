//
//  TDEnterpriseSkydriveViewController.m
//  edX
//
//  Created by Elite Edu on 2018/6/6.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDEnterpriseSkydriveViewController.h"
#import "TDSkydriveFileViewController.h"
#import "TDLocalFileWebViewController.h"
#import "TDSkydriveVideoViewController.h"
#import "TDSkydriveAudioViewController.h"
#import "TDVideoViewController.h"
#import "TDSkydrveLoacalViewController.h"
#import "TDSkydriveImageViewController.h"
#import "TDFileDownloadViewController.h"

#import "TDSkydriveFolderCell.h"
#import "TDSkydriveLocalCell.h"
#import "TDSkydriveFolderHeaderView.h"
#import "TDNodataView.h"

@interface TDEnterpriseSkydriveViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDNodataView *noDataView;

@end

@implementation TDEnterpriseSkydriveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = TDLocalizeSelect(@"ENTERPRISE_SKYDRIVE", nil);
    
    [self setViewConstraint];
}

#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else {
        return 9;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        TDSkydriveLocalCell *cell = [[TDSkydriveLocalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"enterpriseSkydriveCell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.titleLabel.text = @"文件管理";
        
        return cell;
    }
    else {
        
        TDSkydriveFolderCell *cell = [[TDSkydriveFolderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"enterpriseSkydriveCell"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.timeLabel.text = @"2018-01-18 18:28";
        switch (indexPath.row) {
            case 0:
                cell.titleLabel.text = @"技术部pdf技术部pdf技术部pdf技术部技术部pp技术部pdf技术部pdfdf技术部pdf技术部pdf技术部pdf技术部pdf技术部pdf技术部pdf技术部";
                break;
            case 1:
                cell.titleLabel.text = @"设计部xlsx";
                break;
            case 2:
                cell.titleLabel.text = @"市场部htm";
                break;
            case 3:
                cell.titleLabel.text = @"人事部pptx";
                break;
            case 4:
                cell.titleLabel.text = @"销售部ppt";
                break;
            case 5:
                cell.titleLabel.text = @"运营部docx";
                break;
            case 6:
                cell.titleLabel.text = @"会计pages";
                break;
            case 7:
                cell.titleLabel.text = @"研发部rtf";
                break;
                
            default:
                cell.titleLabel.text = @"生产部txt";
                break;
        }
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    TDSkydriveFolderHeaderView *headerView = [[TDSkydriveFolderHeaderView alloc] initWithReuseIdentifier:@"skydriveFolderHeaderView"];
    headerView.titleLabel.text = @"网盘文件夹";
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0;
    }
    
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //xls，xlsx，pdf，pptx，ppt，docx，rtf, txt
    if (indexPath.section == 0) {
//        NSString *fileUrl = [[NSBundle mainBundle] pathForResource:@"111111" ofType:@"xls"];
//        [self gotoPreviewFile:fileUrl type:@"xls"];
        
        [self gotoLocalVc];
    }
    else {
        switch (indexPath.row) {
            case 0: {
//                NSString *fileUrl = [[NSBundle mainBundle] pathForResource:@"111112" ofType:@"pdf"];
//                [self gotoPreviewFile:fileUrl type:@"pdf"];
                [self gotoFolderView];
                
            }
                break;
            case 1: {
//                NSString *fileUrl = [[NSBundle mainBundle] pathForResource:@"111117" ofType:@"xlsx"];
//                [self gotoPreviewFile:fileUrl type:@"xlsx"];
                
                [self gotoAudioPlayVC];
            }
                break;
            case 2: {
//                NSString *fileUrl = [[NSBundle mainBundle] pathForResource:@"Terms-and-Services" ofType:@"htm"];
//                [self gotoPreviewFile:fileUrl type:@"htm"];
                [self gotoVideoPlayVC];
            }
                break;
            case 3: {
//                NSString *fileUrl = [[NSBundle mainBundle] pathForResource:@"111118" ofType:@"pptx"];
//                [self gotoPreviewFile:fileUrl type:@"pptx"];
                
                [self gotoDownloadVc];
                }
                break;
            case 4: {
                NSString *fileUrl = [[NSBundle mainBundle] pathForResource:@"111119" ofType:@"ppt"];
                [self gotoPreviewFile:fileUrl type:@"ppt"];
                }
                break;
            case 5: {
                NSString *fileUrl = [[NSBundle mainBundle] pathForResource:@"111129" ofType:@"png"];
//                [self gotoPreviewFile:fileUrl type:@"docx"];
                [self gotoPreviewImage:fileUrl title:@"png浏览" type:@"png"];
            }
                break;
            case 6: {
                NSString *fileUrl = [[NSBundle mainBundle] pathForResource:@"111132" ofType:@"JPG"];//111125.pages
//                [self gotoPreviewFile:fileUrl type:@"pages"];
                 [self gotoPreviewImage:fileUrl title:@"jpg浏览" type:@"jpg"];
            }
                break;
            case 7: {
                NSString *fileUrl = [[NSBundle mainBundle] pathForResource:@"111130" ofType:@"bmp"];
//                [self gotoPreviewFile:fileUrl type:@"rtf"];
                [self gotoPreviewImage:fileUrl title:@"bmp浏览" type:@"bmp"];
            }
                break;
            default: {
                NSString *fileUrl = [[NSBundle mainBundle] pathForResource:@"111128" ofType:@"gif"];
//                [self gotoPreviewFile:fileUrl type:@"gif"];
                [self gotoPreviewImage:fileUrl title:@"gif浏览" type:@"gif"];
                }
                break;
        }
    }
}

- (void)gotoFolderView {//子文件夹
    
    TDSkydriveFileViewController *skydriveFileVc = [[TDSkydriveFileViewController alloc] init];
    skydriveFileVc.folderName = @"文件夹";
    [self.navigationController pushViewController:skydriveFileVc animated:YES];
}

- (void)gotoPreviewFile:(NSString *)filePath type:(NSString *)type { //文档浏览
    
    if (filePath.length == 0) {
        NSLog(@"----- 空路径 ---");
        return;
    }
    TDLocalFileWebViewController *webVc = [[TDLocalFileWebViewController alloc] init];
    webVc.titleStr = @"文档浏览";
    webVc.url = [NSURL fileURLWithPath:filePath];
    webVc.typeStr = type;
    [self.navigationController pushViewController:webVc animated:YES];
}

- (void)gotoVideoPlayVC { //视频播放
    TDSkydriveVideoViewController *videoVc = [[TDSkydriveVideoViewController alloc] init];
//    TDVideoViewController *videoVc = [[TDVideoViewController alloc] init];
    [self.navigationController pushViewController:videoVc animated:YES];
}

- (void)gotoAudioPlayVC { //音频播放
    TDSkydriveAudioViewController *audioPlayVC = [[TDSkydriveAudioViewController alloc] init];
    [self.navigationController pushViewController:audioPlayVC animated:YES];
}

- (void)gotoPreviewImage:(NSString *)path title:(NSString *)titleStr type:(NSString *)typeStr { //图片预览
    
    TDSkydriveImageViewController *imageVc = [[TDSkydriveImageViewController alloc] init];
    imageVc.filePath = path;
    imageVc.titleStr = titleStr;
    imageVc.typeStr = typeStr;
    [self.navigationController pushViewController:imageVc animated:YES];
}

- (void)gotoLocalVc { //文件管理
    
    TDSkydrveLoacalViewController *localVc = [[TDSkydrveLoacalViewController alloc] init];
    [self.navigationController pushViewController:localVc animated:YES];
}

- (void)gotoDownloadVc { //文件下载
    
    TDFileDownloadViewController *downloadVc = [[TDFileDownloadViewController alloc] init];
    [self.navigationController pushViewController:downloadVc animated:YES];
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorColor = [UIColor colorWithHexString:colorHexStr6];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    self.noDataView = [[TDNodataView alloc] init];
    self.noDataView.imageView.image = [UIImage imageNamed:@"file_null_image"];
    self.noDataView.messageLabel.text = @"该网盘暂无文件";
    [self.tableView addSubview:self.noDataView];
    
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tableView);
        make.top.mas_equalTo(self.tableView.mas_top).offset(116);
        make.size.mas_equalTo(CGSizeMake(TDWidth, TDHeight - 116 - BAR_ALL_HEIHT));
    }];
    
    self.noDataView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end

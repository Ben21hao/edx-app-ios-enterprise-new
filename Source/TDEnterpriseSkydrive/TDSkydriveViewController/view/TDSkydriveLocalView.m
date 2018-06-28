//
//  TDSkydriveLocalView.m
//  edX
//
//  Created by Elite Edu on 2018/6/11.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveLocalView.h"
#import "TDSkydriveLocalFileCell.h"
#import "TDSkydriveFolderHeaderView.h"

#import "TDNodataView.h"
#import "TDSkydrveFileModel.h"
#import "NSString+OEXFormatting.h"

@interface TDSkydriveLocalView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) TDNodataView *noDataView;

@property (nonatomic,strong) NSArray *dowloadingArray;
@property (nonatomic,strong) NSArray *finishArray;
@property (nonatomic,assign) BOOL isEditing;

@end

@implementation TDSkydriveLocalView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.downloadArray.count;
    }
    
    return self.finishArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TDSkydriveLocalFileCell *cell = [[TDSkydriveLocalFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDSkydriveLocalFileCell"];
    cell.selectButton.tag = indexPath.row;
    
    cell.progressView.downloadButton.tag = indexPath.row;
    [cell.progressView.downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    TDSkydrveFileModel *model;
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        model = self.downloadArray[indexPath.row];
        
        cell.progressView.downloadButton.userInteractionEnabled = YES;
    }
    else {
        model = self.finishArray[indexPath.row];
        cell.progressView.downloadButton.userInteractionEnabled = NO;
    }
    
    cell.fileModel = model;
    cell.isEditing = self.isEditing;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    TDSkydriveFolderHeaderView *headerView = [[TDSkydriveFolderHeaderView alloc] initWithReuseIdentifier:@"skydriveLocalHeaderView"];
    if (section == 0) {
        headerView.titleLabel.text = [TDLocalizeSelect(@"SKY_DOWNLOADING", nil) oex_formatWithParameters:@{@"count": [NSString stringWithFormat:@"%lu",(unsigned long)self.downloadArray.count]}];
        headerView.hidden = self.downloadArray.count == 0;
        
    }
    else {
        headerView.titleLabel.text = [TDLocalizeSelect(@"SKY_DOWNLOADED", nil) oex_formatWithParameters:@{@"count":[NSString stringWithFormat:@"%lu",(unsigned long)self.finishArray.count]}]; ;
        headerView.hidden = self.finishArray.count == 0;
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        if (self.downloadArray.count == 0) {
            return 0;
        }
    }
    else {
        if (self.finishArray.count == 0) {
            return 0;
        }
    }
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isEditing) { //选择
        TDSkydriveLocalFileCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.selectButton.selected = !cell.selectButton.selected;
        cell.fileModel.isSelected = !cell.fileModel.isSelected;
        
        [self.delegate userSelectFileRowAtIndexpath:cell.fileModel];
    }
    else {
        if (indexPath.section == 1) {//已下载完成
            [self.delegate userPreviewFileRowAtIndexpath:indexPath];
        }
    }
}

#pragma mark - action
- (void)downloadButtonAction:(UIButton *)sender { //下载
    
    TDSkydrveFileModel *model = self.downloadArray[sender.tag];
    [self.delegate userClickFileRowModel:model];
}

- (void)reloadTableViewForDownload:(NSArray *)downloadArray finish:(NSArray *)finishArray { //刷新数据
    self.downloadArray = downloadArray;
    self.finishArray = finishArray;
    
    BOOL noData = self.downloadArray.count == 0 && self.finishArray.count == 0;
    self.noDataView.hidden = !noData;
    self.editeButton.hidden = noData;
    self.cancelButton.hidden = YES;
    self.deleteButton.hidden = YES;
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(noData ? 0 : -48);
    }];
    
    [self.editeButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(noData ? 0 : 48);
    }];
    
    [self.tableView reloadData];
}

#pragma mark - 编辑
- (void)userEditingFile:(BOOL)editing { //是否编辑
    
    self.isEditing = editing;
    
    self.editeButton.hidden = editing;
    self.cancelButton.hidden = !editing;
    self.deleteButton.hidden = !editing;
    
    if (!editing) { //取消编辑
        self.isAllSelect = NO;
    }
    
    [self.tableView reloadData];
}

- (void)setIsAllSelect:(BOOL)isAllSelect { //全选
    _isAllSelect = isAllSelect;
    
    /*
     遍历处理数据
     */
    for (TDSkydrveFileModel *model in self.downloadArray) {
        model.isSelected = isAllSelect;
    }
    
    for (TDSkydrveFileModel *model in self.finishArray) {
        model.isSelected = isAllSelect;
    }
    
    [self.tableView reloadData];
}


#pragma mark - UI
- (void)configView {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithHexString:colorHexStr6];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self addSubview:self.tableView];
    
    self.editeButton = [self setPlayButtonTitle:TDLocalizeSelect(@"SKY_EDITE", nil) backgroundColor:@"#3e4147"];
    [self addSubview:self.editeButton];
    
    self.deleteButton = [self setPlayButtonTitle:TDLocalizeSelect(@"DELETE", nil) backgroundColor:@"#555a5f"];
    [self addSubview:self.deleteButton];
    
    self.cancelButton = [self setPlayButtonTitle:TDLocalizeSelect(@"CANCEL", nil) backgroundColor:@"#3e4147"];
    [self addSubview:self.cancelButton];
    
    [self userEditingFile:NO];
    
    self.noDataView = [[TDNodataView alloc] init];
    self.noDataView.imageView.image = [UIImage imageNamed:@"file_null_image"];
    self.noDataView.messageLabel.text = TDLocalizeSelect(@"SKY_NO_DOWNLOAD_FILES", nil);
    [self.tableView addSubview:self.noDataView];
    
    self.noDataView.hidden = YES;
}

- (void)setViewConstraint {
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-48);
    }];
    
    [self.noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tableView);
        make.top.mas_equalTo(self.tableView.mas_top).offset(0);
        make.size.mas_equalTo(CGSizeMake(TDWidth, TDHeight - BAR_ALL_HEIHT));
    }];
    
    [self.editeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(48);
    }];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(TDWidth/2, 48));
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(TDWidth/2, 48));
    }];
}

- (UIButton *)setPlayButtonTitle:(NSString *)titleStr backgroundColor:(NSString *)colorStr {
    
    UIButton *button = [[UIButton alloc] init];
    button.showsTouchWhenHighlighted = YES;
    button.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    button.backgroundColor = [UIColor colorWithHexString:colorStr];
    [button setTitleColor:[UIColor colorWithHexString:colorHexStr5] forState:UIControlStateNormal];
    [button setTitle:titleStr forState:UIControlStateNormal];
    
    return button;
}

@end

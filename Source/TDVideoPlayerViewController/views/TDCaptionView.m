//
//  TDCaptionView.m
//  edX
//
//  Created by Elite Edu on 17/3/13.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDCaptionView.h"

@interface TDCaptionView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation TDCaptionView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        [self setviewConstraint];
    }
    return self;
}

#pragma mark - UI
- (void)setviewConstraint {
    self.tableView = [[UITableView alloc] init];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
}

- (void)setTitleArray:(NSArray *)titleArray {
    _titleArray = titleArray;
    [self.tableView reloadData];
}

#pragma mark - tableview Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"captionCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"captionCell"];
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    cell.textLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    
    NSString *title = self.titleArray[indexPath.row];
    cell.textLabel.text = title;
    
    return cell;
}

@end

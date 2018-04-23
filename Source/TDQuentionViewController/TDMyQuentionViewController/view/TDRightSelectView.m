//
//  TDRightSelectView.m
//  edX
//
//  Created by Elite Edu on 2018/1/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDRightSelectView.h"

@interface TDRightSelectView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation TDRightSelectView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.image = [UIImage imageNamed:@"black_Rectangle_top"];
        [self addSubview:self.imageView];
        
        self.tableView = [[UITableView alloc] init];
        self.tableView.tableFooterView = [UIView new];
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.tableView.separatorColor = [UIColor colorWithHexString:colorHexStr9];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.scrollEnabled = NO;
        self.tableView.layer.masksToBounds = YES;
        self.tableView.layer.cornerRadius = 5.0;
        [self addSubview:self.tableView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top);
            make.right.mas_equalTo(self.mas_right).offset(-18);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self);
            make.top.mas_equalTo(self.imageView.mas_bottom).offset(-1);
        }];
    }
    return self;
}

- (void)setTitleArray:(NSArray *)titleArray {
    _titleArray = titleArray;
    
    [self.tableView reloadData];
}

#pragma mark - tableviewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TDRightSelectViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TDRightSelectViewCell"];
    }
    cell.backgroundColor = [UIColor colorWithHexString:colorHexStr10];
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:13];
    cell.textLabel.textColor = [UIColor colorWithHexString:colorHexStr7];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.titleArray[indexPath.row];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.didSelectHandle) {
        self.didSelectHandle(indexPath.row);
    }
}

@end

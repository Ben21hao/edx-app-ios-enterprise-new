//
//  TDActivityViewController.m
//  edX
//
//  Created by Elite Edu on 16/12/10.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "TDActivityViewController.h"
#import "ChooseCourseItem.h"

@interface TDActivityViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation TDActivityViewController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = TDLocalizeSelect(@"COUPON_ACTIVITY", nil);
    
    if (self.dataArray.count > 0) {
        [self setTableviewConstraint];
        [self judgeCanUseActivity];
        
    } else {
        [self setNoneDataView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
}

#pragma mark - 判断哪些优惠券是可用的
- (void)judgeCanUseActivity {
    
    float totalMoney = [self.totalMoney floatValue];
    
    for (int i = 0; i < self.dataArray.count; i ++) {
        ActivityListItem *activityItem = self.dataArray[i];
        
        NSString *activityInfo = activityItem.other_info;
        NSArray *infoArr = [activityInfo componentsSeparatedByString:@"|"];
        if (infoArr.count == 2) {
            
            NSString *condition = infoArr[0];
            NSString *activity = infoArr[1];
            int activityType = [activityItem.activity_type intValue];
            if (activityType == 3) {//满减
                if (totalMoney >= [condition floatValue]) {
                    activityItem.canUse = YES;
                } else{
                    activityItem.canUse = NO;
                }
                
            } else if (activityType == 4) {//满折
                if (totalMoney >= [condition floatValue]) {
                    activityItem.canUse = YES;
                } else{
                     activityItem.canUse = NO;
                }
                
            } else if (activityType == 5) {//买几门减几门价格
                if (self.dataArray.count >= [condition intValue]) {
                    
                    NSArray *courseIdArr = [activity componentsSeparatedByString:@","];
                    if (courseIdArr.count > 0) {
                        
                        NSMutableArray *accordArr = [[NSMutableArray alloc] init];
                        for (ChooseCourseItem *courseItem in self.courseArray) {
                            if ([courseIdArr containsObject:courseItem.course_id]) {
                                [accordArr addObject:courseItem.min_price];
                            }
                        }
                        
                        if (accordArr.count >= [condition intValue]) {
                            activityItem.canUse = YES;
                        } else {
                             activityItem.canUse = NO;
                        }
                    }
                }
            }
        }
    }
    
    ActivityListItem *model = [[ActivityListItem alloc] init];
    model.activity_name = TDLocalizeSelect(@"SELECT_ACTIVITY_ITEM", nil);
    model.canUse = YES;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.dataArray];
    [arr insertObject:model atIndex:0];
    self.dataArray = arr;
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)setTableviewConstraint {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
}

- (void)setNoneDataView {
    UILabel  *noneLabel = [[UILabel alloc] init];
    noneLabel.text = TDLocalizeSelect(@"NO_ACTIVITY", nil);
    noneLabel.textColor = [UIColor colorWithHexString:colorHexStr8];
    noneLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:noneLabel];
    
    [noneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(-18);
    }];
}

#pragma mark - tableview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorColor = [UIColor colorWithHexString:colorHexStr6];
    
    ActivityListItem *model = self.dataArray[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"activietyCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"activietyCell"];
    }
    cell.textLabel.text = model.activity_name;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    
    if ([self.activityStr isEqualToString:model.activity_name]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.userInteractionEnabled = YES;
    if (!model.canUse) {
        cell.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        cell.userInteractionEnabled = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ActivityListItem *model = self.dataArray[indexPath.row];
    if (self.selectActivityHandle) {
        self.selectActivityHandle(model);
    }
    [self.navigationController  popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end

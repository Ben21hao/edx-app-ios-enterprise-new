//
//  TDInformationDetailView.m
//  edX
//
//  Created by Ben on 2017/4/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDInformationDetailView.h"
#import "TDUserInformationCell.h"

@interface TDInformationDetailView () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation TDInformationDetailView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(self);
    }];
}

#pragma mark - tableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    TDUserInformationCell *cell = [[TDUserInformationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCell"];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:colorHexStr7];
    [cell addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(cell);
        make.height.mas_equalTo(0.5);
    }];
    
    cell.userInteractionEnabled = NO;
    cell.detailTextField.userInteractionEnabled = NO;
    cell.detailTextField.tag = indexPath.row;
    cell.isDisclosure = NO;
    cell.backgroundColor = [UIColor whiteColor];
    
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = NSLocalizedString(@"TRURE_NAME", nil);
            cell.detailTextField.text = self.name;
            break;
        case 1:
            cell.titleLabel.text = NSLocalizedString(@"CARD_ID", nil);
            cell.detailTextField.text = self.identifyID;
            break;
        case 2:
            cell.titleLabel.text = NSLocalizedString(@"USER_BIRTHDATE", nil);
            cell.detailTextField.text = self.birthDate;
            break;
        case 3: {
            cell.titleLabel.text = NSLocalizedString(@"USER_SEX", nil);
            cell.detailTextField.text = self.sexStr;
            
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = [UIColor colorWithHexString:colorHexStr7];
            [cell addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.mas_equalTo(cell);
                make.height.mas_equalTo(0.5);
            }];
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}


@end

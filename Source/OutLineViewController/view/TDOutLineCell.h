//
//  TDOutLineCell.h
//  edX
//
//  Created by Elite Edu on 16/12/6.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OutlineFirstItem.h"

@interface TDOutLineCell : UITableViewCell

@property (nonatomic,strong) UILabel *titleLabel;

- (void)setDataForOutLine:(NSArray *)dataArray;


@end

//
//  CouponsNameTableViewCell.h
//  edX
//
//  Created by Elite Edu on 16/10/14.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CouponsNameItem;
@interface CouponsNameTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *textL;
@property(nonatomic,strong)CouponsNameItem *couponsItem;
@end

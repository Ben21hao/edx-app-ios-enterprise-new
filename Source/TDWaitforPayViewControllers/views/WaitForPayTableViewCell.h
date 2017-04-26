//
//  WaitForPayTableViewCell.h
//  edX
//
//  Created by Elite Edu on 16/10/17.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseCourseItem.h"

@class SubOrderItem,OrderItem;
@interface WaitForPayTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UILabel *courseNameL;
@property (weak, nonatomic) IBOutlet UILabel *professorL;
@property (weak, nonatomic) IBOutlet UILabel *min_pricelL;
@property (weak, nonatomic) IBOutlet UILabel *max_priceL;
@property (nonatomic,strong) SubOrderItem *subOrderItem;
@property (nonatomic,strong) OrderItem *orderItem;

@property(nonatomic,strong)ChooseCourseItem *chooseCourseItem;

@end

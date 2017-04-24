//
//  TDChooseCourseCell.h
//  edX
//
//  Created by Elite Edu on 16/12/10.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseCourseItem.h"

@interface TDChooseCourseCell : UITableViewCell

@property (nonatomic,copy) void(^selectButtonHandle)(BOOL isSelected);
- (void)setDataModel:(ChooseCourseItem *)model;

@end

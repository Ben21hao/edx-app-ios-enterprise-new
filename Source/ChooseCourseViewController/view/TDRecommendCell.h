//
//  TDRecommendCell.h
//  edX
//
//  Created by Elite Edu on 16/12/10.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDRecommendCell : UITableViewCell

@property (nonatomic,copy) void(^selectCourseHandle)(NSInteger index);

- (void)setDataWithDataArray:(NSArray *)dataArray;

@end

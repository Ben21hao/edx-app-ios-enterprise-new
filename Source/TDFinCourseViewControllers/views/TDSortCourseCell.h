//
//  TDSortCourseCell.h
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDCourseTagModel.h"

@interface TDSortCourseCell : UITableViewCell

@property (nonatomic,strong) NSArray *tagArray;

@property (nonatomic,copy) void(^selectTagButtonHandle)(TDCourseTagModel *tagModel);

@end

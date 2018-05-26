//
//  TDScoreCellCell.h
//  edX
//
//  Created by Elite Edu on 2018/5/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDCourseScoreModel.h"

@interface TDScoreCellCell : UITableViewCell

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UILabel *leftLabel;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *scoreLabel;
@property (nonatomic,strong) UILabel *line;

@property (nonatomic,strong) TDUnitScoreModel *unitScoreModel;

@end

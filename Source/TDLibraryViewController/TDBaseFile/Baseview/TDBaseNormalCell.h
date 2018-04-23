//
//  TDBaseNormalCell.h
//  EdxProject
//
//  Created by Elite Edu on 2017/12/19.
//  Copyright © 2017年 Elite Edu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDBaseNormalCell : UITableViewCell

@property (nonatomic,strong) UIView *bgView;

- (void)configView;
- (void)setViewConstraint;
- (UILabel *)setLabelStyle:(NSInteger)font color:(NSString *)colorStr;


@end

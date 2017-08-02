//
//  WatchLiveSurveyTableViewCell.h
//  UIModel
//
//  Created by chickenrungo on 2017/3/6.
//  Copyright © 2017年 www.vhall.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VHallSurveyModel;

typedef void(^clickSurveyItem)(VHallSurveyModel *surveyModel);

@interface WatchLiveSurveyTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *surveyLabel;
@property (strong, nonatomic) IBOutlet UIButton *surveyButton;

@property(nonatomic,copy) clickSurveyItem clickSurveyItem;
@property(nonatomic,strong) VHallSurveyModel *model;

@end

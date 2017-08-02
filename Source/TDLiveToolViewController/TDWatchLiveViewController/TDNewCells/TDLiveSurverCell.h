//
//  TDLiveSurverCell.h
//  edX
//
//  Created by Ben on 2017/7/28.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^clickSurveyItem)(VHallSurveyModel *surveyModel);

@interface TDLiveSurverCell : UITableViewCell

@property (strong, nonatomic) UILabel *surveyLabel;
@property (strong, nonatomic) UIButton *surveyButton;

@property (nonatomic,copy) clickSurveyItem clickSurveyItem;
@property (nonatomic,strong) VHallSurveyModel *model;

@end

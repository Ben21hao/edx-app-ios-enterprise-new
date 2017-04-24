//
//  TDBottomCouseView.h
//  edX
//
//  Created by Elite Edu on 16/12/12.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseCourseItem.h"

@interface TDBottomCouseView : UIView

@property (nonatomic,strong) UIButton *bottomButton;

- (void)setCourseViewData:(ChooseCourseItem *)courseItem;

@end

//
//  TDBaseButton.h
//  edX
//
//  Created by Elite Edu on 2017/8/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDBaseButton : UIButton

@property (nonatomic,strong) UIActivityIndicatorView *activityView;

- (instancetype)initWithFrame:(CGRect)frame colorStr:(NSString *)colorStr;

@end
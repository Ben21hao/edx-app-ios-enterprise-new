//
//  TDSkydriveAlertView.h
//  edX
//
//  Created by Elite Edu on 2018/6/7.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TDSkydriveShareTime) {
    TDSkydriveShareTimeOneDay,
    TDSkydriveShareTimeSevenDay,
    TDSkydriveShareTimeForever
};

@interface TDSkydriveAlertView : UIView

@property (nonatomic,strong) UIButton *bgButton;
@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) UIButton *sureButton;

@property (nonatomic,assign) TDSkydriveShareTime timeType;

@end

//
//  TDSkydriveProgressView.h
//  edX
//
//  Created by Elite Edu on 2018/6/19.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDSkydriveProgressView : UIView

@property (nonatomic,strong) UIButton *downloadButton;

@property (nonatomic,assign) double progress;
@property (nonatomic,assign) NSInteger status;

@end

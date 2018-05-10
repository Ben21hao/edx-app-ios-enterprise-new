//
//  TDAudioPlayView.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/9.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDBaseView.h"

@interface TDAudioPlayView : TDBaseView

@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,copy) void(^tapAction)();
@property (nonatomic,copy) void(^longPressAction)();

@end

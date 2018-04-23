//
//  TDImageSelectView.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/10.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDBaseView.h"

@interface TDImageSelectView : TDBaseView

@property (nonatomic,strong) UIButton *firstButton;
@property (nonatomic,strong) UIImageView *firstImage;
@property (nonatomic,strong) UIImageView *secondImage;
@property (nonatomic,strong) UIImageView *thirdImage;
@property (nonatomic,strong) UIImageView *fourthImage;

@property (nonatomic,strong) NSArray *imageArray;

@property (nonatomic,copy) void(^deleteImageHandle)(NSInteger tag);
@property (nonatomic,copy) void(^tapImageHandle)(NSInteger tag);

@end

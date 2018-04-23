//
//  TDSelectBottomView.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/12.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDBaseView.h"
#import "TDShadowButton.h"

@interface TDSelectBottomView : TDBaseView

@property (nonatomic,assign) BOOL isPreView;

@property (nonatomic,strong) UIButton *previewButton;
@property (nonatomic,strong) TDShadowButton *sureButton;

@property (nonatomic,assign) NSInteger selectNum;

@end

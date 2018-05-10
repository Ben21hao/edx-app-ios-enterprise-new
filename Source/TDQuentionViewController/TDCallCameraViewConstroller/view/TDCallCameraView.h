//
//  TDCallCameraView.h
//  edX
//
//  Created by Elite Edu on 2018/4/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDCallCameraView : UIView

@property (nonatomic,strong) UIButton *exchangeButton;
@property (nonatomic,strong) UIButton *dismissButton;
@property (nonatomic,strong) UIButton *cameraImageView;
@property (nonatomic,strong) UIImageView *centerWhiteImage;
@property (nonatomic,strong) UILabel *mindLabel;

@property (nonatomic,strong) UIButton *discarButton;
@property (nonatomic,strong) UIButton *selectButton;

@property (nonatomic) UIView *focusView;

- (void)showSelectButtonHandle; //拍摄完成，显示选择
- (void)hideSelectButtonHandle; //重新拍摄
- (void)updateCameraButtonConstraint:(BOOL)isBig;

@end

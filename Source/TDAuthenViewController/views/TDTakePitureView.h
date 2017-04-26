//
//  TDTakePitureView.h
//  edX
//
//  Created by Ben on 2017/4/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TDPhotoType) {
    TDPhotoTypeFace,
    TDPhotoTypeIdentify
};

@interface TDTakePitureView : UIView

@property (nonatomic,assign) NSInteger type;

@property (nonatomic,strong) UIScrollView *scrollview;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *topLabel;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIButton *imageButton;
@property (nonatomic,strong) UILabel *remindLabel;
@property (nonatomic,strong) UIView *buttonView;
@property (nonatomic,strong) UIButton *resetButton;
@property (nonatomic,strong) UIButton *nextButton;


@end

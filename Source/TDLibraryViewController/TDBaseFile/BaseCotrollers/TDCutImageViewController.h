//
//  TDCutImageViewController.h
//  edX
//
//  Created by Elite Edu on 17/2/16.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CropImageDelegate <NSObject>

- (void)cropImageDidFinishedWithImage:(UIImage *)image;

@end


typedef NS_ENUM(NSInteger,TDPhotoCutFrom) {
    TDPhotoCutFromHeader,
    TDPhotoCutFromAuthen
};

@interface TDCutImageViewController : UIViewController

@property (nonatomic, weak) id <CropImageDelegate> delegate;
@property (nonatomic,copy) void(^cancelHandle)();

@property (nonatomic,assign) NSInteger whereFrom;
@property (nonatomic, assign) BOOL ovalClip; //Yes 圆形裁剪, NO 矩形裁剪 -- 默认NO
- (instancetype)initWithImage:(UIImage *)originalImage delegate:(id)delegate;

@end

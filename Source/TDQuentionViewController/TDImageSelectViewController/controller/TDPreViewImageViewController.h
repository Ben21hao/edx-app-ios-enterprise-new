//
//  TDPreViewImageViewController.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/11.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDSelectImageModel.h"

typedef NS_ENUM(NSInteger, TDPreviewImageFrom) {
    TDPreviewImageFromPreviewAllImage,
    TDPreviewImageFromPreviewSelectImage,
    TDPreviewImageFromQuedionInputView
};

@interface TDPreViewImageViewController : TDBaseViewController

@property (nonatomic,strong) NSArray *imageArray;//全部显示的图片
@property (nonatomic,assign) NSInteger index; //点击第几个进来的

@property (nonatomic,strong) NSArray *hadSelectImageArray; //已经选择的图片
@property (nonatomic,strong) NSArray *inputViewImageArray; //在我的咨询页已存在的图片
@property (nonatomic,assign) NSInteger whereFrom; //从哪进来的

@property (nonatomic,copy) void(^previewSelectHandle)(NSInteger index,BOOL isSelect);

@end

//
//  TDSelectImageModel.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/11.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
//#import <AssetsLibrary/AssetsLibrary.h>

@interface TDSelectImageModel : NSObject

@property (nonatomic,strong) PHAsset *asset;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) NSString *videoUrl; //视频url

@property (nonatomic,assign) BOOL selected;

@end

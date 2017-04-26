//
//  TDTakePictureViewController.h
//  edX
//
//  Created by Ben on 2017/4/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TDAuthenFrom) {
    TDAuthenFromProfile,
    TDAuthenFromPhoto
};

@interface TDTakePictureViewController : TDBaseViewController

@property (nonatomic,assign) NSInteger whereFrom;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) UIImage *faceImage;

@end

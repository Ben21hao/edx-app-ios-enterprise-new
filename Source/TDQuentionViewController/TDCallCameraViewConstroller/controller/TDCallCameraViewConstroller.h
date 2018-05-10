//
//  TDCallCameraViewConstroller.h
//  edX
//
//  Created by Elite Edu on 2018/4/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDCallCameraViewConstroller : UIViewController

@property (nonatomic,copy) void(^handleCameraImage)(UIImage *image);

@end

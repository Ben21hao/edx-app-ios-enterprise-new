//
//  TDRightSelectView.h
//  edX
//
//  Created by Elite Edu on 2018/1/25.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDRightSelectView : UIView

@property (nonatomic,strong) NSArray *titleArray;
@property (nonatomic,strong) void(^didSelectHandle)(NSInteger row);

@end

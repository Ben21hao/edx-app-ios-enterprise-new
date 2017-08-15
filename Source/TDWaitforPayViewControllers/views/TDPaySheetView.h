//
//  TDPaySheetView.h
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDPayMoneyView.h"
#import "TDPayTypeView.h"

@interface TDPaySheetView : UIView

@property (nonatomic,strong) UIView *tapView;
@property (nonatomic,strong) TDPayMoneyView *payMoneyView;
@property (nonatomic,strong) TDPayTypeView *wechatView;
@property (nonatomic,strong) TDPayTypeView *alipayView;

@end

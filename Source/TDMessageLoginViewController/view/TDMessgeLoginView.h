//
//  TDMessgeLoginView.h
//  edX
//
//  Created by Elite Edu on 2018/5/23.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDLoginVerticationView.h"
#import "TDLoginMessageView.h"
#import "TDBaseButton.h"

typedef NS_ENUM(NSInteger, TDLoginMessageViewType) {
    TDLoginMessageViewTypeVertication,
    TDLoginMessageViewTypeSendCode
};

@interface TDMessgeLoginView : UIView

- (instancetype)initWithType:(TDLoginMessageViewType)type;

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) TDLoginVerticationView *verticationView;
@property (nonatomic,strong) TDLoginMessageView *messageView;
@property (nonatomic,strong) TDBaseButton *passwordButton;
@property (nonatomic,strong) UIButton *bottomButton;

@end

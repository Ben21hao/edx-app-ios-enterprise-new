//
//  AliPayView.m
//  edX
//
//  Created by Elite Edu on 16/10/18.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "AliPayView.h"

@implementation AliPayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (AliPayView *)initView{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:@"AliPayView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}
@end

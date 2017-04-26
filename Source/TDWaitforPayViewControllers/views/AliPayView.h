//
//  AliPayView.h
//  edX
//
//  Created by Elite Edu on 16/10/18.
//  Copyright © 2016年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AliPayView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+ (AliPayView *)initView;
@end

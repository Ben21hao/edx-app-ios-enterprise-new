//
//  UserDiscountTableViewCell.m
//  edX
//
//  Created by Elite Edu on 16/8/29.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "UserDiscountTableViewCell.h"
#import "UserCouponItem.h"

@interface UserDiscountTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *contV;

@end

@implementation UserDiscountTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.contV.layer.cornerRadius = 10;
    self.contV.clipsToBounds = YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setUserCouponItem:(UserCouponItem *)UserCouponItem{
    _UserCouponItem = UserCouponItem;
    NSString *str = _UserCouponItem.discount_rate;
    str = [str substringFromIndex:2];
    if (str.length == 1) {
        str = [str stringByAppendingString:@".0"];
    }else{
        NSString *str1 = [str substringToIndex:1];
        NSString *str2 = [str substringFromIndex:1];
        NSString *str3 = [NSString stringWithFormat:@"."];
        str = [str1 stringByAppendingString:str3];
        str = [str stringByAppendingString:str2];
    }
    _firstL.text = [NSString stringWithFormat:@"%@折",str];
    _secondL.text = _UserCouponItem.coupon_name;
    _thirdL.text = _UserCouponItem.coupon_type;
    NSRange range = [_UserCouponItem.coupon_begin_at rangeOfString:@"T"];
    _fourthL.text = [NSString stringWithFormat:@"有效期：%@至%@",[_UserCouponItem.coupon_begin_at substringToIndex:range.location],[_UserCouponItem.coupon_end_at substringToIndex:range.location]];
}
@end

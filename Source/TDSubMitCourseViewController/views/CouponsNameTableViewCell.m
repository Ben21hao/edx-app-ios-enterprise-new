//
//  CouponsNameTableViewCell.m
//  edX
//
//  Created by Elite Edu on 16/10/14.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "CouponsNameTableViewCell.h"
#import "CouponsNameItem.h"

@implementation CouponsNameTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//-(void)setCouponsItem:(CouponsNameItem *)couponsItem{
//    _couponsItem = couponsItem;
//    _textL.text = couponsItem.coupon_name;
//}
@end

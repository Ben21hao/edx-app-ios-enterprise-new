//
//  WaitForPayTableViewCell.m
//  edX
//
//  Created by Elite Edu on 16/10/17.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "WaitForPayTableViewCell.h"
#import "SubOrderItem.h"
#import "OrderItem.h"
#import <UIImageView+WebCache.h>

@implementation WaitForPayTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _imgV.layer.cornerRadius = 5;
    _imgV.layer.masksToBounds=YES;
}

- (void)setChooseCourseItem:(ChooseCourseItem *)chooseCourseItem{
    
    _chooseCourseItem = chooseCourseItem;
    _professorL.text = _chooseCourseItem.professor_name;
    _courseNameL.text = _chooseCourseItem.course_display_name;
    
    NSString *string1 = [NSString stringWithFormat:@"%@%@",ELITEU_URL,_chooseCourseItem.course_pic];
    NSString* string2 = [string1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [_imgV sd_setImageWithURL:[NSURL URLWithString:string2] placeholderImage:[UIImage imageNamed:@"yjz0"]];
    
    TDBaseToolModel *baseTool = [[TDBaseToolModel alloc] init];
    self.min_pricelL.attributedText = [baseTool setString:chooseCourseItem.isCompanyCoupon ? [NSString stringWithFormat:@"￥%.2f",[self.chooseCourseItem.suggest_price floatValue]] : [NSString stringWithFormat:@"￥%.2f", [self.chooseCourseItem.min_price floatValue]] withFont:16  type:1];
    self.max_priceL.attributedText = [baseTool setString:[NSString stringWithFormat:@"￥%.2f",[self.chooseCourseItem.suggest_price floatValue]] withFont:12  type:2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

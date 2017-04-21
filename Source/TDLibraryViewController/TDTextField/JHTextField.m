//
//  JHTextField.m
//  edX
//
//  Created by Elite Edu on 16/8/19.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "JHTextField.h"

@implementation JHTextField

// 修改文本展示区域，一般跟editingRectForBounds一起重写  
- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x+8, bounds.origin.y, bounds.size.width-25, bounds.size.height);
    return inset;
}
// 重写来编辑区域，可以改变光标起始位置，以及光标最右到什么地方，placeHolder的位置也会改变
-(CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect insert = CGRectMake(bounds.origin.x+8, bounds.origin.y, bounds.size.width-25, bounds.size.height);
    return insert;
}
// 控制placeHolder的位置，左右缩20，但是光标位置不变
- (CGRect)placeholderRectForBounds:(CGRect)bounds{
    CGRect insert = CGRectMake(bounds.origin.x+8, bounds.origin.y + bounds.size.height* 0.1, bounds.size.width-25, bounds.size.height);
    return insert;
}



@end

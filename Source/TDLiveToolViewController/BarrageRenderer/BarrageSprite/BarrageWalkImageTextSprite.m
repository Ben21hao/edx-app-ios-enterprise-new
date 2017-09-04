//
//  BarrageWalkImageTextSprite.m
//  BarrageRendererDemo
//
//  Created by UnAsh on 15/11/15.
//  Copyright (c) 2015年 ExBye Inc. All rights reserved.
//

#import "BarrageWalkImageTextSprite.h"
#import "MLEmojiLabel.h"

@implementation BarrageWalkImageTextSprite

- (UIView *)bindingView
{
    
  
    
    
    MLEmojiLabel * label = [[MLEmojiLabel alloc]initWithFrame:CGRectZero];
    label.text = self.text;
    label.textColor = self.textColor;
    label.font = [UIFont systemFontOfSize:self.fontSize];
    if (self.cornerRadius > 0) {
        label.layer.cornerRadius = self.cornerRadius;
        label.clipsToBounds = YES;
    }
    label.layer.borderColor = self.borderColor.CGColor;
    label.layer.borderWidth = self.borderWidth;
    label.backgroundColor = self.backgroundColor;
    label.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    label.customEmojiPlistName = @"faceExpression.plist";
    label.customEmojiBundleName = @"UIModel.bundle";
    label.backgroundColor = [UIColor clearColor];
    label.lineBreakMode = NSLineBreakByCharWrapping;
//    label.isNeedAtAndPoundSign = YES; //是否需要话题和@功能，默认为不需要
    return label;
}

@end

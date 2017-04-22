//
//  TDBaseTableview.m
//  edX
//
//  Created by Elite Edu on 17/3/7.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDBaseTableview.h"

@implementation TDBaseTableview

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

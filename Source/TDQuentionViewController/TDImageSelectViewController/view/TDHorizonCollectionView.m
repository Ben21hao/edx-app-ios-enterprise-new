//
//  TDHorizonCollectionView.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/13.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDHorizonCollectionView.h"

@implementation TDHorizonCollectionView


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (self.contentOffset.x <= 0) {
        return YES;
    }
    return NO;
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    
    [self setContentOffset:CGPointMake(index * TDWidth, 0) animated:NO];
}

@end

//
//  TDBaseCollectionView.m
//  EdxProject
//
//  Created by Elite Edu on 2017/12/27.
//  Copyright © 2017年 Elite Edu. All rights reserved.
//

#import "TDBaseCollectionView.h"

@implementation TDBaseCollectionView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if (self.contentOffset.y <= 0) {
        return YES;
    }
    
    return NO;
}

- (void)scrollsToBottomAnimated:(BOOL)animated {
    CGFloat offset = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
    if (offset > 0) {
        [self setContentOffset:CGPointMake(0, offset) animated:animated];
    }
}

@end

//
//  CommentDetailItem.m
//  edX
//
//  Created by Elite Edu on 16/10/19.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "CommentDetailItem.h"

extern const CGFloat contentLabelFontSize;
extern CGFloat maxContentLabelHeight;

@implementation CommentDetailItem
{
    CGFloat _lastContentWidth;
}

@synthesize content = _content;

- (void)setContent:(NSString *)content{
    _content = content;
}
- (NSString *)content
{
    CGFloat contentW = [UIScreen mainScreen].bounds.size.width - 70;
    if (contentW != _lastContentWidth) {
        _lastContentWidth = contentW;
        CGRect textRect = [_content boundingRectWithSize:CGSizeMake(contentW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:contentLabelFontSize]} context:nil];
        if (textRect.size.height > maxContentLabelHeight) {
            _shouldShowMoreButton = NO;
        } else {
            _shouldShowMoreButton = NO;
        }
    }
    return _content;
}
- (void)setIsOpening:(BOOL)isOpening{
    if (!_shouldShowMoreButton) {
        _isOpening = NO;
    }
    else{
        _isOpening = isOpening;
    }
}

- (void)setIs_praise:(BOOL)is_praise{
    _is_praise = is_praise;
}

- (void)setClick_Open:(BOOL)click_Open {
    _click_Open = click_Open;
}

- (void)setMaxCommentLabelHeight:(float)maxCommentLabelHeight {
    _maxCommentLabelHeight = maxCommentLabelHeight;
}

- (void)setShowMoreButton:(BOOL)showMoreButton {
    _showMoreButton = showMoreButton;
}

@end

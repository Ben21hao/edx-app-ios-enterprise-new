//
//  TDAvPlayerOperation.h
//  edX
//
//  Created by Elite Edu on 2018/5/4.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDAvPlayerOperation : NSObject

/**
 * 注意：播放视频的URL是fileURLWithPath。格式是：“file://var”
 */
- (instancetype)initVideoFileURL:(NSURL *)videoFileURL withFrame:(CGRect)frame withView:(UIView *)view;

- (void)playSight;
- (void)releaseVideoPlayer;
- (void)pauseSight;

@end

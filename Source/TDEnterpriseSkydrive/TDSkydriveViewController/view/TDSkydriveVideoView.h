//
//  TDSkydriveVideoView.h
//  edX
//
//  Created by Elite Edu on 2018/6/13.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDSkydriveVideoMaskView.h"

@interface TDSkydriveVideoView : UIView

@property (nonatomic,strong) UIViewController *videoController;

@property (nonatomic,strong) TDSkydriveVideoMaskView *videoMaskView;
@property (nonatomic,strong) NSString *videoUrl;//视频url
@property (nonatomic,copy) void (^navigationBarHandle)(BOOL hidden);//状态栏的处理

- (void)videoFullScreenAction;//全屏
- (void)replayVideo; //播放视频
- (void)destroyPlayer; //移除播放器

@end

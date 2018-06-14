//
//  TDVideoView.h
//  EdxProject
//
//  Created by Elite Edu on 2018/4/11.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TDVideoViewRate) {
    TDVideoViewRateDefault, //1.0x
    TDVideoViewRateSlow, // .5x
    TDVideoViewRateFast, // 1.5x
    TDVideoViewRateXFast,// 2x
};

extern NSString* const TDVideoViewkIndex;
extern NSString* const TDVideoViewkStart;
extern NSString* const TDVideoViewkEnd;
extern NSString* const TDVideoViewkText;

@protocol TDVideoViewDelegate <NSObject>

- (void)getCaptionItemArray:(NSArray *)captionArray;
- (void)heightLightCaptionText:(NSInteger)row;

@end

@interface TDVideoView : UIView

//字幕相关
@property (nonatomic,weak) id<TDVideoViewDelegate> delegate;
@property (nonatomic,assign) NSInteger selectedRow;

@property (nonatomic,strong) UIViewController *videoController;

@property (nonatomic,strong) NSString *videoUrl;//视频url
@property (nonatomic,copy) void (^navigationBarHandle)(BOOL hidden);//状态栏的处理

- (void)replayVideo; //播放视频
- (void)chooseVideoPlayerRate;//选择播放速度
- (void)destroyPlayer; //移除播放器

@end

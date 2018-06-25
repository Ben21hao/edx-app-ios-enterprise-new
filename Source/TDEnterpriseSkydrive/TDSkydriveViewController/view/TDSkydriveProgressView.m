//
//  TDSkydriveProgressView.m
//  edX
//
//  Created by Elite Edu on 2018/6/19.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveProgressView.h"
#import "TDCircleDrawView.h"

@interface TDSkydriveProgressView ()

@property (nonatomic,strong) TDCircleDrawView *circleView;

@end

@implementation TDSkydriveProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setViewConstraint];
    }
    return self;
}

- (void)setViewConstraint {
    self.backgroundColor = [UIColor whiteColor];
    
    self.downloadButton = [[UIButton alloc] init];
    self.downloadButton.showsTouchWhenHighlighted = YES;
    [self.downloadButton setImage:[UIImage imageNamed:@"download_new_image"] forState:UIControlStateNormal];
    [self addSubview:self.downloadButton];
    
    self.circleView = [[TDCircleDrawView alloc] init];
    self.circleView.backgroundColor = [UIColor clearColor];
    self.circleView.userInteractionEnabled = NO;
    [self addSubview:self.circleView];
    
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    
    [self.circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.downloadButton);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
}

- (void)setProgress:(double)progress {
    _progress = progress;
    
    if (progress == 0) {
        return;
    }
    
    [self.downloadButton setImage:[UIImage imageNamed:@"download_ing_image"] forState:UIControlStateNormal];
    
    self.circleView.progress = progress;
    [self.circleView setNeedsDisplay];
}

- (void)setStatus:(NSInteger)status {
    _status = status;
    
    NSString *imageStr;
    switch (status) {// 0 未下载，1 下载中，2 等待下载，3 暂停，4 下载失败，5 下载完成
        case 0:
            imageStr = @"download_new_image";
            self.circleView.hidden = YES;
            break;
        case 1:
            imageStr = @"download_ing_image";
            self.circleView.hidden = NO;
            break;
        case 2:
            imageStr = @"download_waiting_image";
            self.circleView.hidden = YES;
            break;
        case 3:
            imageStr = @"download_pause_image";
            self.circleView.hidden = NO;
            break;
        case 4:
            imageStr = @"down_load_failed";
            self.circleView.hidden = YES;
            break;
        default:
            imageStr = @"down_load_finish";
            self.circleView.hidden = YES;
            break;
    }
    [self.downloadButton setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
    self.downloadButton.userInteractionEnabled = status != 5 ? YES : NO;
}

@end

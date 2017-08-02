//
//  TDLiveBottomCell.h
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDLiveModel.h"

@interface TDLiveBottomCell : UITableViewCell

@property (nonatomic,assign) NSInteger  whereFrom;
@property (nonatomic,strong) TDLiveModel *model;

@property (nonatomic,strong) UIButton *enterButton;
@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UIButton *praticeButton;

@end

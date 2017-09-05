//
//  TDLiveLotteryView.h
//  edX
//
//  Created by Elite Edu on 2017/9/4.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHallLottery.h"
#import "VHallMsgModels.h"

@interface TDLiveLotteryView : UIView

@property (nonatomic,strong) UITextField *tfName;
@property (nonatomic,strong) UITextField *tfPhone;

@property (nonatomic,strong) VHallLottery *lottery;
@property (nonatomic,strong) VHallEndLotteryModel *endLotteryModel; //中奖结果model

@property (nonatomic,copy) void(^closeButtonHandle)();

@end

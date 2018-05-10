//
//  TDConsultCell.h
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDMyConsultModel.h"

@interface TDConsultCell : UITableViewCell

@property (nonatomic,strong) UILabel *numLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *contentLabel;
@property (nonatomic,strong) UILabel *statusLabel;

@property (nonatomic,strong) TDMyConsultModel *consultModel;

@property (nonatomic,assign) NSInteger whereFrom;//0 未解决；1 已解决

@end

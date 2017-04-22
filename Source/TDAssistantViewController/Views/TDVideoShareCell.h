//
//  TDVideoShareCell.h
//  edX
//
//  Created by Elite Edu on 17/3/2.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDVideoShareCell : UITableViewCell

@property (nonatomic,strong) void(^shareButtonHandle)(NSInteger type);

@end

//
//  TDOrderScoreCell.h
//  edX
//
//  Created by Elite Edu on 17/3/2.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDOrderScoreCell : UITableViewCell

@property (nonatomic,strong) NSArray *tagArray;
@property (nonatomic,strong) NSString *scoreStr;
@property (nonatomic,copy) void(^startButtonHandle)(NSInteger tag);
@property (nonatomic,copy) void(^tagButtonHandle)(NSInteger tag, BOOL isClick);

@end

//
//  TDAssistantCell.h
//  edX
//
//  Created by Elite Edu on 17/2/13.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDAssistantCell : UITableViewCell

@property (nonatomic,strong) UIImageView *headerImage;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *quetionLabel;
@property (nonatomic,assign) NSInteger whereFrom;

@end

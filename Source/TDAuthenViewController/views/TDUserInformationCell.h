//
//  TDUserInformationCell.h
//  edX
//
//  Created by Ben on 2017/4/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDUserInformationCell : UITableViewCell

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UITextField *detailTextField;
@property (nonatomic,assign) BOOL isDisclosure;

@end

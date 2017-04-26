//
//  TDUserInformationView.h
//  edX
//
//  Created by Ben on 2017/4/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDUserInformationView : UIView

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *dateView;
@property (nonatomic,strong) UIButton *handinButton; //提交
@property (nonatomic,strong) UIActivityIndicatorView *activityView;

@property (nonatomic,assign) BOOL isDate;

@property (nonatomic,copy) void(^selectDateHandle)(NSString *dateStr);
@property (nonatomic,copy) void(^selectSexHandle)(NSString *sexStr);

@end

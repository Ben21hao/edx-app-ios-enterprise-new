//
//  TDInformationDetailView.h
//  edX
//
//  Created by Ben on 2017/4/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDInformationDetailView : UIView

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *identifyID;
@property (nonatomic,strong) NSString *birthDate;
@property (nonatomic,strong) NSString *sexStr;

@end

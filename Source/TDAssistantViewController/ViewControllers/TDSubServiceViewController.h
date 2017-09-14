//
//  TDSubServiceViewController.h
//  edX
//
//  Created by Elite Edu on 17/2/10.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TDAssistantFrom) {
    TDAssistantFromOne,
    TDAssistantFromTwo,
    TDAssistantFromThree
};

@interface TDSubServiceViewController : TDBaseViewController

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *company_id;
@property (nonatomic,assign) NSInteger whereFrom;


@end

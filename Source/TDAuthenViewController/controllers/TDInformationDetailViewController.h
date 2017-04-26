//
//  TDInformationDetailViewController.h
//  edX
//
//  Created by Ben on 2017/4/26.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TDAuthenMessageFrom) {
    TDAuthenMessageFromFinish,
    TDAuthenMessageFromAuthen
};

@interface TDInformationDetailViewController : UIViewController

@property (nonatomic,strong) NSString *username;
@property (nonatomic,assign) NSInteger whereFrom;

@end

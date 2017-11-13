//
//  TDFindCourseViewController.h
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDPageingViewController.h"

@interface TDFindCourseViewController : TDPageingViewController

- (instancetype)initWithUserName:(NSString *)username companyId:(NSString *)companyId;

@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *company_id;

@end

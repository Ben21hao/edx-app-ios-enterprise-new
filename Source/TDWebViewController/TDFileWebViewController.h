//
//  TDFileWebViewController.h
//  edX
//
//  Created by Elite Edu on 2017/12/5.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDFileModel.h"

@interface TDFileWebViewController : TDBaseViewController

@property (nonatomic,strong) NSString *couse_id;
@property (nonatomic,strong) NSString *block_id;

- (void)setViewData;

@end

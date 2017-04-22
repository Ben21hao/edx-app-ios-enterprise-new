//
//  TDTimeModel.h
//  edX
//
//  Created by Elite Edu on 17/3/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDTimeModel : NSObject

@property (nonatomic,strong) NSString *time_slice;
@property (nonatomic,assign) BOOL isSelected;
@property (nonatomic,assign) BOOL canSelected;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,assign) NSInteger typeNum;

@end

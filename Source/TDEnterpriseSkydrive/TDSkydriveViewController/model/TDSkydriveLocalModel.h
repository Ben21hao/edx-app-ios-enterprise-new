//
//  TDSkydriveLocalModel.h
//  edX
//
//  Created by Elite Edu on 2018/6/12.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDSkydriveLocalModel : NSObject

@property (nonatomic,strong) NSString *titleStr;
@property (nonatomic,strong) NSString *sizeStr;
@property (nonatomic,assign) NSInteger type;//文件类型

@property (nonatomic,assign) BOOL isEditing;
@property (nonatomic,assign) BOOL isSelected;

@end

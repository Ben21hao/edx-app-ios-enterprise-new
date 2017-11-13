//
//  TDFindCourseView.h
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDFindCourseView : UIView

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray *courseArray;

@property (nonatomic,copy) void(^didSelectRow)(NSInteger rowIndex);

@end

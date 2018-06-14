//
//  TDSkydriveLocalView.h
//  edX
//
//  Created by Elite Edu on 2018/6/11.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDSkydriveLocalModel.h"

@protocol TDSkydriveSelectDelegate <NSObject>

- (void)userPreviewFileRowAtIndexpath:(NSIndexPath *)indexPath; //文件预览
- (void)userSelectFileRowAtIndexpath:(NSIndexPath *)indexPath;//选择编辑文件

@end

@interface TDSkydriveLocalView : UIView 

@property (nonatomic,strong) UIButton *editeButton;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UIButton *cancelButton;

@property (nonatomic,strong) NSArray *downloadArray; //正在下载的文件
@property (nonatomic,strong) NSArray *localFileArray;//已下载的文件

@property (nonatomic,assign) BOOL isAllSelect;
@property (nonatomic,weak) id <TDSkydriveSelectDelegate> delegate;

- (void)userEditingFile:(BOOL)editing;

@end

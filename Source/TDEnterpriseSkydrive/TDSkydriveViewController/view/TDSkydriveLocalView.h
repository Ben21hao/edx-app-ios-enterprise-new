//
//  TDSkydriveLocalView.h
//  edX
//
//  Created by Elite Edu on 2018/6/11.
//  Copyright © 2018年 edX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDSkydrveFileModel.h"

@protocol TDSkydriveSelectDelegate <NSObject>

- (void)userClickFileRowModel:(TDSkydrveFileModel *)model; //点击下载
- (void)userPreviewFileRowAtIndexpath:(NSIndexPath *)indexPath; //文件预览
- (void)userSelectFileRowAtIndexpath:(TDSkydrveFileModel *)model;//选择编辑文件

@end

@interface TDSkydriveLocalView : UIView

@property (nonatomic,strong) UIButton *editeButton;
@property (nonatomic,strong) UIButton *deleteButton;
@property (nonatomic,strong) UIButton *cancelButton;

@property (nonatomic,strong) NSArray *downloadArray; //正在下载的文件
@property (nonatomic,strong) NSArray *localFileArray;//已下载的文件

@property (nonatomic,assign) BOOL isAllSelect;
@property (nonatomic,weak) id <TDSkydriveSelectDelegate> delegate;

- (void)reloadTableViewForDownload:(NSArray *)downloadArray finish:(NSArray *)finishArray; //刷新数据
- (void)userEditingFile:(BOOL)editing; //是否点击编辑按钮


@end

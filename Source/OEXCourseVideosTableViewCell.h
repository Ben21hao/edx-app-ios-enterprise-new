//
//  OEXCourseVideosTableViewCell.h
//  edXVideoLocker
//
//  Created by Rahul Varma on 28/05/14.
//  Copyright (c) 2014-2016 edX. All rights reserved.
//


@class OEXCheckBox;
@class DACircularProgressView;

NS_ASSUME_NONNULL_BEGIN

@interface OEXCourseVideosTableViewCell : UITableViewCell

@property (weak, nonatomic, nullable) IBOutlet UIImageView* img_VideoWatchState;//图片

@property (weak, nonatomic, nullable) IBOutlet UILabel* lbl_Title;//课程名字
@property (weak, nonatomic, nullable) IBOutlet UILabel* lbl_Time;//时间
@property (weak, nonatomic, nullable) IBOutlet UILabel* lbl_Size;//大小
@property (weak, nonatomic, nullable) IBOutlet DACircularProgressView* customProgressView;
@property (weak, nonatomic, nullable) IBOutlet UIButton* btn_Download;
@property (weak, nonatomic, nullable) IBOutlet NSLayoutConstraint *courseVideoStateLeadingConstraint;
@property (weak, nonatomic, nullable) IBOutlet NSLayoutConstraint *subSectionCourseVideoStateLeadingConstraint;

// Used only while editing the table view
@property (weak, nonatomic, nullable) IBOutlet OEXCheckBox* btn_CheckboxDelete;
@property (weak, nonatomic, nullable) IBOutlet UIView* view_DisableOffline;

@end

NS_ASSUME_NONNULL_END

//
//  OEXHelperVideoDownload.h
//  edXVideoLocker
//
//  Created by Rahul Varma on 28/05/14.
//  Copyright (c) 2014-2015 edX. All rights reserved.
//

#import "OEXConstants.h"

NS_ASSUME_NONNULL_BEGIN

@class OEXVideoSummary;

extern double const OEXMaxDownloadProgress;

@interface OEXHelperVideoDownload : NSObject

@property (nonatomic, strong, nullable) OEXVideoSummary* summary;

@property (nonatomic, assign) double downloadProgress;
@property (nonatomic, strong) NSString* filePath;

@property (nonatomic, assign) BOOL isVideoDownloading;  // used to get if the video downloading is in progress 是否正在下载
@property (nonatomic, assign) OEXDownloadState downloadState; //视频下载状态，如Complete，Partial，New
@property (nonatomic, assign) OEXPlayedState watchedState; //视频的观看状态，如Unwatched，PartiallyWatched，Watched
@property (nonatomic, strong, nullable) NSDate* completedDate;
@property (nonatomic, assign) NSTimeInterval lastPlayedInterval;

@property (nonatomic, assign) BOOL isSelected;  // Used only while editing.

@property (nonatomic, strong, nullable) NSString* course_url;
@property (nonatomic, strong, nullable) NSString* course_id;

@end

NS_ASSUME_NONNULL_END

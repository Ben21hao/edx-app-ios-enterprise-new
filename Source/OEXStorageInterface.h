//
//  OEXStorageInterface.h
//  edXLibrary
//
//  Created by Rahul Varma on 07/11/14.
//  Copyright (c) 2014-2016 edX, Inc. All rights reserved.
//

#import "VideoData.h"
#import "LastAccessed.h"
#import "ResourceData.h"

#import "OEXConstants.h"

NS_ASSUME_NONNULL_BEGIN

@protocol OEXStorageInterface <NSObject>

// Save all table data at a time 每次保存所有表数据
- (void)saveCurrentStateToDB;

- (void)openDatabaseForUser:(NSString *)userName; //打开

#pragma mark - ResourceData Method

// Insert Resource data 插入数据资源
- (void)insertResourceDataForURL:(NSString *)url;

// Set if the resource is started 如果资源已启动，则设置
- (void)startedDownloadForResourceURL:(NSString *)url;

// Get the resource data (JSON/image,etc.) for a URL 获取URL的资源数据（JSON /图像等）
- (ResourceData *)resourceDataForURL:(NSString *)url;

// Set if the resource is completed 如果资源已完成设置
- (void)completedDownloadForResourceURL:(NSString *)url;

// Get the download state for resource 获取资源的下载状态
- (OEXDownloadState)downloadStateForResourceURL:(NSString *)url;

- (void)deleteResourceDataForURL:(NSString *)url; //删除

- (NSData *_Nullable)dataForURLString:(NSString *)url;

- (void)updateData:(NSData *)data ForURLString:(NSString *)URLString; //更新

#pragma mark - Existing methods refactored with new DB 现有的方法重构新的DB

- (NSArray *)getAllLocalVideoData; //拿到所有本地视频数据

//Add new record to Video data 向视频数据添加新记录
- (void)startedDownloadForURL:(NSString *)downloadUrl andVideoId:(NSString *)videoId;

// Get a Video data for passed videoID 通过ID得到的视频数据
- (VideoData *)videoDataForVideoID:(NSString *)video_id;

- (NSArray *)getVideosForDownloadUrl:(NSString *)downloadUrl; //通过url获取视频数据

// Get a last accesses data for passed CourseID 通过courseid得到一个最后的访问数据
- (LastAccessed *_Nullable)lastAccessedDataForCourseID:(NSString *)courseID;

// Set a last accesses data for a course. 为课程设置最后一次访问数据
- (void)setLastAccessedSubsection:(NSString *)subsectionID andSubsectionName:(NSString *)subsectionName forCourseID:(nullable NSString *)courseID OnTimeStamp:(NSString *)timestamp;

// Get Video Download state for videoID 通过ID获取视频下载状态
- (OEXDownloadState)videoStateForVideoID:(NSString *)video_id;

// Get Video Watched state for videoID 通过ID获取视频观看状态
- (OEXPlayedState)watchedStateForVideoID:(NSString *)video_id;

// Get Video last played time for videoID 通过ID获取视频最后播放时间
- (float)lastPlayedIntervalForVideoID:(NSString *)video_id;

// Set Video last played time for videoID 写入视频最后播放时间
- (void)markLastPlayedInterval:(float)playedInterval forVideoID:(NSString *)video_id;

// Set Video watched state for videoID 写入视频观看状态
- (void)markPlayedState:(OEXPlayedState)state forVideoID:(NSString *)video_id;

// Returns the data of the video to resume download.   返回视频数据以恢复下载。
- (NSData *_Nullable)resumeDataForVideoID:(NSString *)video_id;

// Set the video details & set the download state to PARTIAL for a video. 设置视频细节&将下载状态设置为视频的部分。
- (void)startedDownloadForVideo:(VideoData *)videoData;

// Set the video details & set the download state to NEW for a video. 设置视频细节&将下载状态设置为视频的新状态。
- (void)onlineEntryForVideo:(VideoData *)videoData;

// Set the video details & set the download state to DOWNLOADED for a video. 设置视频细节&将下载状态设置为视频下载
- (void)completedDownloadForVideo:(VideoData *)videoData;

// Set the download state to NEW for a video as it is cancelled from the download screen. 设置下载状态为新的视频，因为它是从下载屏幕取消。
- (void)cancelledDownloadForVideo:(VideoData *)videoData;

//Set DM_ID (task identifier) value 0 集dm_id（任务标识符）价值0
- (void)pausedAllDownloads;

// Set the download state to NEW for a video and delete the entry form the sandbox. 将下载状态设置为新的视频，并删除沙箱中的条目表单
- (void)deleteDataForVideoID:(NSString *)video_id;

// Get array of videoData entries with download state passed. 得到阵列的视频数据条目通过下载状态
- (NSArray *)getVideosForDownloadState:(OEXDownloadState)state;

// Get videoData entrie with dm_id passed. 通过与dm_id获得视频数据分
- (VideoData *)videoDataForTaskIdentifier:(NSUInteger)dTaskId;

// Get array of videoData entries with dm_id passed. 得到dm_id通过视频数据条目数组
- (NSArray *)videosForTaskIdentifier:(NSUInteger)dTaskId;

- (NSArray *)getAllDownloadingVideosForURL:(NSString *)url; //所有正在下载的视频

// Update the is_resgistered column on refresh 更新is_resgistered柱刷新
- (void)unregisterAllEntries;
- (void)setRegisteredCoursesAndDeleteUnregisteredData:(NSString *)courseid;
- (void)deleteUnregisteredItems;

- (void)createDatabaseDirectory; //创建数据库路径

- (void)activate;
- (void)deactivate;

#pragma mark - PRIVATE - POST GA DB Interface/Protocol Implementation 私有后数据库接口/协议实现

#pragma - insertion query 插入查询
// All the operations will have a "where" clause to filter data as per the logged-in User. 所有操作都有一个“where”子句，根据登录用户过滤数据。

//inserting the video data only if the video is played online or started downloading. 仅当视频在网上播放或开始下载时才插入视频数据。
- (VideoData *)insertVideoData:(NSString *)username
                        Title:(NSString *)title
                         Size:(NSString *)size
                     Duration:(NSString *)duration
                DownloadState:(OEXDownloadState)download_state
                     VideoURL:(NSString *)video_url
                      VideoID:(NSString *)video_id
                      UnitURL:(NSString *)unit_url
                     CourseID:(NSString *)enrollment_id
                         DMID:(int)dm_id
                  ChapterName:(NSString *)chapter_name
                  SectionName:(NSString *)section_name
                    TimeStamp:(nullable NSDate *)downloadCompleteDate
               LastPlayedTime:(float)last_played_offset
                       is_Reg:(BOOL)is_registered
                  PlayedState:(OEXPlayedState)played_state;

#pragma - deletion query 删除查询

//deleting the video data only if the video is deleted in online of offline mode. 只有在脱机模式下删除视频时才删除视频数据
- (void)deleteVideoData:(NSString *)username
                       :(NSString *)video_id;

#pragma - Fetch / selection query 获取/选择查询

//select the video data to show up for a user 选择要显示给用户的视频数据
- (NSArray *)getAllVideoDataFor:(NSString *)username;

- (NSArray *)getVideoDataFor:(NSString *)username
                    VideoID:(NSString *)video_id;

- (NSArray *)getVideoDataFor:(NSString *)username
               EnrollmentID:(NSString *)enrollment_id;

#pragma - update query 更新查询

- (NSArray *)getRecordsForOperation:(NSString *)username
                           VideoID:(NSString *)video_id;

// Update the video data with last played time when playing is paused 当播放暂停时，用上次播放的时间更新视频数据。
- (void)updateLastPlayedTime:(NSString *)username
                     VideoID:(NSString *)video_id
          WithLastPlayedTime:(float)last_played_offset;

// Update the video data with download state 用下载状态更新视频数据
- (void)updateDownloadState:(NSString *)username
                    VideoID:(NSString *)video_id
          WithDownloadState:(int)download_state;

// Update the video data with played state 用播放状态更新视频数据
- (void)updatePlayedState:(NSString *)username
                  VideoID:(NSString *)video_id
          WithPlayedState:(int)played_state;

// Update the video downloaded timestamp 更新视频下载的时间戳
- (void)updateDownloadTimestamp:(NSString *)username
                        VideoID:(NSString *)video_id
                  WithTimeStamp:(NSDate *)downloadCompleteDate;

// Update the course state if it is registered or no 如果注册或更新，请更新课程状态
- (void)updateCourseRegisterState:(NSString *)username
                         CourseID:(NSString *)enrollment_id
                       Withis_Reg:(BOOL)is_registered;

@end

NS_ASSUME_NONNULL_END

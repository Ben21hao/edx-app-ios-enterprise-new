//
//  EdXInterface.m
//  edXVideoLocker
//
//  Created by Nirbhay Agarwal on 22/05/14.
//  Copyright (c) 2014-2015 edX. All rights reserved.
//

@import edXCore;

#import "OEXInterface.h"

#import "edX-Swift.h"
#import "Logger+OEXObjC.h"

#import "NSArray+OEXFunctional.h"
#import "NSArray+OEXSafeAccess.h"
#import "NSJSONSerialization+OEXSafeAccess.h"
#import "NSMutableDictionary+OEXSafeAccess.h"
#import "NSNotificationCenter+OEXSafeAccess.h"

#import "OEXAnalytics.h"
#import "OEXAppDelegate.h"
#import "OEXAuthentication.h"
#import "OEXConfig.h"
#import "OEXCourse.h"
#import "OEXDataParser.h"
#import "OEXDownloadManager.h"
#import "OEXFileUtility.h"
#import "OEXHelperVideoDownload.h"
#import "OEXNetworkConstants.h"
#import "OEXSession.h"
#import "OEXStorageFactory.h"
#import "OEXUserDetails.h"
#import "OEXVideoPathEntry.h"
#import "OEXVideoSummary.h"
#import "Reachability.h"
#import "VideoData.h"

NSString* const OEXCourseListChangedNotification = @"OEXCourseListChangedNotification";
NSString* const OEXCourseListKey = @"OEXCourseListKey";

NSString* const OEXVideoStateChangedNotification = @"OEXVideoStateChangedNotification";
NSString* const OEXDownloadProgressChangedNotification = @"OEXDownloadProgressChangedNotification";
NSString* const OEXDownloadEndedNotification = @"OEXDownloadEndedNotification";
NSString* const OEXSavedAppVersionKey = @"OEXSavedAppVersionKey";

@interface OEXInterface () <OEXDownloadManagerProtocol>

@property (nonatomic, strong) OEXNetworkInterface* network;
@property (nonatomic, strong) OEXDataParser* parser;
@property(nonatomic, weak) OEXDownloadManager* downloadManger;
/// Maps String (representing course video outline) -> OEXVideoSummary array
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSArray<OEXVideoSummary*>*>* videoSummaries;

//Cached Data
@property (nonatomic, assign) int commonDownloadProgress;

@property (nonatomic, strong) NSArray<OEXHelperVideoDownload*>* multipleDownloadArray;

@property(nonatomic, strong) NSTimer* timer;

@end

static OEXInterface* _sharedInterface = nil;

@implementation OEXInterface

#pragma mark Initialization

+ (id)sharedInterface {
    if(!_sharedInterface) {
        _sharedInterface = [[OEXInterface alloc] init];
    }
    return _sharedInterface;
}

- (id)init {
    self = [super init];
    
    self.reachable = YES;//Reachability
    
    self.progressViews = [[NSMutableSet alloc] init]; //Total progress views
    self.videoSummaries = [[NSMutableDictionary alloc] init];

    [self addNotification]; //加入通知

    [self firstLaunchWifiSetting]; //wifi
    [self saveAppVersion]; //app版本
    
    return self;
}

- (void)addNotification {
    
    //Listen to download notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadCompleteNotification:) name:DL_COMPLETE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDownloadComplete:) name:OEXDownloadEndedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgressNotification:) name:DOWNLOAD_PROGRESS_NOTIFICATION object:nil];
    
    //网络变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
    
    //用户登录成功通知
    [[NSNotificationCenter defaultCenter] oex_addObserver:self notification:OEXSessionStartedNotification action:^(NSNotification *notification, OEXInterface* observer, id<OEXRemovable> removable) {
        
        NSLog(@" ----------->>>>>>> 用户登录成功通知");
        
        OEXUserDetails* user = notification.userInfo[OEXSessionStartedUserDetailsKey];
        [observer activateInterfaceForUser:user]; //重新设置默认设置
    }];
    
    //退出登录
    [[NSNotificationCenter defaultCenter] oex_addObserver:self notification:OEXSessionEndedNotification action:^(NSNotification * _Nonnull notification, id  _Nonnull observer, id<OEXRemovable>  _Nonnull removable) {
        
        [observer deactivate];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)backgroundInit { //course details
    
    /* TODO: 这里只拿到需要支付的课程  */
    self.courses = [self parsedObjectWithData:[self resourceDataForURLString:[_network URLStringForType:URL_COURSE_ENROLLMENTS] downloadIfNotAvailable:NO] forURLString:[_network URLStringForType:URL_COURSE_ENROLLMENTS]];
    
    
    for(UserCourseEnrollment* courseEnrollment in _courses) { //videos
        OEXCourse* course = courseEnrollment.course;
        
        NSString* courseVideoDetails = course.video_outline; //course subsection
        NSArray* array = [self videosOfCourseWithURLString:courseVideoDetails];
        [self setVideos:array forURL:course.video_outline];
        
        NSLog(@"backgroundInit 存入字典 %@ -------\n %@",course.video_outline,array);
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self resumePausedDownloads];
    }];
}

#pragma mark - common methods

- (OEXCourse *)courseWithID:(NSString *)courseID { //拿到对应 course_id 课程详细信息
    
    for(UserCourseEnrollment* enrollment in self.courses) {
        if([enrollment.course.course_id isEqual:courseID]) {
            return enrollment.course;
        }
    }
    return nil;
}

- (id)parsedObjectWithData:(NSData *)data forURLString:(NSString *)URLString {
    
    if(!data) {
        NSLog(@"OEXInterface --->>>> Empty data sent for parsing!");
        return nil;
    }

    if([URLString isEqualToString:[self URLStringForType:URL_USER_DETAILS]]) {
        return [self.parser userDetailsWithData:data];
        
    } else if([URLString isEqualToString:[self URLStringForType:URL_COURSE_ENROLLMENTS]]) {
        return [self.parser userCourseEnrollmentsWithData:data]; //返回我的课程数组
        
    } else if([URLString rangeOfString:URL_VIDEO_SUMMARY].location != NSNotFound) {
        return [self processVideoSummaryList:data URLString:URLString];
        
    } else if([URLString rangeOfString:URL_COURSE_ANNOUNCEMENTS].location != NSNotFound) {
        return [self.parser announcementsWithData:data];
        
    } else if([URLString rangeOfString:URL_COURSE_HANDOUTS].location != NSNotFound) {
        return [self.parser handoutsWithData:data];
    }

    return nil;
}

- (NSString *)URLStringForType:(NSString *)type {
    
    NSMutableString* URLString = [NSMutableString stringWithString:[OEXConfig sharedConfig].apiHostURL.absoluteString];

    if([type isEqualToString:URL_USER_DETAILS]) {
        [URLString appendFormat:@"%@/%@", URL_USER_DETAILS, [OEXSession sharedSession].currentUser.username];
        
    } else if([type isEqualToString:URL_COURSE_ENROLLMENTS]) {
        [URLString appendFormat:@"%@/%@%@", URL_USER_DETAILS, [OEXSession sharedSession].currentUser.username, URL_COURSE_ENROLLMENTS];
        
    } else {
        return nil;
    }
    //Append tail
    [URLString appendString:@"?format=json"];

    return URLString;
}

+ (BOOL)isURLForVideo:(NSString *)URLString {
    
    //    https://d2f1egay8yehza.cloudfront.net/mit-6002x/MIT6002XT214-V043800_MB2.mp4
    if([URLString rangeOfString:URL_SUBSTRING_VIDEOS].location != NSNotFound) {
        return YES;
        
    } else if([URLString rangeOfString:URL_EXTENSION_VIDEOS].location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (BOOL)isURLForedXDomain:(NSString *)URLString {
    if([URLString rangeOfString:[OEXConfig sharedConfig].apiHostURL.absoluteString].location != NSNotFound) { //NSNotFound 判断是否含有 eliteu 的域名
        return YES;
    }
    return NO;
}

+ (BOOL)isURLForImage:(NSString *)URLString {
    if([URLString rangeOfString:URL_SUBSTRING_ASSETS].location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (BOOL)isURLForVideoOutline:(NSString *)URLString {
    if([URLString rangeOfString:URL_VIDEO_SUMMARY].location != NSNotFound) {
        return YES;
    }
    return NO;
}

- (void)createDatabaseDirectory {
    [_storage createDatabaseDirectory];
}

#pragma mark - Wifi Only

- (void)firstLaunchWifiSetting {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if(![userDefaults objectForKey:USERDEFAULT_KEY_WIFIONLY]) {
        [userDefaults setBool:YES forKey:USERDEFAULT_KEY_WIFIONLY];
    }
}

+ (BOOL)shouldDownloadOnlyOnWifi {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL should = [userDefaults boolForKey:USERDEFAULT_KEY_WIFIONLY];
    return should;
}

- (BOOL)shouldDownloadOnlyOnWifi {
    return [[self class] shouldDownloadOnlyOnWifi];
}

+ (void)setDownloadOnlyOnWifiPref:(BOOL)should {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:should forKey:USERDEFAULT_KEY_WIFIONLY];
    [userDefaults synchronize];
}

#pragma mark - public methods
- (void)setNumberOfRecentDownloads:(int)numberOfRecentDownloads {
    
    _numberOfRecentDownloads = numberOfRecentDownloads;
    if([OEXSession sharedSession].currentUser.username) {
        NSString* key = [NSString stringWithFormat:@"%@_numberOfRecentDownloads", [OEXSession sharedSession].currentUser.username];
        [[NSUserDefaults standardUserDefaults] setInteger:_numberOfRecentDownloads forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Persist the CC selected Language

+ (void)setCCSelectedLanguage:(NSString *)language {
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:PERSIST_CC];
}

+ (NSString *)getCCSelectedLanguage {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PERSIST_CC];
}

#pragma mark - Persist the CC selected Video Speed

+ (void)setCCSelectedPlaybackSpeed:(OEXVideoSpeed) speed {
    [[NSUserDefaults standardUserDefaults] setInteger:speed forKey:PERSIST_PLAYBACKSPEED];
}

+ (OEXVideoSpeed)getCCSelectedPlaybackSpeed {
    return [[NSUserDefaults standardUserDefaults] integerForKey:PERSIST_PLAYBACKSPEED];
}

+ (float) getOEXVideoSpeed:(OEXVideoSpeed) speed {
    switch (speed) {
        case OEXVideoSpeedDefault:
            return 1.0;
            break;
        case OEXVideoSpeedSlow:
            return 0.5;
        case OEXVideoSpeedFast:
            return 1.5;
        case OEXVideoSpeedXFast:
            return 2.0;
        default:
            return 1.0;
            break;
    }
}

#pragma mark - common Network Calls

- (void)startAllBackgroundDownloads {
   
    if(_commonDownloadProgress == -1) {  //If entering common download mode
        self.commonDownloadProgress = 0;
    }
    [self downloadNextItem];
}

- (void)downloadNextItem {
    switch(_commonDownloadProgress) {
        case 0:
            [self downloadWithRequestString:URL_USER_DETAILS forceUpdate:YES];
            break;
        case 1:
            [self downloadWithRequestString:URL_COURSE_ENROLLMENTS forceUpdate:YES];
            break;
        default:
            _commonDownloadProgress = -1;
            break;
    }
}

#pragma mark - Public

- (void)requestWithRequestString:(NSString*)URLString {
    //Network Request
    [_network callRequestString:URLString];
}

// This method Start Downloads for resources 开始下载资源
- (BOOL)downloadWithRequestString:(NSString*)URLString forceUpdate:(BOOL)update {
    
    if(!_reachable || [OEXInterface isURLForVideo:URLString]) {
        return NO;
    }

    if([URLString isEqualToString:URL_USER_DETAILS]) {
        URLString = [_network URLStringForType:URL_USER_DETAILS];
        
    } else if([URLString isEqualToString:URL_COURSE_ENROLLMENTS]) {
        URLString = [_network URLStringForType:URL_COURSE_ENROLLMENTS];
        
    } else if([URLString rangeOfString:URL_VIDEO_SRT_FILE].location != NSNotFound) {      // For Closed Captioning
        [_network downloadWithURLString:URLString];
        
    } else if([OEXInterface isURLForImage:URLString]) {
        return NO;
    }

    NSString* filePath = [OEXFileUtility filePathForRequestKey:URLString];

    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [_network downloadWithURLString:URLString];
        
    } else {
        if(update) {
            [_network downloadWithURLString:URLString]; //Network Request
            
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_URL_RESPONSE object:self
                                                              userInfo:@{NOTIFICATION_KEY_URL: URLString,
                                                                         NOTIFICATION_KEY_STATUS: NOTIFICATION_VALUE_URL_STATUS_SUCCESS,
                                                                         NOTIFICATION_KEY_OFFLINE: NOTIFICATION_VALUE_OFFLINE_NO, }];
        }
    }
    return YES;
}

- (BOOL)canDownloadVideos:(NSArray *)videos  type:(NSInteger)type {
    
    double totalSpaceRequired = 0;
    //Total space
    for(OEXHelperVideoDownload* video in videos) {
        totalSpaceRequired += [video.summary.size doubleValue];
    }
    totalSpaceRequired = totalSpaceRequired / 1024 / 1024 / 1024;
    
    OEXAppDelegate* appD = (OEXAppDelegate *)[[UIApplication sharedApplication] delegate];
    if([OEXInterface shouldDownloadOnlyOnWifi]) {
        if(![appD.reachability isReachableViaWiFi]) {
            return NO;
        }
    }
    
    if (type == 1) {
        return YES;
    }
    
    if(totalSpaceRequired > 1) {
        self.multipleDownloadArray = videos;
        
        // As suggested by Lou
        UIAlertView* alertView =
            [[UIAlertView alloc] initWithTitle:TDLocalizeSelect(@"LARGE_DOWNLOAD_TITLE", nil)
                                       message:TDLocalizeSelect(@"LARGE_DOWNLOAD_MESSAGE", nil)
                                      delegate:self
                             cancelButtonTitle:TDLocalizeSelect(@"CANCEL", nil)
                             otherButtonTitles:TDLocalizeSelect(@"ACCEPT_LARGE_VIDEO_DOWNLOAD", nil), nil];
        
        [alertView show];
        return NO;
    }
    return YES;
}

- (NSInteger)downloadVideos:(NSArray<OEXHelperVideoDownload*>*)array type:(NSInteger)type {
    BOOL isValid = [self canDownloadVideos:array type:type];
    
    if(!isValid) {
        return 0;
    }
    
    NSInteger count = 0;
    for(OEXHelperVideoDownload* video in array) {
        if(video.summary.videoURL.length > 0 && video.downloadState == OEXDownloadStateNew) {
            [self downloadAllTranscriptsForVideo:video];
            [self addVideoForDownload:video completionHandler:^(BOOL success){}];
            count++;
        }
    }
    return count;
}

- (NSArray<OEXHelperVideoDownload*>*)statesForVideosWithIDs:(NSArray<NSString*>*)videoIDs courseID:(NSString*)courseID {
    NSMutableDictionary* videos = [[NSMutableDictionary alloc] init];
    OEXCourse* course = [self courseWithID:courseID];
    
    for(OEXHelperVideoDownload* video in [self.courseVideos objectForKey:course.video_outline]) {
        [videos safeSetObject:video forKey:video.summary.videoID];
    }
    return [videoIDs oex_map:^id(NSString* videoID) {
        return [videos objectForKey:videoID];
    }];
}

- (NSInteger)downloadVideosWithIDs:(NSArray*)videoIDs courseID:(NSString*)courseID {
    NSArray* videos = [self statesForVideosWithIDs:videoIDs courseID:courseID];
    return [self downloadVideos:videos type:0];
}

- (NSData *)resourceDataForURLString:(NSString *)URLString downloadIfNotAvailable:(BOOL)shouldDownload {
    
    NSData* data = [_storage dataForURLString:URLString];
    
    if(!data && shouldDownload) { //If data is not downloaded, start download
        [self downloadWithRequestString:URLString forceUpdate:NO];
    }
    return data;
}

- (float)lastPlayedIntervalForURL:(NSString*)URLString {
    return 0;
}

- (float)lastPlayedIntervalForVideoID:(NSString*)videoID {
    return [_storage lastPlayedIntervalForVideoID:videoID];
}

- (void)markLastPlayedInterval:(float)playedInterval forVideoID:(NSString *)videoId {
    if(playedInterval <= 0) {
        return;
    }
    [_storage markLastPlayedInterval:playedInterval forVideoID:videoId];
}

- (void)deleteDownloadedVideoForVideoId:(NSString*)videoId completionHandler:(void (^)(BOOL success))completionHandler {
    [_storage deleteDataForVideoID:videoId];
    completionHandler(YES);
}

- (void)setAllEntriesUnregister {
    [_storage unregisterAllEntries];
}

- (void)setRegisteredCourses:(NSArray*)courses {
    NSMutableSet* courseIDs = [[NSMutableSet alloc] init];
    for(OEXCourse* course in courses) {
        if(course.course_id != nil) {
            [courseIDs addObject:course.course_id];
        }
    }
    
    NSArray* videos = [self.storage getAllLocalVideoData];
    for(VideoData* video in videos) {
        if([courseIDs containsObject:video.enrollment_id]) {
            video.is_registered = [NSNumber numberWithBool:YES];
        }
    }
    [self.storage saveCurrentStateToDB];

    NSDictionary* userInfo = @{
                               OEXCourseListKey : [NSArray arrayWithArray:courses]
                               };
    [[NSNotificationCenter defaultCenter] postNotificationName:OEXCourseListChangedNotification object:nil userInfo:userInfo];
}

- (void)deleteUnregisteredItems {
    [_storage deleteUnregisteredItems];
}

- (VideoData*)insertVideoData:(OEXHelperVideoDownload*)helperVideo {
    return [_storage insertVideoData: @""
                               Title: helperVideo.summary.name
                                Size: [NSString stringWithFormat:@"%.2f", [helperVideo.summary.size doubleValue]]
                            Duration: [NSString stringWithFormat:@"%@", helperVideo.summary.duration]
                       DownloadState: helperVideo.downloadState
                            VideoURL: helperVideo.summary.videoURL
                             VideoID: helperVideo.summary.videoID
                             UnitURL: helperVideo.summary.unitURL
                            CourseID: helperVideo.course_id
                                DMID: 0
                         ChapterName: helperVideo.summary.chapterPathEntry.name
                         SectionName: helperVideo.summary.sectionPathEntry.name
                           TimeStamp: nil
                      LastPlayedTime: helperVideo.lastPlayedInterval
                              is_Reg: YES
                         PlayedState: helperVideo.watchedState];
}

#pragma mark Last Accessed

- (OEXHelperVideoDownload*)lastAccessedSubsectionForCourseID:(NSString*)courseID {
    LastAccessed* lastAccessed = [_storage lastAccessedDataForCourseID:courseID];

    if(lastAccessed.course_id) {
        for(UserCourseEnrollment* courseEnrollment in _courses) {
            OEXCourse* course = courseEnrollment.course;

            if([courseID isEqualToString:course.course_id]) {
                for(OEXHelperVideoDownload* video in [self.courseVideos objectForKey : course.video_outline]) {
                    OEXLogInfo(@"LAST ACCESSED", @"video.subSectionID : %@", video.summary.sectionPathEntry.entryID);
                    OEXLogInfo(@"LAST ACCESSED", @"lastAccessed.subsection_id : %@ \n *********************\n", lastAccessed.subsection_id);

                    if([video.summary.sectionPathEntry.entryID isEqualToString:lastAccessed.subsection_id]) {
                        return video;
                    }
                }
            }
        }
    }

    return nil;
}

#pragma mark Update Storage

- (void)updateWithData:(NSData*)data forRequestString:(NSString*)URLString {
    [_storage updateData:data ForURLString:URLString];
}

#pragma mark - EdxNetworkInterface Delegate

- (void)updateTotalProgress {
    
    NSArray* array = [self allVideosForState:OEXDownloadStatePartial];
    float total = 0;
    float done = 0;
    for(OEXHelperVideoDownload* video in array) {
        total += OEXMaxDownloadProgress;
        done += video.downloadProgress;
    }

    BOOL viewHidden = YES;

    if(total > 0) {
        self.totalProgress = (float)done / (float)total;
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            [[NSNotificationCenter defaultCenter] postNotificationName:OEXDownloadProgressChangedNotification object:nil];
        }
        viewHidden = NO;//show circular views
        
    } else {
        viewHidden = YES;
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive && self.totalProgress != 0) {
            self.totalProgress = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:OEXDownloadEndedNotification object:nil];
        }
    }

    if(!_reachable && !viewHidden) {
        viewHidden = YES;
    }

    for(UIView* view in _progressViews) {
        view.hidden = viewHidden;
    }
}

#pragma mark - notification methods

- (void)downloadCompleteNotification:(NSNotification*)notification { //课件数据下载结束
    NSDictionary* dict = notification.userInfo;

    NSURLSessionTask* task = [dict objectForKey:DL_COMPLETE_N_TASK];
    NSURL* url = task.originalRequest.URL;

    NSData* data = [self resourceDataForURLString:url.absoluteString downloadIfNotAvailable:NO];
    
    NSLog(@"下载结束通知 ---------->>> %@",url);
    
    [self returnedData:data forType:url.absoluteString];
}

- (void)videoDownloadComplete:(NSNotification*)notification { //视频下载结束
    NSDictionary* dict = notification.userInfo;
    NSURLSessionTask* task = [dict objectForKey:OEXDownloadEndedNotification];
    NSURL* url = task.originalRequest.URL;
    if([OEXInterface isURLForVideo:url.absoluteString]) {
        self.numberOfRecentDownloads++;
        [self markDownloadProgress:OEXMaxDownloadProgress forURL:url.absoluteString andVideoId:nil];
    }
}

- (void)downloadProgressNotification:(NSNotification*)notification {
    NSDictionary* dictProgress = (NSDictionary*)notification.userInfo;

    NSURLSessionTask* task = [dictProgress objectForKey:DOWNLOAD_PROGRESS_NOTIFICATION_TASK];
    NSString* url = [task.originalRequest.URL absoluteString]; //完整url
    double totalBytesWritten = [[dictProgress objectForKey:DOWNLOAD_PROGRESS_NOTIFICATION_TOTAL_BYTES_WRITTEN] doubleValue];
    double totalBytesExpectedToWrite = [[dictProgress objectForKey:DOWNLOAD_PROGRESS_NOTIFICATION_TOTAL_BYTES_TO_WRITE] doubleValue];

    double completed = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    float completedPercent = completed * OEXMaxDownloadProgress;

    [self markDownloadProgress:completedPercent forURL:url andVideoId:nil];
}

- (void)reachabilityDidChange:(NSNotification*)notification {
    id <Reachability> reachability = [notification object];

    if([reachability isReachable]) {
        self.reachable = YES;

        // TODO: Resume downloads on network availability
        // [self resumePausedDownloads];
    } else {
        self.reachable = NO;
    }

    [self.progressViews makeObjectsPerformSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:!self.reachable]];
    
    [self updateTotalProgress]; //网络发生变化，就立即处理
}

#pragma mark - NetworkInterface Delegate
- (void)returnedData:(NSData*)data forType:(NSString*)URLString {
    
    [self updateWithData:data forRequestString:URLString]; //Update Storage 更新缓存
    
    [self processData:data forType:URLString usingOfflineCache:NO]; //Parse and return 解析并返回
}

- (void)returnedFailureForType:(NSString*)URLString {
    
    if([OEXInterface isURLForVideo:URLString]) { //VIDEO URL
        
    } else {
        NSData* data = [_storage dataForURLString:URLString]; //look for cached response 寻找缓存响应
        
        if(data) {
            [self processData:data forType:URLString usingOfflineCache:YES];
            
        } else {
            //Post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_URL_RESPONSE object:self userInfo:@{NOTIFICATION_KEY_URL: URLString, NOTIFICATION_KEY_STATUS: NOTIFICATION_VALUE_URL_STATUS_FAILED}];
        }
    }
}

- (void)didAddDownloadForURLString:(NSString*)URLString {
}

- (void)didRejectDownloadForURLString:(NSString*)URLString {
}

#pragma mark Video management
- (void)markDownloadProgress:(float)progress forURL:(NSString*)URLString andVideoId:(NSString*)videoId {
    for(OEXHelperVideoDownload* video in [self allVideos]) {
        if(([video.summary.videoURL isEqualToString:URLString] && video.downloadState == OEXDownloadStatePartial)
           || [video.summary.videoID isEqualToString:videoId]) {
            video.downloadProgress = progress;
            video.isVideoDownloading = YES;
            if(progress == OEXMaxDownloadProgress) {
                video.downloadState = OEXDownloadStateComplete;
                video.isVideoDownloading = NO;
                video.completedDate = [NSDate date];
            }
            else if(progress > 0) {
                video.downloadState = OEXDownloadStatePartial;
            }
            else {
                video.downloadState = OEXDownloadStateNew;
                video.isVideoDownloading = NO;
            }
        }
    }
}

#pragma mark - Video liast manangement

- (void)processData:(NSData *)data forType:(NSString *)URLString usingOfflineCache:(BOOL)offline {
    
    if([OEXInterface isURLForVideo:URLString]) {//Check if data type needs parsing
        return;
        
    } else if([OEXInterface isURLForImage:URLString]) {
        
    } else {
        
        id object = [self parsedObjectWithData:data forURLString:URLString]; //Get object
        if(!object) {
            return;
            
        } else if([URLString isEqualToString:[self URLStringForType:URL_COURSE_ENROLLMENTS]]) { //download any additional data if required
            
//            self.courses = (NSArray *)object; //object数组里面的课程比已加入的课程数组数量少 --- 有免费课程的时候
            for(UserCourseEnrollment* courseEnrollment in _courses) {
                OEXCourse* course = courseEnrollment.course;

                //course enrolments, get images for background
                NSString* courseImage = course.courseImageURL;
                NSString* imageDownloadURL = [NSString stringWithFormat:@"%@%@", [OEXConfig sharedConfig].apiHostURL, courseImage];

                BOOL force = NO;
                if(_commonDownloadProgress != -1) {
                    force = YES;
                }

                [self downloadWithRequestString:imageDownloadURL forceUpdate:force];

                //course subsection
                NSString* courseVideoDetails = course.video_outline;
                [self downloadWithRequestString:courseVideoDetails forceUpdate:force];
            }
            
        } else if([OEXInterface isURLForVideoOutline:URLString]) {  //video outlines populate videos
            NSArray* array = [self videosOfCourseWithURLString:URLString];
            [self setVideos:array forURL:URLString];
            
            NSLog(@"processData 存入字典 %@ -------\n %@",URLString,array);
        }

        //If not using common download mode
        if(_commonDownloadProgress == -1) {
            //Delegate call back
        } else {
            _commonDownloadProgress++;
            [self downloadNextItem];
        }
    }

    //Post notification
    NSString* offlineValue = NOTIFICATION_VALUE_OFFLINE_NO;
    if(offline) {
        offlineValue = NOTIFICATION_VALUE_OFFLINE_YES;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_URL_RESPONSE
                                                        object:self
                                                      userInfo:@{NOTIFICATION_KEY_URL: URLString,
                                                                 NOTIFICATION_KEY_STATUS: NOTIFICATION_VALUE_URL_STATUS_SUCCESS,
                                                                 NOTIFICATION_KEY_OFFLINE: offlineValue, }];
}

- (void)makeRecordsForVideos:(NSArray *)videos inCourse:(OEXCourse *)course {
    
    NSMutableDictionary* dictVideoData = [[NSMutableDictionary alloc] init];
    // Added for debugging
    int partiallyDownloaded = 0;
    int newVideos = 0;
    int downloadCompleted = 0;
    
    NSArray* array = [_storage getAllLocalVideoData];//拿到本地数据库所有的视频数据
    for(VideoData* videoData in array) {
        if(videoData.video_id) {
            [dictVideoData setObject:videoData forKey:videoData.video_id];
        }
    }
    
    //Check in DB 在数据库中循环
    for(OEXHelperVideoDownload* video in videos) {
        
        VideoData* data = [dictVideoData objectForKey:video.summary.videoID]; //对应ID的视频数据
        
        OEXDownloadState downloadState = [data.download_state intValue];
        
        video.course_id = course.course_id;
        video.course_url = course.video_outline;
        
        if(!data) { //该视频在本地没有数据
            downloadState = OEXDownloadStateNew; //视频的下载状态
            video.watchedState = OEXPlayedStateUnwatched;
            video.lastPlayedInterval = 0;
            
        } else {
            video.watchedState = [data.played_state intValue]; //视频的观看状态
            video.lastPlayedInterval = [data.last_played_offset integerValue];
        }
        
        switch(downloadState) {
            case OEXDownloadStateNew:
                video.isVideoDownloading = NO;
                newVideos++;
                break;
            case OEXDownloadStatePartial:
                video.isVideoDownloading = YES;
                video.downloadProgress = 1.0;
                partiallyDownloaded++;
                break;
            default:
                video.isVideoDownloading = NO;
                video.downloadProgress = OEXMaxDownloadProgress;
                video.completedDate = data.downloadCompleteDate;
                downloadCompleted++;
                break;
        }
        video.downloadState = downloadState;
    }

}

- (void)addVideos:(NSArray *)videos forCourseWithID:(NSString *)courseID {
    
    NSMutableSet* knownVideoIDs = [[NSMutableSet alloc] init];
    NSMutableDictionary* videosMap = [[NSMutableDictionary alloc] init];
    
    OEXCourse* course = [self courseWithID:courseID];
    NSMutableArray* videoDatas = [[self.courseVideos objectForKey:course.video_outline] mutableCopy];
    
    if(videoDatas == nil) { //数组为空 we don't have any videos for this course yet ；so set it up
        
        videoDatas = [[NSMutableArray alloc] init];
        [self.courseVideos safeSetObject:videoDatas forKey:course.video_outline];
        
    } else { // we do have videos, so collect their IDs so we only add new ones
        
        for(OEXHelperVideoDownload* download in videoDatas) {
            
            [knownVideoIDs addObject:download.summary.videoID];
            [videosMap safeSetObject:download forKey:download.summary.videoID];
        }
    }
    
    NSArray* videoHelpers = [videos oex_map:^id(OEXVideoSummary* summary) {
        
        if(![knownVideoIDs containsObject:summary.videoID]) {
            
            OEXHelperVideoDownload* helper = [[OEXHelperVideoDownload alloc] init];
            helper.summary = summary;
            helper.filePath = [OEXFileUtility filePathForRequestKey:summary.videoURL];
            [videoDatas addObject:helper];
            
            NSLog(@"2 - 遍历 ----->>>  %@",summary.size);
            
            return helper;
            
        } else {
//            OEXHelperVideoDownload* helper = [videosMap objectForKey:summary.videoID];
//            // Hack
//            // Duration doesn't always come through the old API for some reason, so make here we make sure
//            // it's set from the new content.
//            // But we don't actually need to make a record for it so don't return it
//            // TODO: Short term: Update the video summary in the new API to get all its properties from block
//            // TODO: Long term: Get the video module to take a block as its input
//            helper.summary.duration = summary.duration;
//            helper.summary.encodings = summary.encodings;
            
            return nil;
        }
    }];
    
    NSLog(@"addVideos 存入字典 %@ -------\n %@",course.video_outline,videoDatas);
    
    [self.courseVideos safeSetObject:videoDatas forKey:course.video_outline];
    
    [self makeRecordsForVideos:videoHelpers inCourse:course];
}

- (void)setVideos:(NSArray *)videos forURL:(NSString *)URLString {
    
    [self.courseVideos safeSetObject:videos forKey:URLString]; //以 URLString 为 key，将视频数组存入字典中
    
    OEXCourse* course = nil;
    
    for(UserCourseEnrollment* courseEnroll in self.courses) {
        OEXCourse* currentCourse = courseEnroll.course;
        
        if([currentCourse.video_outline isEqualToString:URLString]) { //我的课程数组中存在
            course = currentCourse;
            break;
        }
    }
    
    [self makeRecordsForVideos:videos inCourse:course];
}

- (NSMutableArray *)videosForChapterID:(NSString *)chapter sectionID:(NSString *)section URL:(NSString *)URLString {
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for(OEXHelperVideoDownload* video in [self.courseVideos objectForKey:URLString]) {
        
        if([video.summary.chapterPathEntry.entryID isEqualToString:chapter]) {
            if(section) {
                if([video.summary.sectionPathEntry.entryID isEqualToString:section]) {
                    [array addObject:video];
                }
                
            } else {
                [array addObject:video];
            }
        }
    }
    return array;
}

- (NSMutableArray *)coursesAndVideosForDownloadState:(OEXDownloadState)state { //获取对应下载状态的视频
    
    NSMutableArray* mainArray = [[NSMutableArray alloc] init];

    for(UserCourseEnrollment* courseEnrollment in _courses) {
        
        OEXCourse* course = courseEnrollment.course;
        
        NSMutableArray* videosArray = [[NSMutableArray alloc] init];  //Videos array

        for(OEXHelperVideoDownload* video in [self.courseVideos objectForKey : course.video_outline]) {
            
            if(video.downloadState == OEXDownloadStateComplete && state == OEXDownloadStateComplete) { //Complete 已下载
                [videosArray addObject:video];
                
            } else if(video.downloadState == OEXDownloadStatePartial && video.downloadProgress < OEXMaxDownloadProgress && state == OEXDownloadStatePartial) { //Partial 下载中
                [videosArray addObject:video];
                
            } else if(video.downloadState == OEXDownloadStateNew && OEXDownloadStateNew) {
                //                [videosArray addObject:video];
            }
        }

        NSLog(@"取出下载已字典 %@ -------\n %@ ",course.video_outline,self.courseVideos);
        NSLog(@"已下载视频 ------------ %@ ",videosArray);
        
        if(videosArray.count > 0) {
            NSDictionary* dict = @{CAV_KEY_COURSE:course,
                                   CAV_KEY_VIDEOS:videosArray};
            [mainArray addObject:dict];
        }
    }
    return mainArray;
}

- (NSArray *)allVideos {
    
    NSMutableArray* mainArray = [[NSMutableArray alloc] init];

    for(UserCourseEnrollment* courseEnrollment in _courses) {
        OEXCourse* course = courseEnrollment.course;

        for(OEXHelperVideoDownload* video in [self.courseVideos objectForKey:course.video_outline]) {
            [mainArray addObject:video];
        }
    }
    return mainArray;
}

- (OEXHelperVideoDownload *)getSubsectionNameForSubsectionID:(NSString *)subsectionID {
    
    for(UserCourseEnrollment* courseEnrollment in _courses) {
        OEXCourse* course = courseEnrollment.course;

        for(OEXHelperVideoDownload* video in [self.courseVideos objectForKey:course.video_outline]) {
            if([video.summary.sectionPathEntry.entryID isEqualToString:subsectionID]) {
                return video;
            }
        }
    }

    return nil;
}

- (NSArray *)allVideosForState:(OEXDownloadState)state { //获取特定下载状态的视频
    
    NSMutableArray* mainArray = [[NSMutableArray alloc] init];

    for(UserCourseEnrollment* courseEnrollment in _courses) {
        OEXCourse* course = courseEnrollment.course;

        for(OEXHelperVideoDownload* video in [self.courseVideos objectForKey : course.video_outline]) {
            
            if((video.downloadProgress == OEXMaxDownloadProgress) && (state == OEXDownloadStateComplete)) {//Complete
                [mainArray addObject:video];
                
            } else if((video.isVideoDownloading && (video.downloadProgress < OEXMaxDownloadProgress)) && (state == OEXDownloadStatePartial)) {//Partial
                [mainArray addObject:video];
                
            } else if(!video.isVideoDownloading && (state == OEXDownloadStateNew)) {
                [mainArray addObject:video];
            }
        }
    }

    return mainArray;
}
- (NSArray *)sectionsForChapterID:(NSString *)chapterID URLString:(NSString *)URL { // To get the sections for the given chapter name 为给定的章名得到部分
    
    NSMutableArray* sectionEntries = [[NSMutableArray alloc] init];

    for(OEXVideoSummary* objVideo in [self.videoSummaries objectForKey:URL]) {
        
        OEXVideoPathEntry* chapterEntry = objVideo.chapterPathEntry;
        if([chapterEntry.entryID isEqualToString:chapterID]) {
            
            OEXVideoPathEntry* sectionEntry = objVideo.sectionPathEntry;
            if(![sectionEntries containsObject:sectionEntry]) {
                [sectionEntries addObject: sectionEntry];
            }
        }
    }

    return sectionEntries;
}

- (NSDictionary *)processVideoSummaryList:(NSData *)data URLString:(NSString *)URLString { //为videoSummaries重新赋值
    
    [self.videoSummaries removeObjectForKey:URLString];
    
    NSArray* summaries = [self.parser videoSummaryListWithData:data]; //将data转换为数组
    [self.videoSummaries setObject:summaries forKey:URLString];
    return self.videoSummaries;
}

- (NSArray *)videosOfCourseWithURLString:(NSString *)URL { // Get the data from the URL 从URL中获取视频数据
    
    NSData* data = [self resourceDataForURLString:URL downloadIfNotAvailable:NO];
    if(data) {
        [self processVideoSummaryList:data URLString:URL];
        
    } else {
        [self downloadWithRequestString:URL forceUpdate:YES];
    }

    // Return this array of course video objects. 返回这个视频对象数组
    NSMutableArray* arr_Videos = [[NSMutableArray alloc] init];

    for(OEXVideoSummary* objVideo in [self.videoSummaries objectForKey: URL]) {
        
        OEXHelperVideoDownload* obj_helperVideo = [[OEXHelperVideoDownload alloc] init];
        obj_helperVideo.summary = objVideo;
        obj_helperVideo.filePath = [OEXFileUtility filePathForRequestKey:obj_helperVideo.summary.videoURL];

        [arr_Videos addObject:obj_helperVideo];
    }

    return arr_Videos;
}

- (NSString *)openInBrowserLinkForCourse:(OEXCourse *)course {
    
    NSString* str_link = [[NSString alloc] init];
    for(OEXVideoSummary* objVideo in [self.videoSummaries objectForKey:course.video_outline]) {
        str_link = objVideo.sectionURL;
    }

    return str_link;
}

- (NSArray *)chaptersForURLString:(NSString*)URL { // To get all the chapter data 获取所有章节数据
    
    NSMutableArray* chapterEntries = [[NSMutableArray alloc] init];

    for(OEXVideoSummary* objVideo in [self.videoSummaries objectForKey:URL]) {
        OEXVideoPathEntry* chapterPathEntry = objVideo.chapterPathEntry;
        
        if(![chapterEntries containsObject:chapterPathEntry]) {
            [chapterEntries oex_safeAddObject: chapterPathEntry];
        }
    }
    return chapterEntries;
}

#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 1) {
        NSInteger count = [self downloadVideos:_multipleDownloadArray type:1];
        if(count > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FL_MESSAGE object:self
                                                              userInfo:@{FL_ARRAY: _multipleDownloadArray}];
        }
    } else {
        self.multipleDownloadArray = nil;
    }
}

#pragma mark - Bulk Download
- (float)showBulkProgressViewForCourse:(OEXCourse*)course chapterID:(NSString*)chapterID sectionID:(NSString*)sectionID { //没地方用到
    
    NSMutableArray* arr_Videos = [self videosForChapterID:chapterID sectionID:sectionID URL:course.video_outline];

    float total = 0;
    float done = 0;
    float totalProgress = -1;
    NSInteger count = 0;

    for(OEXHelperVideoDownload* objvideo in arr_Videos) {
        
        if(objvideo.downloadState == OEXDownloadStateNew) {
            return -1;
            
        } else if(objvideo.downloadState == OEXDownloadStatePartial) {
            total += OEXMaxDownloadProgress;
            done += objvideo.downloadProgress;
            totalProgress = (float)done / (float)total;
            
        } else {
            count++;
            if(count == [arr_Videos count]) {
                return -1;
            }
        }
    }
    return totalProgress;
}

#pragma mark - Closed Captioning
- (void)downloadAllTranscriptsForVideo:(OEXHelperVideoDownload *)videoDownloadHelper { //Download All Transcripts 所有文本/下载
    
    [[videoDownloadHelper.summary transcripts] enumerateKeysAndObjectsUsingBlock:^(NSString* language, NSString* url, BOOL *stop) {
        NSData* data = [self resourceDataForURLString:url downloadIfNotAvailable:NO];
        if (!data) {
            [self downloadWithRequestString:url forceUpdate:YES];
        }
    }];
}

#pragma mark - Download Video

- (void)startDownloadForVideo:(OEXHelperVideoDownload *)video completionHandler:(void (^)(BOOL sucess))completionHandler {
    
    OEXAppDelegate* appD = (OEXAppDelegate *)[[UIApplication sharedApplication] delegate];
    if([OEXInterface isURLForVideo:video.summary.videoURL]) {
        if([OEXInterface shouldDownloadOnlyOnWifi]) {
            if(![appD.reachability isReachableViaWiFi]) {
                completionHandler(NO);
                return;
            }
        }
    }
    [self addVideoForDownload:video completionHandler:completionHandler];
}

//将视频加入下载
- (void)addVideoForDownload:(OEXHelperVideoDownload *)video completionHandler:(void (^)(BOOL sucess))completionHandler {
    
    __block VideoData* data = [_storage videoDataForVideoID:video.summary.videoID];
    if(!data || !data.video_url) {
        data = [self insertVideoData:video];
    }

    NSArray* array = [_storage getVideosForDownloadUrl:video.summary.videoURL];
    if([array count] > 1) {
        
        for(VideoData* videoObj in array) {
            if([videoObj.download_state intValue] == OEXDownloadStateComplete) {
                
                [_storage completedDownloadForVideo:data];
                video.downloadProgress = OEXMaxDownloadProgress;
                video.isVideoDownloading = NO;
                video.downloadState = OEXDownloadStateComplete;
                completionHandler(YES);
                return;
            }
        }
    }

    if(data) {
        [[OEXDownloadManager sharedManager] downloadVideoForObject:data withCompletionHandler:^(NSURLSessionDownloadTask* downloadTask) {
            if(downloadTask) {
                video.downloadState = OEXDownloadStatePartial;
                video.downloadProgress = 0.1;
                video.isVideoDownloading = YES;
                completionHandler(YES);
                
            } else {
                completionHandler(NO);
            }
        }];
    }
}

// Cancel Video download 取消视频下载
- (void)cancelDownloadForVideo:(OEXHelperVideoDownload *)video completionHandler:(void (^) (BOOL))completionHandler {
    
    VideoData* data = [_storage videoDataForVideoID:video.summary.videoID];

    if(data) {
        [[OEXDownloadManager sharedManager] cancelDownloadForVideo:data completionHandler:^(BOOL success) {
            video.downloadState = OEXDownloadStateNew;
            video.downloadProgress = 0;
            video.isVideoDownloading = NO;
            completionHandler(success);
        }];
    } else {
        video.isVideoDownloading = NO;
        video.downloadProgress = 0;
        video.downloadState = OEXDownloadStateNew;
    }
}

- (void)resumePausedDownloads {
    [_downloadManger resumePausedDownloads];
}

#pragma mark Video Management

- (OEXHelperVideoDownload *)stateForVideoWithID:(NSString *)videoID courseID:(NSString *)courseID {
    // This being O(n) is pretty mediocre
    // We should rebuild this to have all the videos in a hash table
    // Right now they actually need to be in an array since that is
    // how we decide their order in the UI.
    // But once we switch to the new course structure endpoint, that will no longer be the case
    
    OEXCourse* course = [self courseWithID:courseID];
    for(OEXHelperVideoDownload* video in [self.courseVideos objectForKey:course.video_outline]) { //通过 video_outline 拿到对应的视频
        if([video.summary.videoID isEqual:videoID]) {
            return video;
        }
    }
    return nil;
}

- (OEXDownloadState)downloadStateForVideoWithID:(NSString *)videoID {
    return [self.storage videoStateForVideoID:videoID];
}

- (OEXPlayedState)watchedStateForVideoWithID:(NSString *)videoID {
    return [self.storage watchedStateForVideoID:videoID];
}

- (float)lastPlayedIntervalForVideo:(OEXHelperVideoDownload *)video { //最后一次播放的时间
    return [_storage lastPlayedIntervalForVideoID:video.summary.videoID];
}

- (void)markVideoState:(OEXPlayedState)state forVideo:(OEXHelperVideoDownload *)video { //视频状态发生变化
    
    for(OEXHelperVideoDownload* videoObj in [self allVideos]) {
        if([videoObj.summary.videoID isEqualToString:video.summary.videoID]) {
            videoObj.watchedState = state;
            [self.storage markPlayedState:state forVideoID:video.summary.videoID];
            [[NSNotificationCenter defaultCenter] postNotificationName:OEXVideoStateChangedNotification object:videoObj];
        }
    }
}

- (void)markLastPlayedInterval:(float)playedInterval forVideo:(OEXHelperVideoDownload *)video {
    [_storage markLastPlayedInterval:playedInterval forVideoID:video.summary.videoID];
}

#pragma mark - DownloadManagerDelegate

- (void)downloadTaskDidComplete:(NSURLSessionDownloadTask *)task {
}

- (void)downloadTask:(NSURLSessionDownloadTask *)task didCOmpleteWithError:(NSError *)error {
    
    NSArray* array = [_storage videosForTaskIdentifier:task.taskIdentifier];
    for(VideoData* video in array) {
        video.dm_id = [NSNumber numberWithInt:0];
        video.download_state = [NSNumber numberWithInt:OEXDownloadStateNew];
    }
    [self markDownloadProgress:0.0 forURL:[task.originalRequest.URL absoluteString] andVideoId:nil];

    [_storage saveCurrentStateToDB];
}

- (void)downloadAlreadyInProgress:(NSURLSessionDownloadTask *)task {
}

#pragma mark - Update Last Accessed from server

// Request Body

//ISO 8601 international standard date format
/*
 {
    @"modification_date" :@"2014-11-20 22:10:54.569200+00:00"
    @"last_visited_module_id" : module,
 }
*/

- (NSString *)getFormattedDate {
    
    NSDate* date = [NSDate date];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSSSSSZ"];
    NSString* strdate = [format stringFromDate:date];

    NSString* substringFirst = [strdate substringToIndex:29];
    NSString* substringsecond = [strdate substringFromIndex:29];
    strdate = [NSString stringWithFormat:@"%@:%@", substringFirst, substringsecond];
    return strdate;
}

- (void)updateLastVisitedModule:(NSString *)module forCourseID:(NSString *)courseID {
    
    if(!module) {
        return;
    }

    NSString* timestamp = [self getFormattedDate];

    // Set to DB first and then depending on the response the DB gets updated 首先设置为db，然后根据响应更新db。
    [self setLastAccessedDataToDB:module withTimeStamp:timestamp forCourseID:courseID];

    NSString* path = [NSString stringWithFormat:@"/api/mobile/v0.5/users/%@/course_status_info/%@", [OEXSession sharedSession].currentUser.username, courseID];

    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [OEXConfig sharedConfig].apiHostURL, path]]];

    [request setHTTPMethod:@"PATCH"];
    NSString* authValue = [NSString stringWithFormat:@"%@", [OEXAuthentication authHeaderForApiAccess]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSDictionary* dictionary = @{
        @"modification_date" : timestamp,
        @"last_visited_module_id" : module
    };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];

    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];

    [[session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            NSDictionary* dict = [NSJSONSerialization oex_JSONObjectWithData:data error:&error];

            NSArray* visitedPath = [dict objectForKey:@"last_visited_module_path"];

            NSString* subsectionID;

            for(NSString * subs in visitedPath) {
                if([subs rangeOfString:@"sequential"].location != NSNotFound) {
                    subsectionID = [visitedPath objectAtIndex:2];
                    break;
                }
            }

            if(![module isEqualToString:subsectionID]) {
                [self setLastAccessedDataToDB:subsectionID withTimeStamp:timestamp forCourseID:courseID];
            }
        }] resume];
}

- (void)setLastAccessedDataToDB:(NSString *)subsectionID withTimeStamp:(NSString *)timestamp forCourseID:(NSString *)courseID {
    
    OEXHelperVideoDownload* video = [self getSubsectionNameForSubsectionID:subsectionID];
    [self setLastAccessedSubSectionWithID:subsectionID subsectionName: video.summary.sectionPathEntry.entryID courseID:courseID timeStamp:timestamp];
}

- (void)getLastVisitedModuleForCourseID:(NSString *)courseID {
    
    NSString* path = [NSString stringWithFormat:@"/api/mobile/v0.5/users/%@/course_status_info/%@",
                      [OEXSession sharedSession].currentUser.username, courseID];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [OEXConfig sharedConfig].apiHostURL, path]]];
    
    [request setHTTPMethod:@"GET"];
    NSString* authValue = [NSString stringWithFormat:@"%@", [OEXAuthentication authHeaderForApiAccess]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        NSDictionary* dict = [NSJSONSerialization oex_JSONObjectWithData:data error:&error];
        
        NSArray* visitedPath = [dict objectForKey:@"last_visited_module_path"];
        
        NSString* subsectionID;
        
        for(NSString * subs in visitedPath) {
            if([subs rangeOfString:@"sequential"].location != NSNotFound) {
                subsectionID = subs;
                break;
            }
        }
        
        if(subsectionID) {
            NSString* timestamp = [self getFormattedDate];
            // Set to DB first and then depending on the response the DB gets updated
            [self setLastAccessedDataToDB:subsectionID withTimeStamp:timestamp forCourseID:courseID];
            
            //Post notification
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_URL_RESPONSE
                                                                object:self
                                                              userInfo:@{NOTIFICATION_KEY_URL: NOTIFICATION_VALUE_URL_LASTACCESSED,
                                                                         NOTIFICATION_KEY_STATUS: NOTIFICATION_VALUE_URL_STATUS_SUCCESS}];
        }
    }] resume];
}

#pragma mark - Analytics Call

- (void)sendAnalyticsEvents:(OEXVideoState)state withCurrentTime:(NSTimeInterval)currentTime forVideo:(OEXHelperVideoDownload *)video {
    
    if(isnan(currentTime)) {
        currentTime = 0;
    }
    OEXLogInfo(@"VIDEO", @"Sending analytics");

    switch(state) {
        case OEXVideoStateLoading:
            if(video.summary.videoID) {
                [[OEXAnalytics sharedAnalytics] trackVideoLoading:video.summary.videoID
                                                         CourseID:video.course_id
                                                          UnitURL:video.summary.unitURL];
            }

            break;

        case OEXVideoStateStop:
            if(video.summary.videoID) {
                [[OEXAnalytics sharedAnalytics] trackVideoStop:video.summary.videoID
                                                   CurrentTime:currentTime
                                                      CourseID:video.course_id
                                                       UnitURL:video.summary.unitURL];
            }

            break;

        case OEXVideoStatePlay:
            if(video.summary.videoID) {
                [[OEXAnalytics sharedAnalytics] trackVideoPlaying:video.summary.videoID
                                                      CurrentTime:currentTime
                                                         CourseID:video.course_id
                                                          UnitURL:video.summary.unitURL];
            }

            break;

        case OEXVideoStatePause:
            if(video.summary.videoID) {
                // MOB - 395
                [[OEXAnalytics sharedAnalytics] trackVideoPause:video.summary.videoID
                                                    CurrentTime:currentTime
                                                       CourseID:video.course_id
                                                        UnitURL:video.summary.unitURL];
            }

            break;

        default:
            break;
    }
}

#pragma mark - deactivate user interface
- (void)deactivate { //退出登陆后调用
    
    [OEXInterface setCCSelectedLanguage:@""]; // Set the language to blank 语言设置置空
    
    if(!_network) {
        return;
    }
    
    [self.network invalidateNetworkManager];
    self.network = nil;
    
    [_downloadManger deactivateWithCompletionHandler:^{
        [_storage deactivate];
        
        self.courses = nil;
        self.courseVideos = nil;
        self.parser = nil;
        self.numberOfRecentDownloads = 0;
        [self.videoSummaries removeAllObjects];
    }];
}

# pragma  mark - activate interface for user

- (void)activateInterfaceForUser:(OEXUserDetails *)user { // Reset Default Settings 重新设置默认设置
    
    self.storage = [OEXStorageFactory getInstance];
    
    self.downloadManger = [OEXDownloadManager sharedManager];
    self.downloadManger.delegate = self;
    
    self.parser = [[OEXDataParser alloc] init];
    
    self.commonDownloadProgress = -1;
    // Used for CC
    _sharedInterface.selectedCCIndex = -1;
    _sharedInterface.selectedVideoSpeedIndex = -1;
    
    self.courseVideos = [[NSMutableDictionary alloc] init];

    NSString* key = [NSString stringWithFormat:@"%@_numberOfRecentDownloads", user.username];
    NSInteger recentDownloads = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    //Downloads
    self.numberOfRecentDownloads = (int)recentDownloads;

    self.network = [[OEXNetworkInterface alloc] init];
    self.network.delegate = self;
    [_network activate];
    
    [[OEXDownloadManager sharedManager] activateDownloadManager];
    [self backgroundInit];

    //timed function
    if([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateTotalProgress) userInfo:nil repeats:YES]; //2秒更新一次
    [_timer fire];
    [self startAllBackgroundDownloads];
}

#pragma mark - Course Enrollments
- (UserCourseEnrollment*)enrollmentForCourseWithID:(NSString*)courseID {
    for (UserCourseEnrollment* enrollment in self.courses) {
        if(enrollment.course.course_id == courseID) {
            return enrollment;
        }
    }
    return nil;
}

#pragma mark - App Version
- (void) saveAppVersion {
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSBundle mainBundle].oex_buildVersionString forKey:OEXSavedAppVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (nullable NSString*) getSavedAppVersion {
    return [[NSUserDefaults standardUserDefaults] objectForKey:OEXSavedAppVersionKey];
}

@end

//
//  BCEDocumentDownloadTask.h
//  BCEDocumentReader
//
//  Copyright © 2016年 Baidu. All rights reserved.
//

@import Foundation;

/// 前置声明。
@class BCEDocumentItem;

/**
 *  @brief 下载任务的状态。
 */
typedef NS_ENUM(NSUInteger, BCEDocumentDownloadTaskState) {
    
    /**
     *  等待中。
     */
    BCEDocumentDownloadTaskStateWait,
    /**
     *  下载中。
     */
    BCEDocumentDownloadTaskStateRunning,
    /**
     *  已挂起。
     */
    BCEDocumentDownloadTaskStateSuspend,
    /**
     *  已取消。
     */
    BCEDocumentDownloadTaskStateCanceled,
    /**
     *  已完成。
     */
    BCEDocumentDownloadTaskStateFinish,
    /**
     *  已失败。
     */
    BCEDocumentDownloadTaskStateFailure
};

/**
 *  @brief 抽象一个下载任务。
 */
@interface BCEDocumentDownloadTask : NSObject

/**
 *  @brief 下载任务相关信息。
 */
@property(nonatomic, copy, readonly) BCEDocumentItem* item;

/**
 *  @brief 下载状态。
 */
@property(nonatomic, assign, readonly) BCEDocumentDownloadTaskState state;

/**
 *  @brief 下载进度。
 */
@property(nonatomic, assign, readonly) float progress;

- (instancetype)init NS_UNAVAILABLE;

@end
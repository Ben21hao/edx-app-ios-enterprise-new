//
//  BCEDocumentItem.h
//  BCEDocumentReader
//
//  Copyright © 2016年 Baidu. All rights reserved.
//

@import Foundation;

/**
 *  @brief 一个离线文档的状态。
 */
typedef NS_ENUM(NSUInteger, BCEDocumentItemStatus) {
    /**
     *  正在下载。
     */
    BCEDocumentItemStatusDownloading,
    /**
     *  下载完毕。
     */
    BCEDocumentItemStatusReady,
    /**
     *  数据被删除。
     */
    BCEDocumentItemStatusMiss
};

/**
 *  @brief 一个离线文档的相关信息。
 */
@interface BCEDocumentItem : NSObject

/**
 *  @brief 文档下载成功后，可将此参数传给阅读器来加载文档。
 */
@property(nonatomic, copy, readonly) NSDictionary* parameters;

/**
 *  @brief 文档的标识。值为调用下载接口时传入参数的BDocPlayerSDKeyDocID字段。
 */
@property(nonatomic, copy, readonly) NSString* identify;

/**
 *  @brief 文档的标题。值为调用下载接口时传入参数的BDocPlayerSDKeyDocTitle字段。
 */
@property(nonatomic, copy, readonly) NSString* title;

/**
 *  @brief 文档保存路径。
 */
@property(nonatomic, copy, readonly) NSString* path;

/**
 *  @brief 文档大小。
 */
@property(nonatomic, copy, readonly) NSString* size;

/**
 *  @brief 状态。
 */
@property(nonatomic, assign, readonly) BCEDocumentItemStatus status;

/**
 *  @brief 下载进度。
 */
@property(nonatomic, assign, readonly) float progress;

/**
 *  @brief 用户不能自己创建此类的对象。
 */
- (instancetype)init NS_UNAVAILABLE;

@end

//
//  BCEDocumentDownloader.h
//  BCEDocumentReader
//
//  Copyright © 2016年 Baidu. All rights reserved.
//

#import "BCEDocumentDefine.h"
#import "BCEDocumentItem.h"
#import "BCEDocumentDownloadTask.h"

/**
 *  @brief 文档下载错误码定义。
 */
typedef NS_ENUM(NSUInteger, BCEDocumentDownloadErrorCode) {
    /**
     *  参数错误。
     */
    BCEDocumentDownloadErrorCodeParameterError = BCEDocumentErrorCodeInvalidParameter,
    /**
     *  已经存在。
     */
    BCEDocumentDownloadErrorCodeAlreadyExists,
    /**
     *  被用户取消。
     */
    BCEDocumentDownloadErrorCodeCancelledByUser,
    /**
     *  被用户挂起。
     */
    BCEDocumentDownloadErrorCodeSuspendByUser,
    /**
     *  打开文档文件失败。
     */
    BCEDocumentDownloadErrorCodeOpenFileFailure,
    /**
     *  处理文档文件失败。
     */
    BCEDocumentDownloadErrorCodeProcessFileFailure,
    /**
     *  需要在回调中设置token。
     */
    BCEDocumentDownloadErrorCodeNeedToken,
    /**
     *  请求响应的HTTP状态码不在[200, 300)区间。
     */
    BCEDocumentDownloadErrorCodeHTTPCodeError,
    /**
     *  token无效。
     */
    BCEDocumentDownloadErrorCodeInvalidToken,
    /**
     *  token已过期。
     */
    BCEDocumentDownloadErrorCodeTokenExpired,
    /**
     *  请求的响应不正确。
     */
    BCEDocumentDownloadErrorCodeResponseInvalid,
    /**
     *  文档存储服务返回的错误。
     */
    BCEDocumentDownloadErrorCodeStorageServiceError,
    /**
     *  未知错误。
     */
    BCEDocumentDownloadErrorCodeUnknown
};

/**
 *  @brief BCEDocumentDownloader类的一些回调函数定义。
 */
@protocol BCEDocumentDownloaderDelegate <NSObject>

/**
 *  @brief 下载任务需要认证。
 *  @param auth 设置需要的认证信息。
 */
- (void)task:(BCEDocumentDownloadTask*)task needAuthentication:(NSMutableDictionary*)parameters;

@optional
/**
 *  @brief 任务开始。
 *  @param task 任务。
 */
- (void)taskStart:(BCEDocumentDownloadTask*)task;

/**
 *  @brief 任务进度上报。
 *  @param task     任务。
 *  @param progress 进度。0~100
 */
- (void)task:(BCEDocumentDownloadTask*)task progress:(float)progress;

/**
 *  @brief 任务完成。
 *  @param task  任务。
 *  @param error 错误，不为空表示发生了错误。
 */
- (void)taskEnd:(BCEDocumentDownloadTask*)task error:(NSError*)error;

@end

@interface BCEDocumentDownloader : NSObject


/**
 *  @brief 指定用户名和代理进行初始化。在没有账户系统时，可指定默认值。
 *  @param user     用户名。
 *  @param delegate 代理。
 *  @return 下载管理器。
 */
- (instancetype)initWithUser:(NSString*)user
                    delegate:(id<BCEDocumentDownloaderDelegate>)delegate;

/**
 *  @brief 冻结或者解除冻结。冻结后将不调度处于等待状态的任务。
 *  @param frozen 为YES时表示冻结，为NO时为解除冻结。
 */
- (void)frozen:(BOOL)frozen;

/**
 *  @brief 当前所有(下载中、下载完成)的item。
 *  @return item数组。
 */
- (NSArray<BCEDocumentItem*>*)documents;

/**
 *  @brief 删除一个item
 *  @param item
 */
- (void)removeDocument:(BCEDocumentItem*)item;

/**
 *  @brief 下载指定的文档。如果返回值为空，表示发生了错误，请查看error。
 *  @param parameters 文档的一些参数。
 *  @param error 错误信息，错误码与BCEDownloadErrorCode中定义的值对应。
 *  @return 下载任务。
 */
- (BCEDocumentDownloadTask*)downloadTask:(NSDictionary*)parameters error:(NSError**)error;

/**
 *  @brief 挂起下载任务。
 *  @param task 下载任务。
 */
- (void)suspendTask:(BCEDocumentDownloadTask*)task;

/**
 *  @brief 继续下载任务。
 *  @param task 下载任务。
 */
- (void)resumeTask:(BCEDocumentDownloadTask*)task;

/**
 *  @brief 取消下载任务，并删除已下载的数据。
 *  @param task 下载任务。
 */
- (void)cancelTask:(BCEDocumentDownloadTask*)task;

/**
 *  @brief 继续上次未完成的下载任务。
 *  @return 返回下载任务的数组。
 */
- (NSArray<BCEDocumentDownloadTask*>*)resumeUncompletedTasks;

/**
 *  @brief 停止所有下载任务。将任务下载进度保存到磁盘。
 */
- (void)stopAllTasks;

/**
 *  @brief 删除此用户的所有数据。需要在没有正在下载的任务时调用。调用后，该对象将不再可用。
 */
- (void)clean;

@end

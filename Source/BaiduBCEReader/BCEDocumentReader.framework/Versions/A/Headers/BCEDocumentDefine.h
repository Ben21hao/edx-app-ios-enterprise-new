//
//  BCEDocumentDefine.h
//  BCEDocumentReader
//
//  Copyright © 2016年 Baidu. All rights reserved.
//

@import UIKit;

#ifdef __cplusplus
    #define BCE_EXTERN extern "C" __attribute__((visibility ("default")))
#else
    #define BCE_EXTERN extern __attribute__((visibility ("default")))
#endif

// 文档ID。类型NSString。在加载和下载时均需要提供。
BCE_EXTERN NSString * const BDocPlayerSDKeyDocID;

// 文档的标题。类型NSString。在加载和下载时均需要提供。
BCE_EXTERN NSString * const BDocPlayerSDKeyDocTitle;

// 文档总页数。类型NSString。在加载和下载时均需要提供。
BCE_EXTERN NSString * const BDocPlayerSDKeyTotalPageNum;

// 访问文档的token。类型NSString。在加载和下载时均需要提供。
BCE_EXTERN NSString * const BDocPlayerSDKeyToken;

// 文档关联的Host。类型NSString。在加载和下载时均需要提供。
BCE_EXTERN NSString * const BDocPlayerSDKeyHost;

// 文档类型。类型NSString。取值'doc'或者'ppt'。在加载和下载时均需要提供。
BCE_EXTERN NSString * const BDocPlayerSDKeyDocType;

// 加载文档时指定的起始页数。可选字段，类型NSNumber, 存储NSInteger。
BCE_EXTERN NSString * const BDocPlayerSDKeyPageNumber;

// 加载文档时指定的预览页数。可选字段，类型NSNumber, 存储NSInteger。
BCE_EXTERN NSString * const BDocPlayerSDKeyPreviewPageNumber;

// SDK的版本号。
BCE_EXTERN NSString * const BDPSDKVersion;

/**
 *  @brief 错误码定义。
 */
typedef NS_ENUM(NSInteger, BCEDocumentErrorCode) {
    /**
     *  参数错误。
     */
    BCEDocumentErrorCodeInvalidParameter = 0x0100,
    
    /**
     *  无效token。
     */
    BCEDocumentErrorCodeInvalidToken = 0x108,
};

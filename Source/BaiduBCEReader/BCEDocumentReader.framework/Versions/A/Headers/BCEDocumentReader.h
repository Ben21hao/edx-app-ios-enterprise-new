//
//  BCEDocumentReader.h
//  BCEDocumentReader
//
//  Copyright © 2016年 Baidu. All rights reserved.
//


#import "BCEDocumentDefine.h"

// 前置声明。
@protocol BCEDocumentReaderDelegate;

/**
 *  @brief 阅读器，提供加载文档的功能。以UIView的方式提供。
 */
@interface BCEDocumentReader : UIView

/**
 *  @brief 事件代理。
 */
@property(nonatomic, weak) id<BCEDocumentReaderDelegate> delegate;

/**
 *  @brief 加载文档。
 *  @param parameters 文档相关参数。
 */
- (void)loadDoc:(NSDictionary*)parameters error:(NSError**)error;

/**
 *  @brief 设置字体大小。
 *  @param size 字体大小。取值范围(0, 2]
 */
- (void)setFontSize:(float)size;

@end

/**
 *  @brief 阅读器事件代理。
 */
@protocol BCEDocumentReaderDelegate <NSObject>
@optional

/**
 *  @brief 文档开始加载
 */
- (void)docLoadingStart;

/**
 *  @brief 文档结束结束。是否成功取决于error是否为空。
 *  @param error 错误。
 */
- (void)docLoadingEnded:(NSError*)error;

/**
 *  @brief 翻页事件。
 *  @param page 当前页。
 */
- (void)currentPageChanged:(NSInteger)page;

@end

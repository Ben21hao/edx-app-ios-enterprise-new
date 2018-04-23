//
//  TDImageHandle.h
//  EdxProject
//
//  Created by Elite Edu on 2018/1/12.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#ifndef Block_exe
#define Block_exe(block, ...) \
if (block) { \
block(__VA_ARGS__); \
}
#endif

@interface TDImageHandle : NSObject

/** 获取所有相册
 * @brief result 的元素类型为 PHAssetCollection
 */
- (void)enumeratePHAssetCollectionsWithResultHandler:(void(^)(NSArray <PHAssetCollection *>*result))resultHandler;

/** 获取某一相册下所有图片资源(iOS8以上)
 *  assetCollection: 相册
 *  finishBlock: 完成回调
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)collection finishBlock:(void(^)(NSArray <PHAsset *>*result))finishBlock;

@end

@interface PHAssetCollection (LLAdd)

- (void)posterImage:(void(^)(UIImage *result, NSDictionary *info))resultHandler;

- (void)posterImage:(CGSize)targetSize resultHandler:(void(^)(UIImage *result, NSDictionary *info))resultHandler;

- (NSInteger)numberOfAssets;

@end

@interface PHAsset (LLAdd)

// 缩略图
- (void)thumbnail:(void(^)(UIImage *result, NSDictionary *info))resultHandler;

- (void)thumbnail:(CGSize)targetSize resultHandler:(void(^)(UIImage *result, NSDictionary *info))resultHandler;

// 原图
- (void)original:(void(^)(UIImage *result, NSDictionary *info))resultHandler;

// 目标尺寸视图
- (void)requestImageForTargetSize:(CGSize)targetSize resultHandler:(void(^)(UIImage *result, NSDictionary *info))resultHandler;

- (void)originalSize:(void(^)(NSString *result))result;

@end

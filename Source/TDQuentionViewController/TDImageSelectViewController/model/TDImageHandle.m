//
//  TDImageHandle.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/12.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDImageHandle.h"

static CGFloat const kDefaultThumbnailWidth = 100;

@interface TDImageHandle ()

@property (nonatomic, strong) dispatch_queue_t concurrentQueue;

@end

@implementation TDImageHandle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.concurrentQueue = dispatch_queue_create("com.LLImageHandler.global", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

/** 获取所有相册
 * @brief result 的元素类型为 PHAssetCollection
 */
- (void)enumeratePHAssetCollectionsWithResultHandler:(void(^)(NSArray <PHAssetCollection *>*result))resultHandler {
    
    NSMutableArray *groups = [NSMutableArray array];// 照片群组数组
    
    dispatch_sync(self.concurrentQueue, ^{
        
        // 获取系统相册
        PHFetchResult <PHAssetCollection *>*systemAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        
        for (PHAssetCollection *collection in systemAlbums) {
            
            if ([collection numberOfAssets] > 0) {// 过滤照片数量为0的相册
                [groups addObject:collection];
            }
        }
        
        // 获取用户自定义相册
        PHFetchResult <PHAssetCollection *>*userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        
        for (PHAssetCollection *collection in userAlbums) {
            
            if ([collection numberOfAssets] > 0) { // 过滤照片数量为0的相册
                [groups addObject:collection];
            }
        }
        
//        NSLog(@"-------->>>> %@",groups);
    });
    
    dispatch_sync(self.concurrentQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"1111 -------->>>> %@",groups);
            Block_exe(resultHandler, groups);
        });
    });
}

/* 每个相册中所有的图片
 * 获取所有在assetCollection中的asset(iOS8以上)
 *  assetCollection: 照片群组
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)collection finishBlock:(void(^)(NSArray <PHAsset *>*result))finishBlock {
    
    __block NSMutableArray <PHAsset *>*results = [NSMutableArray array];
    dispatch_async(self.concurrentQueue, ^{
        
        // 获取collection这个相册中的所有资源
        PHFetchResult <PHAsset *>*assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (obj.mediaType == PHAssetMediaTypeImage || obj.mediaType == PHAssetMediaTypeVideo) {//视频和图片
                [results addObject:obj];
            }
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            finishBlock(results);
        });
    });
}

@end

@implementation PHAssetCollection (LLAdd)

- (void)posterImage:(void(^)(UIImage *result, NSDictionary *info))resultHandler {
    CGSize const defaultSize = CGSizeMake(kDefaultThumbnailWidth, kDefaultThumbnailWidth);
    [self posterImage:defaultSize resultHandler:resultHandler];
}

- (void)posterImage:(CGSize)targetSize resultHandler:(void(^)(UIImage *result, NSDictionary *info))resultHandler {
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:self options:nil];
    if (fetchResult.count > 0) { } else {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        PHAsset *asset = fetchResult.lastObject;
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize size = CGSizeMake(targetSize.width * scale, targetSize.height * scale);
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Block_exe(resultHandler, result, info);
            });
        }];
    });
}

- (NSInteger)numberOfAssets {
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init]; //图片索引
    
    NSPredicate *imagePredicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo]; //视频
    NSPredicate *videoPredicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage]; //相片
    NSCompoundPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[imagePredicate,videoPredicate]];
    fetchOptions.predicate = predicate;
    
//    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeVideo];// 注意 %zd 这里不识别，直接导致崩溃
    
    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:self options:fetchOptions];
    
    return result.count;
}

@end

@implementation PHAsset (LLAdd)

- (void)thumbnail:(void(^)(UIImage *result, NSDictionary *info))resultHandler {
    CGSize const defaultSize = CGSizeMake(kDefaultThumbnailWidth, kDefaultThumbnailWidth);
    [self thumbnail:defaultSize resultHandler:resultHandler];
}

- (void)thumbnail:(CGSize)targetSize resultHandler:(void(^)(UIImage *result, NSDictionary *info))resultHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize size = CGSizeMake(targetSize.width * scale, targetSize.height * scale);
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        options.synchronous = YES;
        
        [[PHImageManager defaultManager] requestImageForAsset:self targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Block_exe(resultHandler, result, info);
            });
        }];
    });
}

- (void)original:(void(^)(UIImage *result, NSDictionary *info))resultHandler {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.synchronous = YES;
        
        [[PHImageManager defaultManager] requestImageForAsset:self targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Block_exe(resultHandler, result, info);
            });
        }];
    });
}

- (void)requestImageForTargetSize:(CGSize)targetSize resultHandler:(void(^)(UIImage *result, NSDictionary *info))resultHandler {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize size = CGSizeMake(targetSize.width * scale, targetSize.height * scale);
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.synchronous = YES;
        
        [[PHImageManager defaultManager] requestImageForAsset:self targetSize:size contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Block_exe(resultHandler, result, info);
            });
        }];
    });
}

- (void)originalSize:(void(^)(NSString *result))result {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeNone;
        option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        option.version = PHImageRequestOptionsVersionOriginal;
        option.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:self options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            unsigned long size = imageData.length / 1024;
            NSString *sizeString = [NSString stringWithFormat:@"%liK", size];
            if (size > 1024) {
                NSInteger integral = size / 1024.0;
                NSInteger decimal = size % 1024;
                NSString *decimalString = [NSString stringWithFormat:@"%li",(long)decimal];
                if(decimal > 100){ //取两位
                    decimalString = [decimalString substringToIndex:2];
                }
                sizeString = [NSString stringWithFormat:@"%li.%@M", (long)integral, decimalString];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                Block_exe(result, sizeString);
            });
        }];
    });
}

@end



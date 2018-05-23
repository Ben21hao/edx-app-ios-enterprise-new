//
//  TDWebThumbImageModel.m
//  edX
//
//  Created by Elite Edu on 2018/5/8.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDWebThumbImageModel.h"

@implementation TDWebThumbImageModel

+ (UIImage *)getThumbnailImage:(NSString *)videoPath {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return thumb;
}

+ (UIImage *)getVideoThumbnailImage:(NSString *)videoUrl isLoacal:(BOOL)isLocal {
    
    NSURL *url;
    if (isLocal) {
        url = [NSURL fileURLWithPath:videoUrl];
    }
    else {
        url = [NSURL URLWithString:videoUrl];
    }
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CFTimeInterval thumbnailImageTime = 0;
    NSError *thumbnailImageGenerationError = nil;
    
    CGImageRef thumbnailImageRef = NULL;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage:thumbnailImageRef] : [UIImage imageNamed:@""];
    
    CGImageRelease(thumbnailImageRef);
    return thumbnailImage;
}

@end

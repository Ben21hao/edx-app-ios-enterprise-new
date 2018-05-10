//
//  TDImageSelectViewController.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/10.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDImageSelectViewController.h"
#import "TDBaseCollectionView.h"
#import "TDImageSelectCell.h"
#import "TDSelectBottomView.h"

#import "TDSelectImageModel.h"

#import "TDImageHandle.h"
#import "SRUtil.h"

#import "TDPreViewImageViewController.h"
#import "TDPreviewVideoViewController.h"

#define collectionCell_Width (TDWidth - 16)/4

@interface TDImageSelectViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) TDBaseCollectionView *collectionView;
@property (nonatomic,strong) TDSelectBottomView *bottomView;

@property (nonatomic,strong) NSMutableArray *assetArray;
@property (nonatomic,strong) NSMutableArray *selectImageArray;

@property (nonatomic,strong) TDImageHandle *imageHandle;

@end

@implementation TDImageSelectViewController

- (NSMutableArray *)assetArray {
    if (!_assetArray) {
        _assetArray = [[NSMutableArray alloc] init];
    }
    return _assetArray;
}

- (NSMutableArray *)selectImageArray {
    if (!_selectImageArray) {
        _selectImageArray = [[NSMutableArray alloc] init];
    }
    return _selectImageArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = self.assetCollection.localizedTitle;
    self.rightButton.hidden = NO;
    [self.rightButton setTitle:TDLocalizeSelect(@"CANCEL", nil) forState:UIControlStateNormal];
    WS(weakSelf);
    self.rightButtonHandle = ^(){
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self setSelectViewConstraint];
    
    self.imageHandle = [[TDImageHandle alloc] init];
    [self loadingPhotos];
}

#pragma mark - 确定
- (void)sureButtonAciton:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    sender.selected = YES;
     NSLog(@"---->> 所有图片 == 确定按钮");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"User_Had_SelectImage" object:nil userInfo:@{@"selectImageArray" : self.selectImageArray}];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 预览图片
- (void)previewButtonAction:(UIButton *)sender { //预览
    [self gotoPreviewVC:YES index:0];
}

- (void)gotoPreviewVC:(BOOL)isSelected index:(NSInteger)index {
    
    TDPreViewImageViewController *previewVc = [[TDPreViewImageViewController alloc] init];
    previewVc.index = index;
    previewVc.whereFrom = isSelected ? TDPreviewImageFromPreviewSelectImage : TDPreviewImageFromPreviewAllImage;
    previewVc.imageArray = isSelected ? self.selectImageArray : self.assetArray;
    
    if (isSelected == NO) {
        previewVc.hadSelectImageArray = self.selectImageArray;
        previewVc.inputViewImageArray = self.hadImageArray;
    }
    
    WS(weakSelf);
    previewVc.previewSelectHandle = ^(NSInteger index,BOOL isSelect) {
        
        TDSelectImageModel *model = weakSelf.assetArray[index];
        [weakSelf dealWithImageSelect:isSelect imageModel:model shouldReload:YES];
    };
    
    [self.navigationController pushViewController:previewVc animated:YES];
}

#pragma mark - 视频预览
- (void)gotoPreviewVideo:(TDSelectImageModel *)model {
    
    TDPreviewVideoViewController *previewVideoVC = [[TDPreviewVideoViewController alloc] init];
    previewVideoVC.isWebVideo = NO;
    [self.navigationController pushViewController:previewVideoVC animated:YES];
    
//    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
//    options.version = PHImageRequestOptionsVersionCurrent;
//    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//    
////    WS(weakSelf);
//    [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//        
//        NSString *sanboxPath = info[@"PHImageFileSandboxExtensionTokenKey"];
//        NSArray *array = [sanboxPath componentsSeparatedByString:@";"];
//        NSString *videoPath = array[array.count - 1];
//        
//        if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
//            NSLog(@"videopath ----->> %@",videoPath);
//        }
//        
//        NSString *path = [array[array.count - 1] substringFromIndex:9];
//        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
//            NSLog(@"path ----->> %@",path);
//        }
//        
//        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoPath] options:nil];
//        AVURLAsset *avAsset1 = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:path] options:nil];
//        NSLog(@"videopath %@----->> path %@",avAsset ,avAsset1);
//
//        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset1];
//        if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
//            
//            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
//            
//            NSString *resultPath = [self getVideoSaveFilePathString];
//            if (![[NSFileManager defaultManager] fileExistsAtPath:resultPath]) {
//                NSLog(@"resultPath ----->> %@",resultPath);
//            }
//            NSLog(@"resultPath = %@",resultPath);
//            
//            exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
//            exportSession.outputFileType = AVFileTypeMPEG4;
//            exportSession.shouldOptimizeForNetworkUse = YES;
//            
//            [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
//                 if (exportSession.status == AVAssetExportSessionStatusCompleted) {
//                     
//                     NSData *data = [NSData dataWithContentsOfFile:resultPath];
//                     
//                     float memorySize = (float)data.length / 1024 / 1024;
//                     NSLog(@"视频压缩后大小 %f", memorySize);
//                     
////                     [self playVideowithUrl:[NSURL fileURLWithPath:resultPath]];
//                     
//                     
//                 } else {
//                     NSLog(@"压缩失败");
//                 }
//                 
//             }];
//        }
//        
////        dispatch_async(dispatch_get_main_queue(), ^{
////            TDPreviewVideoViewController *previewVideoVC = [[TDPreviewVideoViewController alloc] init];
////            previewVideoVC.videoPath = [NSString stringWithFormat:@"%@",videoPath];//file://
////            previewVideoVC.isWebVideo = NO;
////            [weakSelf.navigationController pushViewController:previewVideoVC animated:YES];
////        });
//    }];
//    
////            PHImageFileSandboxExtensionTokenKey = "8f71358aa52f24bddc2fd536abff93d933825f5a;00000000;00000000;000000000000001b;com.apple.avasset.read-only;00000001;01000002;00000001005e20b6;/private/var/mobile/Media/DCIM/100APPLE/IMG_0601.MOV";
////            PHImageResultDeliveredImageFormatKey = 20000;
////            PHImageResultIsInCloudKey = 0;
////            PHImageResultWantedImageFormatKey = 20002;
}

- (NSString *)getVideoSaveFilePathString {//录制保存的时候要保存为 mov
    
    NSString *nowTimeStr = [NSString stringWithFormat:@"%lld",[SRUtil getNowTimeStamp]];
    NSString *videoName = [NSString stringWithFormat:@"%@.mov",nowTimeStr];
    
    NSString *path = [SRUtil getVideoCachePath:videoName];
    
    NSLog(@"wov 存储位置拼接 -- %@",path);
    
    return path;
}

#pragma mark - 获取照片
- (void)loadingPhotos {
    
    WS(weakSelf);
    [self.imageHandle enumerateAssetsInAssetCollection:self.assetCollection finishBlock:^(NSArray <PHAsset *> *result) {
        for (PHAsset *asset in result) {
            
            TDSelectImageModel *model = [[TDSelectImageModel alloc] init];
            model.selected = NO;
            model.asset = asset;
            
//            if (asset.mediaType == PHAssetMediaTypeVideo) {
//                AVURLAsset *urlAsset = (AVURLAsset *)asset;
//                model.videoUrl = urlAsset.URL.path;
//            }
            
            if (model) {
                [self.assetArray addObject:model];
            }
        }
        
        [weakSelf.collectionView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.collectionView.contentSize.height > self.collectionView.bounds.size.height) {
                [self.collectionView scrollsToBottomAnimated:NO];
            }
        });
    }];
}

#pragma mark - collectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TDSelectImageModel *model = self.assetArray[indexPath.row];
    
    TDImageSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TDImageSelectCell" forIndexPath:indexPath];
    [cell setSelectCell];
    cell.model = model;
    
    cell.selectButton.tag = indexPath.row;
    [cell.selectButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    cell.selectButton.selected = model.selected;

    if (self.selectImageArray.count + self.hadImageArray.count == 4) {
        cell.shadowView.hidden = model.selected;
    } else {
        cell.shadowView.hidden = YES;
    }
    
    if (self.selectImageArray.count + self.hadImageArray.count > 0 && model.asset.mediaType == PHAssetMediaTypeVideo) {
        cell.shadowView.hidden = NO;
        
    } else if (self.selectImageArray.count + self.hadImageArray.count == 0) {
        cell.shadowView.hidden = YES;
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(collectionCell_Width, collectionCell_Width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(3, 3, 3, 3);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 3;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 3;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TDSelectImageModel *model = self.assetArray[indexPath.row];
    
    if (model.asset.mediaType == PHAssetMediaTypeVideo) { //点击视频
        if (self.selectImageArray.count + self.hadImageArray.count > 0) {
            return;
        }
        
        [self gotoPreviewVideo:model];//视频预览
    }
    else { //点击图片
        [self gotoPreviewVC:NO index:indexPath.row]; //图片预览
    }
}

#pragma mark - 选择按钮
- (void)selectButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    TDSelectImageModel *model = self.assetArray[sender.tag];
    [self dealWithImageSelect:sender.selected imageModel:model shouldReload:NO];
}

- (void)dealWithImageSelect:(BOOL)isSelect imageModel:(TDSelectImageModel *)model shouldReload:(BOOL)reload { //图片选择的加减
    
    model.selected = isSelect;
    
    if (isSelect) {
        [self.selectImageArray addObject:model];
        
        if (reload) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
        
        if (self.selectImageArray.count + self.hadImageArray.count == 4) { //选够四张图片
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cell_showShadow" object:nil];
        }
        
        if (model.asset.mediaType == PHAssetMediaTypeImage && self.selectImageArray.count + self.hadImageArray.count == 1) {//如果第一张选择的是图片，视频不可选
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cell_video_showShadow" object:nil];
        }
    }
    else {
        NSArray *copyArray = [self.selectImageArray copy];
        
        if ([self.selectImageArray containsObject:model]) {
            [self.selectImageArray removeObject:model];
        }
        
        if (reload) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
        
        if (copyArray.count + self.hadImageArray.count == 4) { //变成3张
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cell_hiddenShadow" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cell_video_showShadow" object:nil];
        }
        
        
        if (model.asset.mediaType == PHAssetMediaTypeImage && self.selectImageArray.count + self.hadImageArray.count == 0) {//如果第一张选择的是图片，视频不可选
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cell_video_hiddenShadow" object:nil];
        }
    }
    
    self.bottomView.selectNum = self.selectImageArray.count;
}


#pragma mark - UI
- (void)setSelectViewConstraint {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    self.collectionView = [[TDBaseCollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.view);
    }];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 48, 0);
    [self.collectionView registerClass:[TDImageSelectCell class] forCellWithReuseIdentifier:@"TDImageSelectCell"];
    
    self.bottomView = [[TDSelectBottomView alloc] init];
    self.bottomView.isPreView = NO;
    [self.bottomView.sureButton addTarget:self action:@selector(sureButtonAciton:) forControlEvents:UIControlEventAllEvents];
    [self.bottomView.previewButton addTarget:self action:@selector(previewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottomView];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(48);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end

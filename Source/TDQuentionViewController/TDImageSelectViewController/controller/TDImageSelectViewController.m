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

#import <Photos/Photos.h>
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
    
    if (![[[TDBaseToolModel alloc] init] getNetworkingState]) { //没有网络
        [self.view makeToast:TDLocalizeSelect(@"NETWORK_NOT_AVAILABLE_MESSAGE_TROUBLE", nil) duration:0.8 position:CSToastPositionCenter];
        return;
    }
    
    sender.selected = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"User_Had_SelectImage" object:nil userInfo:@{@"selectImageArray" : self.selectImageArray}];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 预览图片
- (void)previewButtonAction:(UIButton *)sender { //预览
    if (self.selectImageArray.count == 0) {
        return;
    }
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

    PHVideoRequestOptions *options2 = [[PHVideoRequestOptions alloc] init];
    options2.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    WS(weakSelf);
    [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:options2 resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
        //video路径获取
        if (asset && [asset isKindOfClass:[AVURLAsset class]] && [NSString stringWithFormat:@"%@",((AVURLAsset *)asset).URL].length > 0) {
            
            NSString *videoURLStr = [NSString stringWithFormat:@"%@",((AVURLAsset *)asset).URL];
            NSLog(@"--->>> %@ -- %@",info,videoURLStr);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                TDPreviewVideoViewController *previewVideoVC = [[TDPreviewVideoViewController alloc] init];
                previewVideoVC.isWebVideo = NO;
                previewVideoVC.videoPath = videoURLStr;
                previewVideoVC.videoTime = CMTimeGetSeconds(asset.duration);
                previewVideoVC.thumbImage = model.image;
                [weakSelf.navigationController pushViewController:previewVideoVC animated:YES];
            });
        }
    }];
    
//    PHFetchResult *assetsResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:nil];
//    for(PHAsset *a in assetsResult) {
//        [[PHImageManager defaultManager] requestAVAssetForVideo:a options:options2 resultHandler:^(AVAsset *_Nullable asset,AVAudioMix *_Nullable audioMix,NSDictionary*_Nullable info) {
//            
//            //video路径获取
//            if (asset && [asset isKindOfClass:[AVURLAsset class]] && [NSString stringWithFormat:@"%@",((AVURLAsset *)asset).URL].length > 0) {
//                NSString *videoURLStr = [NSString stringWithFormat:@"%@",((AVURLAsset *)asset).URL];
////                videoPath = ((AVURLAsset *)asset).URL.path;
//                NSLog(@"--->>> %@ -- %@",info,videoURLStr);
//            }
//        }];
//    }
    
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
        [self getBigImage:model];
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

- (void)getBigImage:(TDSelectImageModel *)model { //拿到原图图
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [model.asset original:^(UIImage *result, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                model.image = result;
            });
        }];
    });
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

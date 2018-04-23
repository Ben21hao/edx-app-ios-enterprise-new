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

#import "TDPreViewImageViewController.h"

#define collectionCell_Width (TDWidth - 16)/4

@interface TDImageSelectViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) TDBaseCollectionView *collectionView;
@property (nonatomic,strong) TDSelectBottomView *bottomView;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) NSMutableArray *selectImageArray;

@property (nonatomic,strong) TDImageHandle *imageHandle;

@end

@implementation TDImageSelectViewController

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] init];
    }
    return _imageArray;
}

- (NSMutableArray *)selectImageArray {
    if (!_selectImageArray) {
        _selectImageArray = [[NSMutableArray alloc] init];
    }
    return _selectImageArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = TDLocalizeSelect(@"ALL_PHOTO_TITLE", nil);
    self.rightButton.hidden = NO;
    [self.rightButton setTitle:TDLocalizeSelect(@"CANCEL", nil) forState:UIControlStateNormal];
    WS(weakSelf);
    self.rightButtonHandle = ^(){
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self setViewConstraint];
    
    self.imageHandle = [[TDImageHandle alloc] init];
    [self loadingPhotos];
    
}

- (void)selectImageSureButtonAciton:(UIButton *)sender { //确定

//     NSLog(@"---->> 所有图片 == 确定按钮");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"user_had_selectImage" object:nil userInfo:@{@"selectImageArray" : self.selectImageArray}];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)previewButtonAction:(UIButton *)sender { //预览已选择的图片
    [self gotoPreviewVC:YES index:0];
}

- (void)gotoPreviewVC:(BOOL)isSelected index:(NSInteger)index {
    
    TDPreViewImageViewController *previewVc = [[TDPreViewImageViewController alloc] init];
    previewVc.index = index;
    previewVc.whereFrom = isSelected ? TDPreviewImageFromPreviewSelectImage : TDPreviewImageFromPreviewAllImage;
    previewVc.imageArray = isSelected ? self.selectImageArray : self.imageArray;
    
    if (isSelected == NO) {
        previewVc.hadSelectImageArray = self.selectImageArray;
        previewVc.inputViewImageArray = self.hadImageArray;
    }
    
    WS(weakSelf);
    previewVc.previewSelectHandle = ^(NSInteger index,BOOL isSelect) {
        
        TDSelectImageModel *model = weakSelf.imageArray[index];
        [weakSelf dealWithImageSelect:isSelect imageModel:model shouldReload:YES];
    };
    
    [self.navigationController pushViewController:previewVc animated:YES];
}

- (void)loadingPhotos {
    
    WS(weakSelf);
    [self.imageHandle enumerateAssetsInAssetCollection:self.assetCollection finishBlock:^(NSArray <PHAsset *> *result) {
        for (PHAsset *asset in result) {
            
            TDSelectImageModel *model = [[TDSelectImageModel alloc] init];
            model.selected = NO;
            model.asset = asset;
            
            if (model) {
                [self.imageArray addObject:model];
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
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TDSelectImageModel *model = self.imageArray[indexPath.row];
    
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
    [self gotoPreviewVC:NO index:indexPath.row];
}

- (void)selectButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    TDSelectImageModel *model = self.imageArray[sender.tag];
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
        
        if (self.selectImageArray.count + self.hadImageArray.count == 4) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cell_showShadow" object:nil];
        }
        
    } else {
        NSArray *copyArray = [self.selectImageArray copy];
        
        if ([self.selectImageArray containsObject:model]) {
            [self.selectImageArray removeObject:model];
        }
        
        if (reload) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }
        
        if (copyArray.count + self.hadImageArray.count == 4) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"cell_hiddenShadow" object:nil];
        }
    }
    
    self.bottomView.selectNum = self.selectImageArray.count;
}

#pragma mark - UI
- (void)setViewConstraint {
    
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
    [self.bottomView.sureButton addTarget:self action:@selector(selectImageSureButtonAciton:) forControlEvents:UIControlEventAllEvents];
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

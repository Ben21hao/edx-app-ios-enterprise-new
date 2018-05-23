//
//  TDPreViewImageViewController.m
//  EdxProject
//
//  Created by Elite Edu on 2018/1/11.
//  Copyright © 2018年 Elite Edu. All rights reserved.
//

#import "TDPreViewImageViewController.h"
#import "TDSelectImageModel.h"
#import "TDHorizonCollectionView.h"

#import "TDPreviewImageCell.h"
#import "TDSelectBottomView.h"
#import "TDImageHandle.h"

@interface TDPreViewImageViewController () <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIScrollViewDelegate>

@property (nonatomic,strong) TDHorizonCollectionView *collectionView;
@property (nonatomic,strong) TDSelectBottomView *bottomView;
@property (nonatomic,strong) NSMutableArray *selectImageArray;

@property (nonatomic,assign) NSInteger imageIndex; //对第几个图片进行操作
@property (nonatomic,assign) BOOL isHideBottom;

@end

@implementation TDPreViewImageViewController

- (NSMutableArray *)selectImageArray {
    if (!_selectImageArray) {
        _selectImageArray = [[NSMutableArray alloc] initWithArray:self.hadSelectImageArray];
    }
    return _selectImageArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleViewLabel.text = TDLocalizeSelect(@"PHOTO_PREVIEW_TEXT", nil);
    
    [self setViewConstraint];
    self.imageIndex = self.index;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)leftButtonAction:(UIButton *)sender { //返回
    
    if (self.whereFrom == TDPreviewImageFromQuedionInputView) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)selectButtonAction:(UIButton *)sender { //勾选
    
    if (sender.selected == NO && self.selectImageArray.count + self.inputViewImageArray.count >= 4) {
        [self.view makeToast:TDLocalizeSelect(@"MAX_FOUR_PHOTOS", nil) duration:0.8 position:CSToastPositionCenter];
        return;
    }
    
    sender.selected = !sender.selected;
    
    TDSelectImageModel *model = self.imageArray[self.imageIndex];
    model.selected = sender.selected;
    
    if (sender.selected) {
        [self getBigImage:model];
        [self.selectImageArray addObject:model];
        
    } else {
        if ([self.selectImageArray containsObject:model]) {
            [self.selectImageArray removeObject:model];
        }
    }
    self.bottomView.selectNum = self.selectImageArray.count;
    
    if (self.previewSelectHandle) {
        self.previewSelectHandle(self.imageIndex, sender.selected);
    }
}

- (void)previewSureButtonAciton:(UIButton *)sender { //确定

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

#pragma mark - delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TDSelectImageModel *model = self.imageArray[indexPath.row];
    
    TDPreviewImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TDPreviewImageCell" forIndexPath:indexPath];
    [cell setPreviewImageCell];
    cell.model = model;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [cell addGestureRecognizer:tap];
    
    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(TDWidth, TDHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)tapAction:(UITapGestureRecognizer *)tap { //点击
    
    self.isHideBottom = !self.isHideBottom;
    
    BOOL isHidden = self.navigationController.navigationBar.isHidden;
    
    [[UIApplication sharedApplication] setStatusBarHidden:!isHidden withAnimation:UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:!isHidden animated:YES];
    
    [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(isHidden ? 0 : 48);
        make.height.mas_equalTo(48);
    }];
}

- (void)getBigImage:(TDSelectImageModel *)model { //拿到大的缩略图
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [model.asset original:^(UIImage *result, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                model.image = result;
            });
        }];
    });
}

#pragma mark - UI
- (void)setViewConstraint {
    
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[TDHorizonCollectionView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.index = self.index;
    self.collectionView.showsHorizontalScrollIndicator = YES;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[TDPreviewImageCell class] forCellWithReuseIdentifier:@"TDPreviewImageCell"];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
    
    self.bottomView = [[TDSelectBottomView alloc] init];
    self.bottomView.isPreView = YES;
    [self.bottomView.previewButton addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView.sureButton addTarget:self action:@selector(previewSureButtonAciton:) forControlEvents:UIControlEventAllEvents];
    [self.view addSubview:self.bottomView];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(48);
    }];
    
    self.bottomView.previewButton.selected = NO;
    self.bottomView.selectNum = self.hadSelectImageArray.count;
    self.bottomView.hidden = self.whereFrom != TDPreviewImageFromPreviewAllImage;
    
    if (self.whereFrom == TDPreviewImageFromPreviewAllImage) {
        TDSelectImageModel *model = self.imageArray[self.index];
        self.bottomView.previewButton.selected = model.selected;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.collectionView.index = self.index;
    });
}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"---->> %lf",scrollView.contentOffset.x);
    
    self.imageIndex = scrollView.contentOffset.x / TDWidth;
    
    TDSelectImageModel *model = self.imageArray[self.imageIndex];
    self.bottomView.previewButton.selected = model.selected;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

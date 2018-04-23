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
//    NSLog(@"---->> 预览 == 确定按钮");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"user_had_selectImage" object:nil userInfo:@{@"selectImageArray" : self.selectImageArray}];
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
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
    return CGSizeMake(TDWidth, TDHeight - BAR_ALL_HEIHT);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)tap { //点击
    
    self.isHideBottom = !self.isHideBottom;
    
    if (self.isHideBottom) {
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomView.frame = CGRectMake(0, TDHeight - BAR_ALL_HEIHT, TDWidth, 48);
        }];

        
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomView.frame = CGRectMake(0, TDHeight - BAR_ALL_HEIHT - 48, TDWidth, 48);
        }];
    }
    
}

#pragma mark - UI
- (void)setViewConstraint {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[TDHorizonCollectionView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight - BAR_ALL_HEIHT) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.index = self.index;
    self.collectionView.showsHorizontalScrollIndicator = YES;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[TDPreviewImageCell class] forCellWithReuseIdentifier:@"TDPreviewImageCell"];
    
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

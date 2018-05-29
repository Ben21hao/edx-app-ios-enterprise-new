//
//  TDWebImagePreviewViewController.m
//  edX
//
//  Created by Elite Edu on 2018/1/22.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDWebImagePreviewViewController.h"
#import "TDHorizonCollectionView.h"
#import "TDWebImagePreviewCell.h"

@interface TDWebImagePreviewViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) TDHorizonCollectionView *collectionView;
@property (nonatomic,strong) UIPageControl *pageControl;

@end

@implementation TDWebImagePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [self setViewConstraint];
}

#pragma mark - collectionview Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.picUrlArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TDWebImagePreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TDWebImagePreviewCell" forIndexPath:indexPath];
    [cell setPreviewImageCell];
    cell.urlStr = self.picUrlArray[indexPath.row];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [cell addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer *swipeGestre = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureAction:)];
    swipeGestre.direction = UISwipeGestureRecognizerDirectionDown;
    [cell addGestureRecognizer:swipeGestre];

    
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)swipeGestureAction:(UISwipeGestureRecognizer *)gesture {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.pageControl.currentPage = scrollView.contentOffset.x / TDWidth;
}

#pragma mark - UI
- (void)setViewConstraint {
    
    UICollectionViewFlowLayout *layOut = [[UICollectionViewFlowLayout alloc] init];
    layOut.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[TDHorizonCollectionView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, TDHeight) collectionViewLayout:layOut];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = YES;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(self.view);
    }];
    
    [self.collectionView registerClass:[TDWebImagePreviewCell class] forCellWithReuseIdentifier:@"TDWebImagePreviewCell"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.collectionView.index = self.index;
    });
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = self.picUrlArray.count;
    self.pageControl.currentPage = self.index;
    [self.view addSubview:self.pageControl];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-33);
        make.size.mas_equalTo(CGSizeMake(self.picUrlArray.count * 18, 30));
    }];
    
    if (self.picUrlArray.count <= 1) {
        self.pageControl.hidden = YES;
    }
    self.pageControl.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end

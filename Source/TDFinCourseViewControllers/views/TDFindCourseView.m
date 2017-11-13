//
//  TDFindCourseView.m
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDFindCourseView.h"
#import "TDFindCourseCollectionViewCell.h"

#import "OEXCourse.h"
#import <UIImageView+WebCache.h>

@interface TDFindCourseView () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) TDBaseToolModel *toolModel;

@end

@implementation TDFindCourseView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.toolModel = [[TDBaseToolModel alloc] init];
        [self setViewConstraint];
    }
    return self;
}

- (void)setCourseArray:(NSArray *)courseArray {
    _courseArray = courseArray;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.courseArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OEXCourse *courseModel = self.courseArray[indexPath.row];
    NSString *imageStr = [self.toolModel dealwithImageStr:[NSString stringWithFormat:@"%@%@",ELITEU_URL,courseModel.courseImageURL]];
    
    
    TDFindCourseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TDEliteCourseViewControllerCell" forIndexPath:indexPath];
    cell.titleLabel.text = courseModel.name;
    [cell.courseImage sd_setImageWithURL:[NSURL URLWithString:imageStr] placeholderImage:[UIImage imageNamed:@"course_backGroud"]];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
//设置每个Cell 的宽高
- (CGSize)collectionView:(UICollectionView *)collectionView  layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake((TDWidth - 24) / 2, (TDWidth - 24) / 2 * 9 / 16 + 53);
}

//设置每组的cell的边界，上左下右
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 8, 0, 8);
}

//cell的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

//cell的最小列间距，是由API自动计算的，只有当间距小于该值时，cell会进行换行
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

//返回头headerView的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = CGSizeMake(TDWidth, 8);
    return size;
}

//返回头footerView的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size= CGSizeMake(TDWidth, 3);
    return size;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
//    
//    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionViewHeader" forIndexPath:indexPath];
//    headerView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
//    
//    UIView *line = [[UIView alloc] init];
//    line.backgroundColor = [UIColor colorWithHexString:colorHexStr6];
//    [headerView addSubview:line];
//    [line mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.mas_equalTo(headerView);
//        make.centerY.mas_equalTo(headerView);
//        make.height.mas_equalTo(1);
//    }];
//    
//    return headerView;
//}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (self.didSelectRow) {
        self.didSelectRow(indexPath.row);
    }
}


#pragma mark - UI
- (void)setViewConstraint {
    
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[TDFindCourseCollectionViewCell class] forCellWithReuseIdentifier:@"TDEliteCourseViewControllerCell"];
//    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionViewHeader"]; //注册头部视图
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
}


@end

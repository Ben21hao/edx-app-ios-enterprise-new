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
    
    CGFloat height = [self dealWithHeightForItem:indexPath.row];
    return CGSizeMake((TDWidth - 24) / 2, (TDWidth - 24) / 2 * 9 / 16 + 18 + height);
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
    return 8;
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

#pragma mark - 取相对高的高度
- (CGFloat)dealWithHeightForItem:(NSInteger)row { //规则： 对比左右单元的高度，取大的那个
    
    CGFloat height1 = [self getHeithForString:row];;
    
    if (row % 2 == 0) { //row : 0 2 4 双数，左边
        
        if (row + 1 < self.courseArray.count) {
            
            CGFloat height2 = [self getHeithForString:row + 1];
            return MAX(height1, height2);
            
        } else {
            return height1;
        }
    } else { //右边
        
        CGFloat height2 = [self getHeithForString:row - 1];
        return MAX(height1, height2);
    }
}

- (CGFloat)getHeithForString:(NSInteger)row {
    
    OEXCourse *courseModel = self.courseArray[row];
    CGFloat height = [self.toolModel heightForString:courseModel.name font:14 width:(TDWidth - 24) / 2];

    return height > 39 ? 39 : height;
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
    self.collectionView.backgroundColor = [[UIColor colorWithHexString:colorHexStr13] colorWithAlphaComponent:0.4];
    [self addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    self.noDataLabel = [[UILabel alloc] init];
    self.noDataLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.noDataLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.noDataLabel.textAlignment = NSTextAlignmentCenter;
    self.noDataLabel.text = TDLocalizeSelect(@"NO_COURSE_AVAILABLE_TEXT", nil);
    [self.collectionView addSubview:self.noDataLabel];
    
    [self.noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.collectionView);
    }];
    
    self.noDataLabel.hidden = YES;
}


@end

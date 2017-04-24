//
//  TDRecommendCell.m
//  edX
//
//  Created by Elite Edu on 16/12/10.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "TDRecommendCell.h"
#import "TDBottomCouseView.h"

@interface TDRecommendCell ()

@property (nonatomic,strong) UIView *bgView;

@end

@implementation TDRecommendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
        [self config];
        [self setConstraint];
    }
    return self;
}

- (void)config {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self addSubview:self.bgView];
    
}

- (void)setConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
}

#pragma mark - 数据
- (void)setDataWithDataArray:(NSArray *)dataArray {
    if (dataArray != nil) {
        [self addBottomCourseView:dataArray];
    }
}

- (void)addBottomCourseView:(NSArray *)dataArray {
    if (dataArray.count > 0) {
        for (int i = 0; i < dataArray.count; i ++) {
            int row = i / 2;//行
            int remaind = i % 2;//列
            int width = (TDWidth - 25) / 2;//宽
            int height;//高
            if (TDWidth == 320) {
                height = width - 10;
            } else if (TDWidth < 400 && TDWidth > 320) {
                height = width - 30;
            } else {
                height = width - 20;
            }
            int interval = 10;//间隔
            
            TDBottomCouseView *courseView = [[TDBottomCouseView alloc] init];
            [courseView.bottomButton addTarget:self action:@selector(carBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
            courseView.bottomButton.tag = i;
            [courseView setCourseViewData:dataArray[i]];
            [self.bgView addSubview:courseView];
            
            [courseView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.bgView.mas_top).offset(row * (height + interval));
                make.left.mas_equalTo(self.bgView.mas_left).offset((remaind * (width + 5)) + 10);
                make.size.mas_equalTo(CGSizeMake(width, height));
            }];
        }
    }
}

- (void)carBtnSelected:(UIButton *)sender {
    
    if (self.selectCourseHandle) {
        self.selectCourseHandle(sender.tag);
    }
}


@end







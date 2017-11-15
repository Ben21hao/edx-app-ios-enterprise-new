//
//  TDSortCourseCell.m
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDSortCourseCell.h"
#import "TDCourseTagModel.h"

@interface TDSortCourseCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UILabel *noDataLabel;

@end

@implementation TDSortCourseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setViewConstraint];
    }
    return self;
}

- (void)setViewConstraint {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    self.noDataLabel = [[UILabel alloc] init];
    self.noDataLabel.text = TDLocalizeSelect(@"NO_CATEGORIES", nil);
    self.noDataLabel.textAlignment = NSTextAlignmentCenter;
    self.noDataLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.noDataLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
    [self.bgView addSubview:self.noDataLabel];
    
    [self.noDataLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.bgView);
    }];
    self.noDataLabel.hidden = YES;
}

- (void)setTagArray:(NSArray *)tagArray {
    _tagArray = tagArray;
    
    self.noDataLabel.hidden = tagArray.count > 0;
    if (tagArray.count > 0) {
        [self setTagView];
    }
   
}

#pragma mark - 标签布局
- (void)setTagView {
    if (self.tagArray > 0) {
        
        CGFloat leftWidth = 0;
        CGFloat topHeight = 0;
        NSInteger row = 1;
        for (int i = 0; i < self.tagArray.count; i ++) {
            
            CGFloat width = [self getTagStrWidh:i];
            
            if (i == 0) {
                topHeight = 13;
                leftWidth = 13;
                
            } else {
                
                CGFloat lastWidth = [self getTagStrWidh:i - 1]; //前面一个
                
                leftWidth = leftWidth + lastWidth + 13;
                
                if (leftWidth + width + 13 > TDWidth) {
                    leftWidth = 13;
                    topHeight = topHeight + 24 + 13;
                    row ++ ;
                }
            }
            
            UIButton *tagButton = [self setTagButtonIndex:i];
            [self.bgView addSubview:tagButton];
            
            [tagButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.bgView.mas_left).offset(leftWidth);
                make.top.mas_equalTo(self.bgView.mas_top).offset(topHeight);
                make.size.mas_equalTo(CGSizeMake(width, 24));
            }];
        }
        
    }
}

- (CGFloat)getTagStrWidh:(NSInteger)index {
    
    TDCourseTagModel *model = self.tagArray[index];
    NSString *titleStr = [NSString stringWithFormat:@"%@  %@",model.subject_name,model.count];
    
    TDBaseToolModel *toolModel = [[TDBaseToolModel alloc] init];
    CGFloat width = [toolModel widthForString:titleStr font:12] + 28;
    
    return width;
}

- (UIButton *)setTagButtonIndex:(NSInteger)index {
    
    UIButton *button = [[UIButton alloc] init];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 12;
    button.layer.borderColor = [UIColor colorWithHexString:colorHexStr7].CGColor;
    button.layer.borderWidth = 1;
    button.showsTouchWhenHighlighted = YES;
    button.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitleColor:[UIColor colorWithHexString:colorHexStr9] forState:UIControlStateNormal];
    
    button.tag = index;
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    TDCourseTagModel *model = self.tagArray[index];
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:model.subject_name attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr9]}];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"  %@",model.count] attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:colorHexStr1]}];
    [str1 appendAttributedString:str2];
    [button setAttributedTitle:str1 forState:UIControlStateNormal];
    
    return button;
}

- (void)buttonAction:(UIButton *)sender { //跳转
    if (self.selectTagButtonHandle) {
        TDCourseTagModel *model = self.tagArray[sender.tag];
        self.selectTagButtonHandle(model);
    }
}

@end





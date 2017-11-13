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
    
}

- (void)setTagArray:(NSArray *)tagArray {
    _tagArray = tagArray;
    
    [self setTagView];
}

- (void)setTagView {
    if (self.tagArray > 0) {
        
        CGFloat leftWidth = 0;
        CGFloat topHeight = 0;
        NSInteger row = 1;
        for (int i = 0; i < self.tagArray.count; i ++) {
            
            TDCourseTagModel *model = self.tagArray[i];
            NSString *titleStr = [NSString stringWithFormat:@"%@  %@",model.subject_name,model.count];
            
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
            
            UIButton *tagButton = [self setTagButton:titleStr ndex:i];
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

- (UIButton *)setTagButton:(NSString *)titleStr ndex:(NSInteger)index {
    
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
    [button setTitle:titleStr forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)buttonAction:(UIButton *)sender { //跳转
    if (self.selectTagButtonHandle) {
        TDCourseTagModel *model = self.tagArray[sender.tag];
        self.selectTagButtonHandle(model.subject_id);
    }
}


@end





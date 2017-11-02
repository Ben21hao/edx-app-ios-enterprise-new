//
//  TDSortCourseCell.m
//  edX
//
//  Created by Elite Edu on 2017/11/1.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDSortCourseCell.h"

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

    self.tagArray = [NSArray arrayWithObjects:@"第一个tag  标签",@"第二个第tag   标签",@"第三个tag 标签", @"第四个第四个tag  标签",@"第五个第五个ttag   标签",@"第六个六个tagtag 标签",@"第七个第七个tagtag  标签",@"第八个第八个tag tag 标签",@"第九个第九个tag 标tag 标签",@"第10个第10个tag 标tag 标签 标tag 标签",@"第11个第11个tag 标tag 标签 标tag 标签 第11个",nil];
    
    [self setTagView];
}

- (void)setTagView {
    if (self.tagArray > 0) {
        
        TDBaseToolModel *toolModel = [[TDBaseToolModel alloc] init];
        CGFloat leftWidth = 0;
        CGFloat topHeight = 0;
        for (int i = 0; i < self.tagArray.count; i ++) {
            
            NSString *titleStr = self.tagArray[i];
            CGFloat width = [toolModel widthForString:titleStr font:12] + 28;
            
            if (i == 0) {
                topHeight = 13;
                leftWidth = 13;
                
            } else {
                
                NSString *lastTitle = self.tagArray[i - 1]; //前面一个
                CGFloat lastWidth = [toolModel widthForString:lastTitle font:12] + 28;
                leftWidth = leftWidth + lastWidth + 13;
                
                if (leftWidth + width + 13 > TDWidth) {
                    leftWidth = 13;
                    topHeight = topHeight + 24 + 13;
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
    
}


@end





//
//  TDOutLineCell.m
//  edX
//
//  Created by Elite Edu on 16/12/6.
//  Copyright © 2016年 edX. All rights reserved.
//

#import "TDOutLineCell.h"
#import "OutlineThirdItem.h"
#import "OutlineSecondItem.h"
#import <MJExtension/MJExtension.h>

@interface TDOutLineCell ()

@property (nonatomic,strong) UIView *bgView;

@end

@implementation TDOutLineCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self config];
        [self setConstraint];
    }
    return self;
}

- (void)config {
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr5];
    [self addSubview:self.bgView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    [self.bgView addSubview:self.titleLabel];
}

- (void)setConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(20);
        make.top.mas_equalTo(self.bgView.mas_top).offset(0);
        make.height.mas_equalTo(33);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-38);
    }];
}

#pragma mark - 设置数据
- (void)setDataForOutLine:(NSArray *)dataArray {
    if (dataArray.count > 0) {
        
        if (dataArray.count > 0) {
            for (int i = 0; i < dataArray.count; i ++) {
                NSDictionary *dataDic = dataArray[i];
                OutlineThirdItem *thirdItem = [OutlineThirdItem mj_objectWithKeyValues:dataDic];
                
                UILabel *subTitleLabel = [[UILabel alloc] init];
                subTitleLabel.font = [UIFont systemFontOfSize:12];
                subTitleLabel.textColor = [UIColor colorWithHexString:colorHexStr9];
                subTitleLabel.text = thirdItem.display_name;
                [self.bgView addSubview:subTitleLabel];
                
                [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.bgView.mas_top).offset(33 * (i + 1));
                    make.left.mas_equalTo(self.bgView.mas_left).offset(39);
                    make.height.mas_equalTo(33);
                    make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
                }];
            }
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

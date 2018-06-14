//
//  TDSkydriveLocalFileCell.m
//  edX
//
//  Created by Elite Edu on 2018/6/12.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveLocalFileCell.h"

@interface TDSkydriveLocalFileCell ()

@property (nonatomic,strong) UIView *bgView;

@end

@implementation TDSkydriveLocalFileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configeView];
        [self setViewConstraint];
    }
    return self;
}

- (void)configeView {
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bgView];
    
    self.leftImageView = [[UIImageView alloc] init];
    [self.bgView addSubview:self.leftImageView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.titleLabel.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.bgView addSubview:self.titleLabel];
    
    self.sizeLabel = [[UILabel alloc] init];
    self.sizeLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.sizeLabel.textColor = [UIColor colorWithHexString:@"#9b9b9b"];
    [self.bgView addSubview:self.sizeLabel];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.statusLabel.textColor = [UIColor colorWithHexString:@"#9b9b9b"];
    [self.bgView addSubview:self.statusLabel];
    
    self.downloadButton = [[UIButton alloc] init];
    self.downloadButton.showsTouchWhenHighlighted = YES;
    [self.bgView addSubview:self.downloadButton];
    
    self.selectButton = [[UIButton alloc] init];
    [self.selectButton setImage:[UIImage imageNamed:@"select_gray_circle"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"select_blue_circle"] forState:UIControlStateSelected];
    [self.bgView addSubview:self.selectButton];
    
    self.leftImageView.image = [UIImage imageNamed:@"file_MP3_image"];
    [self.downloadButton setImage:[UIImage imageNamed:@"down_load_finish"] forState:UIControlStateNormal];
    
    self.downloadButton.hidden = YES;
}

- (void)setViewConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
    
    [self.downloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(0);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(53, 48));
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.downloadButton);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).offset(13);
        make.right.mas_lessThanOrEqualTo(self.downloadButton.mas_left).offset(-8);
        make.bottom.mas_equalTo(self.leftImageView.mas_centerY).offset(3);
    }];
    
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(3);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sizeLabel.mas_right).offset(3);
        make.centerY.mas_equalTo(self.sizeLabel.mas_centerY);
    }];
}


@end

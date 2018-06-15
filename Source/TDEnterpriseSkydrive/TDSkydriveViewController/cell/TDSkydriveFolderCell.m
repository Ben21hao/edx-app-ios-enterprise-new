//
//  TDSkydriveFolderCell.m
//  edX
//
//  Created by Elite Edu on 2018/6/8.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveFolderCell.h"

@interface TDSkydriveFolderCell ()

@property (nonatomic,strong) UIView *bgView;

@end

@implementation TDSkydriveFolderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configeView];
        [self setViewConstraint];
    }
    return self;
}

- (void)setFileModel:(TDSkydrveFileModel *)fileModel {
    _fileModel = fileModel;
    
    self.titleLabel.text = fileModel.name;
    self.timeLabel.text = fileModel.created_at;
}

#pragma mark - UI
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
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.timeLabel.textColor = [UIColor colorWithHexString:@"#9b9b9b"];
    [self.bgView addSubview:self.timeLabel];
    
    self.leftImageView.image = [UIImage imageNamed:@"file_Folder_Image"];
}

- (void)setViewConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).offset(13);
        make.right.mas_lessThanOrEqualTo(self.bgView.mas_right).offset(-58);
        make.bottom.mas_equalTo(self.leftImageView.mas_centerY).offset(3);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(3);
    }];
}

@end

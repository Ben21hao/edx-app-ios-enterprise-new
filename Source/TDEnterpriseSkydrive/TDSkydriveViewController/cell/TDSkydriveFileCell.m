//
//  TDSkydriveFileCell.m
//  edX
//
//  Created by Elite Edu on 2018/6/11.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDSkydriveFileCell.h"

@interface TDSkydriveFileCell ()

@property (nonatomic,strong) UIView *bgView;

@end

@implementation TDSkydriveFileCell

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
    self.sizeLabel.text = fileModel.file_size;
    
    NSString *imageName = @"file_unkown_type_image";
    if ([fileModel.file_type isEqualToString:@"png"] || [fileModel.file_type isEqualToString:@"PNG"]) { //图片
        imageName = @"file_pic_image";
    }
    else if ([fileModel.file_type isEqualToString:@"jpg"] || [fileModel.file_type isEqualToString:@"JPG"]) { //音频
        imageName = @"file_MP3_image";
    }
    else if ([fileModel.file_type isEqualToString:@"jpeg"] || [fileModel.file_type isEqualToString:@"JPEG"]) { //视频
        imageName = @"file_video_image";
    }
    else if ([fileModel.file_type isEqualToString:@"bmp"] || [fileModel.file_type isEqualToString:@"bmp"]) { //压缩包
        imageName = @"file_package_image";
    }
    else if ([fileModel.file_type isEqualToString:@"gif"] || [fileModel.file_type isEqualToString:@"GIF"]) { //其他类型
        imageName = @"file_unkown_type_image";
    }
    else if ([fileModel.file_type isEqualToString:@"tif"] || [fileModel.file_type isEqualToString:@"TIF"]) {
        
    }
    
    else if ([fileModel.file_type isEqualToString:@"doc"] || [fileModel.file_type isEqualToString:@"docx"]) {
        imageName = @"file_word_image";
    }
    else if ([fileModel.file_type isEqualToString:@"xls"] || [fileModel.file_type isEqualToString:@"xlsx"]) {
        imageName = @"file_excel_image";
    }
    else if ([fileModel.file_type isEqualToString:@"pdf"] || [fileModel.file_type isEqualToString:@"PDF"]) {
        imageName = @"file_pdf_image";
    }
    else if ([fileModel.file_type isEqualToString:@"ppt"] || [fileModel.file_type isEqualToString:@"pptx"]) {
        imageName = @"file_PPT_image";
    }
    else if ([fileModel.file_type isEqualToString:@"rtf"] || [fileModel.file_type isEqualToString:@"RTF"]) {
        imageName = @"file_rtf_image";
    }
    else if ([fileModel.file_type isEqualToString:@"txt"] || [fileModel.file_type isEqualToString:@"TXT"]) {
        imageName = @"file_txt_image";
    }

    self.leftImageView.image = [UIImage imageNamed:imageName];
}

//- (void)

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
    
    self.sizeLabel = [[UILabel alloc] init];
    self.sizeLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.sizeLabel.textColor = [UIColor colorWithHexString:@"#9b9b9b"];
    [self.bgView addSubview:self.sizeLabel];
    
    self.downloadButton = [[UIButton alloc] init];
    self.downloadButton.showsTouchWhenHighlighted = YES;
    [self.bgView addSubview:self.downloadButton];
    
    self.shareButton = [[UIButton alloc] init];
    self.shareButton.showsTouchWhenHighlighted = YES;
    [self.shareButton setImage:[UIImage imageNamed:@"sky_shareButton_image"] forState:UIControlStateNormal];
    [self.bgView addSubview:self.shareButton];
    
    self.leftImageView.image = [UIImage imageNamed:@"file_rtf_image"];
    [self.downloadButton setImage:[UIImage imageNamed:@"no_download"] forState:UIControlStateNormal];
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
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.downloadButton.mas_left);
        make.centerY.mas_equalTo(self.downloadButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).offset(13);
        make.right.mas_lessThanOrEqualTo(self.shareButton.mas_left).offset(-13);
        make.bottom.mas_equalTo(self.leftImageView.mas_centerY).offset(3);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(3);
    }];
    
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_right).offset(3);
        make.centerY.mas_equalTo(self.timeLabel.mas_centerY);
    }];
}

@end



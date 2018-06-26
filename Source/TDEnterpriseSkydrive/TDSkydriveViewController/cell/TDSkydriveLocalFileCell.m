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
@property (nonatomic,strong) NSString *notifiName;
@property (nonatomic,strong) NSString *statusNotifiName;

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

- (void)setIsEditing:(BOOL)isEditing { //是否正在编辑
    _isEditing = isEditing;
    
    [self userEditing:isEditing];
}

- (void)userEditing:(BOOL)isEditing {
    
    self.selectButton.hidden = !isEditing;
    self.progressView.hidden = isEditing;
}

- (void)setFileModel:(TDSkydrveFileModel *)fileModel {
    _fileModel = fileModel;
    
    self.selectButton.selected = fileModel.isSelected;
    
    self.titleLabel.text = fileModel.name;
    if (fileModel.download_size.length > 0 && fileModel.progress > 0) {
        if (fileModel.status == 5) {
            self.sizeLabel.text = fileModel.file_size;
        }
        else {
            self.sizeLabel.text = [NSString stringWithFormat:@"%@/%@",fileModel.download_size,fileModel.file_size];
        }
    }
    else {
        self.sizeLabel.text = fileModel.file_size;
    }
    
    NSString *imageName;
    NSInteger format = [fileModel.file_type_format integerValue];
    switch (format) { //0 文件夹 ，1 图片，2 音频，3 文档，4 视频， 5 压缩包，6 其他
        case 0:
            imageName = @"file_Folder_Image";
            break;
        case 1:
            imageName = @"file_pic_image";
            break;
        case 2:
            imageName = @"file_MP3_image";
            break;
        case 3: {
            if ([fileModel.file_type isEqualToString:@"doc"] || [fileModel.file_type isEqualToString:@"docx"]) {
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
            else {
                imageName = @"file_unkown_type_image";
            }
        }
            break;
        case 4:
            imageName = @"file_video_image";
            break;
        case 5:
            imageName = @"file_package_image";
            break;
            
        default:
            imageName = @"file_unkown_type_image";
            break;
    }
    self.leftImageView.image = [UIImage imageNamed:imageName];
    
    self.progressView.progress = fileModel.progress * 100; //注意乘于100
    self.progressView.status = fileModel.status;
    
    [self cellStatusText:fileModel];
    
//    NSLog(@"本地cell -- 观察者");
    self.notifiName = [NSString stringWithFormat:@"%@_downloadProgressNotification",fileModel.id];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgressNotification:) name:self.notifiName object:nil];
    
    self.statusNotifiName = [NSString stringWithFormat:@"%@_downloadStatusNotification",fileModel.id];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusNotification:) name:self.statusNotifiName object:nil];
}

- (void)updateProgressNotification:(NSNotification *)notification { //更新进度
    
    NSDictionary *userInfo = notification.userInfo;
    CGFloat progress = [userInfo[@"progress"] floatValue];
    
    self.fileModel.progress = progress;
    self.progressView.progress = progress * 100;
    self.progressView.status = 1;
    
    NSString *sizeStr = userInfo[@"download_size"];
    if (sizeStr.length > 0  && progress > 0) {
        self.fileModel.download_size = sizeStr;
        self.sizeLabel.text = [NSString stringWithFormat:@"%@/%@",sizeStr,self.fileModel.file_size];
    }
    
    if (progress == 1) {
        self.fileModel.status = 5;
        self.progressView.status = 5;
        
        self.fileModel.download_size = self.fileModel.file_size;
        self.sizeLabel.text = [NSString stringWithFormat:@"%@",self.fileModel.file_size];
    }
//    NSLog(@"现在进度 -- %f",progress);
}

- (void)updateStatusNotification:(NSNotification *)notification { //更新状态
    
    NSDictionary *userInfo = notification.userInfo;
    NSInteger status = [userInfo[@"status"] integerValue];
    self.progressView.status = status;
    self.fileModel.status = status;
    
    [self cellStatusText:self.fileModel];
    
//    NSLog(@"现在的状态 -- %ld",(long)status);
}

- (void)cellStatusText:(TDSkydrveFileModel *)fileModel {
    
    switch (fileModel.status) {// 0 未下载，1 下载中，2 等待下载，3 暂停，4 下载失败，5 下载完成
        case 0:
            self.statusLabel.text = @"";
            break;
        case 1:
            self.statusLabel.text = @"";
            break;
        case 2:
            self.statusLabel.text = @"等待下载";
            break;
        case 3:
            self.statusLabel.text = @"暂停下载";
            break;
        case 4:
            self.statusLabel.attributedText = [[NSMutableAttributedString alloc]
                                               initWithString:@"下载失败"
                                               attributes:@{
                                                            NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#ff4a5b"]
                                                            }] ;
            break;
        default:
            self.statusLabel.text = @"";
            break;
    }
}

//- (void)dealloc {
////    NSLog(@"本地cell -- 销毁");
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:self.notifiName object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:self.statusNotifiName object:nil];
//}

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
    
    self.sizeLabel = [[UILabel alloc] init];
    self.sizeLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.sizeLabel.textColor = [UIColor colorWithHexString:@"#9b9b9b"];
    [self.bgView addSubview:self.sizeLabel];
    
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.statusLabel.textColor = [UIColor colorWithHexString:@"#9b9b9b"];
    [self.bgView addSubview:self.statusLabel];
    
    self.progressView = [[TDSkydriveProgressView alloc] init];
    self.progressView.progress = 0.0;
    [self.bgView addSubview:self.progressView];
    
    self.selectButton = [[UIButton alloc] init];
    self.selectButton.userInteractionEnabled = NO;
    [self.selectButton setImage:[UIImage imageNamed:@"select_gray_circle"] forState:UIControlStateNormal];
    [self.selectButton setImage:[UIImage imageNamed:@"select_blue_circle"] forState:UIControlStateSelected];
    [self.bgView addSubview:self.selectButton];
    
    self.leftImageView.image = [UIImage imageNamed:@"file_MP3_image"];
    
    [self userEditing:NO];
}

- (void)setViewConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(13);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(0);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.progressView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftImageView.mas_right).offset(13);
        make.right.mas_lessThanOrEqualTo(self.progressView.mas_left).offset(-8);
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

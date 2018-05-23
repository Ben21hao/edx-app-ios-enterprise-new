//
//  TDConsultCell.m
//  edX
//
//  Created by Elite Edu on 2018/4/24.
//  Copyright © 2018年 edX. All rights reserved.
//

#import "TDConsultCell.h"

@interface TDConsultCell ()

@property (nonatomic,strong) UIView *bgView;

@property (nonatomic,assign) BOOL showNum;

@property (nonatomic,strong) TDBaseToolModel *toolModel;

@end

@implementation TDConsultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.showNum = YES;
        
        self.toolModel = [[TDBaseToolModel alloc] init];
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

#pragma mark - data
- (void)setConsultModel:(TDMyConsultModel *)consultModel {
    _consultModel = consultModel;
    
    int type = [consultModel.content_type intValue];
    
    switch (type) {
        case 1:
            self.contentLabel.text = consultModel.content;
            break;
        case 2:
            self.contentLabel.text = TDLocalizeSelect(@"AUDIO_CONTENT", nil);
            break;
        case 3:
            self.contentLabel.text = TDLocalizeSelect(@"PHOTO_CONTENT", nil);
            break;
        case 4:
            self.contentLabel.text = TDLocalizeSelect(@"VIDEO_CONTENT", nil);
            break;
            
        default:
            break;
    }

    self.timeLabel.text = [self.toolModel changeStypeForTime:consultModel.created_at]; //时间
    
    int status = [consultModel.status.consult_status intValue];
    switch (status) { 
        case 1:  {//等待回复
            self.statusLabel.hidden = YES;
            self.numLabel.hidden = YES;
        }
            break;
            
        case 2://x条未读信息;
            self.statusLabel.hidden = YES;
            self.numLabel.hidden = NO;
            self.numLabel.text = [NSString stringWithFormat:@"%@",consultModel.status.num_of_unread];
            break;
            
        case 3://正在追问，等待回复
            self.statusLabel.text = TDLocalizeSelect(@"FOLLOWING_UP", nil);
            self.statusLabel.hidden = NO;
            self.numLabel.hidden = YES;
            break;
            
        case 4://已回复
            self.statusLabel.text = TDLocalizeSelect(@"ANSWERED_TEXT", nil);
            self.statusLabel.hidden = NO;
            self.numLabel.hidden = YES;
            break;
            
        case 5://已解决
            self.statusLabel.text = TDLocalizeSelect(@"CONSULTATION_RESOLVED", nil);
            self.statusLabel.hidden = NO;
            self.numLabel.hidden = YES;
            self.timeLabel.text = [self.toolModel changeStypeForTime:consultModel.updated_at]; //已解决的时间
            break;
            
        default:
            break;
    }
    
    

}

- (void)setWhereFrom:(NSInteger)whereFrom {
    _whereFrom = whereFrom;
    
    if (whereFrom) {
        [self.numLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.bgView.mas_left).offset(0);
            make.centerY.mas_equalTo(self.contentLabel.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(0, 16));
        }];
    }
}

#pragma mark - UI
- (void)configView {
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithHexString:colorHexStr13];
    [self addSubview:self.bgView];
    
    self.numLabel = [self setLabelStyle:10 color:colorHexStr13];
    self.numLabel.layer.masksToBounds = YES;
    self.numLabel.layer.cornerRadius = 8.0;
    self.numLabel.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    self.numLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:self.numLabel];
    
    self.timeLabel = [self setLabelStyle:12 color:colorHexStr7];
    [self.bgView addSubview:self.timeLabel];
    
    self.contentLabel = [self setLabelStyle:14 color:colorHexStr9];
    self.contentLabel.numberOfLines = 1;
    [self.bgView addSubview:self.contentLabel];
    
    self.statusLabel = [self setLabelStyle:12 color:colorHexStr7];
    [self.bgView addSubview:self.statusLabel];
}

- (void)setViewConstraint {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self);
    }];
    
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left).offset(9);
        make.centerY.mas_equalTo(self.contentLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 16));
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.numLabel.mas_right).offset(9);
        make.top.mas_equalTo(self.bgView.mas_top).offset(6);
        make.height.mas_equalTo(18);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_top);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.timeLabel.mas_left);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-13);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(8);
    }];
    
}

- (UILabel *)setLabelStyle:(NSInteger)font color:(NSString *)colorStr {
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"OpenSans" size:font];
    label.textColor = [UIColor colorWithHexString:colorStr];
    return label;
}

@end

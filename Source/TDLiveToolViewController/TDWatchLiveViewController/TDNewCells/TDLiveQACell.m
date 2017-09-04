//
//  TDLiveQACell.m
//  edX
//
//  Created by Elite Edu on 2017/8/31.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDLiveQACell.h"
#import "UIImageView+WebCache.h"
#import "VHallApi.h"
#import "MLEmojiLabel.h"

@interface TDLiveQACell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIButton *lblType;
@property (nonatomic,strong) UILabel *lblNickName;
@property (nonatomic,strong) UILabel *lblTime;
@property (nonatomic,strong) MLEmojiLabel *lblContent;
@property (nonatomic,strong) UIImageView *headImage;

@end

@implementation TDLiveQACell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self configView];
        [self setViewConstraint];
    }
    return self;
}

- (void)configView {
    
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.bgView];
    
    self.lblType = [[UIButton alloc] init];
    self.lblType.layer.cornerRadius = 10;
    self.lblType.layer.masksToBounds = YES;
    self.lblType.layer.borderColor = [UIColor colorWithHexString:@"#DC143C"].CGColor;
    self.lblType.layer.borderWidth = 0.5;
    self.lblType.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [self.lblType setTitleColor:[UIColor colorWithHexString:@"#DC143C"] forState:UIControlStateNormal];
    [self.bgView addSubview:self.lblType];
    
    self.lblNickName = [[UILabel alloc] init];
    self.lblNickName.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.lblNickName.font = [UIFont fontWithName:@"OpenSans" size:16];
    [self.bgView addSubview:self.lblNickName];
    
    self.lblTime = [[UILabel alloc] init];
    self.lblTime.font = [UIFont fontWithName:@"OpenSans" size:12];
    self.lblTime.textColor = [UIColor colorWithHexString:colorHexStr8];
    [self.bgView addSubview:self.lblTime];
    
    self.headImage = [[UIImageView alloc] init];
    self.headImage.image = [UIImage imageNamed:@"UIModel.bundle/head50"];
    self.headImage.layer.masksToBounds = YES;
    self.headImage.layer.cornerRadius = 20.0;
    [self.bgView addSubview:self.headImage];
    
    self.lblContent = [MLEmojiLabel new];
    self.lblContent.font = [UIFont fontWithName:@"OpenSans" size:14];
    self.lblContent.textColor = [UIColor colorWithHexString:colorHexStr9];
    self.lblContent.numberOfLines = 0;
    self.lblContent.lineBreakMode = NSLineBreakByCharWrapping;
    self.lblContent.userInteractionEnabled = NO;
    self.lblContent.disableThreeCommon = YES;
//    self.lblContent.isNeedAtAndPoundSign = YES;//是否需要话题和@功能，默认为不需要
    self.lblContent.textColor = [UIColor colorWithHexString:colorHexStr10];
    self.lblContent.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    self.lblContent.customEmojiPlistName = @"faceExpression.plist";
    self.lblContent.customEmojiBundleName = @"UIModel.bundle";
    [self.bgView addSubview:self.lblContent];
    
}

- (void)setViewConstraint {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self.bgView).offset(18);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.lblNickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_top).offset(12);
        make.left.mas_equalTo(self.headImage.mas_right).offset(8);
        make.height.mas_equalTo(23);
        
    }];
    
    [self.lblType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lblNickName.mas_right).offset(8);
        make.centerY.mas_equalTo(self.lblNickName.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];

    [self.lblTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImage.mas_right).offset(12);
        make.top.mas_equalTo(self.lblNickName.mas_bottom).offset(0);
        make.height.mas_equalTo(18);
    }];
    
    [self.lblContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lblTime.mas_left);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-8);
        make.top.mas_equalTo(self.lblTime.mas_bottom).offset(0);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-8);
    }];

}

- (void)setModel:(VHallQuestionModel *)model {
    _model = model;
    
    self.self.lblNickName.text = [NSString stringWithFormat:@"%@:", _model.nick_name];
    self.lblTime.text = _model.created_at;
    self.lblContent.text = [NSString stringWithFormat:@"%@\n\n\n", _model.content];
    
    if ([_model.type isEqualToString:@"question"]) {
        [self.lblType setTitle:NSLocalizedString(@"ASK_TEXT", nil) forState:UIControlStateNormal];
        self.lblType.layer.borderColor=[UIColor redColor].CGColor;
        [self.lblType setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.headImage sd_setImageWithURL:[NSURL URLWithString:[VHallApi currentUserHeadUrl]] placeholderImage:[UIImage imageNamed:@"UIModel.bundle/head50"]];
        
    } else if ([_model.type isEqualToString:@"answer"]) {
        
        [self.lblType setTitle:NSLocalizedString(@"ANSWER_TEXT", nil) forState:UIControlStateNormal];
        self.lblType.layer.borderColor=[UIColor blueColor].CGColor;
        [self.lblType setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        VHallAnswerModel *answer = (VHallAnswerModel *)_model;
        [self.headImage sd_setImageWithURL:[NSURL URLWithString:answer.avatar] placeholderImage:[UIImage imageNamed:@"UIModel.bundle/head50"]];
    }
}

@end

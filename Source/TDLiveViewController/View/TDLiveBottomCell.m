//
//  TDLiveBottomCell.m
//  edX
//
//  Created by Ben on 2017/6/30.
//  Copyright © 2017年 edX. All rights reserved.
//

#import "TDLiveBottomCell.h"

@interface TDLiveBottomCell ()

@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIButton *enterButton;
@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UIButton *praticeButton;
@property (nonatomic,strong) UIImageView *lineImage;

@end

@implementation TDLiveBottomCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setviewConstraint];
    }
    return self;
}

- (void)setWhereFrom:(NSInteger)whereFrom {
    
    _whereFrom = whereFrom;
    
    [self hideButtonOrNot:whereFrom == 0];
}

- (void)hideButtonOrNot:(BOOL)hide {
    
    self.enterButton.hidden = !hide;
    self.playButton.hidden = hide;
    self.praticeButton.hidden = hide;
}

#pragma mark - UI
- (void)setviewConstraint {
    
    self.bgView = [[UIView alloc] init];
    [self.contentView addSubview:self.bgView];
    
    self.enterButton = [self setButtonStyle];
    [self.bgView addSubview:self.enterButton];
    
    self.playButton = [self setButtonStyle];
    [self.bgView addSubview:self.playButton];
    
    self.praticeButton = [self setButtonStyle];
    [self.bgView addSubview:self.praticeButton];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.enterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(TDWidth / 2 - 18, 35));
    }];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.left.mas_equalTo(self.bgView.mas_left).offset(18);
        make.width.mas_equalTo((TDWidth / 2) - 26);
        make.height.mas_equalTo(35);
    }];
    
    [self.praticeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-18);
        make.left.mas_equalTo(self.playButton.mas_right).offset(18);
        make.height.mas_equalTo(35);
    }];
    
    TDBaseToolModel *toolModel = [[TDBaseToolModel alloc] init];
    self.lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TDWidth, 2)];
    self.lineImage.image = [toolModel drawLineByImageView:self.lineImage color:colorHexStr7];
    [self.bgView addSubview:self.lineImage];
    
    [self.enterButton setTitle:@"01天18时18分18秒" forState:UIControlStateNormal];
    [self.praticeButton setTitle:@"做习题" forState:UIControlStateNormal];
    [self.playButton setTitle:@"回放" forState:UIControlStateNormal];
}

- (UIButton *)setButtonStyle {
    
    UIButton *button = [[UIButton alloc] init];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 4.0;
    button.backgroundColor = [UIColor colorWithHexString:colorHexStr1];
    button.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}

@end
